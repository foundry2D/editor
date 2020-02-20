package;

import haxe.ui.core.Component;
import haxe.ui.containers.VBox;
import utilities.JsonObjectExplorer;

import found.State;
import found.data.SceneFormat;
import found.tool.AnimationEditor;

// @:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/editor-code.xml"))
class EditorAnimationView  implements EditorHierarchyObserver extends EditorTab {

    public var x(get,never):Int;
	function get_x() {
        var comp = this.parentComponent !=null ? this.parentComponent: this;
		return Math.floor(comp.screenX);
	}
	public var y(get,never):Int;
	function get_y() {
        var comp = this.parentComponent !=null ? this.parentComponent: this;
		return Math.floor(comp.screenY);
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
    
    var animationEditor:found.tool.AnimationEditor;
    // var textEditor:CodeComponent;
    public function new(){
        super();
        percentWidth = 100;
        percentHeight = 100;
        this.text = "Animation";
        animationEditor = new found.tool.AnimationEditor(x,y,w,h);
        animationEditor.visible = true;
        EditorHierarchy.register(this);
    }
    public function notifyObjectSelectedInHierarchy(selectedObjectPath:String) : Void {
        var name = State.active.raw.name;
        StringTools.replace(selectedObjectPath,'$name/',"");
        var data:{jsonObject:TObj, jsonObjectUid:Int} = JsonObjectExplorer.getObjectFromSceneObjects(selectedObjectPath);
        animationEditor.selectedUID = data.jsonObjectUid;
        
    }
    public override function renderTo(g:kha.graphics2.Graphics) {
        super.renderTo(g);
        
        if(selectedPage.text != "Animation")return;
        
        animationEditor.setAll(x,y,w,h);
        animationEditor.render(g);
        
        
    }
    public function update(dt:Float){
        if(!animationEditor.visible)return;
        animationEditor.update(dt);
    }
}