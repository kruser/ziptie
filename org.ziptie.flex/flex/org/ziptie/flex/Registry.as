package org.ziptie.flex
{
	import mx.resources.ResourceManager;
	
	import org.ziptie.flex.compare.DiffEditor;
	import org.ziptie.flex.devices.Backup;
	import org.ziptie.flex.devices.BackupJobEditor;
	import org.ziptie.flex.devices.CreateBackupJob;
	import org.ziptie.flex.devices.DeviceDetail;
	import org.ziptie.flex.devices.Discovery;
	import org.ziptie.flex.devices.NeighborsEditor;
	import org.ziptie.flex.tools.CheckboxInputContributor;
	import org.ziptie.flex.tools.ComboInputContributor;
	import org.ziptie.flex.tools.CreateReportJob;
	import org.ziptie.flex.tools.CreateToolJob;
	import org.ziptie.flex.tools.DateTimeInputContributor;
	import org.ziptie.flex.tools.GridInputContributor;
	import org.ziptie.flex.tools.HiddenInputContributor;
	import org.ziptie.flex.tools.IpAddressInputContributor;
	import org.ziptie.flex.tools.ListInputContributor;
	import org.ziptie.flex.tools.PasswordInputContributor;
	import org.ziptie.flex.tools.RunTool;
	import org.ziptie.flex.tools.StringInputContributor;
	import org.ziptie.flex.tools.ToolJobEditor;
	import org.ziptie.flex.tools.ToolOutputEditor;
	import org.ziptie.flex.tools.ValidatePasswordInputContributor;
	import org.ziptie.flex.tools.filestore.ToolStoreInputContributor;
	
	[ResourceBundle('messages')]
	public final class Registry
	{
		[Embed(source='/img/back2.png')]
		public static var backupPng:Class;
		[Embed(source='/img/find.png')]
		public static var deviceDiscoveryPng:Class;
		[Embed(source='/img/find_off.png')]
        public static var deviceDiscoveryOffPng:Class;
		[Embed(source='/wrench.png')]
		public static var wrenchPng:Class;
		[Embed(source='/img/wrench_off.png')]
        public static var wrenchOffPng:Class;
		[Embed(source='/report.png')]
        public static var reportPng:Class;
        [Embed(source='/img/restore.png')]
        public static var restorePng:Class;
        [Embed(source='/credentials.png')]
        public static var credsPng:Class;
        [Embed(source='/adapterdiagnostic.png')]
        public static var adapterDiagPng:Class;
        [Embed(source='/schedulerfilters.png')]
        public static var schedulerfilterPng:Class;
        [Embed(source='/discovery.png')]
        public static var discoveryPng:Class;
        [Embed(source='/adddevice.png')]
        public static var adddevicePng:Class;
		[Embed(source='/devicetags.png')]
        public static var devicetagsPng:Class;
        [Embed(source='/launcher.png')]
        public static var urllauncherPng:Class;
        [Embed(source='/protocols.png')]
        public static var protocolsPng:Class;
        [Embed(source='/cal.png')]
        public static var calPng:Class;        
        [Embed(source='/find.png')]
        public static var findPng:Class;
        [Embed(source='/report24.png')]
        public static var report24png:Class;
        [Bindable]
        [Embed(source='/img/openjob.png')]
        public static var openJobPng:Class;
		[Embed(source='/img/openjob_off.png')]
        public static var openJobOffPng:Class;
        [Bindable] 
        [Embed(source='/backup2.png')]
        public static var backup2Png:Class; 
                
		public static var displayBindingDefaults:Object = {
            'Device':'{hostname} - {ipAddress}',
            'Neighbors':'{hostname} - ' + ResourceManager.getInstance().getString('messages', 'Registry_neighbors'),
            'Config':'{device.hostname} - {revision.path}',
            'Job':'{jobGroup}/{jobName}',
            'Plugin Output':'{pluginDescriptor.toolName}',
            'Diff':ResourceManager.getInstance().getString('messages', 'Registry_diff')
        };

        public static var defaultDeviceColumns:Array = [
            {name:'backupStatus', width:25},
        	{name:'ipAddress', width:125},
        	{name:'hostname'},
        	{name:'adapterId'},
        	{name:'model'}
        ];

		public static var inputTypeContributors:Object = {
		    string: StringInputContributor,
		    ipAddress: IpAddressInputContributor,
		    password: PasswordInputContributor,
            passwordValidate: ValidatePasswordInputContributor,
            datetime: DateTimeInputContributor,
            checkbox: CheckboxInputContributor,
            hidden: HiddenInputContributor,
            combo: ComboInputContributor,
            list: ListInputContributor,
            grid: GridInputContributor,
            toolStoreBrowser: ToolStoreInputContributor
		};

        public static var jobTypes:Object = {
        	'Backup Configuration':{
        		icon:backupPng,
        		displayName:ResourceManager.getInstance().getString('messages', 'jobTypes_backup'),
        		create:CreateBackupJob.run,
        		schedulePermission:'org.ziptie.job.backup.cudPermission',   
        		runPermission:'org.ziptie.job.backup.runPermission',
        		runExisting: Backup.newFromExisting
            },
            'Discover Devices':{
                icon:deviceDiscoveryPng,
                displayName:ResourceManager.getInstance().getString('messages', 'jobTypes_discovery'),
                schedulePermission:'org.ziptie.job.discovery.cudPermission',   
                runPermission:'org.ziptie.job.discovery.runPermission',
                runExisting: Discovery.newFromExisting
            },
            'Script Tool Job':{
            	icon:wrenchPng,
            	displayName:ResourceManager.getInstance().getString('messages', 'jobTypes_tool'),
            	create:CreateToolJob.run,
            	schedulePermission:'org.ziptie.job.plugin.cudPermission',   
                runPermission:'org.ziptie.job.plugin.runPermission',
            	runExisting: RunTool.newFromExisting
            },
            'BIRT Report':{
                icon:reportPng,
                displayName:ResourceManager.getInstance().getString('messages', 'jobTypes_report'),
                create:CreateReportJob.run,
                schedulePermission:'org.ziptie.job.plugin.cudPermission',   
                runPermission:'org.ziptie.job.plugin.runPermission',
                runExisting: RunTool.newFromExisting
            },
            'Restore Configuration':{
                icon:restorePng,
                schedulePermission:'org.ziptie.job.restore.cudPermission',   
                runPermission:'org.ziptie.job.restore.runPermission',
                displayName:ResourceManager.getInstance().getString('messages', 'jobTypes_restore')
            }
        };

        public static var editors:Object = {
        	'Job:Script Tool Job':ToolJobEditor,
        	'Job:BIRT Report':ToolJobEditor,
        	'Job:Backup Configuration':BackupJobEditor,
        	'Device':DeviceDetail,
        	'Config':ConfigEditor,
        	'Neighbors':NeighborsEditor,
        	'Plugin Output':ToolOutputEditor,
        	'Diff':DiffEditor
        };

		public function Registry()
		{
		}
	}
}