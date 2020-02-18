package;

import haxe.ui.components.Button;
import haxe.ui.core.Component;
import haxe.ui.containers.menus.*;
import haxe.ui.core.Screen;
import haxe.ui.containers.TabView;
import haxe.ui.Toolkit;
import kha.FileSystem;
import haxe.ui.events.UIEvent;
#if arm_csm
import iron.Trait;
import iron.data.SceneFormat;
import iron.system.ArmPack;
// import iron.format.BlendParser;
#elseif found
import found.Trait;
import found.State;
import found.Found;
import found.object.Object.MoveData;
import found.data.SceneFormat;
#end

class EditorUi extends Trait{
    public var keys:{ctrl:Bool,alt:Bool,shift:Bool} = {ctrl:false,alt:false,shift:false};
    public var editor:EditorView;
    public var inspector:EditorInspector;
    public var hierarchy:EditorHierarchy;
    var projectmanager:ManagerView;
    var dialog:FileBrowserDialog;
    public var gameView:EditorGameView;
    var codeView:EditorCodeView;
    var animationView:EditorAnimationView;
    public static var scenePath:String = "";
    public static  var projectPath:String = ".";
    public static var cwd:String = '.';
    // static var bl:BlendParser = null;
    var isBlend = false;

    public function new(){
        super();
        Toolkit.init();
        kha.FileSystem.init(function(){
            gameView = new EditorGameView();
            var done = function(){

                if(editor != null)
                    Screen.instance.removeComponent(editor);
                Screen.instance.addComponent(projectmanager);
            }
            if(!FileSystem.exists(EditorUi.cwd+"/pjml.found")){
                projectmanager = new ManagerView();
                done();
            }
            else {
                #if kha_html5
                for(key in kha.FileSystem.dbKeys.keys()){
                    if(key == EditorUi.cwd+"/pjml.found")continue;
                    kha.FileSystem.getContent(key,function(data:String){
                        #if debug
                        trace('Fetched data from $key');
                        #end
                    });
                }
                #end
                kha.FileSystem.getContent(EditorUi.cwd+"/pjml.found",function(data:String){
                    var out:{list:Array<found.data.Project.TProject>} = haxe.Json.parse(data);
                    projectmanager = new ManagerView(out.list);
                    done();
                });
            }
                
            
            // else {
            //     #if arm_csm
            //     iron.App.notifyOnInit(function(){
            //         iron.Scene.active.notifyOnInit(init);
            //     });
            //     iron.App.notifyOnReset(function(){
            //         iron.Scene.active.notifyOnInit(init);
            //     });
            //     iron.App.notifyOnRender2D(render);
            //     #elseif found
            //     init();
            //     #end
            // }
        });

    }

    public function init(){
        if(projectmanager != null)
            Screen.instance.removeComponent(projectmanager);
        editor = new EditorView();
        codeView = new EditorCodeView();
        animationView = new EditorAnimationView();
        // var path = FileSystem.fixPath(projectPath)+"/build_bowling/compiled/Assets/Scene.arm";//"/bowling.blend";
        // if(StringTools.endsWith(path,"blend")){
        //     isBlend = true;
        // }//'$path

        // iron.data.Data.getBlob(path,createHierarchy);
        #if arm_csm
        createHierarchy(iron.Scene.active.raw);
        #elseif found
        createHierarchy(found.State.active.raw);
        #end
        
        var tab = new ProjectExplorer(projectPath);
        var menu  = new EditorMenu();
        editor.header.addComponent(menu);
        addToParent(editor.ePanelBottom,tab);
        var tools = new EditorTools(editor);
        Screen.instance.addComponent(editor);
    }
    function createHierarchy(blob:TSceneFormat){
        // if(isBlend){
        //     bl = new BlendParser(blob);
        //     trace(bl.dir("Scene"));
        //     var scenes = bl.get("Scene");
        //     trace(scenes.length);
        // }else{
            // raw = ArmPack.decode(blob.bytes);
            inspector = new EditorInspector();
            addToParent(editor.ePanelRight,inspector);
            hierarchy = new EditorHierarchy(blob,inspector);
            addToParent(editor.ePanelLeft,hierarchy);
            addToParent(editor.ePanelTop,gameView);// @TODO: Do we really need to put this here ?
            addToParent(editor.ePanelTop,codeView);
            addToParent(editor.ePanelTop,animationView);
        // }
        
    }
    @:access(EditorTab)
    public function addToParent(parent:TabView, child:EditorTab){
        parent.addComponent(child);
        child.init(parent);
    }
    public function update(): Void {

    }

    #if found
    public static var activeMouse:Bool = false;
    public static var gridMove:Bool = false;
    public static var arrow:Int = -1;
    public static var arrowMode:Int = 0;// 0 = Move; 1 = Scale
    public static var minusX:Float = 0;// Basically the arrow size maybe @RENAME ?
    public static var minusY:Float = 0;// Basically the arrow size maybe @RENAME ?
    static var event:UIEvent = new UIEvent(UIEvent.CHANGE);
    @:access(EditorInspector)
    public function updateMouse(x:Int,y:Int,cx:Int,cy:Int){
        var doUpdate = true;
        var curPos = State.active._entities[inspector.index].position;
        var scale = State.active._entities[inspector.index].scale;
        var scaleFactor = Math.ceil(gameView.w)/Found.WIDTH;

        var px = ((x-gameView.x-minusX)/gameView.w)*Found.WIDTH;
        var py = ((y-gameView.y-minusY)/gameView.h)*Found.HEIGHT;
        
        //Get scaling values
        var direction = 1;
        if(arrow == 0){
            direction = curPos.x-px > 0 ? -1:1;
        }
        else if(arrow == 1){
            direction = curPos.y-py < 0 ? -1:1;
        }
        var sx = direction*(Math.abs(curPos.x-px)/Found.WIDTH);
        var sy = direction*(Math.abs(curPos.y-py)/Found.HEIGHT);
        
        //Clamp position to grid
        if(gridMove || keys.ctrl){//Clamp to grid
            doUpdate  = Math.abs(curPos.x-px) > Found.GRID*0.99 || Math.abs(px-curPos.x) > Found.GRID*0.99;
            px = Math.floor(px);
            px += (Found.GRID-(px % Found.GRID));
        }
        if(gridMove || keys.ctrl ){//Clamp to grid
            doUpdate  = doUpdate ? doUpdate : Math.abs(curPos.y-py) > Found.GRID*0.99 || Math.abs(py-curPos.y) > Found.GRID*0.99;
            py = Math.floor(py);
            py += (Found.GRID-(py % Found.GRID));
        }

        if(doUpdate){
            if(arrowMode == 0 || arrow == 2){
                updatePos(px,py);
            }
            else if(arrowMode == 1){
                if(keys.ctrl && arrow == 0){
                    updateScale(scale.x+sx,scale.y+sx);
                }
                else if(keys.ctrl && arrow == 1){
                    updateScale(scale.x+sy,scale.y+sy);
                }
                else{
                    updateScale(scale.x+sx,scale.y+sy);
                }
            }
            
        }
        
        if(px+((minusX+(minusX/5)*2)/gameView.w)*Found.WIDTH > Found.WIDTH || px < 0 || py > Found.HEIGHT ||py+((minusY+(minusY/5)*2)/gameView.h)*Found.HEIGHT < 0){
            activeMouse = false;
            return;
        }
    }
    @:access(EditorInspector)
    function updateScale(sx:Float,sy:Float){
        if(keys.ctrl){
            State.active._entities[inspector.index].resize(
                function(data:kha.math.Vector2){
                    data.x = sx;
                    data.y = sy;
                    return data;
            });
            Reflect.setProperty(State.active.raw._entities[inspector.index].scale,"x",sx);
            inspector.updateData(event);
        }
        else{
            switch(arrow){
                case 0:
                    State.active._entities[inspector.index].resize(
                        function(data:kha.math.Vector2){
                            data.x = sx;
                            return data;
                    });
                    Reflect.setProperty(State.active.raw._entities[inspector.index].scale,"x",sx);
                    inspector.updateData(event);
                case 1:
                    State.active._entities[inspector.index].resize(
                        function(data:kha.math.Vector2){
                            data.y = sy;
                            return data;
                    });
                    Reflect.setProperty(State.active.raw._entities[inspector.index].scale,"y",sy);
                    inspector.updateData(event);
            }
        }
    }
    @:access(EditorInspector)
    function updatePos(px:Float,py:Float){
        switch(arrow){
            case 0:
                State.active._entities[inspector.index].translate(
                    function(data:MoveData){
                        data._positions.x = px;
                        return data;
                });
                Reflect.setProperty(State.active.raw._entities[inspector.index].position,"x",px);
                inspector.updateData(event);
            case 1:
                State.active._entities[inspector.index].translate(
                    function(data:MoveData){
                        data._positions.y = py;
                        return data;
                });
                Reflect.setProperty(State.active.raw._entities[inspector.index].position,"y",py);
                inspector.updateData(event);
            case 2:
                State.active._entities[inspector.index].translate(
                    function(data:MoveData){
                        data._positions.x = px;
                        data._positions.y = py;
                        return data;
                });
                Reflect.setProperty(State.active.raw._entities[inspector.index].position,"x",px);
                Reflect.setProperty(State.active.raw._entities[inspector.index].position,"y",py);
                inspector.updateData(event);
        }
    }
    public function saveSceneData(){
        if(StringTools.contains(hierarchy.path.text,'*')){
            var i = 0;
            for(entity in State.active._entities){
                if(entity.dataChanged){
                    State.active.raw._entities[i] = entity.raw; 
                }
                i++;
            }
            FileSystem.saveContent(scenePath,haxe.Json.stringify(State.active.raw));
            hierarchy.path.text = StringTools.replace(hierarchy.path.text,'*','');
        }
    }
    #elseif arm_csm
    public function saveSceneData(){
        trace("Implement me");
    }
    #end
    
}