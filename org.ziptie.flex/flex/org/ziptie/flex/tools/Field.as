package org.ziptie.flex.tools
{
	import org.ziptie.flex.CsvElf;
	
	public class Field
	{
		[Bindable]
		public var name:String;
		[Bindable]
		public var label:String;
		[Bindable]
		public var type:String;
		[Bindable]
		public var group:String;
		[Bindable]
		public var defaultValue:String;
		[Bindable]
		public var defaultXpath:String;
		[Bindable]
		public var defaultXpathDisplay:Array;
		[Bindable]
		public var metadata:Object = {};

		public function Field()
		{
		}

        public function get isMulti():Boolean
        {
        	return type == 'grid' || type == 'list' || type == 'combo';
        }

        public static function create(xml:XML, index:int):Field
        {
        	var name:String = xml.entry.(@key==('input.' + index));
        	if (name == '')
        	{
        		return null;
        	}

        	var field:Field = new Field();
        	field.name = name;
        	field.label = xml.entry.(@key=='input.' + index + '.label');
        	field.defaultValue = xml.entry.(@key=='input.' + index + '.default');
        	field.defaultXpath = xml.entry.(@key=='input.' + index + '.default.xpath');
        	field.group = xml.entry.(@key=='input.' + index + '.group');
        	field.type = xml.entry.(@key=='input.' + index + '.type');

            var strMetadata:String = xml.entry.(@key=='input.' + index + '.meta');
            strMetadata = strMetadata.replace(/^\s*/, '').replace(/\s*$/, '');
            if (strMetadata.charAt(0) == '\"')
            {
            	strMetadata.search(/[^\\]"/);
            }
            for each (var entry:String in CsvElf.toArray(strMetadata)[0])
            {
            	var split:Array = entry.split('=', 2);
            	if (split.length == 2)
            	{
            		field.metadata[split[0]] = split[1];
            	}
            	else
            	{
            		field.metadata[split[0]] = "";
            	}
            } 

            var strDisplay:String = xml.entry.(@key=='input.' + index + '.default.xpath.display');
            if (strDisplay != '')
            {
            	field.defaultXpathDisplay = CsvElf.toArray(strDisplay)[0];
            }
        	return field;
        }
	}
}