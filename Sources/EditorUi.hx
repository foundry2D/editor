package;

import kha.System;
import found.data.DataLoader;
import zui.Zui;
import kha.input.KeyCode;
import khafs.Fs;
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
#end

import utilities.Config;

class EditorUi extends Trait{
    public var visible(default,set) = true;
    function set_visible(v:Bool){
        if(v){
            registerInput();
        }
        else {
            unregisterInput();
        }
        return visible  = v;
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
    var center:EditorPanel;
    var bottom:EditorPanel;
    var right:EditorPanel;
    var menu:EditorMenuBar;
    public static var scenePath:String = "";
    public static var projectName:String = "";
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
    final fsFiletypeExceptions:Array<String> = [".vhx",".prj"];
    public function new(){
        super();
        kha.Window.get(0).notifyOnResize(onResize);
        ui = new Zui({font: kha.Assets.fonts.font_default,autoNotifyInput: false});
        Fs.init(function(){
            Config.load(function() {
                Config.init();
                isPlayMode = Config.raw.defaultPlayMode;
                gameView = new EditorGameView();
                var done = function(){

                    if(editor != null && editor.visible){
                        editor.visible = false;
                        throw("This is valid logic ?");
                    }
                    for(f in projectmanager._render2D)found.App.notifyOnRender2D(f);
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
        },fsFiletypeExceptions);

    }
    @:access(found.trait.internal.CanvasScript)
    function onResize(w:Int, h:Int){
        trace("Resized ?");
        if(projectmanager != null && projectmanager.ready && projectmanager.visible){
            projectmanager.scaleOnReady();
        }
        if(editor != null && editor.ready && editor.visible){
            editor.scaleOnReady();
        }
    }
    @:access(found.App)
    public function render(canvas:kha.Canvas){
        if(projectmanager != null && projectmanager.ready && projectmanager.visible){
            canvas.g2.begin(projectmanager.visible,projectmanager.theme.WINDOW_BG_COL);
            for(f in projectmanager._render2D)f(canvas.g2);
            canvas.g2.end();
        }
        if(editor != null && editor.ready && editor.visible){
            canvas.g2.begin();
            for(f in editor._render2D)f(canvas.g2);
            canvas.g2.end();
        }
        if(EditorMenu.show){
            EditorMenu.render(canvas.g2);
        }
    }

    public function init(){
        editor = new EditorView(ui);
        for(f in editor._render2D)found.App.removeRender2D(f);
        center = new EditorPanel();
        bottom = new EditorPanel();
        projectExplorer = new ProjectExplorer();
        bottom.addTab(projectExplorer);
        codeView = new EditorCodeView();
        animationView = new EditorAnimationView();
        center.addTab(gameView);
        center.addTab(codeView);
        center.addTab(animationView);

        // Setup right layout
        right = new EditorPanel();
        inspector = new EditorInspector();
        right.addTab(inspector);
        editor.addToElementDraw("RightLayout", right);

        hierarchy = new EditorHierarchy(found.State.active.raw,inspector);
        editor.addToElementDraw("LeftLayout",hierarchy);
        editor.addToElementDraw("TopLayout",center);
        
        
        
        menu  = new EditorMenuBar();
        editor.addToElementDraw("HeaderLayout",menu);
        editor.addToElementDraw("BottomLayout",bottom);
        var tools = new EditorTools(editor);
        keyboard = Input.getKeyboard();
        mouse = Input.getMouse();
        this.visible = true;
    }

    var lastChange:Float = 0.0;
    public function update(dt:Float): Void {
        if(mouse == null || keyboard == null)return;

        ui.enabled = !zui.Popup.show;

        if(keysDown(Config.keymap.file_save))
            saveSceneData();
        
        if(center.tabname != tr("Code") && keysDown(Config.keymap.file_open)){
            openScene();
        }


        if(animationView != null) {
            animationView.update(dt);
            if(keyboard.started("space")){
                animationView.notifyPlayPause();
            }
        }
        
        if(keyboard.down("f9") && 0.1 < kha.Scheduler.time()-lastChange){
            lastChange = kha.Scheduler.time();
            Found.fullscreen = !Found.fullscreen;
        }

        if(mouse.x > EditorMenu.menuX + EditorMenu.menuW || mouse.x < EditorMenu.menuX - ui.ELEMENT_W() * 0.05 || mouse.y > EditorMenu.menuY + EditorMenu.menuH || mouse.y < EditorMenu.menuY - ui.ELEMENT_H()){
            EditorMenu.show = false;
        }

        //Game View based Input
        if(gameView.active)
        {
            if(keyboard.down("1") && keyboard.down("control")){
                EditorUi.arrowMode = 0;
                EditorTools.redrawArrows = true;
            }
            else if(keyboard.down("2") && keyboard.down("control")){
                EditorUi.arrowMode = 1;
                EditorTools.redrawArrows = true;
            }
            var inSceneView = mouse.x > gameView.x && mouse.y > gameView.y && mouse.x < gameView.x + gameView.width && mouse.y < gameView.y + gameView.height;
            if(inSceneView && mouse.down("middle") && mouse.moved){
                if(State.active!= null){
                    State.active.cam.position.x+=mouse.distX;
                    State.active.cam.position.y+=mouse.distY;
                }
            }
            if(inSceneView && mouse.down("left") && mouse.moved){
                updateMouse(mouse.x,mouse.y,mouse.distX,mouse.distY);
            }
            else{
                arrow = -1;
            }
        }
        
    }

    function keysDown(keymap:String) {
        var keys = keymap.split('+');
        for(key in keys){
            if(key == "ctrl")key = "control";

            if(key.length == 1){
                if(!keyboard.started(key))
                    return false;
            }
            else {
                if(!keyboard.down(key))
                    return false;
            }
        }
        return true;
    }
    
    public static var gridMove:Bool = false;
    public static var arrow:Int = -1;
    public static var arrowMode:Int = 0;// 0 = Move; 1 = Scale
    public static var minusX:Float = 0;// Basically the arrow size maybe @RENAME ?
    public static var minusY:Float = 0;// Basically the arrow size maybe @RENAME ?
    @:access(EditorInspector)
    public function updateMouse(x:Float,y:Float,cx:Float,cy:Float){
        if(inspector.index==-1)return;

        var doUpdate = true;
        var curPos = State.active._entities[inspector.index].position;
        var scale = State.active._entities[inspector.index].scale;

        var px = (x-gameView.x - minusX)+State.active.cam.position.x;
        var py = (y-gameView.y - minusY)+State.active.cam.position.y;
        
        //Get scaling values
        var direction = 1;
        if(arrow == 0){
            direction = curPos.x-px > 0 ? -1:1;
        }
        else if(arrow == 1){
            direction = curPos.y-py < 0 ? -1:1;
        }
        var sx = Util.fround(direction*(Math.abs(curPos.x-px)/Found.WIDTH),2);
        var sy = Util.fround(direction*(Math.abs(curPos.y-py)/Found.HEIGHT),2);
        
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
        inspector.redraw();
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
        inspector.redraw();
    }
    @:access(found.anim.Sprite)
    function saveSceneData(){
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
    
    function saveSceneAs() {
        FileBrowserDialog.open(function(path:String){
            scenePath = path;
            this.saveSceneData();
        },projectPath);
    }

    function openScene(){
        var done = function(path:String){
            if(path == "")return;

            var sep = Fs.sep;
            var name = path.split(sep)[path.split(sep).length-1];
            if(StringTools.contains(name,".json") && Fs.exists(path)){
                name = StringTools.replace(name,'.json',"");
                scenePath = path;
                found.State.set(name,this.init);//

            }
            else{
                trace('Error: file with name $name is not a valid scene name or the path "$path" was invalid ');
            }

        }
        FileBrowserDialog.open(done);
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
    
}