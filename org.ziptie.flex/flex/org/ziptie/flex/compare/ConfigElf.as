package org.ziptie.flex.compare
{
	import mx.collections.ArrayCollection;
	
	import org.ziptie.flex.services.ResultElf;
	
	public class ConfigElf
	{
		public function ConfigElf()
		{
		}

        public static function flattenChangeLogs(changeLogs:ArrayCollection):ArrayCollection
        {
            var configs:ArrayCollection = new ArrayCollection();
            for each (var changeLog:Object in changeLogs)
            {
                var timestamp:Date = changeLog.timestamp;
                var changes:ArrayCollection = ResultElf.array(changeLog.changes);
                for each (var change:Object in changes)
                {
                    configs.addItem({path:change.path, lastChanged:timestamp});
                }
            }
            return configs;
        }
	}
}