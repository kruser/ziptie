package org.ziptie.flex.progress
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.managers.PopUpManager;
	
	public class ProgressManager extends EventDispatcher
	{
		private static var _progressDialog:ProgressDialog;

		[Bindable]
		public static var progressItems:ArrayCollection = new ArrayCollection();

		public function ProgressManager()
		{
		}

        public static function run(item:ProgressItem, showDialog:Boolean = true):void
        {
            if (_progressDialog == null && showDialog)
            {
	        	_progressDialog = PopUpManager.createPopUp(Application.application.mainPage, ProgressDialog, true) as ProgressDialog;
	        	PopUpManager.centerPopUp(_progressDialog);
	        	_progressDialog.addEventListener(Event.REMOVED, onClose);
            }

            progressItems.addItem(item);
            item.addEventListener(Event.COMPLETE, onComplete);

        	item.doStart();
        }

        private static function onComplete(event:Event):void
        {
        	var ndx:int = progressItems.getItemIndex(event.target);
        	if (ndx >= 0)
        	{
        		progressItems.removeItemAt(ndx);
        	}
        }

        private static function onClose(event:Event):void
        {
        	_progressDialog = null;
        }
	}
}