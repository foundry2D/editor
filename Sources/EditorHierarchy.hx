package;

import zui.Canvas.TElement;
import zui.Ext;

#if arm_csm
import iron.data.SceneFormat;
#else
import found.State;
import found.data.SceneFormat;
#end

class EditorHierarchy extends EditorPanel {

    static public var inspector:EditorInspector;
    static var clone:EditorHierarchy;
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
        clone.redraw();
        if(inspector.index == -1)return;
        State.active._entities[inspector.index].dataChanged = true;
        
    }
    public static function makeClean(){
        sceneName = StringTools.replace(sceneName,'*','');
        clone.redraw();
        
    }
    function redraw(){
        windowHandle.redraws = 2;
        hierarchy.redraw();
    }
    static var hierarchy:Hierarchy;
    var scene:TSceneFormat;
    public function new(raw:TSceneFormat=null,p_inspector:EditorInspector = null) {
        super();
        clone = this;
        inspector = p_inspector;
        hierarchy = new Hierarchy();
        hierarchy.parent = this;
        tabs.push(hierarchy);
        tabs.push(inspector.inspector);
        setFromScene(raw,true);

    }
    
    override public function render(ui:zui.Zui,element:TElement){
        if(scene == null) return;
        super.render(ui,element);
    }
    public function setFromScene(raw:TSceneFormat,onBoot:Bool = false){
        sceneName = raw.name;
        if(!onBoot){
            inspector.clear();
        }
        scene = raw;
    }
}
