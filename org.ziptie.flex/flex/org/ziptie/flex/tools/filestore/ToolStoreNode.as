package org.ziptie.flex.tools.filestore
{
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.rpc.AbstractOperation;
	import mx.rpc.events.ResultEvent;
	import mx.utils.ObjectUtil;
	
	import org.ziptie.flex.services.ResultElf;
	import org.ziptie.flex.services.WebServiceElf;
	
	public class ToolStoreNode
	{
        private var _children:ArrayCollection;
		public var path:String;
        public var loaded:Boolean = false;

		public function ToolStoreNode(path:String)
		{
			this.path = path;
		}

        public function get isFolder():Boolean
        {
        	return path.charAt(path.length - 1) == '/';
        }

        public function get label():String
        {
        	var start:int;
        	var end:int;
        	if (path.charAt(path.length-1) == '/')
        	{
        		start = path.lastIndexOf('/', path.length - 2) + 1;
        		end = path.length - 1;
        	}
        	else
        	{
        		start = path.lastIndexOf('/') + 1;
        		end = path.length;
        	}
        	return path.substring(start, end);
        }

        public function get children():ArrayCollection
        {
        	if (_children == null)
        	{
        		_children = new ArrayCollection();

                WebServiceElf.call('plugins', 'getFileStoreEntries', onResult, path);
        	}

        	return _children;
        }

        public function onResult(event:ResultEvent):void
        {
            _children.sort = new Sort();
            _children.sort.compareFunction = compare;
            _children.refresh();

            for each (var child:String in ResultElf.array(event))
            {
            	_children.addItem(new ToolStoreNode(path + child));
            }
            loaded = true;
        }

        private function compare(a:ToolStoreNode, b:ToolStoreNode, fields:Array = null):int
        {
        	if (a.isFolder && !b.isFolder)
        	{
        		return -1;
        	}
        	else if (!a.isFolder && b.isFolder)
        	{
        		return 1;
        	}

            return ObjectUtil.stringCompare(a.label, b.label, true);
        }
	}
}