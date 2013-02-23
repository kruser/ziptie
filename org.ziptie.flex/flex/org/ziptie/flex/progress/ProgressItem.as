package org.ziptie.flex.progress
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

    [Event(name=Event.CANCEL, eventType='flash.events.Event')]
    [Event(name=Event.COMPLETE, eventType='flash.events.Event')]
	public class ProgressItem extends EventDispatcher
	{
		private var _message:String;
		private var _percent:int;
		private var _title:String;

		public var background:Boolean = false;

		public function ProgressItem(title:String)
		{
			_title = title;
		}

        [Bindable(event='titleChanged')]
        public function get title():String
        {
        	return _title;
        }

        [Bindable(event='messageChanged')]
        public function get message():String
        {
        	return _message == null ? "" : _message;
        }

        [Bindable(event='percentChanged')]
        public function get percentComplete():int
        {
        	return _percent;
        }

        protected function start():void
        {
        }

        protected function cancel():void
        {
        }

        protected function done():void
        {
        	dispatchEvent(new Event(Event.COMPLETE));
        }

        protected function progress(message:String, percent:int = -1):void
        {
        	if (_message != message)
        	{
	        	_message = message;
	        	dispatchEvent(new Event("messageChanged"));
	        }
        	if (_percent != percent)
        	{
        		_percent = percent;
                dispatchEvent(new Event("percentChanged"));
        	}
        }

        internal final function doStart():void
        {
        	start();
        }

        internal final function doCancel():void
        {
        	cancel();
        	dispatchEvent(new Event(Event.CANCEL));
        }
	}
}