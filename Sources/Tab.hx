package;
import zui.Zui.Layout;
class Tab {

    public var parent:EditorPanel;
    public var position:Int = -1;
    public var active(get,null):Bool;
    public final name:String;
    @:isVar public var layout(get,null):Layout;
    function get_layout(){
        return layout;
    }
    @:isVar public var canScroll(get,null):Bool;
    function get_canScroll(){
        return canScroll;
    }

    public function new(tabname:String,?p_layout:Layout = Layout.Vertical,?p_canScroll = true){
        name = tabname;
        layout = p_layout;
        canScroll = p_canScroll;
    }
    function get_active(){
        if(parent == null)return false;
        return parent.htab.position == position;
    }
    public function redraw() {
        
    }
    public function render(ui:zui.Zui){

    }
}