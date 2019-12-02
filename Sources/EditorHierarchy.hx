package;

import haxe.ui.extended.NodeData;
import haxe.ui.extended.InspectorNode;
import haxe.ui.data.ListDataSource;
import haxe.ui.events.UIEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.KeyboardEvent;

#if arm_csm
import iron.data.SceneFormat;
#else
import kha.math.Vector2;
import coin.State;
import coin.object.Object;
import coin.data.SceneFormat;
#end
@:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/editor-hierarchy.xml"))
class EditorHierarchy extends EditorTab {
    static public var inspector:EditorInspector;
    public function new(raw:TSceneFormat=null,p_inspector:EditorInspector = null) {
        super();
        inspector = p_inspector;
        titems = [
            {name:"Add Object",expands:false,onClicked: addObj2Scn},
            {name:"Add Sprite",expands:false,onClicked: addSprite2Scn},
            {name:"Add Emitter",expands:false,onClicked: addEmitter2Scn},
        ];
        setFromScene(raw,true);

    }

    public function setFromScene(raw:TSceneFormat,onBoot:Bool = false){
        path.text = raw.name;
        if(!onBoot){
            tree.clear();
            inspector.tree.clear();
        }
            
        #if arm_csm
        tree.dataSource = getObjData(raw.objects,raw.name);
        #else
        tree.dataSource = getObjData(raw._entities,raw.name);
        #end
    }

    function getObjData(objs:Array<TObj>,path:String):ListDataSource<NodeData>{
        path+='/';
        var ds = new ListDataSource<NodeData>();
        for(obj in objs){
            if(Reflect.hasField(obj,"children")){
                ds.add({
                    name: obj.name,
                    path: path,
                    type:"img/"+obj.type,
                    childs: getObjData(obj.children,path+obj.name)
                });
            }
            else {
                ds.add({
                    name: obj.name,
                    path: path+obj.name,
                    type:"img/"+obj.type
                });
            }
        }
        return ds;
    }
    

    @:bind(tree,MouseEvent.RIGHT_CLICK)
    function rightClick(e:MouseEvent){
        super.onRightclickcall(e);
    }

    function addObj2Scn(e:MouseEvent){
        var data:TObj = {
            name: "Object",
            type: "object",
            position: new Vector2(),
            rotation:0.0,
            width: 0.0,
            height:0.0,
            scale: new Vector2(1.0,1.0),
            center: new Vector2(),
            depth: 0.0,
            active: true
        };
        State.active.raw._entities.push(data);
        State.active.addEntity(data,true);
        tree.dataSource.add(getObjData([data],EditorUi.raw.name).get(0));
        tree.addNode(tree.dataSource.get(tree.dataSource.size-1));
    }

    function addSprite2Scn(e:MouseEvent){
        var data:TSpriteData = {
            name: "Sprite",
            type: "sprite_object",
            position: new Vector2(),
            rotation:0.0,
            width: 250.0,
            height:250.0,
            scale: new Vector2(1.0,1.0),
            center: new Vector2(),
            depth: 0.0,
            active: true,
            c_width:0.0,
            c_height:0.0,
            c_center: new Vector2(),
            shape: "",
            imagePath: "basic"
        };
        State.active.raw._entities.push(data);
        State.active.addEntity(data,true);
        tree.dataSource.add(getObjData([data],EditorUi.raw.name).get(0));
        tree.addNode(tree.dataSource.get(tree.dataSource.size-1));
    }
    
    function addEmitter2Scn(e:MouseEvent){
        var data:TEmitterData = {
            name: "Emitter",
            type: "emitter_object",
            position: new Vector2(),
            rotation:0.0,
            width: 0.0,
            height:0.0,
            scale: new Vector2(1.0,1.0),
            center: new Vector2(),
            depth: 0.0,
            active: true,
            amount: 1
        };
        State.active.raw._entities.push(data);
        State.active.addEntity(data,true);
        tree.dataSource.add(getObjData([data],EditorUi.raw.name).get(0));
        tree.addNode(tree.dataSource.get(tree.dataSource.size-1));
    }
    @:bind(tree,UIEvent.CHANGE)
    function updateInspector(e:UIEvent){
        if(inspector != null && tree.selectedNode != null){
            var out:{ds:ListDataSource<InspectorData>,obj:TObj,index:Int} = getInspectorNode(tree.selectedNode.path);
            inspector.tree.dataSource = out.ds;
            inspector.rawData = out.obj;
            inspector.index = out.index;
        }
    }

    static function fetch(obj:TObj,field:String,type:String):Any{
        if(Reflect.hasField(obj,field)){
            var value = Reflect.field(obj,field);
            if(value != null){
                return value;
            }
        }
        var out:Any;
        switch(type){
            case 'Bool':
                out = field.indexOf("visible") >= 0 || field.indexOf("active") >= 0 ;
            case 'String':
                out = "";
            case 'Array':
                out = [];
            default:
                out = null;
        }
        
        return out;
    }

    function getObj(objs:Array<Object> , path:String){
        var split = path.split("/"); 
        var name = split[0];
        var isLast = split[split.length-1] == name;
        var i= -1;
        var out:TObj = null;
        for(obj in objs){
            if(name == obj.name && isLast){
                out= obj.raw;
                i = obj.uid;
            }
            // else if(name == obj.name && Reflect.hasField(obj,"children")){
            //     out = getObj(obj.children,StringTools.replace(path,'$name/',""));
            // }
        }
        return {obj: out, index: i};
    }
    
    function getInspectorNode(path:String){
        var ds = new ListDataSource<InspectorData>();
        var name = EditorUi.raw.name;
        StringTools.replace(path,'$name/',"");
    #if arm_csm
        var dat:{obj:TObj, index:Int} =getObj(EditorUi.raw.objects,path);
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
    #elseif coin
        var dat:{obj:TObj, index:Int} = getObj(State.active._entities,path);
        var obj:TObj = dat.obj;
        ds.add(getIDataFrom(obj));
        var out = ds.get(ds.size-1);

        for(f in Reflect.fields(out)){
            if(EditorInspector.defaults.exists(f)) continue;

            if(!Reflect.hasField(obj,f)){
                trace('Field $f was deleted from '+out.name);
                Reflect.deleteField(out,f);
            }
        }
    #end
        return {ds:ds,obj:obj,index:dat.index};
    }
    public static function getIDataFrom(obj:TObj){
        var scale = Reflect.hasField(obj,'scale') ? obj.scale: new kha.math.Vector2(1.0,1.0);
        var path = State.active.raw.name+"/"+obj.name;
        var data:InspectorData = {
            name: obj.name,
            path: path,
            type:"img/"+obj.type,
            px: obj.position.x,
            py: obj.position.y,
            pz: obj.depth,
            sx: scale.x,
            sy: scale.y,
            rz: obj.rotation,
            w: obj.width,
            h: obj.height,
            active: obj.active,
            imagePath: fetch(obj,"imagePath",'String'),
            traits: fetch(obj,"traits",'Array'),
        };
        return data;
    }
    
}