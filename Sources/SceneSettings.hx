package;

import found.State;
import haxe.ui.core.Component;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;

@:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/scene-settings.xml"))
class SceneSettings extends Component{

    public function new(){
        super();
        sceneName.text = State.active.raw.name != null ? State.active.raw.name : '';
        depthSort.value = State.active.raw._depth != null ? State.active.raw._depth : true;
        if(depthSort.value )zsort.hidden =  State.active.raw._Zsort != null ? State.active.raw._Zsort: false;
        if(State.active.raw.physicsWorld != null){
            physWidth.value = State.active.raw.physicsWorld.width;
            physHeight.value = State.active.raw.physicsWorld.height;
            physX.value = State.active.raw.physicsWorld.x;
            physY.value = State.active.raw.physicsWorld.y;
            gravity_x.value = State.active.raw.physicsWorld.gravity_x;
            gravity_y.value = State.active.raw.physicsWorld.gravity_y;
            iterations.value = State.active.raw.physicsWorld.iterations;
            history.value = State.active.raw.physicsWorld.history;
        }
    }
    @:bind(physOpts,MouseEvent.CLICK)
    function onEdit(e:MouseEvent){
        if(e.target != null){
            if(e.target.text == '+'){
                physOptions.hidden = false;
                physOpts.text = '-';
            }
            else if(e.target.text == '-'){
                physOptions.hidden = true;
                physOpts.text = '+';
            }
        }
    }
    @:bind(iterations,UIEvent.CHANGE)
    function updateitText(e:UIEvent){
        itText.text = ""+iterations.pos;
    }
    @:bind(history,UIEvent.CHANGE)
    function updatehistText(e:UIEvent){
        histText.text = ""+history.pos;
    }
}