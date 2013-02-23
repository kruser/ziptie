package org.ziptie.flex.services
{
	import flash.xml.XMLDocument;
	
	import mx.rpc.xml.SimpleXMLDecoder;
	
	public class ServerEvent
	{
        private var _type:String;
        private var _queue:String;
        private var _text:String;
        private var _xml:XML;
        private var _object:Object;

		public function ServerEvent(type:String, queue:String, text:String)
		{
			_type = type;
			_queue = queue;
			_text = text;
		}

        public function get type():String
        {
        	return _type;
        }

        public function get queue():String
        {
        	return _queue;
        }

        public function get text():String
        {
        	return _text
        }

        public function get xml():XML
        {
        	if (_xml == null)
        	{
        		_xml = new XML(_text);
        	}
        	return _xml;
        }

        public function get object():Object
        {
        	if (_object == null)
        	{
        		var decoder:SimpleXMLDecoder = new SimpleXMLDecoder(true);
                _object = decoder.decodeXML(new XMLDocument(_text).firstChild);
        	}
        	return _object;
        }
	}
}