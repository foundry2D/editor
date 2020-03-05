
import Inspector.Handles;
import haxe.ui.core.Component;
import haxe.ui.extended.NodeData;
import haxe.ui.extended.InspectorNode;
import haxe.ui.data.ListDataSource;
import haxe.ui.events.UIEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.containers.menus.MenuItem;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.extended.InspectorField;
import kha.FileSystem;
import utilities.JsonObjectExplorer;
#if arm_csm
import iron.data.SceneFormat;
#elseif found
import found.App;
import found.State;
import found.data.SceneFormat;
import found.object.Object;
import found.math.Util;
#end

@:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/editor-inspector.xml"))
class EditorInspector implements EditorHierarchyObserver extends EditorTab {

    public var x(get,never):Int;
	function get_x() {
        var comp = this.parentComponent !=null ? this.parentComponent: this;
		return Math.floor(this.screenX);
	}
	public var y(get,never):Int;
	function get_y() {
        var comp = this.parentComponent !=null ? this.parentComponent: this;
		return Math.floor(this.screenY);
	}
	public var w(get,never):Int;
	function get_w() {
        var comp = this.parentComponent !=null ? this.parentComponent: this;
		return Math.ceil(this.componentWidth);
	}
	public var h(get,never):Int;
	function get_h() {
        var comp = this.parentComponent !=null ? this.parentComponent: this;
		return Math.ceil(this.componentHeight);
    }

    public var rawData(default,set):TObj;
    function set_rawData(obj:TObj){
        return rawData = obj;
    }
    public var index(default,set):Int = -1;
    function set_index(value:Int){
        return index = value;
    }
    public var currentObject(get,null):Null<Object>;
    function get_currentObject(){
        if(index == -1)return null;
        return State.active._entities[index];
    }
    var inspector:Inspector;
    public function new() {
        super();
        this.text = "Inspector";
        inspector = new Inspector(x,y,w,h);
        inspector.searchImage = browseImage;
        // tree.rclickItems = [ 
        //     {name:"Add Trait",expands:false,onClicked: addTrait,filter: "traits"},
        //     {name:"Remove Trait",expands:false,onClicked: rmTrait,filter: "traits"},
        // ];
        // tree.updateData = updateData;
        // tree.initFields.set("addRigidbody",initRbodyButton);
        // tree.buttonsClick.set("browseImage",browseImage);
        // tree.buttonsClick.set("addTraits",addTrait);
        // tree.buttonsClick.set("addRigidbody",addRigidbody);
        EditorHierarchy.register(this);
    }
    @:access(Inspector)
    public function clear(){
        inspector.scene.resize(0);
        inspector.object.resize(0);
    }
    public function notifyObjectSelectedInHierarchy(selectedObjectPath:String) : Void {
        var out:{ds:ListDataSource<InspectorData>,obj:TObj,index:Int} = getInspectorNode(selectedObjectPath);
        index = out.index;
        // tree.dataSource = out.ds;
        rawData = out.obj;
        inspector.setObject(out.obj);
        if(rawData.type == "tilemap_object"){
            found.Found.tileeditor.selectMap(out.index);                
        } 
        else{
            found.Found.tileeditor.selectMap(-1);
        }             
    }
    public override function renderTo(g:kha.graphics2.Graphics) {
        super.renderTo(g);
        
        if(selectedPage.text != "Inspector")return;
        else{
            inspector.visible = true;
        }
        inspector.setAll(x,y,w,h);
        inspector.render(g);
        
        
    }

    function getInspectorNode(path:String) {
        var ds = new ListDataSource<InspectorData>();
        var name = State.active.raw.name;
        StringTools.replace(path,'$name/',"");
    #if arm_csm
        var dat:{obj:TObj, index:Int} =getObj(raw.objects,path);//@FIXME: We should set the raw correctly
        var obj:TObj = dat.obj;
        var mat = iron.math.Mat4.fromFloat32Array(obj.transform.values);
        var pos = mat.getLoc();
        var scale = mat.getScale();
        var quat = new iron.math.Quat(); 
        var rot = quat.fromMat(mat).getEuler();
        var const = 180/Math.PI;
        ds.add({
            name: obj.name,
            path: path,
            type:"img/"+obj.type,
            dataref: obj.data_ref,
            px: pos.x,
            py: pos.y,
            pz: pos.z,
            rx: rot.x*const,
            ry: rot.y*const,
            rz: rot.z*const,
            sx: scale.x,
            sy: scale.y,
            sz: scale.z,
            materialRefs: fetch(obj,'material_refs','Array'),
            particleRefs: fetch(obj,'particle_refs','Array'),
            isParticle: fetch(obj,"is_particle",'Bool'),
            groupref: fetch(obj,"groupref",'String'),
            lods: fetch(obj,"lods",'Array'),
            traits: fetch(obj,"traits",'Array'),
            constraints: fetch(obj,"constraints",'Array'),
            properties: fetch(obj,"properties",'Array'),
            objectActions: fetch(obj,'object_actions','Array'),
            boneActions: fetch(obj,'bone_actions','Array') ,
            visible: fetch(obj,"visible",'Bool'),
            visibleMesh: fetch(obj,"visible_mesh",'Bool'),
            visibleShadow: fetch(obj,"visible_shadow",'Bool'),
            mobile: fetch(obj,"mobile",'Bool'),
            autoSpawn: fetch(obj,"spawn",'Bool'),
            localOnly: fetch(obj,"local_only",'Bool'),
            tilesheetRef: fetch(obj,"tilesheetRef",'String'),
            tilesheetActionRef: fetch(obj,"tilesheetActionRef",'String'),
            sampled: fetch(obj,"sampled",'Bool')
        });
    #elseif found
        var data:{jsonObject:TObj, jsonObjectUid:Int} = JsonObjectExplorer.getObjectFromSceneObjects( path);
        var out = getIDataFrom(data.jsonObject);
    
        for(f in Reflect.fields(out)){
            if(EditorInspector.defaults.exists(f)) continue;
            
            if(!Reflect.hasField(data.jsonObject,f)){
                trace('Field $f was deleted from ' + out.name);
                Reflect.deleteField(out,f);
            }
        }
        ds.add(out);
    #end
        // @TODO Set class variables directly instead of returning values
        return {ds:ds,obj:data.jsonObject,index:data.jsonObjectUid};
    }

    public static function getIDataFrom(obj:TObj){
        var scale = Reflect.hasField(obj,'scale') ? obj.scale : new kha.math.Vector2(1.0,1.0);
        var path = State.active.raw.name + "/" + obj.name;
        var data:InspectorData = {
            name: obj.name,
            path: path,
            type:"img/"+obj.type,
            px: obj.position.x,
            py: obj.position.y,
            pz: obj.depth,
            sx: scale.x,
            sy: scale.y,
            rz: obj.rotation.z,
            w: obj.width,
            h: obj.height,
            active: obj.active,
            imagePath: JsonObjectExplorer.getFieldValueInJsonObject(obj, "imagePath", 'String'),
            traits: JsonObjectExplorer.getFieldValueInJsonObject(obj, "traits", 'Array'),
            rigidBody: JsonObjectExplorer.getFieldValueInJsonObject(obj, "rigidBody", 'Typedef'),
        };
        return data;
    }

    function initRbodyButton(c:Component){
        var node:InspectorField = c.parentComponent.findComponent("rigidBody",InspectorField);
        if(node.hasChildren && c.text == "+"){
            c.text = "-";
        }
    }
    function addRigidbody(e:MouseEvent){
        var node:InspectorField = e.target.parentComponent.findComponent("rigidBody",InspectorField) ;
        if(e.target.text == "+"){
            e.target.text = "-";
        }
        else if(e.target.text == "-"){

            e.target.text = "+";
        }
        // e.target = node;
        // this.updateData(e);
    }
    function addTrait(e:MouseEvent){
        
    }
    function rmTrait(e:MouseEvent){
        // var item:MenuItem = cast(e.target);
        // if(item.icon != "Traits:"){
        //     trace(item);
        // }
    }
    function browseImage(){
        FileBrowserDialog.open(new UIEvent(UIEvent.CHANGE));
        FileBrowserDialog.inst.onDialogClosed = function(e:DialogEvent){
            var path = null;
            if(e.button == DialogButton.APPLY)
                path = FileBrowserDialog.inst.fb.filepath.text;
            var error = true;
            var sep = FileSystem.sep;
            if(path != null){
                var name = path.split(sep)[path.split(sep).length-1];
                var type = name.split('.')[1];
                switch(type){
                    case 'png' | 'jpg':
                        if(index != -1 && rawData != null){
                            Reflect.setProperty(rawData,"imagePath",path);
                            cast(State.active._entities[index],found.anim.Sprite).set(cast(rawData));
                            dirtyScene("imagePath",path);
                        }
                        error = false;
                    default:
                        trace('Error: file has filetype $type which is not a valid filetype for images ');
                }
            }
            if(error){
                trace('Error: file with name $name is not a valid image name or the path "$path" was invalid ');
            }

        }
    }
    #if found
    public static var defaults:Map<String,String> = [
        "px" =>"x","py"=>"y","pz"=>"depth",
        "rz"=>"z",
        "sx"=>"x","sy"=>"y",
        "w"=>"width","h"=>"height",
        "path"=>"",
        "traits"=>""
    ];
    // @:access(haxe.ui.backend.kha.TextField,found.Scene)
    // function updateData(e:UIEvent){
    //     var _rawData = rawData;
    //     var changed:Bool = false;
    //     var value:Null<Any> = null; 
    //     if(e.target != null){
    //         id = e.target.id;
    //         // trace(id);
    //         var prop = "pos";
    //         switch(e.target.id){
    //             case "px" | "py":
    //                 id = defaults.get(e.target.id);
    //                 value = Reflect.getProperty(e.target,"pos");
    //                 if(value == null)return;

    //                 changed = Reflect.field(_rawData.position,id) != value;
    //                 Reflect.setProperty(_rawData.position,id,value);
    //             case "sx" | "sy":
    //                 id = defaults.get(e.target.id);
    //                 value = Reflect.getProperty(e.target,"pos");
    //                 if(value == null)return;

    //                 changed = Reflect.field(_rawData.scale,id) != value;
    //                 Reflect.setProperty(_rawData.scale,id,value);
    //             case "w" | "h" | "pz" | "rz":
    //                 id = defaults.get(e.target.id);
    //                 value = Reflect.getProperty(e.target,"pos");
    //                 if(value == null)return;
                    
    //                 if(id== "z"){
    //                     changed = Reflect.field(_rawData.rotation,id) != value;
    //                     Reflect.setProperty(_rawData.rotation,id,value);
    //                 }else{
    //                     changed = Reflect.field(_rawData,id) != value;
    //                     Reflect.setProperty(_rawData,id,value);
    //                 }
                    
    //             case "active":
    //                 value = Reflect.getProperty(e.target,"selected");
    //                 if(value == null)return;
                    
    //                 changed = Reflect.field(_rawData,id) != value;
    //                 Reflect.setProperty(_rawData,id,value);
    //             case "imagePath":
    //                 var tf:haxe.ui.backend.kha.TextField = Reflect.getProperty(e.target,"_textInput")._tf;
    //                 if(tf.isActive && !tf._caretInfo.visible ){
    //                     value = Reflect.getProperty(e.target,"text");
    //                     if(value == null)return;
                    
    //                     changed = Reflect.field(_rawData,id) != value;
    //                     Reflect.setProperty(_rawData,id,value);
    //                     cast(State.active._entities[index],found.anim.Sprite).set(cast(_rawData));
    //                 }
    //             case "traits":
    //                 var trait = cast(e.target,TraitsDialog).feed.selectedItem;
    //                 tree.curNode.traits.addField({type:trait.type,class_name: trait.classname});
    //                 State.active._entities[index].raw.traits.push({type:trait.type,class_name: trait.classname});
    //                 found.Scene.createTraits([{type:trait.type,class_name: trait.classname}],State.active._entities[index]);
    //                 changed = true;
    //             case "rigidBody":
    //                 trace("Rigidbody called");
    //             default:
    //         }

    //     }
    //     if(changed){
    //         dirtyScene(id,value);
    //     }
    // }
    function dirtyScene(id:String,value:Any){
        EditorHierarchy.makeDirty();
        Reflect.setProperty(State.active._entities[index],id,value);
    }
    public function updateField(uid:Int,id:String,data:Any){
        if(uid > State.active._entities.length-1) return;
        switch(id){
            case "_positions":
                var x = Util.fround(Reflect.getProperty(data,"x"),2);
                var y = Util.fround(Reflect.getProperty(data,"y"),2);
                if(index == uid){
                    rawData.position.x = x;
                    rawData.position.y = y;
                    inspector.redraw();
                }
                // State.active._entities[uid].raw.position = data;
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