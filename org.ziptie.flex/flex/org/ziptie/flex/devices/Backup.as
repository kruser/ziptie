package org.ziptie.flex.devices
{
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import org.ziptie.flex.jobs.RunNowProgressItem;
	import org.ziptie.flex.services.EventManager;
	import org.ziptie.flex.services.ServerEvent;
	
	public class Backup extends RunNowProgressItem
	{
        private var _scheme:String;
        private var _data:String;

        private var _existingName:String;
        private var _existingGroup:String;

        private var _subscriberId:int;

        private var _complete:int = 0;
        private var _failures:int = 0;
        private var _total:int = 0;

        public function Backup()
        {
        	super(ResourceManager.getInstance().getString('messages', 'BackupDevicesJob_title'));
        }

        public static function newFromExisting(jobName:String, jobGroup:String, jobType:String):Backup
        {
            var backup:Backup = new Backup();
            backup._existingName = jobName;
            backup._existingGroup = jobGroup;
            return backup;
        }

        public static function newFromScheme(scheme:String, data:String):Backup
        {
            var backup:Backup = new Backup();
        	backup._scheme = scheme;
        	backup._data = data;
            return backup;
        }

		public static function newFromArray(devices:Array):Backup
		{
            var scheme:String = 'ipCsv';
			var data:String = "";
            for each (var device:Object in devices)
            {
                data += device.ipAddress + '@' + device.managedNetwork + ',';
            }

            return newFromScheme(scheme, data);
		}

        override protected function start():void
        {
        	_subscriberId = EventManager.subscribe('backup', '*', onEvent, onSubscribed);
        }

        private function onSubscribed():void
        {
            var rm:IResourceManager = ResourceManager.getInstance();

            if (_existingName == null)
            {
	            var jobData:Object = new Object();
	            jobData.jobName = rm.getString('messages', 'BackupDevicesJob_backupJobName');
	            jobData.jobGroup = '_interactive';
	            jobData.jobType = 'Backup Configuration';
	            jobData.description = rm.getString('messages', 'BackupDevicesJob_jobData_description');
	            jobData.persistent = false;
	            jobData.jobParameters = [
	                {key:'ipResolutionScheme', value:_scheme},
	                {key:'ipResolutionData', value:_data}
	            ];
	
	            runNow(jobData);
            }
            else
            {
            	runExistingNow(_existingName, _existingGroup);
            }
        }

        override protected function done():void
        {
        	EventManager.unsubscribe(_subscriberId);

        	super.done();
        }

        private function onEvent(event:ServerEvent):void
        {
            var payload:XML = event.xml;

            if (execution.id == payload.entry.(@key=='ExecutionId'))
            {
            	if (event.type == 'complete')
            	{
	            	var result:String = payload.entry.(@key=='Result');
	            	if (result != "SUCCESS")
	            	{
	            		_failures++;
	            	}
	            	_complete++;
            	}
            	else if (event.type == 'started')
            	{
	                _total = payload.entry.(@key=='TotalDevices');
            	}

            	var params:Array = new Array(_complete, _total, _failures);
            	var rm:IResourceManager = ResourceManager.getInstance(); 
            	var msg:String = rm.getString('messages', 'BackupDevicesJob_progress', params);
            	progress(msg, (_complete * 100) / _total);
            }
        }
	}
}
