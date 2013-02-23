package org.ziptie.flex.devices
{
	import mx.collections.ArrayCollection;
	import mx.resources.ResourceManager;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	import org.ziptie.flex.progress.ProgressItem;
	import org.ziptie.flex.search.Devices;
	import org.ziptie.flex.services.WebServiceElf;
	
	public class Remove extends ProgressItem
	{
		private const CONCURRENCY:int = 5;

		private var _toRemove:ArrayCollection;
		private var _complete:int = 0;
		private var _failures:int = 0;
		private var _total:int;

		public function Remove(devices:Array)
		{
			super(ResourceManager.getInstance().getString('messages', 'Remove_progressName'));
            _toRemove = new ArrayCollection(devices);
            _total = _toRemove.length;
		}

        override protected function start():void
        {
        	for (var i:int = 0; i < CONCURRENCY; i++)
        	{
        		if (!removeNext())
        		{
        			return;
        		}
        	}
        }

        private function updateProgress():void
        {
        	var msg:String;
        	if (_failures > 0)
        	{
                ResourceManager.getInstance().getString('messages', 'Remove_status', new Array(_complete, _total, _failures));
        	}
        	else
        	{
                ResourceManager.getInstance().getString('messages', 'Remove_status', new Array(_complete, _total));
            }

        	progress(msg, (_complete * 100) / _total);

            if (_failures + _complete == _total)
            {
            	done();
            }
        }

        override protected function cancel():void
        {
        	_toRemove.removeAll();
        	done();
        }

        override protected function done():void
        {
        	super.done();
        	Devices.instance.go();
        }

        private function onRemove(event:ResultEvent):void
        {
        	_complete++;
            updateProgress();
        	removeNext();
        }

        private function onFault(event:FaultEvent):void
        {
        	WebServiceElf.fault(event);

            _failures++;
            updateProgress();
        	removeNext();
        }

        private function removeNext():Boolean
        {
        	if (_toRemove.length == 0)
        	{
        		return false;
        	}

        	var device:Object = _toRemove.removeItemAt(0);

        	WebServiceElf.callWithFaultHandler(
                    'devices',
                    'deleteDevice',
                    onRemove,
                    onFault,
                    device.ipAddress,
                    device.managedNetwork);

        	return true;
        }
	}
}