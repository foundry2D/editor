
import haxe.ui.extended.NodeData;
import haxe.ui.data.ListDataSource;
import haxe.ui.events.UIEvent;
#if arm_csm
import iron.data.SceneFormat;
#elseif coin
import coin.State;
import coin.data.SceneFormat;
#end

@:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/editor-inspector.xml"))
class EditorInspector extends EditorTab {
    public var rawData:TObj;
    public var index:Int = -1;
    public var wait:Array<Int> = [];
    public function new() {
        super();
        tree.updateData = updateData;
        
    }
    #if coin
    public static var defaults:Map<String,String> = [
        "px" =>"x","py"=>"y","pz"=>"depth",
        "rz"=>"rotation",
        "sx"=>"x","sy"=>"y",
        "w"=>"width","h"=>"height",
        "path"=>"",
        "traits"=>""
    ];
    @:access(haxe.ui.backend.kha.TextField)
    function updateData(e:UIEvent){
        var _rawData = Reflect.copy(rawData);
        var isValidChange = false;
        var isPropChange = false;
        if(e.target != null){
            var id = e.target.id;
            var prop = "pos";
            switch(e.target.id){
                case "px" | "py":
                    id = defaults.get(e.target.id);
                    Reflect.setProperty(_rawData.position,id,Reflect.getProperty(e.target,"pos"));
                case "sx" | "sy":
                    id = defaults.get(e.target.id);
                    Reflect.setProperty(_rawData.scale,id,Reflect.getProperty(e.target,"pos"));
                case "w" | "h" | "pz" | "rz":
                    if(e.target.id == "w" || e.target.id == "h")
                        trace(Reflect.getProperty(e.target,"pos"));
                    id = defaults.get(e.target.id);
                    Reflect.setProperty(_rawData,id,Reflect.getProperty(e.target,"pos"));
                case "active":
                    Reflect.setProperty(_rawData,id,Reflect.getProperty(e.target,"selected"));
                case "imagePath":
                    var tf:haxe.ui.backend.kha.TextField = Reflect.getProperty(e.target,"_textInput")._tf;
                    if(tf.isActive && !tf._caretInfo.visible )
                        Reflect.setProperty(_rawData,id,Reflect.getProperty(e.target,"text"));
                default:
            }
            trace(id);
            trace(Reflect.getProperty(State.active._entities[index].raw,id));
            trace(Reflect.getProperty(_rawData,id));
            isValidChange = Reflect.getProperty(State.active._entities[index].raw,id) != Reflect.getProperty(_rawData,id);
            trace(isValidChange);
        }
        // State.active.raw._entities[index] = rawData;
        if(State.active._entities[index] != null && isValidChange || isPropChange){
            State.active._entities[index].raw = _rawData;
            if(e.target != null && wait[wait.length-1] == 1)
                wait.pop();
        }
    }
    #else
    function updateData(e:UIEvent){
        trace("Implement me");
    }
    #end
}