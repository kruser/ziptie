package org.ziptie.flex
{
	import mx.events.IndexChangedEvent;
	
	/**
	 * Utilities to validate IP addresses, ranges of IPs and subnets.
	 * 
	 * Valid inputs:
	 *   192.168.1.2
	 *   192.168.1.0-192.168.3.255
	 *   192.168.1.0/24
	 *   192.168.*.1-10
	 */
	public class NetworkAddressElf
	{
		private static var IPV4_REGEX:RegExp = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/;
		private static var IPV6_REGEX:RegExp = /^((?:[a-f\d]{1,4}:){7}[a-f\d]{1,4}|((?:[a-f\d]{1,4}:){0,6}[a-f\d]{1,4})?::((?:[a-f\d]{1,4}:){0,6}[a-f\d]{1,4})?)$/i;
		private static var IPV6_WILDCARD_CHUNK:RegExp = /^(\*[a-f\d]{0,3}|[a-f\d]{0,3}\*|[a-f\d]{1,4}\-[a-f\d]{1,4}|[a-f\d]{1,4})$/i
		private static var IPV4_WILDCARD_CHUNK:RegExp = /^(\d{0,2}\*|\d{1,3}\-\d{1,3}|\d{1,3})$/;
		
		public function NetworkAddressElf()
		{
		}

		/**
		 * Validates if the incoming address is an IP address, a subnet in CIDR notation,
		 * an IP range or an IP wildcard definition.
		 */
		public static function isValidAddressDefinition(address:String):Boolean
		{
			if (isValidIp(address))
			{
				return true;
			}
			else if (isValidCidr(address))
			{
				return true;
			}
			else if (isValidRange(address))
			{
				return true;
			}
			else if (isValidWildcard(address))
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		/**
		 * Validates an IP address
		 */
        public static function isValidIp(ipAddress:String):Boolean
        {
        	if (ipAddress.indexOf(":") != -1)
        	{
        		return IPV6_REGEX.test(ipAddress);	
        	}
        	else
        	{
        		return IPV4_REGEX.test(ipAddress);
        	}
        }

		/**
		 * Validates a subnet definition
		 * 
		 * A valid definition is 192.168.1.0/24
		 */
		public static function isValidCidr(network:String):Boolean
		{
			var pieces:Array = network.split('/');
			if (pieces.length == 2 && isValidIp(pieces[0]))
			{
				var strMask:String = pieces[1];
				if (strMask.match(/^\d+$/) == null)
				{
					return false;
				}

				var mask:int = int (strMask);
				if (pieces[0].indexOf(":") != -1)
				{
					return (mask >=0 && mask <=128);
				}
				else
				{
					return (mask >=0 && mask <=32);
				}
			}
			return false;
		}
		
		/**
		 * Validates an IP Range.
		 * 
		 * A valid range is: 192.168.1.0-192.168.3.255
		 */
		public static function isValidRange(range:String):Boolean
		{
			var pieces:Array = range.split('-');
			return (pieces.length == 2 && isValidIp(pieces[0]) && isValidIp(pieces[1]));
		}
		
		/**
		 * Validates an IP wildcard.
		 * 
		 * A valid wildcard is: 192.168.*.10-100
		 */
		public static function isValidWildcard(ipWildcard:String):Boolean
		{
			var addrChunks:Array;
			if (ipWildcard.indexOf(':') != -1)
        	{
        		addrChunks = ipWildcard.split(':');
        		var oneEmpty:Boolean = false;
        		for each (var v6Chunk:String in addrChunks)
        		{
        			if (v6Chunk.length > 0)
        			{
        				if (!IPV6_WILDCARD_CHUNK.test(v6Chunk))
        				{
        					return false;
        				}
        			}
        			else if (!oneEmpty)
        			{
        				oneEmpty = true;
        			}
        			else
        			{
        				return false;
        			}
        		}
        	}
        	else
        	{
        		addrChunks = ipWildcard.split('.');
        		for each (var v4Chunk:String in addrChunks)
        		{
        			if (!IPV4_WILDCARD_CHUNK.test(v4Chunk))
        			{
        				return false;
        			}
        		}
        	}
			return true;
		}
 	}
}