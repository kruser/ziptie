package org.ziptie.flex.jobs
{
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	
	import org.ziptie.flex.services.PagedWebService;
	
	public class ExecutionHistoryService extends PagedWebService
	{
		private var _sort:String;
		private var _descending:Boolean;
		private var _executions:Object = new Object();

		public function ExecutionHistoryService(sort:String, descending:Boolean)
		{
			super('scheduler', 'getExecutionData', 'executionData');
			addEventListener(CollectionEvent.COLLECTION_CHANGE, collectionChanged);

			_sort = sort;
			_descending = descending;
		}

        override protected function buildArgs(pageData:Object):Array
        {
            return new Array(pageData, _sort, _descending);
        }

        public function update(execution:Object):Boolean
        {
        	var old:String = _executions[execution.id];
        	if (old == null)
        	{
        		return false;
        	}

            return replace(int(old), execution);
        }

        private function collectionChanged(event:CollectionEvent):void
        {
        	if (event.kind == CollectionEventKind.ADD)
        	{
        		var items:Array = event.items;
	        	for (var key:String in items)
	        	{
	        		var index:int = int(key);
	        		var execution:Object = items[index];
	        		_executions[execution.id] = index + event.location;
	        	}
        	}
        }
	}
}
