package ZipTie::Adapters::CheckPoint::OPSEC::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils qw(get_port_number mask_to_bits trim);
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK = qw(parse_rules parse_object_groups);

sub parse_rules
{

	# parse while streaming in the file as the objects file
	# can get quite big.
	my ( $in, $out ) = @_;
	$out->open_element('filterLists');
	$out->open_element('filterList');
	open( RULES, $in->{rulesFile} );
	my $rulesWhitespace;          # leading whitepsace on the rules definition
	my $currentRuleWhiteSpace;    # leading whitespace on each rule definition
	my $currentRule;
	while ( my $line = <RULES> )
	{

		if ( $line =~ /(^\s+):rules\s+/ )
		{
			$rulesWhitespace = $1;
		}
		elsif ($rulesWhitespace)
		{
			if ( $line =~ /^$rulesWhitespace\)/ )
			{
				$rulesWhitespace = undef;
			}
			elsif ( ( $line =~ /(^\s+):\s*\(/ ) && ( !$currentRuleWhiteSpace ) )
			{
				$currentRuleWhiteSpace = $1;
				$currentRule .= $line;
			}
			elsif ( $currentRuleWhiteSpace && ( $line =~ /^$currentRuleWhiteSpace\)/ ) )
			{
				_process_rule( $currentRule, $out );
				$currentRule           = undef;
				$currentRuleWhiteSpace = undef;
			}
			else
			{
				$currentRule .= $line;
			}
		}
	}
	close(RULES);
	$out->print_element( 'mode', 'stateful' );
	$out->print_element( 'name', 'OPSEC' );
	$out->close_element('filterList');
	$out->close_element('filterLists');
}

sub parse_object_groups
{

	# parse while streaming in the file as the objects file
	# can get quite big.
	my ( $in, $out ) = @_;
	$out->open_element('objectGroups');
	open( OBJECTS, $in->{objectsFile} );
	my $parentWhitespace;           # leading whitepsace on the netobj definition
	my $currentObjectWhitespace;    # leading whitespace on each object definition
	my $currentObject;
	my $type;
	while ( my $line = <OBJECTS> )
	{

		if ( $line =~ /(^\s+):(netobj|servobj)/ )
		{
			$parentWhitespace = $1;
			$type             = $2;
		}
		elsif ($parentWhitespace)
		{
			if ( $line =~ /^$parentWhitespace\)/ )
			{
				$parentWhitespace = undef;
			}
			elsif ( ( $line =~ /(^\s+):\s*\(/ ) && ( !$currentObjectWhitespace ) )
			{
				$currentObjectWhitespace = $1;
				$currentObject .= $line;
			}
			elsif ( $currentObjectWhitespace && ( $line =~ /^$currentObjectWhitespace\)/ ) )
			{
				if ( $type eq 'netobj' )
				{
					_process_network_groups( $currentObject, $out );
				}
				elsif ( $type eq 'servobj' )
				{
					_process_service_groups( $currentObject, $out );
				}
				$currentObject           = undef;
				$currentObjectWhitespace = undef;
			}
			else
			{
				$currentObject .= $line;
			}
		}
	}
	close(OBJECTS);
	$out->close_element('objectGroups');
}

sub _process_rule
{
	my ( $ruleConfig, $out ) = @_;
	my $ruleObj = _object_to_hash($ruleConfig);
	my $name    = ( keys(%$ruleObj) )[0];
	my $rule = $ruleObj->{$name};
	my $filterEntry = { name => $name, log => 'false', };
	foreach my $child( @{ $rule->{'track'}->{'children'} } )
	{
		$filterEntry->{log} = 'true' if ( $child eq 'Log' );
	}

	my $actionElement = ( keys( %{ $rule->{'action'} } ) )[0];
	my $action        = $rule->{'action'}->{$actionElement}->{'action'};
	if ( !$action )
	{
		$action = $rule->{'action'}->{$actionElement}->{'type'};
	}
	$action = 'permit' if ( $action eq 'accept' );
	$filterEntry->{primaryAction} = $action;
	
	_parse_rule_target($rule, $filterEntry, 'src');
	_parse_rule_target($rule, $filterEntry, 'dst');
	if (defined $rule->{'services'}->{'children'})
	{
		foreach my $child( @{ $rule->{'services'}->{'children'} } )
		{
			push (@{$filterEntry->{'destinationService'}}, { objectGroupReference => $child, });
		}
	}

	$out->print_element( 'filterEntry', $filterEntry );
}

sub _parse_rule_target
{
	my ($rule, $filterEntry, $target) = @_;
	my $zedTarget = ($target eq 'src') ? 'sourceIpAddr' : 'destinationIpAddr';
	
	if ( defined $rule->{$target}->{'Any'} )
	{
		push (@{$filterEntry->{$zedTarget}},  _get_any());
	}
	if (defined $rule->{$target}->{'children'})
	{
		foreach my $child( @{ $rule->{$target}->{'children'} } )
		{
			my $objectGroup = { objectGroupReference => $child, };
			push (@{$filterEntry->{$zedTarget}},  $objectGroup);
		}
	}
}

sub _process_network_groups
{
	my ( $object, $out ) = @_;

	my $networkGroup = _object_to_hash($object);
	my $name         = ( keys(%$networkGroup) )[0];
	my $type         = $networkGroup->{$name}->{'type'};
	if ( $type && $type =~ /^(machines_range|host|network)$/ )
	{
		$out->open_element('networkGroup');
		$out->print_element( 'id', $name );

		if ( $type eq 'machines_range' )
		{
			my $range = {
				startAddress => $networkGroup->{$name}->{'ipaddr_first'},
				endAddress   => $networkGroup->{$name}->{'ipaddr_last'},
			};
			$out->print_element( 'range', $range );
		}
		elsif ( $type eq 'host' )
		{
			$out->print_element( 'host', $networkGroup->{$name}->{'ipaddr'} );
		}
		elsif ( $type eq 'network' )
		{
			my $subnet = {
				address => $networkGroup->{$name}->{'ipaddr'},
				mask    => mask_to_bits( $networkGroup->{$name}->{'netmask'} ),
			};
			$out->print_element( 'subnet', $subnet );
		}
		$out->close_element('networkGroup');
	}
}

sub _process_service_groups
{
	my ( $object, $out ) = @_;
	my $serviceGroup = _object_to_hash($object);
	my $name         = ( keys(%$serviceGroup) )[0];
	my $protocol     = $serviceGroup->{$name}->{'type'};

	if ( $protocol && $protocol =~ /^(tcp|udp|group)$/i )
	{
		$protocol = lc($protocol);
		$out->open_element('serviceGroup');
		$out->print_element( 'id', $name );
		if ( $protocol eq 'group' )
		{
			foreach my $children ( @{ $serviceGroup->{$name}->{'children'} } )
			{
				$out->print_element( 'objectGroupReference', $children );
			}
		}
		else
		{
			my $port = $serviceGroup->{$name}->{'port'};
			if ( $port =~ /^\d+$/ )
			{
				my $portExpression = {
					port     => $port,
					operator => 'eq',
					protocol => $protocol,
				};
				$out->print_element( 'portExpression', $portExpression );
			}
			elsif ( $port =~ /^(\d+)-(\d+)$/ )
			{
				my $portRange = {
					portStart => $1,
					portEnd   => $2,
					protocol  => lc($protocol),
				};
				$out->print_element( 'portRange', $portRange );
			}
		}
		$out->close_element('serviceGroup');
	}

}

sub _object_to_hash
{

	# turns a check point configuration object into a standard
	# perl hashtable
	my $objectText = shift;
	my $newObject  = {};

	my @stack;
	push( @stack, $newObject );

	my $key;
	my $word;

	foreach my $char ( split( //, $objectText ) )
	{
		$word =~ s/\s*$// if ( $char =~ /[:()]/ );    # remove only trailing whitespace

		if ( $char eq ':' )
		{
			if ($word)
			{
				if ( $word =~ /^\s/ && !$key )
				{
					$word =~ s/^\s+//;
					my $current = peek(@stack);
					push( @{ $current->{'children'} }, $word );
				}
				else
				{
					my $current = peek(@stack);
					$current->{$word} = {};
					push( @stack, $current->{$word} );
				}
			}
		}
		elsif ( $char eq '(' )
		{
			$key = $word;
			if ( length($key) > 0 )
			{
				my $current = peek(@stack);
				$current->{$key} = {};
				push( @stack, $current->{$key} );
			}
		}
		elsif ( $char eq ')' )
		{
			if ( $word =~ /^\s/ && !$key )
			{
				$word =~ s/^\s+//;
				my $current = pop(@stack);
				push( @{ $current->{'children'} }, $word );
			}
			else
			{
				pop(@stack);
				if ( defined $word && length($key) > 0 )
				{
					my $current = peek(@stack);
					$current->{$key} = $word;
				}
			}
		}
		else
		{
			$word .= $char;
		}

		$word = '' if ( $char =~ /[:()]/ );
		$key  = '' if ( $char =~ /[:)]/ );
	}
	return $newObject;
}

sub peek
{
	my @array = @_;
	return $array[$#array];
}

sub _get_any
{
	# return a real 'any' subnet for IPv4 and IPv6
	my $ipv4Any = { address => '0.0.0.0', mask => '0', };
	my $ipv6Any = { address => '::',     mask => '0', };
	my @anyObj;
	push (@anyObj, {network => $ipv4Any});
	push (@anyObj, {network => $ipv6Any});
	return @anyObj; 
}

1;
