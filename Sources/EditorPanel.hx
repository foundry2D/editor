import zui.Zui.Handle;
import haxe.ui.containers.VBox;

class EditorPanel extends VBox {

    var tabs:Array<Tab> = [];
    public var htab = zui.Id.handle({position: 0});
    var windowHandle:zui.Zui.Handle;
    public var x(get,never):Int;
	function get_x() {
        var comp = this.parentComponent !=null ? this.parentComponent: this;
		return Math.floor(this.screenX);
	}
	public var y(get,never):Int;
	function get_y() {
        var comp = this.parentComponent !=null ? this.parentComponent: this;
		return Math.floor(this.screenY);
	}
	public var w(get,never):Int;
	function get_w() {
        var comp = this.parentComponent !=null ? this.parentComponent: this;
		return Math.ceil(comp.componentWidth);
	}
	public var h(get,never):Int;
	function get_h() {
        var comp = this.parentComponent !=null ? this.parentComponent: this;
		return Math.ceil(comp.componentHeight);
    }

    public function new(){
        super();
        windowHandle = new Handle();
    }
    @:access(zui.Zui)
    function render(ui:zui.Zui){
        if(ui.window(windowHandle, x, y, w, h)){
            for (tab in tabs){
                tab.render(ui);
            }
            ui._y = y;
            ui.tooltip("Add a new Tab");//@TODO: Add translation
            if(ui.tab(htab,"+")){
                htab.position = 0;
            }
        }
    }
}