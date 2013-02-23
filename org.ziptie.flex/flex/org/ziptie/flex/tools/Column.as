package org.ziptie.flex.tools
{
	import mx.collections.ArrayCollection;
	
	import org.ziptie.flex.CsvElf;
	
	public class Column
	{
        public var name:String;
        public var imageSelectorRegex:RegExp;
        public var resizable:Boolean;
        public var width:Number;
        public var alignment:String;
        public var index:int;
        public var imageKeys:Array;
        public var tool:String;

		public function Column()
		{
		}

        
        public static function create(xml:XML, index:int):Column
        {
            var name:String = xml.entry.(@key==('column.' + index));
            if (name == '')
            {
	        	var hasColumn:Boolean = false;
	        	for each (var entry:XML in xml.entry)
	        	{
	        		var key:String = entry.@key;
	        		if (key.indexOf('column.' + index) == 0)
	        		{
	        			hasColumn = true;
	        			break;
	        		}
	        	}
	
	            if (!hasColumn)
	            {
	            	return null;
	            }
            }

            var column:Column = new Column();
            column.name = name;
            column.index = index;

            var icons:String = xml.entry.(@key=='column.' + index + '.icons');
            if (icons != '')
            {
            	column.imageKeys = CsvElf.toArray(icons)[0];
            }

            var regex:String = xml.entry.(@key=='column.' + index + '.regex');
            if (regex != '')
            {
                column.imageSelectorRegex = new RegExp(regex);
            }

            var resizable:String = xml.entry.(@key=='column.' + index + '.resizable')
            column.resizable = resizable == '' || resizable.toLowerCase() == 'true';
            var width:String = xml.entry.(@key=='column.' + index + '.width')
            column.width = Number(width);

            var alignment:String = xml.entry.(@key=='column.' + index + '.alignment')
            column.alignment = alignment.toUpperCase();

            return column;
        }
	}
}