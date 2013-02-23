package org.ziptie.flex.tags
{
	[Bindable]
	public class Tag
	{
		public var name:String;
		public var applied:Boolean;
		private var _create:Boolean;
		private var _origApplied:Boolean;
 
		public function Tag(name:String, applied:Boolean = true, create:Boolean = false)
		{
			this.name = name;
			this.applied = applied;
            _origApplied = applied;
			_create = create;
		}

        public function get remove():Boolean
        {
        	return !applied && _origApplied;
        }

        public function get add():Boolean
        {
        	return applied && _create || applied && !_origApplied;
        }

        public function get create():Boolean
        {
        	return _create;
        }
	}
}