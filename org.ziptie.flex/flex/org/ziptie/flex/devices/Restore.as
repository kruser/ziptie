package org.ziptie.flex.devices
{
	import com.adobe.utils.DateUtil;
	
	import mx.controls.Alert;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;

	import org.ziptie.flex.DisplayElf;
	import org.ziptie.flex.jobs.JobElf;
	import org.ziptie.flex.jobs.RunNowProgressItem;
	import org.ziptie.flex.services.EventManager;
	import org.ziptie.flex.services.ServerEvent;

	public class Restore extends RunNowProgressItem
	{
		private var _revision:Object;
		private var _device:Object;
		private var _subscriberId:int;

		public function Restore()
		{
			super(ResourceManager.getInstance().getString('messages', 'Restore_progressName'));
		}

        public static function newFromConfig(device:Object, revision:Object):Restore
        {
        	var restore:Restore = new Restore();
        	restore._device = device;
        	restore._revision = revision;
        	return restore;
        }

        override protected function start():void
        {
        	_subscriberId = EventManager.subscribe('restore', 'complete', onComplete, onSubscribe);
        }

        private function onSubscribe():void
        {
            var rm:IResourceManager = ResourceManager.getInstance();

        	var tstamp:String = DateUtil.toW3CDTF(_revision.lastChanged);
        	var job:Object = new Object();
            job.jobName = rm.getString('messages', 'Restore_jobName');
            job.jobGroup = JobElf.RUN_NOW_GROUP;
            job.description = "Restore configuration";
            job.jobType = "Restore Configuration";
            job.persistent = false; 
            job.jobParameters = [
                {key:'ipResolutionScheme', value:'ipCsv'},
                {key:'ipResolutionData', value:_device.ipAddress + '@' + _device.managedNetwork},
                {key:'configPath', value:_revision.path},
                {key:'configTimestamp', value:tstamp}
            ];

        	runNow(job);

        	progress(rm.getString('messages', 'Restore_status'), -1);
        }

        override protected function done():void
        {
        	EventManager.unsubscribe(_subscriberId);
        	super.done();
        }

        private function onComplete(event:ServerEvent):void
        {
        	var payload:XML = event.xml;
            if (execution.id == payload.entry.(@key=='ExecutionId'))
            {
            	var status:String = payload.entry.(@key=='Outcome');
            	if (status != 'SUCCESS')
            	{
            		var detail:String = payload.entry.(@key=='Error');

					var rm:IResourceManager = ResourceManager.getInstance();
					var title:String = rm.getString('messages', 'Restore_error_title');
					var msg:String = rm.getString('messages', 'Restore_error_message', new Array(DisplayElf.format('Device', _device)));
            		ErrorDetails.open(title, msg, status, detail);
            	}
            }
        }
	}
}
