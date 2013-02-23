package org.ziptie.flex
{
	import mx.collections.ArrayCollection;
	
	/**
	 * An RFC 4180 CSV parser.
	 */
	public class CsvElf
	{
		public function CsvElf()
		{
		}

        public static function toCsv(array:*):String
        {
        	if (array == null)
        	{
        		return '';
        	}

        	var csv:String = '';
            if (array is Array)
            {
            	var len:int = (array as Array).length;
            	for (var i:int = 0 ; i < len; i++)
            	{
            		csv += toCell(array[i]);
            	}
            }
            else
            {
	        	for each (var cellObject:Object in array)
	        	{
	        		csv += toCell(cellObject);
	        	}
            }

            if (csv.length < 2)
            {
            	return '';
            }

        	return csv.substr(0, csv.length - 1);
        }

        private static function toCell(object:Object):String
        {
    		var cell:String = object.toString();
        	return '\"' + cell.replace(/"/g, '\"\"') + '\",'; // <- This is actually a comment, but some syntax coloring might be broken");
        }

        public static function toArray(csv:String):Array
        {
        	var rows:ArrayCollection = new ArrayCollection();
            var row:ArrayCollection = new ArrayCollection();

        	var cursor:int = 0;
        	var start:uint = cursor;

            while (true)
            {
            	var cc:String = csv.charAt(cursor);
	        	if (cc == '"')
	        	{
	        		start = cursor + 1;
	        		while (true)
	        		{
		        		cursor = csv.indexOf('"', cursor + 1);
		        		if (cursor == -1)
		        		{
		        			row.addItem(csv.substring(start));
		        			rows.addItem(row.toArray());
		        			return rows.toArray();
		        		}

		        		if (csv.charAt(cursor + 1) == '"')
		        		{
		        			cursor++;
		        		}
		        		else
		        		{
		        			row.addItem(csv.substring(start, cursor).replace(/""/g, '\"'));
		        			cursor++;

		        			c = csv.charAt(cursor)
		        			if (c == ',')
		        			{
		        				cursor++;
		        			}
		        			else if (c == '\r')
                            {
                                cursor++;
                                if (csv.charAt(cursor) == '\n')
                                {
                                    cursor++;
                                }
                                rows.addItem(row.toArray());
                                row = new ArrayCollection();
                            }
                            else if (c == '\n')
                            {
    		        			cursor++;
                                rows.addItem(row.toArray());
                                row = new ArrayCollection();
                            }
                            else if (c == '')
                            {
                            	rows.addItem(row.toArray());
                            	return rows.toArray();
                            }
		        			break;
		        		}
	        		}
	        	}
	        	else if (cc == ',')
	        	{
                    row.addItem('');
	        		cursor++;
	        	}
	        	else if (cc == '\r')
	        	{
                    row.addItem('');

	        		cursor++;
	        		if (csv.charAt(cursor) == '\n')
	        		{
	        			cursor++;
	        		}
	        		rows.addItem(row.toArray());
	        		row = new ArrayCollection();
	        	}
	        	else if (cc == '\n')
	        	{
                    row.addItem('');
	        		cursor++;
	        		rows.addItem(row.toArray());
	        		row = new ArrayCollection();
	        	}
	        	else if (cc == '')
	        	{
                    row.addItem('');
	        		rows.addItem(row.toArray());
	        		return rows.toArray();
	        	}
	        	else
	        	{
	        		start = cursor;
	        		for (; ; cursor++)
	        		{
	        			var c:String = csv.charAt(cursor)
	        			if (c == ',')
	        			{
	        				row.addItem(csv.substring(start, cursor));
	        				cursor++;
	        				break;
	        			}
	        			else if (c == '\n')
	        			{
	        				row.addItem(csv.substring(start, cursor));
	        				cursor++;
	        				rows.addItem(row.toArray());
	        				row = new ArrayCollection();
	        				break;
	        			}
	        			else if (c == '\r')
	        			{
	        				row.addItem(csv.substring(start, cursor));
                            cursor++;
                            if (csv.charAt(cursor) == '\n')
                            {
                                cursor++;
                            }
                            rows.addItem(row.toArray());
                            row = new ArrayCollection();
	        			}
	        			else if (c == '')
	        			{
	        				row.addItem(csv.substring(start));
	        				rows.addItem(row.toArray());
	        				return rows.toArray();
	        			}
	        		}
	        	}
            }

        	return rows.toArray();
        }
	}
}