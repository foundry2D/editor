
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
        var _rawData = rawData;
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
                        trace(e.target.id+' '+Reflect.getProperty(e.target,"pos"));
                    id = defaults.get(e.target.id);
                    Reflect.setProperty(_rawData,id,Reflect.getProperty(e.target,"pos"));
                case "active":
                    Reflect.setProperty(_rawData,id,Reflect.getProperty(e.target,"selected"));
                case "imagePath":
                    var tf:haxe.ui.backend.kha.TextField = Reflect.getProperty(e.target,"_textInput")._tf;
                    if(tf.isActive && !tf._caretInfo.visible ){
                        trace(tf._caretInfo.visible);
                        trace(tf.isActive);
                        Reflect.setProperty(_rawData,id,Reflect.getProperty(e.target,"text"));
                    }
                        
                default:
            }
        }
        if(State.active._entities[index] != null ){
            State.active._entities[index].raw = _rawData;
        }
    }
    public function updateField(uid:Int,id:String,data:Any){
        switch(id){
            case "_positions":
                var x = Reflect.getProperty(data,"x");
                var y = Reflect.getProperty(data,"y");
                if(index == uid){
                    Reflect.setProperty(tree.curNode.transform.px,"pos",x);
                    Reflect.setProperty(tree.curNode.transform.py,"pos",y);
                }
                State.active._entities[uid].raw.position = data;
            case "_rotations":
                if(index == uid){
                    Reflect.setProperty(tree.curNode.transform.rz,"pos",data);
                }
                State.active._entities[uid].raw.rotation = data;
            case "_scales":
                var x = Reflect.getProperty(data,"x");
                var y = Reflect.getProperty(data,"y");
                if(index == uid){
                    Reflect.setProperty(tree.curNode.transform.sx,"pos",x);
                    Reflect.setProperty(tree.curNode.transform.sy,"pos",y);
                }
                State.active._entities[uid].raw.scale = data;
            case "imagePath":
                var width =Reflect.getProperty(data,"width");
                var height = Reflect.getProperty(data,"height");
                trace(width);
                trace(height);
                if(index == uid){
                    Reflect.setProperty(tree.curNode.transform.w,"pos",width);
                    Reflect.setProperty(tree.curNode.transform.h,"pos",height);
                }

        }
        // tree.dispatch(new UIEvent(UIEvent.CHANGE));
    }
    #else
    function updateData(e:UIEvent){
        trace("Implement me");
    }
    #end
}