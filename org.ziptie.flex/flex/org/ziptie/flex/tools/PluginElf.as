package org.ziptie.flex.tools
{
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.rpc.events.ResultEvent;
	
	import org.ziptie.flex.services.ResultElf;
	import org.ziptie.flex.services.WebServiceElf;
	
	public class PluginElf
	{
		private static var _pluginProperties:Object;
		private static var _pluginDescriptors:Object;
		private static var _callbacks:ArrayCollection = new ArrayCollection();

		public function PluginElf()
		{
		}

        
        public static function getPluginDescriptor(name:String, callback:Function):void
        {
        	if (_pluginDescriptors != null)
        	{
        		callback(_pluginDescriptors[name]);
        		return;
        	}
            else if (_pluginProperties == null)
            {
            	load();
            }

            _callbacks.addItem({name: name, callback: callback});
        }

        public static function getPluginDescriptors(type:String, onLoad:Function = null):ArrayCollection
        {
            if (_pluginProperties == null)
            {
                _pluginProperties = new Object();
                load();
            }

        	var result:ArrayCollection = _pluginProperties[type];
        	if (result == null)
        	{
                result = createPluginTypeCollection();
                _pluginProperties[type] = result;
                if (onLoad != null)
                {
                    _callbacks.addItem({type: type, callback: onLoad});
                }
            }

            return result;
        }

        private static function load():void
        {
        	if (_pluginProperties == null)
        	{
        		_pluginProperties = new Object();
        	}

            WebServiceElf.call('plugins', 'getPluginDescriptors', onLoad);
        }

        private static function createPluginTypeCollection():ArrayCollection
        {
            var col:ArrayCollection = new ArrayCollection();
            col.sort = new Sort();
            col.sort.fields = [new SortField('toolName')];
            col.refresh();
            return col;
        }

        private static function onLoad(event:ResultEvent):void
        {
        	_pluginDescriptors = new Object();

            for each (var pd:Object in ResultElf.array(event))
            {
                var type:ArrayCollection = _pluginProperties[pd.pluginType];
                if (type == null)
                {
                    type = createPluginTypeCollection();
                    _pluginProperties[pd.pluginType] = type;
                }

                var descriptor:PluginDescriptor = new PluginDescriptor(pd);
                type.addItem(descriptor);

                _pluginDescriptors[pd.toolName] = descriptor;
            }

            for each (var o:Object in _callbacks)
            {
            	if (o.type != null)
            	{
            		o.callback(_pluginProperties[o.type]);
            	}
            	else
            	{
                    o.callback(_pluginDescriptors[o.name]);
            	}
            }

            _callbacks = null;
        }
    }
}