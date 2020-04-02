package;

import found.data.DataLoader;
import zui.Zui;
import kha.input.KeyCode;
import haxe.ui.components.Button;
import haxe.ui.core.Component;
import haxe.ui.containers.menus.*;
import haxe.ui.core.Screen;
import haxe.ui.containers.TabView;
import haxe.ui.Toolkit;
import khafs.Fs;
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
import found.math.Util;
import found.object.Object.MoveData;
import found.data.SceneFormat;
#end

import utilities.Config;

class EditorUi extends Trait{
    public var visible(default,set) = true;
    function set_visible(v:Bool){
        if(inspector == null)return true;
        if(v){
            registerInput();
        }
        else {
            unregisterInput();
        }
        return inspector.inspector.visible  = visible  = v;
    }
    public var keys:{ctrl:Bool,alt:Bool,shift:Bool} = {ctrl:false,alt:false,shift:false};
    public var editor:EditorView;
    public var inspector:EditorInspector;
    public var hierarchy:EditorHierarchy;
    public var isPlayMode:Bool;
    var projectmanager:ManagerView;
    var dialog:FileBrowserDialog;
    public var gameView:EditorGameView;
    public var codeView:EditorCodeView;
    var animationView:EditorAnimationView;
    var projectExplorer:ProjectExplorer;
    var menu:EditorMenuBar;
    public static var scenePath:String = "";
    public static  var projectPath(default,set):String = ".";
    static function set_projectPath(path:String){
        Reflect.setField(ProjectExplorer,"currentPath",path);
        return projectPath = path;
    }
    public static var cwd:String = '.';
    // static var bl:BlendParser = null;
    var isBlend = false;
    public var ui:Zui;
    public function new(){
        super();
        Toolkit.init();
        ui = new Zui({font: kha.Assets.fonts.font_default,autoNotifyInput: false});
        Fs.init(function(){
            Config.load(function() {
                Config.init();
                isPlayMode = Config.raw.defaultPlayMode;
                gameView = new EditorGameView();
                var done = function(){

                    if(editor != null)
                        Screen.instance.removeComponent(editor);
                    Screen.instance.addComponent(projectmanager);
                    registerInput();
                }
                
                if(!Fs.exists(EditorUi.cwd+"/pjml.found")){
                    projectmanager = new ManagerView();
                    done();
                }
                else {
                    #if kha_html5
                    for(key in Fs.dbKeys.keys()){
                        if(key == EditorUi.cwd+"/pjml.found")continue;
                        Fs.getContent(key,function(data:String){
                            #if debug
                            trace('Fetched data from $key');
                            #end
                        });
                    }
                    #end
                    Fs.getContent(EditorUi.cwd+"/pjml.found",function(data:String){
                        var out:{list:Array<found.data.Project.TProject>} = haxe.Json.parse(data);
                        projectmanager = new ManagerView(out.list);
                        done();
                    });

                }
            });    
            
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

    public function render(canvas:kha.Canvas){

        ui.begin(canvas.g2);
        if(menu != null)
            menu.render(ui);
        if(inspector != null)
            inspector.render(ui);
        if(animationView != null)
            animationView.render(ui);
        if(codeView != null)
            codeView.render(ui);
        if(hierarchy != null)
            hierarchy.render(ui);
        if(projectExplorer != null)
            projectExplorer.render(ui);
        ui.end();
        if(EditorMenu.show){
            EditorMenu.render(canvas.g2);
        }

    }

    function registerInput(){
        kha.input.Mouse.get().notify(onMouseDownEditor, onMouseUpEditor, onMouseMoveEditor, onMouseWheelEditor);
        kha.input.Keyboard.get().notify(onKeyDownEditor, onKeyUpEditor, onKeyPressEditor);
        #if (kha_android || kha_ios)
        if (kha.input.Surface.get() != null) kha.input.Surface.get().notify(onTouchDownEditor, onTouchUpEditor, onTouchMoveEditor);
        #end
    }
    function unregisterInput(){
        kha.input.Mouse.get().remove(onMouseDownEditor, onMouseUpEditor, onMouseMoveEditor, onMouseWheelEditor);
        kha.input.Keyboard.get().remove(onKeyDownEditor, onKeyUpEditor, onKeyPressEditor);
        #if (kha_android || kha_ios)
        if (kha.input.Surface.get() != null) kha.input.Surface.get().remove(onTouchDownEditor, onTouchUpEditor, onTouchMoveEditor);
        #end
    }

    function onMouseDownEditor(button: Int, x: Int, y: Int) {
        ui.onMouseDown(button,x,y);
    }
    function onMouseUpEditor(button: Int, x: Int, y: Int) {
        ui.onMouseUp(button,x,y);
    }
    function onMouseMoveEditor(x: Int, y: Int, movementX: Int, movementY: Int) {
        ui.onMouseMove(x,y,movementX,movementY);
    }
    function onMouseWheelEditor(delta: Int) {
        ui.onMouseWheel(delta);
    }
    function onKeyDownEditor(code: kha.input.KeyCode) {
        ui.onKeyDown(code);
    }
    function onKeyUpEditor(code: kha.input.KeyCode) {
        ui.onKeyUp(code);
    }
    function onKeyPressEditor(char: String) {
        ui.onKeyPress(char);
    }

    #if (kha_android || kha_ios)
	function onTouchDownEditor(index: Int, x: Int, y: Int) {
		// Two fingers down - right mouse button
		if (index == 1) { ui.onMouseDown(0, x, y); ui.onMouseDown(1, x, y); }
	}

	function onTouchUpEditor(index: Int, x: Int, y: Int) {
		if (index == 1) ui.onMouseUp(1, x, y);
	}

	function onTouchMoveEditor(index: Int, x: Int, y: Int) {}
	#end

    public function init(){
        if(projectmanager != null)
            Screen.instance.removeComponent(projectmanager);
        editor = new EditorView();
        codeView = new EditorCodeView();
        animationView = new EditorAnimationView(ui);

        #if arm_csm
        createHierarchy(iron.Scene.active.raw);
        #elseif found
        createHierarchy(found.State.active.raw);
        #end
        
        projectExplorer = new ProjectExplorer();
        menu  = new EditorMenuBar();
        editor.header.addComponent(menu);
        addToParent(editor.ePanelBottom,projectExplorer);
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
            inspector = new EditorInspector(ui);
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
    public function update(dt:Float): Void {
        if(animationView != null) {
            animationView.update(dt);
        }
    }
    public function onKeyPressed(keyCode:KeyCode){
        if(keyCode == KeyCode.F9){
			Found.fullscreen = !Found.fullscreen;
		}
		if(keyCode == KeyCode.F1){
			EditorUi.arrowMode = 0;
		}
		if(keyCode == KeyCode.F2){
			EditorUi.arrowMode = 1;
        }
        if(keyCode == KeyCode.Space && animationView != null){
            animationView.notifyPlayPause();
        }
		if(keyCode == KeyCode.S && keys.ctrl)
			saveSceneData();
		if(keyCode == KeyCode.Control)
			keys.ctrl = true;
		if(keyCode == KeyCode.Alt)
			keys.alt = true;
		if(keyCode == KeyCode.Shift)
			keys.shift = true;
    }
    public function onKeyReleased(keyCode:KeyCode):Void {
        if(keyCode == KeyCode.Control)
			keys.ctrl = false;
		if(keyCode == KeyCode.Alt)
			keys.alt = false;
		if(keyCode == KeyCode.Shift)
			keys.shift = false;
    }
    public function onMousePressed(button:Int, x:Int, y:Int):Void {
        if(button==2){
            activeMiddleMouse = true;
        }
    }
    public function onMouseReleased(button:Int, x:Int, y:Int):Void {
        if(activeMouse && button == 0/* Left */){
			activeMouse = false;
		}
        if(button==2){
            activeMiddleMouse = false;
        }
    }
    public function onMouseMove(x:Int, y:Int, mx:Int, my:Int):Void {
        if(activeMiddleMouse){
            if(State.active!= null){
                State.active.cam.position.x+=mx;
                State.active.cam.position.y+=my;
            }
        }
    }

    #if found
    public static var activeMiddleMouse:Bool = false;
    public static var activeMouse:Bool = false;
    public static var gridMove:Bool = false;
    public static var arrow:Int = -1;
    public static var arrowMode:Int = 0;// 0 = Move; 1 = Scale
    public static var minusX:Float = 0;// Basically the arrow size maybe @RENAME ?
    public static var minusY:Float = 0;// Basically the arrow size maybe @RENAME ?
    static var event:UIEvent = new UIEvent(UIEvent.CHANGE);
    @:access(EditorInspector)
    public function updateMouse(x:Int,y:Int,cx:Int,cy:Int){
        // x += Std.int(State.active.cam.position.x);
        // y += Std.int(State.active.cam.position.y);
        var doUpdate = true;
        var curPos = State.active._entities[inspector.index].position;
        var scale = State.active._entities[inspector.index].scale;
        var scaleFactor = Math.ceil(gameView.w)/Found.WIDTH;

        var px = ((x-gameView.x-minusX)/gameView.w)*Found.WIDTH+State.active.cam.position.x;
        var py = ((y-gameView.y-minusY)/gameView.h)*Found.HEIGHT+State.active.cam.position.y;
        
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
            px = Util.snap(px,Found.GRID);
        }
        if(gridMove || keys.ctrl ){//Clamp to grid
            doUpdate  = doUpdate ? doUpdate : Math.abs(curPos.y-py) > Found.GRID*0.99 || Math.abs(py-curPos.y) > Found.GRID*0.99;
            py = Math.floor(py);
            py = Util.snap(py,Found.GRID);
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
        
        if(px+((minusX+(minusX/5)*2)/gameView.w)*Found.WIDTH > Found.WIDTH +State.active.cam.position.x || px < State.active.cam.position.x || py > Found.HEIGHT+State.active.cam.position.y ||py+((minusY+(minusY/5)*2)/gameView.h)*Found.HEIGHT < State.active.cam.position.y){
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
                case 1:
                    State.active._entities[inspector.index].resize(
                        function(data:kha.math.Vector2){
                            data.y = sy;
                            return data;
                    });
                    Reflect.setProperty(State.active.raw._entities[inspector.index].scale,"y",sy);
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
            case 1:
                State.active._entities[inspector.index].translate(
                    function(data:MoveData){
                        data._positions.y = py;
                        return data;
                });
                Reflect.setProperty(State.active.raw._entities[inspector.index].position,"y",py);
            case 2:
                State.active._entities[inspector.index].translate(
                    function(data:MoveData){
                        data._positions.x = px;
                        data._positions.y = py;
                        return data;
                });
                Reflect.setProperty(State.active.raw._entities[inspector.index].position,"x",px);
                Reflect.setProperty(State.active.raw._entities[inspector.index].position,"y",py);
        }
    }
    @:access(found.anim.Sprite)
    public function saveSceneData(){
        if(StringTools.contains(EditorHierarchy.sceneName,'*')){
            var i = 0;
            for(entity in State.active._entities){
                if(entity.dataChanged){
                    State.active.raw._entities[i] = entity.raw;
                }
                i++;
            }
            Fs.saveContent(scenePath,DataLoader.stringify(State.active.raw));
            EditorHierarchy.sceneName = StringTools.replace(EditorHierarchy.sceneName,'*','');
        }
    }
    #elseif arm_csm
    public function saveSceneData(){
        trace("Implement me");
    }
    #end
    
}