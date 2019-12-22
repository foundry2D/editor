
import haxe.ui.extended.NodeData;
import haxe.ui.data.ListDataSource;
import haxe.ui.events.UIEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.containers.menus.MenuItem;
#if arm_csm
import iron.data.SceneFormat;
#elseif coin
import coin.App;
import coin.State;
import coin.data.SceneFormat;
#end

@:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/editor-inspector.xml"))
class EditorInspector extends EditorTab {
    public var rawData(default,set):TObj;
    function set_rawData(obj:TObj){
        return rawData = obj;
    }
    public var index(default,set):Int = -1;
    function set_index(value:Int){
        return index = value;
    }
    public function new() {
        super();
        tree.rclickItems = [ 
            {name:"Add Trait",expands:false,onClicked: addTrait,filter: "traits"},
            {name:"Remove Trait",expands:false,onClicked: rmTrait,filter: "traits"},
        ];
        tree.updateData = updateData;
        
    }
    function addTrait(e:MouseEvent){
        TraitsDialog.open(e);
    }
    function rmTrait(e:MouseEvent){
        // var item:MenuItem = cast(e.target);
        // if(item.icon != "Traits:"){
        //     trace(item);
        // }
    }
    #if coin
    public static var defaults:Map<String,String> = [
        "px" =>"x","py"=>"y","pz"=>"depth",
        "rz"=>"z",
        "sx"=>"x","sy"=>"y",
        "w"=>"width","h"=>"height",
        "path"=>"",
        "traits"=>""
    ];
    @:access(haxe.ui.backend.kha.TextField,coin.Scene)
    function updateData(e:UIEvent){
        var _rawData = rawData;
        var changed:Bool = false;
        var value:Null<Any> = null; 
        if(e.target != null){
            id = e.target.id;
            trace(id);
            var prop = "pos";
            switch(e.target.id){
                case "px" | "py":
                    id = defaults.get(e.target.id);
                    value = Reflect.getProperty(e.target,"pos");
                    if(value == null)return;

                    changed = Reflect.field(_rawData.position,id) != value;
                    Reflect.setProperty(_rawData.position,id,value);
                case "sx" | "sy":
                    id = defaults.get(e.target.id);
                    value = Reflect.getProperty(e.target,"pos");
                    if(value == null)return;

                    changed = Reflect.field(_rawData.scale,id) != value;
                    Reflect.setProperty(_rawData.scale,id,value);
                case "w" | "h" | "pz" | "rz":
                    id = defaults.get(e.target.id);
                    value = Reflect.getProperty(e.target,"pos");
                    if(value == null)return;
                    
                    if(id== "z"){
                        changed = Reflect.field(_rawData.rotation,id) != value;
                        Reflect.setProperty(_rawData.rotation,id,value);
                    }else{
                        changed = Reflect.field(_rawData,id) != value;
                        Reflect.setProperty(_rawData,id,value);
                    }
                    
                case "active":
                    value = Reflect.getProperty(e.target,"selected");
                    if(value == null)return;
                    
                    changed = Reflect.field(_rawData,id) != value;
                    Reflect.setProperty(_rawData,id,value);
                case "imagePath":
                    var tf:haxe.ui.backend.kha.TextField = Reflect.getProperty(e.target,"_textInput")._tf;
                    if(tf.isActive && !tf._caretInfo.visible ){
                        value = Reflect.getProperty(e.target,"text");
                        if(value == null)return;
                    
                        changed = Reflect.field(_rawData,id) != value;
                        Reflect.setProperty(_rawData,id,value);
                        cast(State.active._entities[index],coin.anim.Sprite).set(cast(_rawData));
                    }
                case "traits":
                    var trait = cast(e.target,TraitsDialog).feed.selectedItem;
                    tree.curNode.traits.addField({type:trait.type,class_name: trait.classname});
                    State.active._entities[index].raw.traits.push({type:trait.type,class_name: trait.classname});
                    coin.Scene.createTraits([{type:trait.type,class_name: trait.classname}],State.active._entities[index]);
                    changed = true;
                default:
            }

        }
        if(changed){
            if(!StringTools.contains(App.editorui.hierarchy.path.text,'*'))
			    App.editorui.hierarchy.path.text+='*';
            Reflect.setProperty(State.active._entities[index],id,value);
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
                var z = Reflect.getProperty(data,"z");
                if(index == uid){
                    Reflect.setProperty(tree.curNode.transform.rz,"pos",z);
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