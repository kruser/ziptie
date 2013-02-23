package org.ziptie.flex.services
{
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.events.CloseEvent;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	import mx.rpc.AbstractOperation;
	import mx.rpc.AsyncToken;
	import mx.rpc.Responder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	import org.ziptie.flex.devices.ErrorDetails;

	/**
	 * Provides a cache of web service bindings so that we don't have to reload 
	 * the WSDLs or XSDs anytime we want to call a webservice.
	 */
	public class WebServiceElf
	{
		private static var _services:Object = new Object();

		public function WebServiceElf()
		{
		}

        public static function callWithArgs(serviceName:String, method:String, callback:Function, args:Array):AsyncToken
        {
            var op:AbstractOperation = getService(serviceName).getOperation(method);
        	op.arguments = args;
            var token:AsyncToken = op.send();
            token.addResponder(new Responder((callback == null ? eatResult : callback), fault));
            return token;
        }

        public static function callWithFaultHandler(serviceName:String, method:String, callback:Function, onFault:Function, ... args):AsyncToken
        {
        	var op:AbstractOperation = getService(serviceName).getOperation(method);
            op.arguments = args;
            var token:AsyncToken = op.send();
            token.addResponder(new Responder((callback == null ? eatResult : callback), onFault));
            return token;
        }

        public static function call(serviceName:String, method:String, callback:Function, ... args):AsyncToken
        {
        	return callWithArgs(serviceName, method, callback, args);
        }

        private static function getService(name:String):WebService
        {
        	var service:WebService = _services[name];
        	if (service == null)
        	{
        		service = new WebService();
                service.wsdl = Application.application.server + '/server/' + name + '?wsdl';
                service.loadWSDL();

                _services[name] = service;
        	}

        	return service;
        }

        public static function fault(event:FaultEvent):void
        {
            if (!event.fault.hasOwnProperty('element'))
            {
                callWithFaultHandler('security', 'getCurrentUser', error, timeout);
            }
            else
            {
                var elem:XML = event.fault['element'];

                var ns:Namespace = new Namespace('ns', "http://jax-ws.dev.java.net/");
                elem.addNamespace(ns);

                var ex:XMLList = elem.detail.ns::exception;
            	var msg:String = ex.message;
            	var cause:XMLList = ex.ns::cause;
            	if (cause.length() == 0)
            	{
            		cause = ex;
            	}

                var stack:String = cause.attribute('class') + ': ' + cause.message + '\n';
            	var frames:XMLList = cause.ns::stackTrace.ns::frame;
            	for each (var frame:XML in frames)
            	{
            		stack += '  at ' + frame.attribute('class') + '.' + frame.@method + '(' + frame.@file + ':' + frame.@line + ')\n';
            	}
            	ErrorDetails.open(ResourceManager.getInstance().getString('messages', 'error'), msg, null, stack);
            }
        }

        private static function error(event:ResultEvent):void
        {
            var rm:IResourceManager = ResourceManager.getInstance();
            var title:String = rm.getString("messages", 'error');
            var msg:String = rm.getString('messages', 'WebServiceElf_serverError');
            Alert.show(msg, title);
        }

        private static function timeout(event:FaultEvent):void
        {
            var rm:IResourceManager = ResourceManager.getInstance();
            var title:String = rm.getString("messages", 'WebServiceElf_timeoutTitle');
            var msg:String = rm.getString('messages', 'WebServiceElf_connectionTimedOut');
            Alert.show(msg, title, 4, null, logout);
        }

        private static function logout(event:CloseEvent):void
        {
            navigateToURL(new URLRequest(Application.application.server), '_self');
        }

        private static function eatResult(event:ResultEvent):void
        {
        }
	}
}
