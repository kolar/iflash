package vk.events {
  import flash.events.Event;
  
  import vk.APIConnection;

  /**
   * @author Artyom Kolnogorov
   */
  public class IFlashEvent extends Event {
    public static const CONNECTION_INIT: String = "onConnectionInit";
    
    private var _VK:APIConnection;
    public function IFlashEvent(type:String, vk:APIConnection, bubbles:Boolean = false, cancelable:Boolean = false) {
      super(type, bubbles, cancelable);
      VK = vk;
    }
    public function get VK():APIConnection {
      return _VK;
    }
    public function set VK(value:APIConnection):void {
      _VK = value;
    }
  }
}