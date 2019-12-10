
import haxe.ui.extended.NodeData;
import haxe.ui.data.ListDataSource;
import haxe.ui.events.UIEvent;
#if arm_csm
import iron.data.SceneFormat;
#elseif coin
import coin.App;
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
        var changed:Bool = false;
        if(e.target != null){
            id = e.target.id;
            var prop = "pos";
            switch(e.target.id){
                case "px" | "py":
                    id = defaults.get(e.target.id);
                    var value = Reflect.getProperty(e.target,"pos");
                    if(value == null)return;

                    changed = Reflect.field(_rawData.position,id) != value;
                    Reflect.setProperty(_rawData.position,id,value);
                case "sx" | "sy":
                    id = defaults.get(e.target.id);
                    var value = Reflect.getProperty(e.target,"pos");
                    if(value == null)return;

                    changed = Reflect.field(_rawData.scale,id) != value;
                    Reflect.setProperty(_rawData.scale,id,value);
                case "w" | "h" | "pz" | "rz":
                    id = defaults.get(e.target.id);
                    var value = Reflect.getProperty(e.target,"pos");
                    if(value == null)return;
                    
                    changed = Reflect.field(_rawData,id) != value;
                    Reflect.setProperty(_rawData,id,value);
                case "active":
                    var value = Reflect.getProperty(e.target,"selected");
                    if(value == null)return;
                    
                    changed = Reflect.field(_rawData,id) != value;
                    Reflect.setProperty(_rawData,id,value);
                case "imagePath":
                    var tf:haxe.ui.backend.kha.TextField = Reflect.getProperty(e.target,"_textInput")._tf;
                    if(tf.isActive && !tf._caretInfo.visible ){
                        var value = Reflect.getProperty(e.target,"text");
                        if(value == null)return;
                    
                        changed = Reflect.field(_rawData,id) != value;
                        Reflect.setProperty(_rawData,id,value);
                    }
                default:
            }

        }
        if(changed){
            
            if(!StringTools.contains(App.editorui.hierarchy.path.text,'*'))
			    App.editorui.hierarchy.path.text+='*';
            State.active._entities[index].dataChanged = true;

        }
    }
    public function updateField(uid:Int,id:String,data:Any){
        if(uid > State.active._entities.length-1) return;
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
    public function updateField(uid:Int,id:String,data:Any){
        trace("Implement me");
    }
    #end
}