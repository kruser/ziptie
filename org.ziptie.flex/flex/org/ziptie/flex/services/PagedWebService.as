package org.ziptie.flex.services
{
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.collections.errors.ItemPendingError;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.rpc.IResponder;
	import mx.rpc.events.ResultEvent;
	
	public class PagedWebService extends EventDispatcher implements IList
	{
		protected static var PAGE_SIZE:int = 100;

        private var _dataField:String;
        private var _service:String;
        private var _operation:String;

        private var _pages:Object;
        private var _length:int = 1;
        private var _pending:Object = new Object();
        private var _pagesPending:Object = new Object();

        /**
         * @param service The name of the webservice endpoint.
         * @param operation The method name on the webservice.
         * @param dataField The property name of the array field for the pageData object.
         */
		public function PagedWebService(service:String, operation:String, dataField:String)
		{
			_service = service;
            _operation = operation;
            _dataField = dataField;
		}

        /**
         * Subclasses override the to build the webservice call arguments.
         * @param pageData The requested page.
         * @return An array of arguments that will be passed into the webservice as the operation's arguments.
         */ 
        protected function buildArgs(pageData:Object):Array
        {
        	throw new IllegalOperationError("This must be overriden by the subclass");
        }

        private function loadPage(pageNumber:int):void
        {
        	if (_pagesPending[pageNumber] != null)
        	{
        		return;
        	}
        	else
        	{
        		_pagesPending[pageNumber] = true;
        	}

            var page:Object = new Object();
            page.pageSize = PAGE_SIZE;
            page.offset = pageNumber * PAGE_SIZE;
            page[_dataField] = new ArrayCollection();
            page.total = _length;

            WebServiceElf.callWithArgs(_service, _operation, pageResult, buildArgs(page));
            trace("Requested page number " + pageNumber);
        }

        public function get length():int
        {
            return _length;
        }

        public function getItemAt(index:int, prefetch:int=0):Object
        {
            if (_pages == null)
            {
                _pages = new Object();
            }

            var pageNumber:int = index / PAGE_SIZE;

            var page:ArrayCollection = _pages[pageNumber];
            if (page == null)
            {
                if (_pending[index] != null)
                {
                    throw _pending[index] as ItemPendingError;
                }

                var ipe:ItemPendingError = new ItemPendingError("Loading page " + pageNumber);
                _pending[index] = ipe;

                loadPage(pageNumber);

                throw ipe;
            }

            if (page.length == 0)
            {
                return null;
            }

            var offset:int = index % PAGE_SIZE;
            return page.getItemAt(offset);
        }

        /**
         * Call to replace an existing object in the results with a newer one.
         * @param index The index of the old object.
         * @param object The object to replace it with.
         */
        protected function replace(index:int, object:Object):Boolean
        {
        	var pageNumber:int = index / PAGE_SIZE;
        	var offset:int = index % PAGE_SIZE;
        	var page:ArrayCollection = _pages[pageNumber];
        	if (page == null)
        	{
        		return false;
        	}

            page.setItemAt(object, offset);

        	dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.REPLACE, index, index, new Array(object)));
        	return true;
        }

        private function pageResult(event:ResultEvent):void
        {
            var page:Object = event.result;
            var offset:int = page.offset;
            var data:ArrayCollection = page[_dataField];

            var pageNumber:int = offset / PAGE_SIZE;

            trace("Received page number " + pageNumber);
            _pages[pageNumber] = data;

            for (var i:int = 0 ; i < data.length ; i++)
            {
                var ndx:int = i + offset;
                var ipe:ItemPendingError = _pending[ndx];
                if (ipe != null)
                {
                    for each (var responder:IResponder in ipe.responders)
                    {
                        responder.result(data.getItemAt(i));
                    }

                    delete _pending[ndx];
                }
            }

            if (_length != page.total)
            {
                _length = page.total;
                dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.ADD, offset, -1, data.toArray()));
            }
        }

        public function itemUpdated(item:Object, property:Object=null, oldValue:Object=null, newValue:Object=null):void
        {
            throw new IllegalOperationError();
        }
        
        public function getItemIndex(item:Object):int
        {
            throw new IllegalOperationError();
        }
        
        public function addItem(item:Object):void
        {
            throw new IllegalOperationError();
        }
        
        public function addItemAt(item:Object, index:int):void
        {
            throw new IllegalOperationError();
        }
        
        public function removeAll():void
        {
            throw new IllegalOperationError();
        }
        
        public function removeItemAt(index:int):Object
        {
            throw new IllegalOperationError();
        }
        
        public function setItemAt(item:Object, index:int):Object
        {
            throw new IllegalOperationError();
        }
        
        public function toArray():Array
        {
            throw new IllegalOperationError();
        }
	}
}