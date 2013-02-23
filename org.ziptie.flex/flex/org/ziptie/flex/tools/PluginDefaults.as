package org.ziptie.flex.tools
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import memorphic.xpath.XPathQuery;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.utils.Base64Decoder;
	
	import org.ziptie.flex.CsvElf;
	import org.ziptie.flex.services.WebServiceElf;
	
	public class PluginDefaults extends EventDispatcher
	{
		private var _plugin:PluginDescriptor;
		private var _ipAddress:String;
		private var _managedNetwork:String;
		private var _values:Object;

		public function PluginDefaults(plugin:PluginDescriptor, ipAddress:String, managedNetwork:String)
		{
			_plugin = plugin;
			_ipAddress = ipAddress;
			_managedNetwork = managedNetwork;
		}

        public function get values():Object
        {
        	return _values;
        }

        public function load():void
        {
            WebServiceElf.call(
                    'configstore',
                    'retrieveRevision',
                    onZed,
                    _ipAddress,
                    _managedNetwork,
                    '/ZipTie-Element-Document');
        }

        private function onZed(event:ResultEvent):void
        {
            var rev:Object = event.result;
            if (rev == null)
            {
            	return;
            }

            var decoder:Base64Decoder = new Base64Decoder();
            decoder.decode(rev.content);

            var text:String = decoder.toByteArray().toString();
            var xml:XML = new XML(text);

            var values:Object = new Object();

            for each (var field:Field in _plugin.fields)
            {
                var key:String = "input." + field.name;
                if (field.defaultXpath != '')
                {
                    var useNamespaces:Boolean = field.metadata.hasOwnProperty('namespaces');
                    var query:XPathQuery = new XPathQuery(field.defaultXpath);
                    query.context.openAllNamespaces = !useNamespaces;
                    var result:XMLList = query.exec(xml);
                    if (field.isMulti)
                    {
                        if (field.defaultXpathDisplay != null)
                        {
                            var cells:ArrayCollection = new ArrayCollection();

                            var exps:ArrayCollection = new ArrayCollection();

                            for each (var col:String in field.defaultXpathDisplay)
                            {
                                query = new XPathQuery(col);
                                query.context.openAllNamespaces = !useNamespaces;
                                exps.addItem(query);
                            }

                            for each (var node:XML in result)
                            {
                                for each (var xpath:XPathQuery in exps)
                                {
                                    var val:XMLList = xpath.exec(node);
                                    cells.addItem(val.toString());
                                }
                            }

                            values[key] = CsvElf.toCsv(cells);
                        }
                        else
                        {
                            values[key] = CsvElf.toCsv(result);
                        }
                    }
                    else
                    {
                        var value:String = '';
                        for each (var item:XML in result)
                        {
                            value += item.toString()
                        }
                        values[key] = value;
                    }
                }
            }

            _values = values;
            dispatchEvent(new Event(Event.COMPLETE));
        }
	}
}
