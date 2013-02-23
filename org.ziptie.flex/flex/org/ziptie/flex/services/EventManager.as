package org.ziptie.flex.services
{
	import mx.collections.ArrayCollection;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.ResultEvent;
	
    /**
     * Provides a single location for the management of even subscriptions.
     */ 
	public final class EventManager
	{
		private static var _connected:Boolean = false;

		// start at 1 instead of 0 so that people can safely unsubscribe nothing using the default value for int
		private static var _nextId:int = 1; 
		private static var _listeners:Object;
		private static var _queueCounts:Object;
		private static var _subscribers:Object;
		private static var _subscribed:Object;

        // static init
        {
        	_listeners = new Object();
        	_queueCounts = new Object();
        	_subscribers = new Object();
        	_subscribed = new Object();
        }

		public function EventManager()
		{
		}

        /**
         * Subscribe for events on a queue.
         * Use '*' as the event type to recieve all types of events on the queue.
         * callback should be of the form: function callback(queue:String, eventType:String, payload:XML):void
         */ 
        public static function subscribe(queue:String, eventType:String, callback:Function, onSubscribe:Function = null):int
        {
        	var id:int = _nextId;
        	_nextId++;

            var key:String = queue + ':' + eventType;
            _subscribers[id] = {key: key, queue: queue};

        	var listeners:Object = _listeners[key];
        	if (listeners == null)
        	{
        		listeners = new Object();
        		_listeners[key] = listeners;
        	}
        	listeners[id] = callback;

            if (_queueCounts[queue] == null || _queueCounts[queue] == 0)
            {
            	_queueCounts[queue] = 1;
            	var at:AsyncToken = WebServiceElf.call('events', 'subscribe', subscribed, queue);
                at['queue'] = queue;

                var ac:ArrayCollection = new ArrayCollection();
                if (onSubscribe != null)
                {
                    ac.addItem(onSubscribe);
                }
                _subscribed[queue + ":callback"] = ac;
            }
            else
            {
            	if (onSubscribe != null)
            	{
	            	if (_subscribed.hasOwnProperty(queue))
	            	{
	            		onSubscribe();
	            	}
	            	else
	            	{
	            		_subscribed[queue + ":callback"].addItem(onSubscribe);
	            	}
	            }

            	_queueCounts[queue]++;
            }

            if (id == 1)
            {
            	// start polling with the first subscriber
            	poll();
            }

        	return id;
        }

        private static function subscribed(event:ResultEvent):void
        {
        	var queue:String = event.token['queue'];
        	_subscribed[queue] = true;

        	var callbacks:ArrayCollection = _subscribed[queue + ":callback"];
            for each (var callback:Function in callbacks)
            {
            	callback();
            }

        	delete _subscribed[queue + ":callback"];
        }

        /**
         * Unsubscribe the listener.  id is the value that was returned from subscribe
         */
        public static function unsubscribe(id:int):void
        {
        	var subscriber:Object = _subscribers[id];
        	if (subscriber == null)
        	{
        		return;
        	}

        	delete _subscribers[id];
            delete _listeners[subscriber.key][id];
            var queue:String = subscriber.queue
            _queueCounts[queue]--;
            if (_queueCounts[queue] == 0)
            {
            	WebServiceElf.call('events', 'unsubscribe', null, queue);
            	delete _subscribed[queue];
            }
        }

        private static function poll():void
        {
        	WebServiceElf.call('events', 'poll', onMessage);
        }

        private static function onMessage(result:ResultEvent):void
        {
            for each (var event:Object in ResultElf.array(result))
            {
            	var type:String = event.type;
	        	var queue:String = event.queue;
            	var se:ServerEvent = new ServerEvent(type, queue, event.text);
	
	            notify(_listeners[queue + ':' + type], se);
	            notify(_listeners[queue + ':*'], se);
            }

            poll();
        }

        private static function notify(listeners:Object, event:ServerEvent):void
        {
        	if (listeners == null)
        	{
        		return;
        	}

        	for each (var listener:Function in listeners)
            {
                listener(event);
            }
        }
	}
}
