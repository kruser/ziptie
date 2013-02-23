package org.ziptie.flex.tools
{
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.core.Application;
	import mx.rpc.events.ResultEvent;
	import mx.utils.StringUtil;
	
	import org.ziptie.flex.DisplayElf;
	import org.ziptie.flex.editor.EditorElf;
	import org.ziptie.flex.jobs.JobProgressItem;
	import org.ziptie.flex.services.EventManager;
	import org.ziptie.flex.services.ResultElf;
	import org.ziptie.flex.services.ServerEvent;
	import org.ziptie.flex.services.WebServiceElf;

	public class AttachToTool extends JobProgressItem
	{
		private var _pluginDescriptor:PluginDescriptor;
		private var _scriptListener:int = -1;
		private var _reportOpened:Boolean = false;

		public function AttachToTool(executionData:Object)
		{
			super(DisplayElf.format('Job', executionData));
			execution = executionData;
		}

		public function get pluginDescriptor():PluginDescriptor
		{
			return _pluginDescriptor;
		}

        override protected function start():void
        {
        	var inProgress:Boolean = execution.endTime == null;
        	if (inProgress)
        	{
	        	startListening(null);
	
	        	_scriptListener = EventManager.subscribe('plugins', 'script', onScript);
                progress("Attaching to job: " + execution.jobName + "/" + execution.jobGroup, -1);
        	}

            WebServiceElf.call('plugins', 'getExecutionRecord', executionRecord, execution.id);

            if (!inProgress)
            {
            	done();
            }
        }

        override protected function done():void
        {
            EventManager.unsubscribe(_scriptListener);
            super.done();

            if (_pluginDescriptor != null && _pluginDescriptor.outputFormat == 'PDF')
            {
            	openReport();
            }
            else
            {
                WebServiceElf.call('plugins', 'getExecutionDetails', onExecutionDetails, execution.id);
            }
        }

        private function onExecutionDetails(event:ResultEvent):void
        {
            for each (var record:Object in ResultElf.array(event.result))
            {
                dispatchEvent(new PluginRecordEvent(record.id, record.gridData, record.ipAddress, record.managedNetwork));
            }
        }

        private function openReport():void
        {
        	if (_reportOpened)
        	{
        		return;
        	}

        	_reportOpened = true;

            var url:String = StringUtil.substitute(
                    '{0}/pluginDetail?executionId={1}&format=pdf',
                    Application.application.server,
                    execution.id);
            navigateToURL(new URLRequest(url));
        }

        private function onScript(event:ServerEvent):void
        {
            var xml:XML = event.xml;
            if (xml.entry.(@key=='ExecutionId') == execution.id)
            {
                var gridData:String = xml.entry.(@key=='GridData');
                var id:int = int(xml.entry.(@key=='RecordId'));
                var ip:String = xml.entry.(@key=="IpAddress");
                var net:String = xml.entry.(@key=="ManagedNetwork");

                dispatchEvent(new PluginRecordEvent(id, gridData, ip == '' ? null : ip, net == '' ? null : net));
            }
        }

        private function onPluginDescriptor(pd:PluginDescriptor):void
        {
        	_pluginDescriptor = pd;

        	if (_pluginDescriptor.pluginType == 'script')
            {
                EditorElf.open('Plugin Output', this);
            }
            else if (execution.endTime != null)
        	{
            	openReport();
            }
        }

        private function executionRecord(event:ResultEvent):void
        {
            var execRecord:Object = event.result;
            PluginElf.getPluginDescriptor(execRecord.pluginName, onPluginDescriptor);
        }
	}
}