package vk {
  import flash.external.ExternalInterface;
  import flash.system.Security;
  import flash.net.URLRequest;
  import flash.events.*;
  
  import vk.Net;
  import vk.events.CustomEvent;
  import vk.events.IFlashEvent;

  /**
   * @author Artyom Kolnogorov
   */
  public class APIConnection extends EventDispatcher {
    
    private const CLB_PREFIX:String = '__iflash__';
    
    private var apiCallbacks:Object;
    private var apiReqId:uint = 0;
    private var domain:String = '*';
    
    public function APIConnection(...params) {
      if (!ExternalInterface || !ExternalInterface.available)
      {
        throw new Error('External Interface init error');
      }
      if (typeof params[0] === 'string') {
        domain = params[0];
        params[1] && addEventListener(IFlashEvent.CONNECTION_INIT, params[1]);
      } else {
        params[0] && addEventListener(IFlashEvent.CONNECTION_INIT, params[0]);
      }
      apiCallbacks = new Object();
      Security.allowDomain(domain);
      registerCallbacks();
      sendData('ready');
    }
    
    /*
     * Public methods
     */
    public function callMethod(...params):void {
      var paramsArr:Array = params as Array;
      paramsArr.unshift('callMethod');
      sendData.apply(this, paramsArr);
    }
    
    public function navigateToURL(url:String, window:String = '_self') {
      if (window == '_blank') {
        Net.getURL(new URLRequest(url), window);
      } else {
        sendData('navigateToURL', url);
      }
    }
    
    public function debug(msg:*):void {
      if (!msg.toString) {
        return;
      }
      sendData('debug', msg.toString());
    }
    
    public function api(method:String, params:Object, onComplete:Function = null, onError:Function = null):void {
      apiCallbacks[++apiReqId] = [onComplete, onError];
      sendData('api', method, params, apiReqId);
    }
    
    /*
     * Callbacks
     */
    public function customEvent(...params): void {
      var paramsArr:Array = params as Array;
      var eventName:String = paramsArr.shift();
      debug('API Event: '+eventName);
      var e:CustomEvent = new CustomEvent(eventName);
      e.params = paramsArr;
      dispatchEvent(e);
    }
    
    /*
     * Obsolete callbacks
     */
    private function onApplicationAdded(...params): void {
      var paramsArr:Array = params as Array;
      paramsArr.unshift('onApplicationAdded');
      customEvent.apply(this, paramsArr);
    }
    
    private function onSettingsChanged(...params): void {
      var paramsArr:Array = params as Array;
      paramsArr.unshift('onSettingsChanged');
      customEvent.apply(this, paramsArr);
    }
    
    private function onBalanceChanged(...params): void {
      var paramsArr:Array = params as Array;
      paramsArr.unshift('onBalanceChanged');
      customEvent.apply(this, paramsArr);
    }
    
    private function onMerchantPaymentCancel(...params): void {
      var paramsArr:Array = params as Array;
      paramsArr.unshift('onMerchantPaymentCancel');
      customEvent.apply(this, paramsArr);
    }
    
    private function onMerchantPaymentSuccess(...params): void {
      var paramsArr:Array = params as Array;
      paramsArr.unshift('onMerchantPaymentSuccess');
      customEvent.apply(this, paramsArr);
    }
    
    private function onMerchantPaymentFail(...params): void {
      var paramsArr:Array = params as Array;
      paramsArr.unshift('onMerchantPaymentFail');
      customEvent.apply(this, paramsArr);
    }
    
    private function onProfilePhotoSave(...params): void {
      var paramsArr:Array = params as Array;
      paramsArr.unshift('onProfilePhotoSave');
      customEvent.apply(this, paramsArr);
    }
    
    private function onProfilePhotoCancel(...params): void {
      var paramsArr:Array = params as Array;
      paramsArr.unshift('onProfilePhotoCancel');
      customEvent.apply(this, paramsArr);
    }
    
    private function onWallPostSave(...params): void {
      var paramsArr:Array = params as Array;
      paramsArr.unshift('onWallPostSave');
      customEvent.apply(this, paramsArr);
    }
    
    private function onWallPostCancel(...params): void {
      var paramsArr:Array = params as Array;
      paramsArr.unshift('onWallPostCancel');
      customEvent.apply(this, paramsArr);
    }
    
    private function onWindowResized(...params): void {
      var paramsArr:Array = params as Array;
      paramsArr.unshift('onWindowResized');
      customEvent.apply(this, paramsArr);
    }
    
    private function onLocationChanged(...params): void {
      var paramsArr:Array = params as Array;
      paramsArr.unshift('onLocationChanged');
      customEvent.apply(this, paramsArr);
    }
    
    private function onWindowBlur(...params): void {
      var paramsArr:Array = params as Array;
      paramsArr.unshift('onWindowBlur');
      customEvent.apply(this, paramsArr);
    }
    
    private function onWindowFocus(...params): void {
      var paramsArr:Array = params as Array;
      paramsArr.unshift('onWindowFocus');
      customEvent.apply(this, paramsArr);
    }
    
    private function onScrollTop(...params): void {
      var paramsArr:Array = params as Array;
      paramsArr.unshift('onScrollTop');
      customEvent.apply(this, paramsArr);
    }
    
    private function onScroll(...params): void {
      var paramsArr:Array = params as Array;
      paramsArr.unshift('onScroll');
      customEvent.apply(this, paramsArr);
    }
    
    /*
     * Private methods
     */
    private function registerCallbacks():void
    {
      if (ExternalInterface && ExternalInterface.available)
      {
        ExternalInterface.addCallback('onApplicationAdded', onApplicationAdded);
        ExternalInterface.addCallback('onSettingsChanged', onSettingsChanged);
        ExternalInterface.addCallback('onBalanceChanged', onBalanceChanged);
        ExternalInterface.addCallback('onMerchantPaymentCancel', onMerchantPaymentCancel);
        ExternalInterface.addCallback('onMerchantPaymentSuccess', onMerchantPaymentSuccess);
        ExternalInterface.addCallback('onMerchantPaymentFail', onMerchantPaymentFail);
        ExternalInterface.addCallback('onProfilePhotoSave', onProfilePhotoSave);
        ExternalInterface.addCallback('onProfilePhotoCancel', onProfilePhotoCancel);
        ExternalInterface.addCallback('﻿onWallPostSave', ﻿onWallPostSave);
        ExternalInterface.addCallback('﻿﻿onWallPostCancel', ﻿﻿onWallPostCancel);
        ExternalInterface.addCallback('onWindowResized', onWindowResized);
        ExternalInterface.addCallback('onLocationChanged', onLocationChanged);
        ExternalInterface.addCallback('onWindowBlur', onWindowBlur);
        ExternalInterface.addCallback('onWindowFocus', onWindowFocus);
        ExternalInterface.addCallback('onScrollTop', onScrollTop);
        ExternalInterface.addCallback('onScroll', onScroll);
        
        ExternalInterface.addCallback('apiCallback', apiCallback);
        ExternalInterface.addCallback('init', initConnection);
      }
    }
    
    private function apiCallback(data:Object, req:uint): void {
      if (apiCallbacks[req]) {
        if (typeof data.response !== 'undefined') {
          apiCallbacks[req][0] && apiCallbacks[req][0](data.response);
        }
        else if (typeof data.error !== 'undefined') {
          apiCallbacks[req][1] && apiCallbacks[req][1](data.error);
        }
        delete apiCallbacks[req];
      }
    }
    
    private function initConnection(...params): void {
      debug('Connection initialized.');
      dispatchEvent(new IFlashEvent(IFlashEvent.CONNECTION_INIT, this));
    }
    
    private function sendData(...params) {
      var paramsArr:Array = params as Array;
      paramsArr[0] = CLB_PREFIX + paramsArr[0];
      if (ExternalInterface && ExternalInterface.available)
      {
        return ExternalInterface.call.apply(null, paramsArr);
      }
    }
  }
}
