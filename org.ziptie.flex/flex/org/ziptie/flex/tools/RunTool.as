package org.ziptie.flex.tools
{
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	import mx.rpc.events.ResultEvent;
	import mx.utils.StringUtil;
	
	import org.ziptie.flex.editor.EditorElf;
	import org.ziptie.flex.jobs.JobElf;
	import org.ziptie.flex.jobs.RunNowProgressItem;
	import org.ziptie.flex.services.EventManager;
	import org.ziptie.flex.services.ResultElf;
	import org.ziptie.flex.services.ServerEvent;
	import org.ziptie.flex.services.WebServiceElf;

	public class RunTool extends RunNowProgressItem
	{
		private static const REPORT:String = 'BIRT Report';
		private static const SCRIPT:String = 'Script Tool Job';

        public var pluginDescriptor:PluginDescriptor;

        private var _existingName:String;
        private var _existingGroup:String;

        private var _toolName:String;
		private var _devices:String;
		private var _inputs:Object;
		private var _total:int;
		private var _complete:int;

		private var _scriptListener:int;
		private var _startListener:int;

		private var _type:String;
		private var _didStart:Boolean = false;
		private var _numSubscribes:int = 0;

        public function RunTool(name:String)
        {
        	super(name);
        }

        public static function newFromExisting(jobName:String, jobGroup:String, jobType:String, pd:PluginDescriptor = null):RunTool
        {
        	var tool:RunTool = new RunTool(jobName + '/' + jobGroup);
        	tool._existingName = jobName;
        	tool._existingGroup = jobGroup;
        	tool._type = jobType;
        	tool.pluginDescriptor = pd;
        	return tool;
        }

		public static function newFromArray(pd:PluginDescriptor, devices:Array, inputs:Object = null):RunTool
		{
			var tool:RunTool = new RunTool(pd.toolName);

			tool._devices = '';
			for each (var device:Object in devices)
			{
				tool._devices += device.ipAddress + '@' + device.managedNetwork + ',';
			}

			tool._inputs = inputs;
			tool._toolName = pd.toolName;

            tool.pluginDescriptor = pd;
            if (pd.pluginType == 'report')
            {
                tool._type = REPORT;
            }
            else
            {
                tool._type = SCRIPT;
            }

			return tool;
		}

        override protected function start():void
        {
        	if (pluginDescriptor == null && _type == SCRIPT)
        	{
        		loadPluginDescriptor();
        	}

        	_scriptListener = EventManager.subscribe('plugins', 'script', onScript, onSubscribe);
        	_startListener = EventManager.subscribe('plugins', 'started', onStarted, onSubscribe);
        }
        private function onSubscribe():void
        {
        	_numSubscribes++;
        	if (_numSubscribes < 2)
        	{
        		return;
        	}

        	var rm:IResourceManager = ResourceManager.getInstance();

            if (_existingName == null)
            {
	        	var job:Object = new Object();
	        	job.jobName = _toolName;
	        	job.jobGroup = JobElf.RUN_NOW_GROUP;
	        	job.jobType = _type;
	        	job.description = rm.getString('messages', 'ScriptToolJob_description');
	        	job.persistent = false;
	            job.jobParameters = new ArrayCollection();
	
	            JobElf.setParam(job, 'tool', _toolName);
	            JobElf.setParam(job, 'ipResolutionScheme', 'ipCsv');
	            JobElf.setParam(job, 'ipResolutionData', _devices);
	
	            if (_inputs != null)
	            {
		            for (var key:String in _inputs)
		            {
		            	JobElf.setParam(job, key, _inputs[key]);
		            }
	            }
	
	            runNow(job);
            }
            else
            {
            	runExistingNow(_existingName, _existingGroup);
            }

            progress("Running tool", -1);
        }

        private function loadPluginDescriptor():void
        {
        	WebServiceElf.call('scheduler', 'getJob', onJob, _existingName, _existingGroup);
        }

        private function onJob(event:ResultEvent):void
        {
        	var job:Object = event.result;
        	var toolName:String = JobElf.getParam(job, 'tool');
        	PluginElf.getPluginDescriptor(toolName, onPluginDescriptor);
        }

        private function onPluginDescriptor(pd:PluginDescriptor):void
        {
        	pluginDescriptor = pd;
        	if (_didStart)
        	{
                EditorElf.open('Plugin Output', this);
        	}
        }

        override protected function started():void
        {
        	_didStart = true;
            if (_type == SCRIPT && pluginDescriptor != null)
            {
                EditorElf.open('Plugin Output', this);
            }
        }

        override protected function done():void
        {
            EventManager.unsubscribe(_scriptListener);
            EventManager.unsubscribe(_startListener);
            super.done();

            if (_type == REPORT)
            {
            	var url:String = StringUtil.substitute('{0}/pluginDetail?executionId={1}&format=pdf', Application.application.server, execution.id);
                navigateToURL(new URLRequest(url));
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

        private function onStarted(event:ServerEvent):void
        {
        	var xml:XML = event.xml;
            if (xml.entry.(@key=='ExecutionId') == execution.id)
            {
            	_total = int(xml.entry.(@key=='TotalDevices'));
            	updateProgress();
            }
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

                _complete++;
                updateProgress();
            }
        }

        private function updateProgress():void
        {
            var params:Array = [_complete, _total];
            progress(ResourceManager.getInstance().getString('messages', 'RunTool_progress', params), (_complete * 100) / _total);
        }
	}
}
