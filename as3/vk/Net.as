package vk {
  import flash.net.URLRequest;
  import flash.net.navigateToURL;
  
  public class Net {
    public static function getURL(request:URLRequest, window:String = null):void {
      navigateToURL(request, window);
    }
  }
}
