package org.ziptie.flex.arpsearch
{
	import org.ziptie.flex.services.PagedWebService;

	public class PagedArpQuery extends PagedWebService
	{
		private var _query:String;
		private var _sort:String;
		private var _desc:Boolean;

		public function PagedArpQuery(query:String, sort:String, desc:Boolean)
		{
			super('telemetry', 'getArpEntries', 'arpEntries');
			_query = query;
			_sort = sort;
			_desc = desc;
		}

        override protected function buildArgs(pageData:Object):Array
        {
        	return new Array(pageData, _query, _sort, _desc);
        }
	}
}