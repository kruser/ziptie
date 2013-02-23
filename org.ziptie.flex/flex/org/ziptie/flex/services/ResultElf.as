package org.ziptie.flex.services
{
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	public class ResultElf
	{
		public function ResultElf()
		{
		}

        public static function array(object:Object):ArrayCollection
        {
            if (object is ResultEvent)
            {
            	object = ResultEvent(object).result;
            }

        	if (object == null)
        	{
        		return new ArrayCollection();
        	}
        	else if (object is Array)
        	{
        		return new ArrayCollection(object as Array);
        	}
        	else if (object is ArrayCollection)
        	{
        		return object as ArrayCollection;
        	}
        	else
        	{
        		var ac:ArrayCollection = new ArrayCollection();
        		ac.addItem(object);
        		return ac;
        	}
        }
	}
}