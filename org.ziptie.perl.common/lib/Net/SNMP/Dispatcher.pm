# -*- mode: perl -*- 
# ============================================================================

package Net::SNMP::Dispatcher;

# $Id: Dispatcher.pm,v 1.1 2007/05/31 17:36:51 dwhite Exp $

# Object the dispatches SNMP messages and handles the scheduling of events.

# Copyright (c) 2001-2005 David M. Town <dtown@cpan.org>
# All rights reserved.

# This program is free software; you may redistribute it and/or modify it
# under the same terms as Perl itself.

# ============================================================================

use strict;
use Errno;

use Net::SNMP::MessageProcessing();
use Net::SNMP::Message qw( TRUE FALSE );

## Version of the Net::SNMP::Dispatcher module

our $VERSION = v3.0.1;

## Package variables

our $INSTANCE;            # Reference to our Singleton object

our $DEBUG = FALSE;       # Debug flag

our $MESSAGE_PROCESSING;  # Reference to the Message Processing object

## Event array indexes

sub _ACTIVE()   { 0 }     # State of the event
sub _TIME()     { 1 }     # Execution time
sub _CALLBACK() { 2 }     # Callback reference
sub _PREVIOUS() { 3 }     # Previous event
sub _NEXT()     { 4 }     # Next event

BEGIN
{
   # Use a higher resolution of time() if the Time::HiRes module is available. 

   if (eval('require Time::HiRes')) {
      Time::HiRes->import('time');
   }

   # Validate the creation of the Message Processing object. 

   if (!defined($MESSAGE_PROCESSING = Net::SNMP::MessageProcessing->instance)) {
      die('FATAL: Failed to create Message Processing instance');
   }
}

# [public methods] -----------------------------------------------------------

sub instance
{
   $INSTANCE ||= Net::SNMP::Dispatcher->_new;
}

sub activate
{
   my ($this) = @_;

   # Return immediately if the Dispatcher is already active.
   return TRUE if ($this->{_active});

   # Indicate that the Dispatcher is active and block  
   # on select() calls.  

   $this->{_active}   = TRUE;
   $this->{_blocking} = TRUE;

   while (defined($this->{_event_queue_h})) { 
      $this->_event_handle; 
   }

   # Flag the Dispatcher as not active 
   $this->{_active} = FALSE; 
}

sub one_event
{
   my ($this) = @_;

   # Return immediately if the Dispatcher is already active.
   return TRUE if ($this->{_active});

   # Indicate that the Dispatcher is active and DO NOT 
   # block on select() calls.
   
   $this->{_active}   = TRUE; 
   $this->{_blocking} = FALSE;

   $this->_event_handle;

   # Flag the Dispatcher as not active
   $this->{_active} = FALSE;

   defined($this->{_event_queue_h}) ? TRUE : FALSE; 
}

sub listen
{
   my ($this) = @_;

   # Return immediately if the Dispatcher is already active.
   return TRUE if ($this->{_active});

   # Indicate that the Dispatcher is active and block
   # on select() calls.

   $this->{_active}   = TRUE;
   $this->{_blocking} = TRUE;

   while (defined($this->{_event_queue_h}) || keys(%{$this->{_descriptors}})) {

      # Handle queued events
      events: while (defined($this->{_event_queue_h})) {
         $this->_event_handle;
      }

      # Block on select() until there is file descriptor activity.
      DEBUG_INFO('waiting for activity');
      $this->_event_select(undef);

   }

   # Flag the Dispatcher as not active
   $this->{_active} = FALSE;
}

sub send_pdu
{
   my ($this, $pdu, $delay) = @_;

   # Clear any previous errors
   $this->_error_clear;

   if ((@_ < 2) || !ref($pdu)) {
      return $this->_error('Required PDU missing');
   }

   # If the Dispatcher is active and the delay value is negative,
   # send the message immediately.

   if ($delay < 0) {
      if ($this->{_active}) {
         return $this->_send_pdu($pdu, $pdu->timeout, $pdu->retries);
      } 
      $delay = 0;
   }

   $this->schedule($delay, [\&_send_pdu, $pdu, $pdu->timeout, $pdu->retries]);

   TRUE;
}

sub return_response_pdu
{
   my ($this, $pdu) = @_;

   $this->send_pdu($pdu, -1);
}

sub schedule
{
   my ($this, $time, $callback) = @_;

   $this->_event_create($time, $this->_callback_create($callback));
}

sub cancel
{
   my ($this, $event) = @_;

   $this->_event_delete($event);
}

sub register
{
   my ($this, $transport, $callback) = @_;

   # Transport Domain and file descriptor must be valid.
   my $fileno;

   if ((!defined($transport)) || (!defined($fileno = $transport->fileno))) {
      return $this->_error('Invalid Transport Domain');
   }

   # NOTE: The callback must read the data associated with the
   #       file descriptor or the Dispatcher will continuously
   #       call the callback and get stuck in an infinite loop.

   if (!exists($this->{_descriptors}->{$fileno})) {

      DEBUG_INFO('adding descriptor [%d]', $fileno);

      $this->{_rin} = '' unless defined($this->{_rin});

      # Add the file descriptor to the list
      $this->{_descriptors}->{$fileno} = [
         $this->_callback_create($callback), # Callback
         $transport,                         # Transport Domain object 
         1                                   # Reference count
      ];

      # Add the file descriptor to the "readable" vector
      vec($this->{_rin}, $fileno, 1) = 1;

   } else {
      # Bump up the reference count
      $this->{_descriptors}->{$fileno}->[2]++;
   }

   # Return the Transport Domain object 
   $transport;
}

sub deregister
{
   my ($this, $transport) = @_;

   # Transport Domain and file descriptor must be valid.
   my $fileno;

   if ((!defined($transport)) || (!defined($fileno = $transport->fileno))) {
      return $this->_error('Invalid Transport Domain');
   }

   if (exists($this->{_descriptors}->{$fileno})) {

      # Check reference count
      if (--$this->{_descriptors}->{$fileno}->[2] < 1) {

         DEBUG_INFO('removing descriptor [%d]', $fileno);

         # Remove the file descriptor from the list
         delete($this->{_descriptors}->{$fileno});

         # Remove the file descriptor from the "readable" vector
         vec($this->{_rin}, $fileno, 1) = 0;

         # Undefine the vector if there are no file descriptors,
         # some systems expect this to make select() work properly.

         $this->{_rin} = undef unless keys(%{$this->{_descriptors}});
      }

   } else {
      return $this->_error('Not registered for this Transport Domain');
   }

   # Return the Transport Domain object 
   $transport;
}

sub error
{
   $_[0]->{_error} || '';
}

sub debug
{
   (@_ == 2) ? $DEBUG = ($_[1]) ? TRUE : FALSE : $DEBUG;
}

# [private methods] ----------------------------------------------------------

sub _new
{
   my ($class) = @_;

   # The constructor is private since we only want one 
   # Dispatcher object.

   bless {
      '_active'        => FALSE,  # State of this Dispatcher object
      '_blocking'      => TRUE,   # Block on select()
      '_error'         => undef,  # Error message
      '_event_queue_h' => undef,  # Head of the event queue
      '_event_queue_t' => undef,  # Tail of the event queue
      '_rin'           => undef,  # Readable vector for select()
      '_descriptors'   => {},     # List of file descriptors to monitor
   }, $class;
}

sub _send_pdu
{
   my ($this, $pdu, $timeout, $retries) = @_;

   # Pass the PDU to Message Processing so that it can
   # create the new outgoing message.

   my $msg = $MESSAGE_PROCESSING->prepare_outgoing_msg($pdu);

   if (!defined($msg)) {
      # Inform the command generator about the Message Processing error.
      $pdu->status_information($MESSAGE_PROCESSING->error);
      return; 
   }

   # Actually send the message.

   if (!defined($msg->send)) {

      if ($pdu->expect_response) {
         $MESSAGE_PROCESSING->msg_handle_delete($pdu->msg_id);
      }

      # A crude attempt to recover from temporary failures.
      if (($retries-- > 0) && ($!{EAGAIN} || $!{EWOULDBLOCK})) {
         DEBUG_INFO('attempting recovery from temporary failure');
         $this->schedule($timeout, [\&_send_pdu, $pdu, $timeout, $retries]);
         return FALSE;
      }

      # Inform the command generator about the send() error.
      $pdu->status_information($msg->error);

      return;
   }

   # Schedule the timeout handler if the message expects a response.

   if ($pdu->expect_response) {
      $this->register($msg->transport, [\&_transport_response_received]);
      $msg->timeout_id(
         $this->schedule(
            $timeout, [\&_transport_timeout, $pdu, $timeout, $retries] 
         )
      ); 
   }

   TRUE;
}

sub _transport_timeout
{
   my ($this, $pdu, $timeout, $retries) = @_;

   # Stop waiting for responses
   $this->deregister($pdu->transport);

   if ($retries-- > 0) {

      # Resend a new message.
      DEBUG_INFO('retries left %d', $retries); 
      $this->_send_pdu($pdu, $timeout, $retries);

   } else {

      # Delete the msgHandle. 
      $MESSAGE_PROCESSING->msg_handle_delete($pdu->msg_id);

      # Inform the command generator about the timeout. 
      $pdu->status_information(
          "No response from remote host '%s'", $pdu->hostname
      ); 

      return;

   } 
}

sub _transport_response_received
{
   my ($this, $transport) = @_;

   # Clear any previous errors
   $this->_error_clear;

   die('FATAL: Invalid Transport Domain') unless ref($transport);

   # Create a new Message object to receive the response
   my ($msg, $error) = Net::SNMP::Message->new(-transport => $transport);

   if (!defined($msg)) {
      die sprintf('Failed to create Message object [%s]', $error);
   }

   # Read the message from the Transport Layer  
   if (!defined($msg->recv)) {
      $this->deregister($transport) unless ($transport->connectionless);
      return $this->_error($msg->error);
   }

   # For connection-oriented Transport Domains, it is possible to
   # "recv" an empty buffer if reassembly is required.

   if (!$msg->length) {
      DEBUG_INFO('ignoring zero length message');
      return FALSE;
   }

   # Hand the message over to Message Processing.
   if (!defined($MESSAGE_PROCESSING->prepare_data_elements($msg))) {
      return $this->_error($MESSAGE_PROCESSING->error);  
   }

   # Set the error if applicable. 
   $msg->error($MESSAGE_PROCESSING->error) if ($MESSAGE_PROCESSING->error);

   # Cancel the timeout.
   $this->cancel($msg->timeout_id);

   # Stop waiting for responses.
   $this->deregister($transport);

   # Notify the command generator to process the response.
   $msg->process_response_pdu; 
}

sub _event_create
{
   my ($this, $time, $callback) = @_;

   # Create a new event anonymous array and add it to the queue.   
   # The event is initialized based on the currrent state of the 
   # Dispatcher object.  If the Dispatcher is not currently running
   # the event needs to be created such that it will get properly
   # initialized when the Dispatcher is started.

   $this->_event_insert(
      [
         $this->{_active},                          # State of the object
         $this->{_active} ? time() + $time : $time, # Execution time
         $callback,                                 # Callback reference
         undef,                                     # Previous event
         undef,                                     # Next event 
      ]
   ); 
}

sub _event_insert
{
   my ($this, $event) = @_;

   # If the head of the list is not defined, we _must_ be the only
   # entry in the list, so create a new head and tail reference.

   if (!defined($this->{_event_queue_h})) {
      DEBUG_INFO('created new head and tail [%s]', $event);
      return $this->{_event_queue_h} = $this->{_event_queue_t} = $event;
   }

   # Estimate the midpoint of the list by calculating the average of
   # the time associated with the head and tail of the list.  Based
   # on this value either start at the head or tail of the list to
   # search for an insertion point for the new Event.

   my $midpoint = (($this->{_event_queue_h}->[_TIME] +
                    $this->{_event_queue_t}->[_TIME]) / 2);


   if ($event->[_TIME] >= $midpoint) {

      # Search backwards from the tail of the list

      for (my $e = $this->{_event_queue_t}; defined($e); $e = $e->[_PREVIOUS])
      {
         if ($e->[_TIME] <= $event->[_TIME]) {
            $event->[_PREVIOUS] = $e;
            $event->[_NEXT] = $e->[_NEXT];
            if ($e eq $this->{_event_queue_t}) {
               DEBUG_INFO('modified tail [%s]', $event);
               $this->{_event_queue_t} = $event;
            } else {
               DEBUG_INFO('inserted [%s] into list', $event);
               $e->[_NEXT]->[_PREVIOUS] = $event;
            }
            return $e->[_NEXT] = $event;
         }
      }

      DEBUG_INFO('added [%s] to head of list', $event);
      $event->[_NEXT] = $this->{_event_queue_h};
      $this->{_event_queue_h} = $this->{_event_queue_h}->[_PREVIOUS] = $event;

   } else {

      # Search forward from the head of the list

      for (my $e = $this->{_event_queue_h}; defined($e); $e = $e->[_NEXT]) {
         if ($e->[_TIME] > $event->[_TIME]) {
            $event->[_NEXT] = $e;
            $event->[_PREVIOUS] = $e->[_PREVIOUS];
            if ($e eq $this->{_event_queue_h}) {
               DEBUG_INFO('modified head [%s]', $event);
               $this->{_event_queue_h} = $event;
            } else {
               DEBUG_INFO('inserted [%s] into list', $event);
               $e->[_PREVIOUS]->[_NEXT] = $event; 
            }
            return $e->[_PREVIOUS] = $event;
         }
      }

      DEBUG_INFO('added [%s] to tail of list', $event);
      $event->[_PREVIOUS] = $this->{_event_queue_t};
      $this->{_event_queue_t} = $this->{_event_queue_t}->[_NEXT] = $event;

   }
}

sub _event_delete
{
   my ($this, $event) = @_;

   my $info = '';

   # Update the previous event
   if (defined($event->[_PREVIOUS])) {
      $event->[_PREVIOUS]->[_NEXT] = $event->[_NEXT];
   } elsif ($event eq $this->{_event_queue_h}) {
      if (defined($this->{_event_queue_h} = $event->[_NEXT])) {
          $info = sprintf(', defined new head [%s]', $event->[_NEXT]);
      } else {
         DEBUG_INFO('deleted [%s], list is now empty', $event);
         $this->{_event_queue_t} = undef @{$event}; 
         return FALSE; # Indicate queue is empty
      }
   } else {
      die('FATAL: Attempt to delete invalid Event head');
   }

   # Update the next event
   if (defined($event->[_NEXT])) {
      $event->[_NEXT]->[_PREVIOUS] = $event->[_PREVIOUS];
   } elsif ($event eq $this->{_event_queue_t}) {
      $info .= sprintf(', defined new tail [%s]', $event->[_PREVIOUS]); 
      $this->{_event_queue_t} = $event->[_PREVIOUS];
   } else {
      die('FATAL: Attempt to delete invalid Event tail');
   }

   DEBUG_INFO('deleted [%s]%s', $event, $info);
   undef @{$event};

   # Indicate queue still has entries
   TRUE;
}

sub _event_init
{
   my ($this, $event) = @_;

   DEBUG_INFO('initializing event [%s]', $event);

   # Save the time and callback because they will be cleared.
   my ($time, $callback) = @{$event}[_TIME, _CALLBACK];

   # Remove the event from the queue.
   $this->_event_delete($event);

   # Update the appropriate fields.
   $event->[_ACTIVE]   = $this->{_active};
   $event->[_TIME]     = $this->{_active} ? time() + $time : $time; 
   $event->[_CALLBACK] = $callback;

   # Insert the event back into the queue.
   $this->_event_insert($event); 

   TRUE;
}

sub _event_handle
{
   my ($this) = @_;

   # Events are sorted by time, so the event at the head of the list
   # is the next event that needs to be executed.

   return FALSE unless defined(my $event = $this->{_event_queue_h});

   # Calculate a timeout based on the current time and the lowest 
   # event time (if the event does not need initialized).

   my $timeout = ($event->[_ACTIVE]) ? ($event->[_TIME] - time()) : 0;

   # If the timeout is less than 0, we are running late.  Adjust the
   # the timeout to poll the descriptors before acting on the event. 
   
   if ($timeout < 0) {
      DEBUG_INFO('event [%s], skew = %f', $event, -$timeout);
      $timeout = 0;
   } else {
      DEBUG_INFO('event [%s], poll delay = %f', $event, $timeout);
   }

   # Check the file descriptors for activity.  If there has been any
   # activity, we must return because the activity could have cancelled 
   # the event or returned control here before the event is ready to
   # be acted upon. 

   return TRUE if ($this->_event_select($this->{_blocking} ? $timeout : 0));

   # If we are not blocking and the timeout is non-zero, then it is
   # not time to act on the event.

   return TRUE if ((!$this->{_blocking}) && ($timeout > 0));

   # If we made it here, we can finally act on the event.  If the event
   # was inserted with a non-zero delay while the Dispatcher was not
   # active, the execution time of the event needs to be updated.

   if ((!$event->[_ACTIVE]) && ($event->[_TIME] > 0)) {
      return $this->_event_init($event);
   } else {
      $this->_callback_execute($event->[_CALLBACK]);
   }

   # Once we reach here, we are done with the event, so remove it
   # from the head of the queue.

   $this->_event_delete($event);
}

sub _event_select
{
   my ($this, $timeout) = @_;

   my $nfound = select(my $rout = $this->{_rin}, undef, undef, $timeout);

   if ((!defined($nfound)) || ($nfound < 0)) {

      if ($!{EINTR}) { # Recoverable error
         return TRUE;
      } else {
         die sprintf('FATAL: select() error [%s]', $!);
      }

   } elsif ($nfound > 0) {

      # Find out which file descriptors have data ready for reading.

      if (defined($rout)) {
         foreach (keys(%{$this->{_descriptors}})) {
            if (vec($rout, $_, 1)) {
               DEBUG_INFO('descriptor [%d] ready for read', $_);
               $this->_callback_execute(@{$this->{_descriptors}->{$_}}[0,1]);
            }
         }
      }

      return TRUE;
   }

   # No file descriptor activity. 

   FALSE; 
}

sub _callback_create
{
   my ($this, $callback) = @_;

   return unless (@_ == 2);

   # Callbacks can be passed in two different ways.  If the callback
   # has options, the callback must be passed as an ARRAY reference
   # with the first element being a CODE reference and the remaining
   # elements the arguments.  If the callback has no options it is
   # just passed as a CODE reference.

   if ((ref($callback) eq 'ARRAY') && (ref($callback->[0]) eq 'CODE')) {
      $callback;
   } elsif (ref($callback) eq 'CODE') {
      [$callback];
   } else {
      return;
   }
}

sub _callback_execute
{
#  my ($this, @argv) = @_;

   return unless (@_ > 1) && defined($_[1]);

   # The callback is invoked passing a reference to this object
   # with the parameters passed by the user next and then any 
   # parameters that we provide.

   my $this = shift(@_);
   my @argv = @{shift(@_)};
   my $cb   = shift(@argv);
   
   # Protect ourselves from user error. 
   eval { $cb->($this, @argv, @_); };

   ($@) ? $this->_error($@) : TRUE;
}

sub _error
{
   my $this = shift;

   if (!defined($this->{_error})) {
      $this->{_error} = (@_ > 1) ? sprintf(shift(@_), @_) : $_[0];
      if ($this->debug) {
         printf("error: [%d] %s(): %s\n",
            (caller(0))[2], (caller(1))[3], $this->{_error}
         );
      }
   }

   return;
}

sub _error_clear
{
   $_[0]->{_error} = undef;
}

sub DEBUG_INFO
{
   return unless $DEBUG;

   printf(
      sprintf('debug: [%d] %s(): ', (caller(0))[2], (caller(1))[3]) . 
      ((@_ > 1) ? shift(@_) : '%s') .
      "\n",
      @_
   );

   $DEBUG;
}

# ============================================================================
1; # [end Net::SNMP::Dispatcher]
