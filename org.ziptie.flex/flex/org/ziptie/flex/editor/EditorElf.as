package org.ziptie.flex.editor
{
	import flash.display.DisplayObject;
	
	import mx.containers.TabNavigator;
	import mx.controls.Alert;
	import mx.core.Application;
	
	import org.ziptie.flex.Registry;
	
	public class EditorElf
	{
		public function EditorElf()
		{
		}

        public static function open(type:String, object:Object):Editor
        {
        	var clazz:Class = Registry.editors[type];
        	if (clazz == null)
        	{
        		Alert.show("No open handler for given object type: " + type, "Cannot Open");
        		return null;
        	}

            var content:TabNavigator = Application.application.mainPage.content;

            var editors:Array = content.getChildren();
            for each (var child:DisplayObject in editors)
            {
            	var editor:Editor = child as Editor;
            	if (editor != null && editor.editorType == type && editor.inputEquals(object))
            	{
            		content.selectedChild = editor;
            		return editor;
            	}
            }

            var newEditor:Editor = new clazz();
            newEditor.editorType = type;
            newEditor.input = object;
            content.addChild(newEditor);
            content.selectedChild = newEditor;
            return newEditor;
        }
	}
}