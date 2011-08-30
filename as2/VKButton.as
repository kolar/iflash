class VKButton extends MovieClip
{
  private var _label:String = '';
  private var label_tf:TextField = null;
  private var btn:MovieClip = null;
  
  function VKButton()
  {
    updateButton();
  }
  public function set label(label:String)
  {
    this._label = label;
    updateButton();
  }
  private function updateButton()
  {
    label_tf._width = 5000;
    label_tf.html = true;
    label_tf.htmlText = "<p>"+_label+"</p>";
    label_tf._width = label_tf.textWidth + 27;
    btn.right._x = label_tf.textWidth + 22;
    btn.createEmptyMovieClip("center", 0);
    VKButton.rect(btn.center, null, 0x36638E, 5, 0, label_tf.textWidth + 17, 23);
  }
  private static function rect(mc:MovieClip, ls:Number, fs:Number, x:Number, y:Number, w:Number, h:Number)
  {
    mc.lineStyle(1, (ls===null)?0:ls, (ls===null)?0:100, true, "normal", "square", "miter");
    mc.beginFill((fs===null)?0:fs, (fs===null)?0:100);
    mc.moveTo(x, y);
    mc.lineTo(w+x, y);
    mc.lineTo(w+x, h+y);
    mc.lineTo(x, h+y);
    mc.lineTo(x, y);
    mc.endFill();
  }
}
