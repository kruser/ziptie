package org.ziptie.flex.jobs
{
	import mx.rpc.events.ResultEvent;
	
	import org.ziptie.flex.services.WebServiceElf;
	
	public class RunNowProgressItem extends JobProgressItem
	{
		private var _jobData:Object;
		private var _jobName:String;
		private var _jobGroup:String;

		public function RunNowProgressItem(title:String)
		{
			super(title);
		}

        protected function runNow(jobData:Object):void
        {
        	_jobData = jobData;
        	startListening(doRunNow);
        }

        private function doRunNow():void
        {
            WebServiceElf.call('scheduler', 'runNow', onStart, _jobData);
            _jobData = null;
        }

        protected function runExistingNow(jobName:String, jobGroup:String):void
        {
        	_jobName = jobName;
        	_jobGroup = jobGroup;
            startListening(doRunExistingNow);
        }

        private function doRunExistingNow():void
        {
            WebServiceElf.call('scheduler', 'runExistingJobNow', onStart, _jobName, _jobGroup);
            _jobName = null;
            _jobGroup = null;
        }

        protected function started():void
        {
        }

        private function onStart(event:ResultEvent):void
        {
        	execution = event.result;
            started();
        }
	}
}