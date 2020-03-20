package;

import haxe.ui.containers.menus.*;
import haxe.ui.core.Screen;
import haxe.ui.extended.NodeData;
import haxe.ui.data.ListDataSource;
import haxe.ui.events.UIEvent;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.events.MouseEvent;
import EditorTab.TItem;

#if arm_csm
import iron.data.SceneFormat;
#else
import kha.math.Vector2;
import kha.math.Vector3;
import found.State;
import found.object.Object;
import found.data.SceneFormat;
#end
// @:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/editor-hierarchy.xml"))
class EditorHierarchy extends EditorTab {

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
		return Math.ceil(this.componentWidth);
	}
	public var h(get,never):Int;
	function get_h() {
        var comp = this.parentComponent !=null ? this.parentComponent: this;
		return Math.ceil(this.componentHeight);
    }

    static public var inspector:EditorInspector;
    var selectedObjectUID : Int = -1;
    static var observers:Array<EditorHierarchyObserver> = [];

    public static function register(observer : EditorHierarchyObserver) : Void {
        observers.push(observer);
    }
    
    public static function unregister(observer : EditorHierarchyObserver) : Void {
        observers.remove(observer);
    }

    
    public function onSelected(uid:Int, obj:TObj) : Void {
        for(item in observers){
            item.notifyObjectSelectedInHierarchy(obj,uid);
        }
    }
    
    public function selectScene(){
        inspector.notifySceneSelect();
    }
    public static var sceneName = "";
    public static function makeDirty(){
        if(!StringTools.contains(sceneName,'*'))
            sceneName+='*';
        hierarchy.redraw();
        if(inspector.index == -1)return;
        State.active._entities[inspector.index].dataChanged = true;
        
    }
    static var hierarchy:Hierarchy;
    var scene:TSceneFormat;
    public function new(raw:TSceneFormat=null,p_inspector:EditorInspector = null) {
        super();
        this.text = "Hierarchy";
        inspector = p_inspector;
        hierarchy = new Hierarchy(x,y,w,h);
        hierarchy.parent = this;
        setFromScene(raw,true);

    }
    public function render(ui:zui.Zui){
        if(scene == null) return;
        hierarchy.setAll(x,y,w,h);
        hierarchy.render(ui,scene);
    }
    public function setFromScene(raw:TSceneFormat,onBoot:Bool = false){
        sceneName = raw.name;
        if(!onBoot){
            inspector.clear();
        }
        scene = raw;
            
        // #if arm_csm
        // tree.dataSource = getObjData(raw.objects,raw.name);
        // #else
        // tree.dataSource = getObjData(raw._entities,raw.name);
        // #end
    }


    // function duplicateObject(e:MouseEvent){
    //     if(inspector.index >= 0){
    //         addData2Scn(State.active.raw._entities[inspector.index]);
    //     }
    // }

    // function removeObject(e:MouseEvent){
    //     if(inspector.index >= 0){
    //         rmvData2Scn(inspector.index);
    //     }
    // }
    
    // function addEmitter2Scn(e:MouseEvent){
    //     var data:TEmitterData = {
    //         name: "Emitter",
    //         type: "emitter_object",
    //         position: new Vector2(),
    //         rotation:new Vector3(),
    //         width: 0.0,
    //         height:0.0,
    //         scale: new Vector2(1.0,1.0),
    //         center: new Vector2(),
    //         depth: 0.0,
    //         active: true,
    //         amount: 1
    //     };
    //     addData2Scn(data);
    // }
}
