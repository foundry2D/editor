package;

import utilities.JsonObjectExplorer;

import found.State;
import found.data.SceneFormat;
import found.tool.AnimationEditor;

//@TODO: Maybe we should merge everything in the AnimatorEditor ?
//I think we made it this way to make it easy to port the code to say a drawing tool...
//We should revisite this in the futur
class EditorAnimationView  implements EditorHierarchyObserver extends Tab {
    
    var animationEditor:found.tool.AnimationEditor;
    public function new(){
        
        EditorHierarchy.register(this);
    }
    public function notifyObjectSelectedInHierarchy(selectedObject:TObj,selectedUID:Int) : Void {
        animationEditor.selectedUID = selectedUID;
        
    }
    @:access(found.tool.AnimationEditor)
    public function notifyPlayPause(){
        if(!active)return;
        animationEditor.doUpdate = !animationEditor.doUpdate;
    }

    override public function render(ui:zui.Zui) {

        if(animationEditor == null && parent != null){
            animationEditor = new found.tool.AnimationEditor(parent,this);
        }
        else if(animationEditor == null) { return; }
        
        animationEditor.setAll(parent.x,parent.y,parent.w,parent.h);
        animationEditor.render(ui);
    }
    public function update(dt:Float){
        if(!active)return;
        animationEditor.update(dt);
    }
}