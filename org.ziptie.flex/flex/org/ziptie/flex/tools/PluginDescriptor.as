package org.ziptie.flex.tools
{
	import mx.collections.ArrayCollection;
	
	public class PluginDescriptor
	{
		public static const SINGLE:String = 'SINGLE';
		public static const NONE:String = 'NONE';

		private var _pluginDescriptor:Object;
		private var _properties:XML;
		private var _fields:ArrayCollection;
		private var _columns:ArrayCollection;

		public function PluginDescriptor(pluginDescriptor:Object)
		{
			_pluginDescriptor = pluginDescriptor;
		}

        public function get toolName():String
        {
        	return _pluginDescriptor.toolName;
        }

        public function get properties():XML
        {
        	if (_properties == null)
        	{
        		_properties = new XML(_pluginDescriptor.propertyText);
        	}
        	return _properties;
        }

        public function get category():String
        {
        	return properties.entry.(@key=='tool.category');
        }

        public function get isInteractive():Boolean
        {
        	return fields.length > 0;
        }

        public function get enabled():Boolean
        {
        	var val:String = properties.entry.(@key=='script.enabled');
        	return val == '' || val.toLowerCase() != 'false';
        }

        public function get modeSupported():String
        {
            var mode:String = properties.entry.(@key=='mode.supported');
            return mode.toUpperCase();
        }

        public function get fields():ArrayCollection
        {
        	if (_fields == null)
        	{
        		_fields = new ArrayCollection();
	        	for (var i:int; true; i++)
                {
                    var field:Field = Field.create(properties, i);
                    if (field == null)
                    {
                        break;
                    }
                    _fields.addItem(field);
                }
        	}

        	return _fields;
        }

        public function get outputFormat():String
        {
        	var format:String = properties.entry.(@key=='detail.format');
            if (format == '')
            {
            	if (pluginType == 'report')
            	{
            		return 'PDF';
            	}
                return 'grid(text)';
            }
            return format;
        }

        public function get columns():ArrayCollection
        {
        	if (_columns == null)
        	{
        		_columns = new ArrayCollection();
        		for (var i:int; true; i++)
        		{
        			var column:Column = Column.create(properties, i);
        			if (column ==null)
        			{
        				break;
        			}
        			_columns.addItem(column);
        		}
        	}
        	return _columns;
        }

        public function get defaultColumn():int
        {
        	var c:String = properties.entry.(@key=='column.default');
        	return c == '' ? 0 : int(c);
        }

        public function get detailVisible():Boolean
        {
        	var c:String = properties.entry.(@key=='detail.visible');
        	return c == '' || c.toLowerCase() == 'true';
        }

        public function get pluginType():String
        {
        	return _pluginDescriptor.pluginType;
        }

        public function get requiresZedDefaults():Boolean
        {
        	for each (var field:Field in fields)
        	{
        		if (field.defaultXpath != '')
        		{
        			return true;
        		}
        	}
        	return false;
        }

        public function isToolSupported(devices:Array):Boolean
        {
        	var f:String = properties.entry.(@key=='enable.filter');
        	if (f == '')
        	{
        		return true;
        	}

            return true;
//            try
//            {
//	            var filter:Filter = new Filter(f);
//
//                for (var int:i = 0 ; i < devices.length; i++)
//                {
//                    var device:Object = devices[i];
//
//                    // Check to see if the current device was supported
//                    var isCurrentDeviceSupported:Boolean = filter.matchCase(device);
//                    if (!isCurrentDeviceSupported)
//                    {
//                        return false;
//                    }
//                }
//            }
//            catch (InvalidSyntaxException e)
//            {
//                String msg = String.format("The enable filter string for the '%s' tool is invalid/malformed!", toolProperties.getToolName()); //$NON-NLS-1$
//                ErrorElf.logError(new InvalidSyntaxException(msg, e.getFilter(), e));
//            }
        }
	}
}
