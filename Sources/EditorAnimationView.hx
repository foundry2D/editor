package;


import found.data.SceneFormat;

//@TODO: Maybe we should merge everything in the AnimatorEditor ?
//I think we made it this way to make it easy to port the code to say a drawing tool...
//We should revisite this in the futur
class EditorAnimationView  implements EditorHierarchyObserver extends Tab {
    
    var animationEditor:AnimationEditor;
    public function new(){
        super(tr("Animation"));
        EditorHierarchy.getInstance().register(this);
    }

    public function notifySceneSelectedInHierarchy() : Void {
        if(animationEditor == null){
            if(!initAnimationEditor()){
                return;
            }
        }
        animationEditor.selectedUID = -1;
    }

    public function notifyObjectSelectedInHierarchy(selectedObject:TObj,selectedUID:Int) : Void {
        if(animationEditor == null){
            if(!initAnimationEditor()){
                return;
            }
        }
        animationEditor.selectedUID = selectedUID;
        
    }
    @:access(AnimationEditor)
    public function notifyPlayPause(){
        if(!active)return;
        animationEditor.doUpdate = !animationEditor.doUpdate;
    }
    function initAnimationEditor(){
        if(animationEditor == null && parent != null){
            animationEditor = new AnimationEditor(parent,this);
            return true;
        }
        return false;
    }
    override public function render(ui:zui.Zui) {

        if(animationEditor == null){
            if(!initAnimationEditor()){
                return;
            }
        }
        animationEditor.setAll(parent.x,parent.y,parent.w,parent.h);
        animationEditor.render(ui);
    }
    override public function update(dt:Float){
        if(!active)return;
        if(animationEditor == null){
            if(!initAnimationEditor()){
                return;
            }
        }
        animationEditor.update(dt);
    }
    @:access(AnimationEditor)
    override function redraw() {
        super.redraw();
        if(animationEditor == null){
            if(!initAnimationEditor()){
                return;
            }
        }
        animationEditor.timelineHandle.redraws = 2;
    }
}