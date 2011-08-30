package vk.ui {
  import flash.display.Sprite;
  import flash.display.Shape;

  /**
   * @author Andrew Rogozov
   */
  internal class VKButtonDisplayState extends Sprite {
    private var bgColor:uint;
    public function VKButtonDisplayState(bgColor:uint, width: uint, height: uint) {
        this.bgColor = bgColor;
        draw(width, height);
    }

    private function draw(width: Number, height: Number):void {
      var child: Shape = new Shape();
      child.graphics.beginFill(bgColor);
      child.graphics.drawRoundRect(0, 0, width, height, 5);
      child.graphics.endFill();
      addChild(child);
    }
  }
}
