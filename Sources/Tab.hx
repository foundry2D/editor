class Tab {

    public var parent:EditorPanel;
    public var position:Int = -1;
    public var active(get,null):Bool;
    function get_active(){
        if(parent == null)return false;
        return parent.htab.position == position;
    }
    public function redraw() {
        
    }
    public function render(ui:zui.Zui){

    }
}