package org.ziptie.flex.credentials
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

    [Event(name='change', type='flash.events.Event')]	
	public class AddrSet extends EventDispatcher
	{
		public static const NEW:String = "NEW";
		public static const UNCHANGED:String = "UNCHANGED";
		public static const MODIFIED:String = "MODIFIED";
		public static const REMOVED:String = "REMOVED";
		public static const NONEXISTENT:String = "NONEXISTENT";

        private var _state:String = UNCHANGED;
        private var _default:Boolean;

        [Bindable]
        public var config:Object;

		public function AddrSet(cc:Object, defualt:Boolean = false)
		{
			config = cc;
			_default = defualt;
		}

        public function isDefault():Boolean
        {
        	return _default;
        }

        [Bindable(event='change')]
        public function get state():String
        {
        	return _state;
        }

        public function changeState(newState:String):void
        {
        	if (_state == NEW)
        	{
        		if (newState == REMOVED)
        		{
        			_state = NONEXISTENT;
        			dispatchEvent(new Event(Event.CHANGE));
        		}
        		// else, the state is still NEW
        	}
        	else if (_state != newState)
        	{
        		_state = newState;
        		dispatchEvent(new Event(Event.CHANGE));
        	}
        }
	}
	
}