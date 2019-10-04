package;

import haxe.ui.extended.NodeData;
import haxe.ui.extended.InspectorNode;
import haxe.ui.data.ListDataSource;
import haxe.ui.events.UIEvent;
import iron.data.SceneFormat;

@:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/editor-hierarchy.xml"))
class EditorHierarchy extends EditorTab {
    var inspector:EditorInspector;
    public function new(raw:TSceneFormat=null,p_inspector:EditorInspector = null) {
        super();
        inspector = p_inspector;
        setFromScene(raw);

    }

    public function setFromScene(raw:TSceneFormat){
        path.text = raw.name;
        tree.dataSource = getObjData(raw.objects,raw.name);
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
    function getIt(path:String){
        var ds = new ListDataSource<InspectorData>();
        var name = EditorUi.raw.name;
        StringTools.replace(path,'$name/',"");
        var obj:TObj = getObj(EditorUi.raw.objects,path);
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
        
        return ds;
    }
    function fetch(obj:TObj,field:String,type:String):Any{
        if(Reflect.hasField(obj,field)){
            var value = Reflect.field(obj,field);
            if(value != null){
                return value;
            }
        }
        var out:Any;
        switch(type){
            case 'Bool':
                out = field.indexOf("visible") >= 0;
            case 'String':
                out = "";
            case 'Array':
                out = [];
            default:
                out = null;
        }
        
        return out;
    }
    function getObj(objs:Null<Array<TObj>> , path:String){
        var split = path.split("/"); 
        var name = split[0];
        var isLast = split[split.length-1] == name;
        var out:TObj = null;
        for(obj in objs){
            if(name == obj.name && isLast){
                out= obj;
            }
            else if(name == obj.name && Reflect.hasField(obj,"children")){
                out = getObj(obj.children,StringTools.replace(path,'$name/',""));
            }
        }
        return out;
    }
    @:bind(tree,UIEvent.CHANGE)
    function updateInspector(e:UIEvent){
        if(inspector != null){
            inspector.tree.dataSource = getIt(tree.selectedNode.path);
        }
    }
}