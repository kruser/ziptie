package org.ziptie.flex.devices
{
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.rpc.events.ResultEvent;
	
	import org.ziptie.flex.services.ResultElf;
	import org.ziptie.flex.services.WebServiceElf;
	
	public final class AdaptersElf
	{
		private static var _adapters:ArrayCollection;
		private static var _adaptersById:Object;

        public static function load():void
        {
        	if (_adapters != null)
        	{
        		return;
        	}

    		var field:SortField = new SortField("shortName", true);
            var sort:Sort = new Sort();
            sort.fields = [field];

            _adaptersById = new Object();

            _adapters = new ArrayCollection();
            _adapters.sort = sort;
            _adapters.refresh();

            WebServiceElf.call('adapters', 'getAvailableAdapters', result);
        }

        public static function get adapters():ArrayCollection
        {
    		load();
            return _adapters;
        }

        public static function get adaptersById():Object
        {
        	load();
            return _adaptersById;
        }

        private static function result(event:ResultEvent):void
        {
        	for each (var adapter:Object in ResultElf.array(event.result))
        	{
        		_adapters.addItem(adapter);
        		_adaptersById[adapter.adapterId] = adapter;
        	}
        }
	}
}
