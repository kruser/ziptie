package org.ziptie.flex.search
{
	import org.ziptie.flex.services.PagedWebService;

	public class PagedDeviceQuery extends PagedWebService
	{
		private var _scheme:String;
		private var _query:String;
		private var _sort:String;
		private var _descending:Boolean;

		public function PagedDeviceQuery(scheme:String, data:String, sort:String, desc:Boolean)
		{
			super('devicesearch', 'search', 'devices');

			_scheme = scheme;
			_query = data;
			_sort = sort;
			_descending = desc;
		}

        override protected function buildArgs(pageData:Object):Array
        {
        	return new Array(_scheme, _query, pageData, _sort, _descending);
        }
	}
}