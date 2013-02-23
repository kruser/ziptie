package org.ziptie.flex.devices
{
	import mx.collections.ArrayCollection;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import org.ziptie.flex.jobs.RunNowProgressItem;
	import org.ziptie.flex.search.Devices;
	import org.ziptie.flex.services.EventManager;
	import org.ziptie.flex.services.ServerEvent;

    [ResourceBundle('messages')]	
	public class Discovery extends RunNowProgressItem
	{
		private var _existingName:String;
		private var _existingGroup:String;

        private var _addrCsv:String;
        private var _crawl:Boolean;
        private var _subscriberId:int;

        public function Discovery()
        {
			super(ResourceManager.getInstance().getString('messages', 'discovery_jobTitle'));
        }

        public static function newFromExisting(jobName:String, jobGroup:String, jobType:String):Discovery
        {
        	var discovery:Discovery = new Discovery();
        	discovery._existingName = jobName;
        	discovery._existingGroup = jobGroup;
        	return discovery;
        }

        public static function newFromArray(addresses:ArrayCollection, crawl:Boolean):Discovery
		{
			var discovery:Discovery = new Discovery();

			discovery._crawl = crawl;
            discovery._addrCsv = "";
            for each (var addr:String in addresses)
            {
                discovery._addrCsv = discovery._addrCsv.concat(addr, ',');
            }

            return discovery;
		}

        override protected function start():void
        {
        	_subscriberId = EventManager.subscribe('discovery', '*', updateStatus, onSubscribed);
        }

        private function onSubscribed():void
        {
            if (_existingName == null)
            {
		        var rm:IResourceManager = ResourceManager.getInstance();

		        var jobData:Object = new Object();
		        jobData.jobName = rm.getString('messages', 'DiscoveryJob_name');
		        jobData.jobGroup = '_interactive';
		        jobData.jobType = 'Discover Devices';
		        jobData.description = rm.getString('messages', 'DiscoveryJob_description');
		        jobData.persistent = false;
		        jobData.jobParameters = [
		            {key:'addresses', value:_addrCsv},
		            {key:'crawl', value:_crawl}
		        ]

		        runNow(jobData);
            }
            else
            {
            	runExistingNow(_existingName, _existingGroup);
            }

            progress(title, -1);
        }

        private function updateStatus(event:ServerEvent):void
        {
        	var status:XML = event.xml;

            var analyzed:int = status.entry.(@key=='AddressesAnalyzed');
            var queueSize:int = status.entry.(@key=='QueueSize');
            var responded:int = status.entry.(@key=='RespondedToSnmp');

            var args:Array = new Array(queueSize, analyzed, responded);
            var rm:IResourceManager = ResourceManager.getInstance();
        	var msg:String = rm.getString('messages', 'DiscoveryJob_discoveryStatus', args);
        	progress(msg, -1);
        }

        override protected function done():void
        {
            EventManager.unsubscribe(_subscriberId);

            super.done();

            Devices.instance.go();
        }
	}
}
