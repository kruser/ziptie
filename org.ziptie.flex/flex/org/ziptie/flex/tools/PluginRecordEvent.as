package org.ziptie.flex.tools
{
	import flash.events.Event;
	
	public class PluginRecordEvent extends Event
	{
		public static const TYPE:String = 'pluginRecord';

        private var _id:int;
        private var _gridData:String;
        private var _net:String;
        private var _ip:String;

		public function PluginRecordEvent(id:int, gridData:String, ip:String, net:String)
		{
			super(TYPE);
			_id = id;
			_gridData = gridData;
			_ip = ip;
			_net = net;
		}

        public function get ipAddress():String
        {
        	return _ip;
        }

        public function get managedNetwork():String
        {
        	return _net;
        }

        public function get id():int
        {
        	return _id;
        }

        public function get gridData():String
        {
        	return _gridData;
        }
	}
}