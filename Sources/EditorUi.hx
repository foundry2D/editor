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
import found.Input;
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
    public var editor:EditorView;
    public var inspector:EditorInspector;
    public var hierarchy:EditorHierarchy;
    public var isPlayMode:Bool;
    var managerEditor:EditorView;
    var projectmanager:ManagerView;
    var dialog:FileBrowserDialog;
    public var gameView:EditorGameView;
    public var codeView:EditorCodeView;
    var animationView:EditorAnimationView;
    var projectExplorer:ProjectExplorer;
    var center:CenterPanel;
    var bottom:BottomPanel;
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
    var keyboard:found.Input.Keyboard;
    var mouse:found.Input.Mouse;
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
                    Fs.getContent(EditorUi.cwd+"/pjml.found",function(data:String){
                        var out:{list:Array<found.data.Project.TProject>} = haxe.Json.parse(data);
                        projectmanager = new ManagerView(out.list);
                        done();
                    });
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
        // if(animationView != null)
        //     animationView.render(ui);
        // if(codeView != null)
        //     codeView.render(ui);
        if(bottom != null)
            bottom.render(ui);
        if(hierarchy != null)
            hierarchy.render(ui);
        if(center != null)
            center.render(ui);
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
        center = new CenterPanel();
        bottom = new BottomPanel();
        projectExplorer = new ProjectExplorer();
        bottom.addTab(projectExplorer);
        codeView = new EditorCodeView();
        animationView = new EditorAnimationView();
        center.addTab(gameView);
        center.addTab(codeView);
        center.addTab(animationView);

        #if arm_csm
        createHierarchy(iron.Scene.active.raw);
        #elseif found
        createHierarchy(found.State.active.raw);
        #end
        
        
        menu  = new EditorMenuBar();
        editor.header.addComponent(menu);
        editor.ePanelBottom.addComponent(bottom);
        var tools = new EditorTools(editor);
        Screen.instance.addComponent(editor);
        keyboard = Input.getKeyboard();
        mouse = Input.getMouse();
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
            editor.ePanelRight.addComponent(inspector);
            hierarchy = new EditorHierarchy(blob,inspector);
            editor.ePanelLeft.addComponent(hierarchy);
            editor.ePanelTop.addComponent(center);
            // addToParent(editor.ePanelTop,codeView);
            // addToParent(editor.ePanelTop,animationView);
        // }
        
    }
    @:access(EditorTab)
    public function addToParent(parent:TabView, child:EditorTab){
        parent.addComponent(child);
        child.init(parent);
    }
    var lastChange:Float = 0.0;
    public function update(dt:Float): Void {
        if(mouse == null || keyboard == null)return;

        if(keyboard.started("s") && keyboard.down("control"))
			saveSceneData();

        if(animationView != null) {
            animationView.update(dt);
            if(keyboard.started("space")){
                animationView.notifyPlayPause();
            }
        }
        
        //Game View based Input
        if(gameView.active)
        {
            if(keyboard.down("f9") && 0.1 < kha.Scheduler.time()-lastChange){
                lastChange = kha.Scheduler.time();
                Found.fullscreen = !Found.fullscreen;
            }
            if(keyboard.started("f1")){
                EditorUi.arrowMode = 0;
            }
            if(keyboard.started("f2")){
                EditorUi.arrowMode = 1;
            }

            if(mouse.down("middle") && mouse.moved){
                if(State.active!= null){
                    State.active.cam.position.x+=mouse.distX;
                    State.active.cam.position.y+=mouse.distY;
                }
            }
            if(mouse.down("left") && mouse.moved){
                updateMouse(mouse.x,mouse.y,mouse.distX,mouse.distY);
            }
            else{
                arrow = -1;
            }
        }
        
    }

    #if found
    public static var gridMove:Bool = false;
    public static var arrow:Int = -1;
    public static var arrowMode:Int = 0;// 0 = Move; 1 = Scale
    public static var minusX:Float = 0;// Basically the arrow size maybe @RENAME ?
    public static var minusY:Float = 0;// Basically the arrow size maybe @RENAME ?
    static var event:UIEvent = new UIEvent(UIEvent.CHANGE);
    @:access(EditorInspector)
    public function updateMouse(x:Float,y:Float,cx:Float,cy:Float){
        if(inspector.index==-1)return;

        var doUpdate = true;
        var curPos = State.active._entities[inspector.index].position;
        var scale = State.active._entities[inspector.index].scale;
        var scaleFactor = Math.ceil(gameView.width)/Found.WIDTH;

        var px = ((x-gameView.x-minusX)/gameView.width)*Found.WIDTH+State.active.cam.position.x;
        var py = ((y-gameView.y-minusY)/gameView.height)*Found.HEIGHT+State.active.cam.position.y;
        
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
        if(gridMove || keyboard.down("control")){//Clamp to grid
            doUpdate  = Math.abs(curPos.x-px) > Found.GRID*0.99 || Math.abs(px-curPos.x) > Found.GRID*0.99;
            px = Math.floor(px);
            px = Util.snap(px,Found.GRID);
        }
        if(gridMove || keyboard.down("control") ){//Clamp to grid
            doUpdate  = doUpdate ? doUpdate : Math.abs(curPos.y-py) > Found.GRID*0.99 || Math.abs(py-curPos.y) > Found.GRID*0.99;
            py = Math.floor(py);
            py = Util.snap(py,Found.GRID);
        }

        if(doUpdate){
            if(arrowMode == 0 || arrow == 2){
                updatePos(px,py);
            }
            else if(arrowMode == 1){
                var isDown = keyboard.down("control");
                if(isDown && arrow == 0){
                    updateScale(scale.x+sx,scale.y+sx,isDown);
                }
                else if(isDown && arrow == 1){
                    updateScale(scale.x+sy,scale.y+sy,isDown);
                }
                else{
                    updateScale(scale.x+sx,scale.y+sy);
                }
            }
            
        }
        
        if(px+((minusX+(minusX/5)*2)/gameView.width)*Found.WIDTH > Found.WIDTH +State.active.cam.position.x || px < State.active.cam.position.x || py > Found.HEIGHT+State.active.cam.position.y ||py+((minusY+(minusY/5)*2)/gameView.height)*Found.HEIGHT < State.active.cam.position.y){
            return;
        }
    }
    @:access(EditorInspector)
    function updateScale(sx:Float,sy:Float,ctrl:Bool = false){
        if(ctrl){
            State.active._entities[inspector.index].scale.x = sx;
            State.active._entities[inspector.index].scale.y = sy;
            Reflect.setProperty(State.active.raw._entities[inspector.index].scale,"x",sx);
        }
        else{
            switch(arrow){
                case 0:
                    State.active._entities[inspector.index].scale.x = sx;
                    Reflect.setProperty(State.active.raw._entities[inspector.index].scale,"x",sx);
                case 1:
                    State.active._entities[inspector.index].scale.y = sy;
                    Reflect.setProperty(State.active.raw._entities[inspector.index].scale,"y",sy);
            }
        }
    }
    @:access(EditorInspector)
    function updatePos(px:Float,py:Float){ 
        switch(arrow){
            case 0:
                State.active._entities[inspector.index].position.x = px;
                Reflect.setProperty(State.active.raw._entities[inspector.index].position,"x",px);
            case 1:
                State.active._entities[inspector.index].position.y = py;
                Reflect.setProperty(State.active.raw._entities[inspector.index].position,"y",py);
            case 2:
                State.active._entities[inspector.index].position.x = px;
                State.active._entities[inspector.index].position.y = py;
                Reflect.setProperty(State.active.raw._entities[inspector.index].position,"x",px);
                Reflect.setProperty(State.active.raw._entities[inspector.index].position,"y",py);
        }
        inspector.inspector.redraw();
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
            EditorHierarchy.makeClean();
            Fs.saveContent(scenePath,DataLoader.stringify(State.active.raw));
        }
    }
    #elseif arm_csm
    public function saveSceneData(){
        trace("Implement me");
    }
    #end
    
}