package org.ziptie.flex.jobs
{
	import org.ziptie.flex.progress.ProgressItem;
	import org.ziptie.flex.services.EventManager;
	import org.ziptie.flex.services.ServerEvent;
	import org.ziptie.flex.services.WebServiceElf;

	public class JobProgressItem extends ProgressItem
	{
        private var _execution:Object;
        private var _eventListenerId:int;

		public function JobProgressItem(title:String)
		{
			super(title);
		}

        public function set execution(execution:Object):void
        {
        	_execution = execution;
        }

        public function get execution():Object
        {
            return _execution;
        }

        protected function startListening(onListen:Function):void
        {
        	_eventListenerId = EventManager.subscribe('scheduler.trigger', 'complete', onComplete, onListen);
        }

        override protected function cancel():void
        {
            WebServiceElf.call('scheduler', 'interruptJob', null, _execution.id);
        }

        override protected function done():void
        {
            EventManager.unsubscribe(_eventListenerId);

            super.done();
        }

        private function onComplete(event:ServerEvent):void
        {
            if (_execution.id == event.object.id)
            {
                done();
            }
        }
	}
}