package org.ziptie.flex.tools.filestore
{
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.controls.treeClasses.ITreeDataDescriptor;
	import mx.rpc.AbstractOperation;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	import org.ziptie.flex.services.WebServiceElf;

	public class ToolStoreDataDescriptor implements ITreeDataDescriptor
	{
        public function ToolStoreDataDescriptor()
        {
		}

		public function getChildren(node:Object, model:Object=null):ICollectionView
		{
			var tsn:ToolStoreNode = ToolStoreNode(node);
            if (!tsn.isFolder)
            {
                return null;
            }
           
            return ToolStoreNode(node).children;
		}

		public function hasChildren(node:Object, model:Object=null):Boolean
		{
            var tsn:ToolStoreNode = ToolStoreNode(node);
            if (!tsn.isFolder)
            {
            	return false;
            }
			return !tsn.loaded || (tsn.loaded && tsn.children.length > 0)
		}

		public function isBranch(node:Object, model:Object=null):Boolean
		{
			return ToolStoreNode(node).isFolder;
		}

		public function getData(node:Object, model:Object=null):Object
		{
			return null;
		}

		public function addChildAt(parent:Object, newChild:Object, index:int, model:Object=null):Boolean
		{
			return false;
		}
		
		public function removeChildAt(parent:Object, child:Object, index:int, model:Object=null):Boolean
		{
			return false;
		}
    }
}
