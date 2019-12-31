package;

import haxe.ui.components.Button;
import haxe.ui.core.Component;
import haxe.ui.containers.menus.*;
import haxe.ui.core.Screen;
import haxe.ui.Toolkit;
import kha.FileSystem;
import haxe.ui.events.UIEvent;
#if arm_csm
import iron.Trait;
import iron.data.SceneFormat;
import iron.system.ArmPack;
// import iron.format.BlendParser;
#elseif coin
import coin.Trait;
import coin.State;
import coin.Coin;
import coin.object.Object.MoveData;
import coin.data.SceneFormat;
#end

class EditorUi extends Trait{
    public var keys:{ctrl:Bool,alt:Bool,shift:Bool} = {ctrl:false,alt:false,shift:false};
    public var editor:EditorView;
    public var inspector:EditorInspector;
    public var hierarchy:EditorHierarchy;
    var projectmanager:ManagerView;
    var dialog:FileBrowserDialog;
    public var gameView:EditorGameView; 
    static public var raw:TSceneFormat =null;
    static public var scenePath:String = "";
    static public var projectPath:String = "..";
    // static var bl:BlendParser = null;
    var isBlend = false;
    public function new(plist:Array<foundry.data.Project.TProject> = null){
        super();
        Toolkit.init();
        if(plist != null){
            projectmanager = new ManagerView(plist);
            Screen.instance.addComponent(projectmanager);
        }
        else {
            #if arm_csm
            iron.App.notifyOnInit(function(){
                iron.Scene.active.notifyOnInit(init);
            });
            iron.App.notifyOnReset(function(){
                iron.Scene.active.notifyOnInit(init);
            });
            iron.App.notifyOnRender2D(render);
            #elseif coin
            init();
            #end
        }
        

    }
    function init(){
        kha.FileSystem.init(function(){
            trace('Hello Cruel World !');
            gameView = new EditorGameView();
            editor = new EditorView();
            // var path = FileSystem.fixPath(projectPath)+"/build_bowling/compiled/Assets/Scene.arm";//"/bowling.blend";
            // if(StringTools.endsWith(path,"blend")){
            //     isBlend = true;
            // }//'$path

            // iron.data.Data.getBlob(path,createHierarchy);
            #if arm_csm
            createHierarchy(iron.Scene.active.raw);
            #elseif coin
            createHierarchy(coin.State.active.raw);
            #end
            
            var tab = new ProjectExplorer(projectPath);
            var menu  = new EditorMenu();
            editor.header.addComponent(menu);
            editor.ePanelBottom.addComponent(tab);
            var tools = new EditorTools(editor);
            Screen.instance.addComponent(editor);
        });
    }
    function createHierarchy(blob:TSceneFormat){
        // if(isBlend){
        //     bl = new BlendParser(blob);
        //     trace(bl.dir("Scene"));
        //     var scenes = bl.get("Scene");
        //     trace(scenes.length);
        // }else{
            // raw = ArmPack.decode(blob.bytes);
            raw = blob;
            inspector = new EditorInspector();
            editor.ePanelRight.addComponent(inspector);
            hierarchy = new EditorHierarchy(blob,inspector);
            editor.ePanelLeft.addComponent(hierarchy);
            editor.ePanelTop.addComponent(gameView);
        // }
        
    }
    public function update(): Void {

    }

    #if coin
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
        var scaleFactor = Math.ceil(gameView.w)/Coin.WIDTH;

        var px = ((x-gameView.x-minusX)/gameView.w)*Coin.WIDTH;
        var py = ((y-gameView.y-minusY)/gameView.h)*Coin.HEIGHT;
        
        //Get scaling values
        var direction = 1;
        if(arrow == 0){
            direction = curPos.x-px > 0 ? -1:1;
        }
        else if(arrow == 1){
            direction = curPos.y-py < 0 ? -1:1;
        }
        var sx = direction*(Math.abs(curPos.x-px)/Coin.WIDTH);
        var sy = direction*(Math.abs(curPos.y-py)/Coin.HEIGHT);
        
        //Clamp position to grid
        if(gridMove || keys.ctrl){//Clamp to grid
            doUpdate  = Math.abs(curPos.x-px) > Coin.GRID*0.99 || Math.abs(px-curPos.x) > Coin.GRID*0.99;
            px = Math.floor(px);
            px += (Coin.GRID-(px % Coin.GRID));
        }
        if(gridMove || keys.ctrl ){//Clamp to grid
            doUpdate  = doUpdate ? doUpdate : Math.abs(curPos.y-py) > Coin.GRID*0.99 || Math.abs(py-curPos.y) > Coin.GRID*0.99;
            py = Math.floor(py);
            py += (Coin.GRID-(py % Coin.GRID));
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
        
        if(px+((minusX+(minusX/5)*2)/gameView.w)*Coin.WIDTH > Coin.WIDTH || px < 0 || py > Coin.HEIGHT ||py+((minusY+(minusY/5)*2)/gameView.h)*Coin.HEIGHT < 0){
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
            FileSystem.saveToFile(scenePath,haxe.io.Bytes.ofString(haxe.Json.stringify(State.active.raw)));
            hierarchy.path.text = StringTools.replace(hierarchy.path.text,'*','');
        }
    }
    #elseif arm_csm
    public function saveSceneData(){
        trace("Implement me");
    }
    #end
    
}