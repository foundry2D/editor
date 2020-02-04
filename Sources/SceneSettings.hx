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
        if(_zsort.hidden && depthSort.value )_zsort.hidden = false;

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