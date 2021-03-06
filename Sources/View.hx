package;

import zui.Zui;
import zui.Canvas.TElement;

interface View {
    public function render(ui:Zui,element:TElement):Void;
    public function update(dt:Float):Void;
    public function redraw():Void;
}