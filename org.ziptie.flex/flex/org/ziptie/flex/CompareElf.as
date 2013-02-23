package org.ziptie.flex
{
	import mx.utils.ObjectUtil;
	
	public class CompareElf
	{
		public function CompareElf()
		{
		}

        public static function compare(s1:String, s2:String, ignoreCase:Boolean = true):int
        {
        	var r:int = doCompare(s1, s2, ignoreCase);
        	if (r > 0)
        	{
        		return 1;
        	}
        	else if (r < 0)
        	{
        		return -1;
        	}
        	else
        	{
        		return 0;
        	}
        }

	    private static function doCompare(s1:String, s2:String, ignoreCase:Boolean):int
	    {
	        if (s1 == null)
	        {
	            return (-1);
	        }
	
	        if (s2 == null)
	        {
	            return 1;
	        }
	
	        var zeroCount1:int = 0;
	        var zeroCount2:int = 0;
	
	        var l1:int = s1.length
	        var l2:int = s2.length;
	
	        var c1Pos:int = 0;
	        var c2Pos:int = 0;
	
	        while (c1Pos < l1 && c2Pos < l2)
	        {
	            var c1:String = s1.charAt(c1Pos++);
	            var c2:String = s2.charAt(c2Pos++);

	            if (isDigit(c1) && isDigit(c2))
	            {
	                var n1Pos:int = c1Pos - 1;
	                var n2Pos:int = c2Pos - 1;
	
	                if (c1 == '0')
	                {
	                    zeroCount1++;
	                    n1Pos++;
	                }
	
	                if (c2 == '0')
	                {
	                    zeroCount2++;
	                    n2Pos++;
	                }
	
	                while (c1Pos < l1)
	                {
	                    var d:String = s1.charAt(c1Pos);
	                    if (!isDigit(d))
	                    {
	                        break;
	                    }
	
	                    if (c1Pos - n1Pos == 0 && d == '0')
	                    {
	                        zeroCount1++;
	                        n1Pos++;
	                    }
	
	                    c1Pos++;
	                }
	
	                while (c2Pos < l2)
	                {
	                    var dig:String = s2.charAt(c2Pos);
	                    if (!isDigit(dig))
	                    {
	                        break;
	                    }
	
	                    if (c2Pos - n2Pos == 0 && dig == '0')
	                    {
	                        zeroCount2++;
	                        n2Pos++;
	                    }
	
	                    c2Pos++;
	                }
	
	                var n1Length:int = c1Pos - n1Pos;
	                var n2Length:int = c2Pos - n2Pos;
	
	                if (n1Length != n2Length)
	                {
	                    return (n1Length - n2Length);
	                }
	
	                for (var i:int = 0; i < n1Length; i++)
	                {
	                    var nc1:Number = s1.charCodeAt(n1Pos++);
	                    var nc2:Number = s2.charCodeAt(n2Pos++);
	
	                    if (nc1 != nc2)
	                    {
	                        return (nc1 - nc2);
	                    }
	                }
	            }
	            else
	            {
	                if (ignoreCase)
	                {
	                    c1 = c1.toLowerCase();
	                    c2 = c1.toLowerCase();
	                }
	
	                if (c1 != c2)
	                {
	                    return (c1.charCodeAt() - c2.charCodeAt());
	                }
	            }
	        }
	
	        return ((l1 - zeroCount1) - (l2 - zeroCount2));
	    }

        public static function isDigit(c:String):Boolean
        {
        	return c > '/' && c < ':';
        }

	}
}