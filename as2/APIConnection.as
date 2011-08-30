import flash.external.ExternalInterface;

/**
 * @author Artyom Kolnogorov
 */
class APIConnection {
  
  private var CLB_PREFIX:String = '__iflash__';
  private var noop:Function = function() {};
  
  private var apiCallbacks:Object;
  private var apiReqId:Number = 0;
  private var domain:String = '*';
  
  public function APIConnection() {
    if (ExternalInterface && ExternalInterface.available)
    {
      if (typeof arguments[0] === 'string') {
        domain = arguments[0];
        onConnectionInit = arguments[1] || noop;
      } else {
        onConnectionInit = arguments[0] || noop;
      }
      apiCallbacks = new Object();
      System.security.allowDomain(domain);
      registerCallbacks();
      sendData('ready');
    }
  }
  
  /*
   * Public methods
   */
  public function callMethod() {
    var paramsArr:Array = arguments;
    paramsArr.unshift('callMethod');
    sendData.apply(this, paramsArr);
  }
  
  public function navigateToURL(url:String, window:String) {
    if (window == '_blank') {
      _root.getURL(url, window);
    } else {
      sendData('navigateToURL', url);
    }
  }
  
  public function debug(msg:Object) {
    if (!msg || !msg.toString) {
      return;
    }
    sendData('debug', msg.toString());
  }
  
  public function api(method:String, params:Object, onComplete:Function, onError:Function) {
    apiCallbacks[++apiReqId] = [onComplete, onError];
    sendData('api', method, params, apiReqId);
  }
  
  /*
   * Obsolete callbacks
   */
  public var onApplicationAdded:Function = noop;
  public var onSettingsChanged:Function = noop;
  public var onBalanceChanged:Function = noop;
  public var onMerchantPaymentCancel:Function = noop;
  public var onMerchantPaymentSuccess:Function = noop;
  public var onMerchantPaymentFail:Function = noop;
  public var onProfilePhotoSave:Function = noop;
  public var onProfilePhotoCancel:Function = noop;
  public var onWallPostSave:Function = noop;
  public var onWallPostCancel:Function = noop;
  public var onWindowResized:Function = noop;
  public var onLocationChanged:Function = noop;
  public var onWindowBlur:Function = noop;
  public var onWindowFocus:Function = noop;
  public var onScrollTop:Function = noop;
  
  private var onConnectionInit:Function = noop;
  
  /*
   * Private methods
   */
  private function registerCallbacks()
  {
    if (ExternalInterface && ExternalInterface.available)
    {
      ExternalInterface.addCallback('onApplicationAdded', this, function() { this.onApplicationAdded(); });
      ExternalInterface.addCallback('onSettingsChanged', this, function(s) { this.onSettingsChanged(s); });
      ExternalInterface.addCallback('onBalanceChanged', this, function(b) { this.onBalanceChanged(b); });
      ExternalInterface.addCallback('onMerchantPaymentCancel', this, function() { this.onMerchantPaymentCancel(); });
      ExternalInterface.addCallback('onMerchantPaymentSuccess', this, function(m) { this.onMerchantPaymentSuccess(m); });
      ExternalInterface.addCallback('onMerchantPaymentFail', this, function() { this.onMerchantPaymentFail(); });
      ExternalInterface.addCallback('onProfilePhotoSave', this, function() { this.onProfilePhotoSave(); });
      ExternalInterface.addCallback('onProfilePhotoCancel', this, function() { this.onProfilePhotoCancel(); });
      ExternalInterface.addCallback('onWallPostSave', this, function() { this.onWallPostSave(); });
      ExternalInterface.addCallback('onWallPostCancel', this, function() { this.onWallPostCancel(); });
      ExternalInterface.addCallback('onWindowResized', this, function(w, h) { this.onWindowResized(w, h); });
      ExternalInterface.addCallback('onLocationChanged', this, function(l) { this.onLocationChanged(l); });
      ExternalInterface.addCallback('onWindowBlur', this, function() { this.onWindowBlur(); });
      ExternalInterface.addCallback('onWindowFocus', this, function() { this.onWindowFocus(); });
      ExternalInterface.addCallback('onScrollTop', this, function(t) { this.onScrollTop(t); });
      
      ExternalInterface.addCallback('apiCallback', this, apiCallback);
      ExternalInterface.addCallback('init', this, initConnection);
    }
  }
  
  private function apiCallback(data:Object, req:Number) {
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
  
  private function initConnection() {
    debug('Connection initialized.');
    onConnectionInit.call(this, this);
  }
  
  private function sendData() {
    var paramsArr:Array = Array.prototype.slice.call(arguments);
    paramsArr[0] = CLB_PREFIX + paramsArr[0];
    if (ExternalInterface && ExternalInterface.available)
    {
      return ExternalInterface.call.apply(null, paramsArr);
    }
  }
}
