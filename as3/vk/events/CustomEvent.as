package vk.events {
  import flash.events.Event;

  /**
   * @author Artyom Kolnogorov
   */
  public class CustomEvent extends Event {
    public static const CONN_INIT: String = "onConnectionInit";
    public static const WINDOW_BLUR: String = "onWindowBlur";
    public static const WINDOW_FOCUS: String = "onWindowFocus";
    public static const APP_ADDED: String = "onApplicationAdded";
    public static const WALL_SAVE: String = "onWallPostSave";
    public static const WALL_CANCEL: String = "onWallPostCancel";
    public static const PHOTO_SAVE: String = "onProfilePhotoSave";
    public static const PHOTO_CANCEL: String = "onProfilePhotoCancel";
    
    private var _data: Object = new Object();
    private var _params: Array = new Array();
    public function CustomEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = false) {
      super(type, bubbles, cancelable);
    }
    public function get data():Object {
      return _data;
    }
    public function set data(value: Object):void {
      _data = value;
    }
    public function get params(): Array {
      return _params;
    }
    public function set params(value: Array):void {
      _params = value;
    }
  }
}