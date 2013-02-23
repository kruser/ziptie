package org.ziptie.flex
{
    import com.adobe.utils.DateUtil;
    
    import flash.net.SharedObject;
    
    import mx.formatters.DateFormatter;
    import mx.resources.ResourceManager;
	
    public class DisplayElf
    {
    	private static var dateFormats:Object = new Object();

		public function DisplayElf()
		{
		}

        public static function formatDate(type:String, value:Object):String
        {
            var formatter:DateFormatter = dateFormats[type];
            if (formatter == null)
            {
                var format:String = ResourceManager.getInstance().getString('messages', 'dateFormat_' + type);
                formatter = new DateFormatter();
                formatter.formatString = format;

                dateFormats[type] = formatter;
            }

            if (value is String)
            {
                value = DateUtil.parseW3CDTF(String(value));
            }

            return formatter.format(value);
        }

        public static function setFormat(type:String, format:String):void
        {
        }

        public static function format(type:String, object:Object, format:String = null):String
        {
        	if (format == null)
        	{
        		var so:SharedObject = SharedObject.getLocal("displayFormats");
        		format = so.data[type];
        		if (format == null)
        		{
        			format = Registry.displayBindingDefaults[type];
        		}
        	}

            return bind(object, format);
        }

        public static function bind(object:Object, format:String):String
        {
        	if (format == null)
        	{
        		return object.toString();
        	}

            var output:String = "";

            var length:Number = format.length;
            var start:Number = -1;
            var end:Number = length;
            while (true)
            {
                end = format.indexOf('{', start);
	            if (end > -1)
	            {
	                output = output.concat(format.substring(start + 1, end));
	                start = format.indexOf('}', end);
	                if (start > -1)
	                {
	                    var val:Object = object;
	                    for each (var key:String in format.substring(end + 1, start).split('.'))
	                    {
	                    	if (val == null)
	                    	{
	                    		break;
	                    	}

                            val = val[key];
	                    }

	                    if (val != null)
	                    {
	                        output = output.concat(val);
	                    }
	                }
	                else
	                {
	                    output = output.concat(format.substring(end, length));
	                    break;
	                }
	            }
	            else
	            {
	                output = output.concat(format.substring(start + 1, length));
	                break;
	            }
	        }

	        return output;
        }
	}
}