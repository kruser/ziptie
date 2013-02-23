package org.ziptie.flex.jobs
{
	import mx.collections.ArrayCollection;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	import mx.rpc.events.ResultEvent;
	
	import org.ziptie.flex.services.EventManager;
	import org.ziptie.flex.services.ResultElf;
	import org.ziptie.flex.services.ServerEvent;
	import org.ziptie.flex.services.WebServiceElf;
	
	public class JobElf
	{
		public static const RUN_NOW_GROUP:String = '_interactive';
        private static var _jobs:ArrayCollection;
        private static var _jobsByNameGroup:Object = new Object();
        
        private static var minutesSeconds:RegExp = /^(\*|[1-5]?\d|([1-5]?\d|\*)[-\/][1-5]?\d|([1-5]?\d,)+[1-5]?\d)$/;
        private static var hours:RegExp = /^(\*|[1-2]?\d|([1-2]?\d|\*)[-\/][1-2]?\d|([1-2]?\d,)+[1-2]?\d)$/;
        private static var dayOfMonth:RegExp = /^([*?LWC]|[1-3]?\d[LWC]?|([1-3]?\d|\*)[-\/][1-3]?\d|([1-3]?\d,)+[1-3]?\d|LW)$/;
        private static var month:RegExp = /^(\*|(1?\d|(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC))|(1?\d|\*)[-\/]1?\d|((1?\d|(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)),)+(1?\d|(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC))|(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)\-(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC))$/;
        private static var dayOfWeek:RegExp = /^([*?L]|(SUN|MON|TUE|WED|THU|FRI|SAT)|[1-7]?\d[LC]?|([1-7]|\*|(SUN|MON|TUE|WED|THU|FRI|SAT))[-\/#]([1-7]|(SUN|MON|TUE|WED|THU|FRI|SAT))|(([1-7]|(SUN|MON|TUE|WED|THU|FRI|SAT)),)+([1-7]|(SUN|MON|TUE|WED|THU|FRI|SAT)))$/;
		private static var year:RegExp = /^(\*|\d{4}|(\d{4}|\*)[-\/]\d{4}|(\d{4},)+\d{4})$/;
		
		public function JobElf()
		{
		}

        public static function getJobGroupDisplayName(group:String):String
        {
        	if (group == JobElf.RUN_NOW_GROUP)
            {
                return ResourceManager.getInstance().getString('messages', 'interactiveGroup');
            }
            else if (group.charAt(0) == "_")
            {
                return ResourceManager.getInstance().getString('messages', 'internalGroup');
            }
            return group;
        }

        public static function setParam(job:Object, key:String, value:String):void
        {
        	var isSet:Boolean = false;

        	var params:ArrayCollection = ResultElf.array(job.jobParameters);
            for each (var param:Object in params)
            {
                if (param.key == key)
                {
                    param.value = value;
                    isSet = true;
                }
            }

            if (!isSet)
            {
            	params.addItem({key: key, value: value});
            	job.jobParameters = params;
            }
        }

        public static function getParam(job:Object, key:String):String
        {
        	for each (var param:Object in ResultElf.array(job.jobParameters))
        	{
        		if (param.key == key)
        		{
        			return param.value;
        		}
        	}

        	return null;
        }

        public static function get allJobs():ArrayCollection
        {
        	if (_jobs == null)
        	{
        		_jobs = new ArrayCollection();
	            EventManager.subscribe('scheduler', '*', jobChanged, onSubscribe);
        	}
        	return _jobs;
        }

        private static function onSubscribe():void
        {
            WebServiceElf.call('scheduler', 'getJobGroupNames', groups);
        }

        public static function validateNewName(jobName:String, jobGroup:String):Object
        {
            var nameError:String;
            var groupError:String;

            var resourceManager:IResourceManager = ResourceManager.getInstance();
            var nameRegex:RegExp = new RegExp('^' + resourceManager.getString('messages', 'JobNamePage_nameRegex') + '$');
            var groupRegex:RegExp = new RegExp('^' + resourceManager.getString('messages', 'JobNamePage_groupRegex') + '$');

            if (exists(jobName, jobGroup))
            {
                nameError = 'JobNameValidator_jobAlreadyExists';
            }
            else
            {
	            if (jobName == '')
	            {
	                nameError = 'JobNamePage_mustSpecifyName';
	            }
	            else if (jobName.match(nameRegex) == null)
	            {
	                nameError = 'JobNamePage_invalidJobName';
	            }

	            if (jobGroup == '')
	            {
	                groupError = 'JobNamePage_mustSpecifyGroup';
	            }
	            else if (jobGroup.match(groupRegex) == null)
	            {
	                groupError = 'JobNamePage_invalidGroup';
	            }
            }

            if (nameError == null && groupError == null)
            {
            	return null;
            }

            var result:Object = new Object();
            if (nameError != null)
            {
            	result.nameError = resourceManager.getString('messages', nameError);
            }

            if (groupError != null)
            {
                result.groupError = resourceManager.getString('messages', groupError);
            }

            return result;
        }

        private static function exists(jobName:String, jobGroup:String):Boolean
        {
            return _jobsByNameGroup[jobName + ':' + jobGroup] != null;
        }

        private static function jobChanged(event:ServerEvent):void
        {
            if (event.type == 'job.added')
            {
                WebServiceElf.call('scheduler', 'getJobMetadataByGroup', jobsResult, event.xml.entry.(@key=='job.group'));
            }
            else if (event.type == 'job.deleted')
            {
                var payload:XML = event.xml;
                var jobName:String = payload.entry.(@key=='job.name');
                var jobGroup:String = payload.entry.(@key=='job.group');

                var key:String = jobName + ':' + jobGroup;

                var job:Object = _jobsByNameGroup[key];
                if (job != null)
                {
                    delete _jobsByNameGroup[key];

                    var ndx:int = _jobs.getItemIndex(job);
                    if (ndx >= 0)
                    {
                        _jobs.removeItemAt(ndx);
                    }
                }
            }
        }

        private static function groups(event:ResultEvent):void
        {
            for each (var group:String in ResultElf.array(event))
            {
                WebServiceElf.call('scheduler', 'getJobMetadataByGroup', jobsResult, group);
            }
        }

        private static function jobsResult(event:ResultEvent):void
        {
            for each (var job:Object in ResultElf.array(event))
            {
                var key:String = job.jobName + ":" + job.jobGroup;

                if (_jobsByNameGroup[key] == null)
                {
                    _jobs.addItem(job);
                    _jobsByNameGroup[key] = job;
                }
            }
        }
        
     	/**
     	 * Returns true if the Quartz cron expression argument is valid. Returns
     	 * false otherwise.
     	 * 
     	 * See http://quartz.sourceforge.net/javadoc/org/quartz/CronTrigger.html
     	 */
        public static function validateCronExpression(cron:String):Boolean
        {
        	var cronSections:Array = cron.split(/\s+/);
        	var len:int = cronSections.length;
        	if (len == 6 || len == 7)
        	{
        		if (!minutesSeconds.test(cronSections[0])) { return false; }
        		else if (!minutesSeconds.test(cronSections[1])) { return false; }
        		else if (!hours.test(cronSections[2])) { return false; }
        		else if (!dayOfMonth.test(cronSections[3])) { return false; }
        		else if (!month.test(cronSections[4])) { return false; }
        		else if (!dayOfWeek.test(cronSections[5])) { return false; }
        		else if (len == 7 && !year.test(cronSections[6])) { return false; }
        		else { return true; }
        	}
        	return false;
        }

	}
}
