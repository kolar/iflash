package vk.ui {
  import flash.display.SimpleButton;
  import flash.display.DisplayObjectContainer;
  //import flash.events.*;
  import flash.text.TextFormat;
  import flash.text.TextField;
  import flash.text.TextFieldAutoSize;

  
  /**
   * @author andrew
   */
  public class VKButton extends SimpleButton {
    private var _buttonType: Number = 1;
    private var _label: String = '';
    private var _upText: TextField;
    private var _upTextFormat: TextFormat;
    private var _overText: TextField;
    private var _overTextFormat: TextFormat;
    
    public function VKButton(label: String, type: Number = 1)
    {
      this._buttonType = type;
      this._label = label;
      this.init();
      this.updateButton();
    }
    
    public function set label(value: String): void
    {
      _label = value;
      updateButton();
    }
    
    private function init(): void
    {
      _upTextFormat = new TextFormat();
      _overTextFormat = new TextFormat();
      
      switch (_buttonType)
      {
        case 2:
         _upTextFormat.color = 0x222222;
         _overTextFormat.color = 0x606060;
         break;
        case 1:
        default:
         _upTextFormat.color = 0xF3F3F3;
         _overTextFormat.color = 0xDAE1E8;
      }
      
      _upTextFormat.font = "Tahoma";
      _upTextFormat.size = 11;
      
      _upText = new TextField();
      _upText.wordWrap = false;
      _upText.autoSize = TextFieldAutoSize.LEFT;
     // _upText.gridFitType = GridFitType.SUBPIXEL;
      _upText.defaultTextFormat = _upTextFormat;
      
      _overTextFormat.font = "Tahoma";
      _overTextFormat.size = 11;
      
      
      _overText = new TextField();
      _overText.wordWrap = false;
      _overText.autoSize = TextFieldAutoSize.LEFT;
      _overText.defaultTextFormat = _overTextFormat;
      
      useHandCursor  = true;
    }
    
    private function updateButton(): void
    {
      var bgColor: uint;
      switch (_buttonType)
      {
        case 2:
          bgColor = 0xDEDEDE;
        break;
        default:
          bgColor = 0x36638E;
      }
      
      _upText.text = _overText.text = _label;
      
      upState = new VKButtonDisplayState(bgColor, _upText.textWidth + 24, 24);
      overState = new VKButtonDisplayState(bgColor, _upText.textWidth + 24, 24);
      downState = hitTestState = overState;
      
      _upText.x = 10;
      _upText.y = Math.round((upState.height - _upText.textHeight) / 2) - 3;
       
      _overText.x = _upText.x;
      _overText.y = _upText.y;
       
      (upState as DisplayObjectContainer).addChild(_upText);
      (overState as DisplayObjectContainer).addChild(_overText);
    }
  }
}
