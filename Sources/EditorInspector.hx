
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
    public function new() {
        super();
        tree.updateData = updateData;
        
    }
    #if coin
    public static var defaults:Map<String,String> = [
        "px" =>"x","py"=>"y","pz"=>"depth",
        "rz"=>"rotation",
        "sx"=>"scale","sy"=>"scale",
        "w"=>"width","h"=>"height",
        "path"=>"",
        "traits"=>""
    ];
    function updateData(e:UIEvent){        
        if(e.target != null){
            var index = State.active.raw._entities.indexOf(rawData);
            switch(e.target.id){
                case "px" | "py":
                    Reflect.setProperty(rawData.position,defaults.get(e.target.id),Reflect.getProperty(e.target,"pos"));
                default:
            }
            // State.active.raw._entities[index] = rawData;
            State.active._entities[index].raw = rawData;
        }
    }
    #else
    function updateData(e:UIEvent){}
    #end
}