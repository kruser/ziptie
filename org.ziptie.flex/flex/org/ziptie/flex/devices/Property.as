package org.ziptie.flex.devices
{
    public class Property
    {
        private var _name:String;
        private var _value:String;

        public function Property(name:String, value:String)
        {
            _name= name;
            _value = value;
        }

        public function get name():String
        {
            return _name;
        }

        public function get value():String
        {
            return _value;
        }
    }
}