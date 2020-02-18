package;

import haxe.ui.containers.menus.*;
import haxe.ui.core.Screen;
import haxe.ui.extended.NodeData;
import haxe.ui.data.ListDataSource;
import haxe.ui.events.UIEvent;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.events.MouseEvent;
import EditorTab.TItem;

#if arm_csm
import iron.data.SceneFormat;
#else
import kha.math.Vector2;
import kha.math.Vector3;
import found.State;
import found.object.Object;
import found.data.SceneFormat;
#end
@:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/editor-hierarchy.xml"))
class EditorHierarchy extends EditorTab {
    static public var inspector:EditorInspector;
    var selectedObjectUID : Int = -1;
    static var observers:Array<EditorHierarchyObserver> = [];

    public static function register(observer : EditorHierarchyObserver) : Void {
        observers.push(observer);
    }
    
    public static function unregister(observer : EditorHierarchyObserver) : Void {
        observers.remove(observer);
    }

    @:bind(tree,UIEvent.CHANGE) // @TODO: add custom event for object selection
    function onSelected(e:UIEvent) : Void {
        if(tree.selectedNode != null) {
            for(item in observers){
                item.notifyObjectSelectedInHierarchy(tree.selectedNode.data.path);
            }
        }
    }
    
    public function new(raw:TSceneFormat=null,p_inspector:EditorInspector = null) {
        super();
        this.text = "Hierarchy";
        inspector = p_inspector;
        titems = [
            {name:"Add Object",expands:false,onClicked: addObj2Scn},
            {name:"Add Sprite",expands:false,onClicked: addSprite2Scn},
            {name:"Add Emitter",expands:false,onClicked: addEmitter2Scn},
            {name:"Add Tilemap",expands:false,onClicked: addTilemap2Scn},
        ];
        tree.rclickItems = [
            {name:"Duplicate Object",expands:false,onClicked: duplicateObject},
            {name:"Remove Object",expands:false,onClicked: removeObject},
        ];
        pathItems = [
            {name:"Rename Scene",expands:false,onClicked:function(e:MouseEvent){
                trace("Implement renaming");
            }},
            {name: "Edit Scene Settings",expands:false,onClicked:function(e:MouseEvent){
                var cust = new CustomDialog({name:"Scene Settings",type:"warning"});
                var settings = new SceneSettings();
                cust.container.addComponent(settings);
                cust.show();
                cust.onDialogClosed = closeSceneEdit;
            }}
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

    function duplicateObject(e:MouseEvent){
        if(inspector.index >= 0){
            addData2Scn(State.active.raw._entities[inspector.index]);
        }
    }

    function removeObject(e:MouseEvent){
        if(inspector.index >= 0){
            rmvData2Scn(inspector.index);
        }
    }

    function addData2Scn(data:TObj){
        State.active.raw._entities.push(data);
        State.active.addEntity(data,true);
        tree.dataSource.add(getObjData([data],State.active.raw.name).get(0));
        tree.addNode(tree.dataSource.get(tree.dataSource.size-1));
    }

    @:access(found.object.Object,found.object.Executor)
    function rmvData2Scn(uid:Int){

        State.active._entities[uid].active  = false;
        for(exe in found.object.Executor.executors){
			var modified:Array<Any> = Reflect.field(found.object.Object,exe.field);
			modified.splice(uid,1);
		}

        State.active.raw._entities.splice(uid,1);
        State.active._entities.splice(uid,1);
        var data = tree.dataSource.get(uid);
        tree.dataSource.remove(data);
        tree.removeNode(data);
        
        // Reset scene
        Object.uidCounter--;
        for(i in 0...State.active._entities.length){
            Reflect.setProperty(State.active._entities[i],"uid",i);
            State.active._entities[i].dataChanged = true;
        }
        this.path.text+='*';
    }

    function addObj2Scn(e:MouseEvent){
        var data:TObj = {
            name: "Object",
            type: "object",
            position: new Vector2(),
            rotation: new Vector3(),
            width: 0.0,
            height:0.0,
            scale: new Vector2(1.0,1.0),
            center: new Vector2(),
            depth: 0.0,
            active: true
        };
        addData2Scn(data);
    }

    function addSprite2Scn(e:MouseEvent){
        var data:TSpriteData = {
            name: "Sprite",
            type: "sprite_object",
            position: new Vector2(),
            rotation:new Vector3(),
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
        addData2Scn(data);
    }

    function addTilemap2Scn(e:MouseEvent){
        var data:TTilemapData = {
            name: "Tilemap",
            type: "tilemap_object",
            position: new Vector2(0.0,0.0),
            rotation:new Vector3(),
            width: 1280.0,
            height:960.0,
            scale: new Vector2(1.0,1.0),
            center: new Vector2(),
            depth: 0.0,
            active: true,
            tileWidth: 64,
            tileHeight: 64,
            map: [],
            images: [{name: "Sprite",
            type: "sprite_object",
            position: new Vector2(),
            rotation:new Vector3(),
            width: 896.0,
            height:448.0,
            scale: new Vector2(1.0,1.0),
            center: new Vector2(),
            depth: 0.0,
            active: true,
            c_width:0.0,
            c_height:0.0,
            c_center: new Vector2(),
            shape: "",
            imagePath: "tilesheet",
            usedIds: [0],
            tileWidth: 64,
            tileHeight: 64 }],
            cull: false,
            cullOffset: 100
        };
        addData2Scn(data);
    }
    
    function addEmitter2Scn(e:MouseEvent){
        var data:TEmitterData = {
            name: "Emitter",
            type: "emitter_object",
            position: new Vector2(),
            rotation:new Vector3(),
            width: 0.0,
            height:0.0,
            scale: new Vector2(1.0,1.0),
            center: new Vector2(),
            depth: 0.0,
            active: true,
            amount: 1
        };
        addData2Scn(data);
    }
   
    var pathItems:Array<TItem> = null;// Initialized in new
    function closeSceneEdit(e:DialogEvent){
        var settings:SceneSettings = e.target.findComponent(SceneSettings,true);
        var nraw:TSceneFormat = {name:settings.sceneName.text,_depth: settings.depthSort.value};
        if(nraw._depth)nraw._Zsort = settings.zsort.value;
        if(settings.physOpts.text != '+'){
            nraw.physicsWorld = {
                width: settings.physWidth.value,
                height: settings.physHeight.value,
                x: settings.physX.value,
                y: settings.physY.value,
                gravity_x: settings.gravity_x.value,
                gravity_y: settings.gravity_y.value,
                iterations: settings.iterations.value,
                history: settings.history.value
            };
        }
        nraw._entities = State.active.raw._entities;
        nraw.traits = State.active.raw.traits;
        trace(nraw.name);
        trace(State.active.raw.name);
        trace(path.text);
        if(State.active.raw.name != nraw.name){
            var add = "";
            if(StringTools.contains(path.text,'*'))
                add = '*';
            path.text = nraw.name+add;
        }
        Reflect.setProperty(State.active,"raw",nraw);
        if(!StringTools.contains(path.text,'*'))
            path.text+='*';
        
    };
    @:bind(path,MouseEvent.RIGHT_CLICK)
    function sceneEdit(e:MouseEvent){
        var menu = new Menu();
        for(i in pathItems){
            trace(i.name);
            // if(i.filter != null && e.target.id != i.filter)continue;
            var item = new MenuItem();
            item.text  = i.name;
            item.expandable = i.expands;
            item.onClick = i.onClicked;
            menu.addComponent(item);
        }
        menu.show();
        menu.left = e.screenX;
        menu.top = e.screenY;
        Screen.instance.addComponent(menu);
    }
    
}
