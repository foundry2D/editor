package;


import kha.Assets;
import found.trait.internal.LoadingScript;
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
import found.data.Project.TProject;
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
    public var isPlayMode(default,set):Bool;
    function set_isPlayMode(b:Bool){
        isPlayMode = b;
        if(console != null)
            console.clear(true);
        return isPlayMode;
    }
    var managerEditor:EditorView;
    var projectmanager:ManagerView;
    var dialog:FileBrowserDialog;
    public var gameView:EditorGameView;
    public var codeView:EditorCodeView;
    var animationView:EditorAnimationView;
    var projectExplorer:ProjectExplorer;
    var console:EditorConsole;
    var center:EditorPanel;
    var bottom:EditorPanel;
    var right:EditorPanel;
    var left:EditorPanel;
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
                    var projList:Array<TProject> = getLocalProjects();
                    projectmanager = new ManagerView(projList);
                    done();
                }
                else {
                    Fs.getContent(EditorUi.cwd+"/pjml.found",function(data:String){
                        var out:{list:Array<TProject>} = haxe.Json.parse(data);
                        out.list = out.list.concat(getLocalProjects());
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
        
    }
    static function getLocalProjects():Array<TProject>{
        var out:Array<TProject> = [];
        for(asset in Assets.blobs.names){
            if(StringTools.endsWith(asset,"_prj")){
                var proj:TProject = haxe.Json.parse(Assets.blobs.get(asset).toString());
                out.push(proj);
            }
        }
        return out;
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
        console = new EditorConsole();
        bottom.addTab(console);
        codeView = new EditorCodeView();
        animationView = new EditorAnimationView();
        center.addTab(gameView);
        center.addTab(codeView);
        center.addTab(animationView);
        editor.addToElementDraw("TopLayout",center);

        // Setup right layout
        right = new EditorPanel();
        inspector = new EditorInspector();
        right.addTab(inspector);
        editor.addToElementDraw("RightLayout", right);

        // Setup left layout
        left = new EditorPanel();
        hierarchy = EditorHierarchy.getInstance();
        left.addTab(hierarchy);
        editor.addToElementDraw("LeftLayout", left);
        
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
        
        if(keysDown(Config.keymap.toggle_playmode))
            togglePlayMode();
        
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
            else if(!mouse.down("left") || !inSceneView){
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
    
    public static var arrow:Int = -1;
    public static var arrowMode:Int = 0;// 0 = Move; 1 = Scale
    var lastMX:Float;
    var lastMY:Float;
    @:access(EditorInspector)
    public function updateMouse(x:Float,y:Float,cx:Float,cy:Float){
        if(inspector.index==-1)return;

        var doUpdate = true;
        var curPos = State.active._entities[inspector.index].position;
        var scale = State.active._entities[inspector.index].scale;

        var px = cx/gameView.width*Found.WIDTH;
        var py = cy/gameView.height*Found.HEIGHT;
    
        var sx = cx/gameView.width;
        var sy = cy/gameView.height;

        if(doUpdate){
            if(arrowMode == 0 || arrow == 2){
                var canUpdate = Math.abs(lastMX - mouse.x) > Found.GRID || Math.abs(lastMY - mouse.y) > Found.GRID;
                var ctrl = keyboard.down("control");
                if(ctrl && canUpdate){
                    if(arrow == 0){
                        px *= lastMX - mouse.x > 0 ? 1:-1;
                    }
                    else if(arrow == 1){
                        py *= lastMY - mouse.y > 0 ? 1:-1;
                    }
                    updatePos(px,py,true);
                    lastMX = mouse.x;
                    lastMY = mouse.y;
                }
                else if(!ctrl) {
                    updatePos(px,py,false);
                }

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
            State.active._entities[inspector.index].scale.x += sx;
            State.active._entities[inspector.index].scale.y += sy;
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
    function updatePos(px:Float,py:Float,toGrid:Bool){
        var x = State.active._entities[inspector.index].position.x + px;
        var y = State.active._entities[inspector.index].position.y + py;
        x = toGrid ? Util.snap(Math.floor(x),Found.GRID) : x;
        y = toGrid ? Util.snap(Math.floor(y),Found.GRID) : y;
        switch(arrow){
            case 0:
                State.active._entities[inspector.index].position.x = x;
                Reflect.setProperty(State.active.raw._entities[inspector.index].position,"x",x);
            case 1:
                State.active._entities[inspector.index].position.y = y;
                Reflect.setProperty(State.active.raw._entities[inspector.index].position,"y",y);
            case 2:
                State.active._entities[inspector.index].position.x = x;
                State.active._entities[inspector.index].position.y = y;
                Reflect.setProperty(State.active.raw._entities[inspector.index].position,"x",x);
                Reflect.setProperty(State.active.raw._entities[inspector.index].position,"y",y);
        }
        inspector.redraw();
    }
    @:access(found.anim.Sprite)
    function saveSceneData(){
        if(EditorHierarchy.getInstance().isDirty()){
            var i = 0;
            for(entity in State.active._entities){
                if(entity.dataChanged){
                    State.active.raw._entities[i] = entity.raw;
                }
                i++;
            }
            EditorHierarchy.getInstance().makeClean();
            Fs.saveContent(scenePath,DataLoader.stringify(State.active.raw));
        }
    }
    
    function saveSceneAs() {
        FileBrowserDialog.open(function(path:String){
            //@TODO: Add more checks to make sure user passed a valid path.
            if(!path.endsWith('.json')){
                path += '.json';
            }
            scenePath = path;
            EditorHierarchy.getInstance().makeDirty();
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
                error('file with name $name is not a valid scene name or the path "$path" was invalid ');
            }

        }
        FileBrowserDialog.open(done);
    }

    @:access(found.Scene,found.object.Object,found.Trait)
    public static function togglePlayMode(){
        if(found.App.editorui.isPlayMode){
            for(object in found.State.active.activeEntities){
                for (t in object.traits){
                    if (t._remove != null) {
                        for (f in t._remove) f();
                    }
                }
            }
            found.App.editorui.isPlayMode = false;
        }
        else{
            for(obj in found.State.active.inactiveEntities){
                if(obj.raw.active){
                    obj.active = true;
                }
            }
            for(object in found.State.active.activeEntities){
                for (t in object.traits){
                    if (t._awake != null) {
                        for (f in t._awake) found.App.notifyOnAwake(f);
                    }
                    if (t._init != null) {
                        for (f in t._init) found.App.notifyOnInit(f);
                    }
                }
            }
            found.App.editorui.isPlayMode = true;
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
    
}