package;

import found.object.Object.MoveData;
import kha.math.Vector2;
import found.trait.internal.Arrows;
import kha.Assets;
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
//@TODO: Cleanup the variables here. Since we are changing a lot it would be valuable
// To check everything we use and don't use and remove unneeded code.  
class EditorUi extends Trait{
    public var visible(default,set) = true;
    function set_visible(v:Bool){
        if(v){
            registerInput();
        }
        else {
            unregisterInput();
        }
        if(listViews.length > 0){
            listViews[currentView].visible = v;
        }
        return visible  = v;
    }

    public var inspector:EditorInspector;
    public var hierarchy:EditorHierarchy;
    public var isPlayMode(default,set):Bool;
    function set_isPlayMode(b:Bool){
        isPlayMode = b;
        if(console != null)
            console.clear(true);
        return isPlayMode;
    }
    
    var projectmanager:ManagerView;
    var dialog:FileBrowserDialog;
    public var gameView:EditorGameView;
    public var codeView:EditorCodeView;
    var animationView:EditorAnimationView;
    var console:EditorConsole;
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
    @:access(ManagerView)
    public function new(){
        super();
        kha.Window.get(0).notifyOnResize(onResize);
        ui = new Zui({font:kha.Assets.fonts.font_default,theme: zui.Canvas.themes[0]});
        Fs.init(function(){
            Config.load(function() {
                Config.init();
                isPlayMode = Config.raw.defaultPlayMode;
                gameView = new EditorGameView();
                var done = function(){

                    if(listViews.length > 0 && listViews[currentView].visible){
                        listViews[currentView].visible = false;
                        throw("This is valid logic ?");
                    }
                    for(f in projectmanager._render2D)found.App.notifyOnRender2D(f);
                    registerInput();
                }
                
                if(!Fs.exists(EditorUi.cwd+"/pjml.found")){
                    var projList:Array<TProject> = getLocalProjects();
                    projectmanager = new ManagerView(projList,ui);
                    done();
                }
                else {
                    Fs.getContent(EditorUi.cwd+"/pjml.found",function(data:String){
                        var out:{list:Array<TProject>} = haxe.Json.parse(data);
                        out.list = out.list.concat(getLocalProjects());
                        projectmanager = new ManagerView(out.list,ui);
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
    public var currentView(default,set):Int = 0;
    function set_currentView(value:Int){
        if(value > listViews.length-1)throw 'View with number $value is higher then the number of views available.';
        currentView = value;
        redraw();
        return currentView;
    }
    var listViews:Array<EditorView> = [];
    @:access(EditorView)
    public function redraw() {
        for (view in listViews[currentView].toDraw){
            view.redraw();
        }
    }
    
    public function setUIScale(factor:Float){
        Found.popupZuiInstance.setScale(factor);
        ui.setScale(factor);
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
        if(listViews.length > 0 && listViews[currentView].ready && listViews[currentView].visible){
            var isClear = !(currentView == 0);
            var bgColor = isClear ? ui.t.WINDOW_BG_COL : null;
            canvas.g2.begin(isClear,bgColor);
            for(f in listViews[currentView]._render2D)f(canvas.g2);
            canvas.g2.end();
        }
        if(EditorMenu.show){
            EditorMenu.render(canvas.g2);
        }
    }

    public function init(){
        listViews.splice(0,listViews.length);
        
        var editor = new EditorView(ui,"main");
        var codeEditor = new EditorView(ui,"codeView");
        var drawEditor = new EditorView(ui,"drawView");
        listViews.push(editor);
        listViews.push(codeEditor);
        listViews.push(drawEditor);

        //Setup Code view
        var center = new EditorPanel();
        var bottom = new EditorPanel();
        bottom.addTab(new ProjectExplorer());
        console = new EditorConsole();
        bottom.addTab(console);
        center.addTab(gameView);
        var codePanel = new EditorPanel();
        codeView = new EditorCodeView();
        codePanel.addTab(codeView);
        codeEditor.addToElementDraw("Code",codePanel);
        codeEditor.addToElementDraw("Explorer",bottom);
        codeEditor.addToElementDraw("Game",center);

        //Setup Draw view
        var drawPanel = new EditorPanel();
        animationView = new EditorAnimationView();
        drawPanel.addTab(animationView);
        drawEditor.addToElementDraw("Draw",drawPanel);

        // Setup Scene View
        var right = new EditorPanel(false);
        var left = new EditorPanel();
        inspector = new EditorInspector();
        hierarchy = EditorHierarchy.getInstance();
        right.addTab(inspector);
        left.addTab(hierarchy);
        editor.addToElementDraw("RightLayout", right);
        editor.addToElementDraw("LeftLayout", left);
        
        menu  = new EditorMenuBar();
        var elemName = "Header";
        editor.addToElementDraw(elemName,menu);
        codeEditor.addToElementDraw(elemName,menu);
        drawEditor.addToElementDraw(elemName,menu);


        keyboard = Input.getKeyboard();
        mouse = Input.getMouse();
        this.visible = true;
    }

    var lastChange:Float = 0.0;
    @:access(EditorHierarchy)
    public function update(dt:Float): Void {
        if(mouse == null || keyboard == null)return;

        ui.enabled = !zui.Popup.show;

        var isInMainView = currentView == 0;
        
        if(keysDown(Config.keymap.file_save))
            saveSceneData();
        
        if(keysDown(Config.keymap.toggle_playmode))
            togglePlayMode();
        
        if(currentView == 0 && keysDown(Config.keymap.file_open)){
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
            listViews[currentView].visible = !listViews[currentView].visible;
        }

        if(mouse.x > EditorMenu.menuX + EditorMenu.menuW || mouse.x < EditorMenu.menuX - ui.ELEMENT_W() * 0.05 || mouse.y > EditorMenu.menuY + EditorMenu.menuH || mouse.y < EditorMenu.menuY - ui.ELEMENT_H()){
            EditorMenu.show = false;
        }

        if(isInMainView || this.isHidden()){
            if(mouse.down("middle") && mouse.moved){
                if(State.active!= null){
                    State.active.cam.position.x+=mouse.distX;
                    State.active.cam.position.y+=mouse.distY;
                }
            }
            if(keyboard.down("control") && mouse.wheelDelta != 0){
                var mult = mouse.wheelDelta * -1;
                if(found.State.active.cam.zoom > 0){
                    found.State.active.cam.zoom += 0.1 * mult;
                    if(found.State.active.cam.zoom < 0.01){
                        found.State.active.cam.zoom = 0.1;
                    }
                }
            }
        }
        if(isInMainView){
            if(keyboard.down("1") && keyboard.down("control")){
                EditorUi.arrowMode = 0;
                EditorTools.redrawArrows = true;
            }
            else if(keyboard.down("2") && keyboard.down("control")){
                EditorUi.arrowMode = 1;
                EditorTools.redrawArrows = true;
            }
    
            if(mouse.down("left") && (mouse.moved || keyboard.down("control"))){
                updateMouse(mouse.x,mouse.y,mouse.distX,mouse.distY);
            }
            else if(!mouse.down("left")){
                arrow = -1;
            }
            
            if(mouse.started("left") && !isInUi()){
                var mpos = found.State.active.cam.screenToWorld(new Vector2(mouse.x,mouse.y));
                for(entity in found.State.active._entities){
                    if(found.State.active.cam == entity)continue;
                    var dif = entity.position.sub(mpos);
                    if(Math.abs(dif.x) < entity.width && Math.abs(dif.y) < entity.height && mpos.x > entity.position.x && mpos.y > entity.position.y)
                    {
                        hierarchy.onObjectSelected(entity.uid,entity.raw);
                    }
                }
            }
        }
    }

    public function isHidden(){
        if(currentView < 0 )return true;
        return !listViews[currentView].visible;
    }
    @:access(EditorMenuBar)
    public function isInUi() {
        var pos = new Vector2(mouse.x,mouse.y);
        var inInspector = false;
        if(inspector.parent.visible){
            var x = inspector.parent.x;
            var y = inspector.parent.y;
            var w = inspector.parent.w;
            var h = inspector.lastH;
            inInspector = pos.x > x && pos.x < x + w && pos.y > y && pos.y < y + h;
        }
        var inHiearchy = false;
        if(hierarchy.parent.visible){
            var x = hierarchy.parent.x;
            var y = hierarchy.parent.y;
            var w = hierarchy.parent.w;
            var h = hierarchy.lastH;
            inHiearchy = pos.x > x && pos.x < x + w && pos.y > y && pos.y < y + h;
        }
        var inMenu = false;
        if(menu.visible){
            var x = menu.rect.x;
            var y = menu.rect.y;
            var w = menu.rect.z;
            var h = menu.rect.w;
            inMenu = pos.x > x && pos.x < x + w && pos.y > y && pos.y < y + h;
            
        }
        return this.isHidden() ? false : (inInspector || inHiearchy || inMenu || !Found.tileeditor.notInEditor() || zui.Popup.show);
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
    var distX:Float;
    var distY:Float;
    @:access(EditorInspector)
    public function updateMouse(x:Float,y:Float,cx:Float,cy:Float){
        if(inspector.index==-1)return;

        var doUpdate = true;
        var scale = State.active._entities[inspector.index].scale;

        var px = cx;
        var py = cy;
    
        var sx = cx/Found.WIDTH;
        var sy = cy/Found.HEIGHT;

        if(doUpdate){
            if(arrowMode == 0 || arrow == 2){
                var canUpdate = Math.abs(distX) > Found.GRID || Math.abs(distY) > Found.GRID;
                var ctrl = keyboard.down("control");
                if(ctrl && canUpdate){
                    if(arrow == 0){
                        px = distX > 0 ? px: px + distX;
                    }
                    else if(arrow == 1){
                        py = distY > 0 ? py: py + distY;
                    }
                    else {
                        if(Math.abs(distX) > Found.GRID){
                            px = distX > 0 ? px: px + distX;
                            distX = 0;
                        }
                        else
                            px = 0;
                        if(Math.abs(distY) > Found.GRID){
                            py = distY > 0 ? py: py + distY;
                            distY = 0;
                        }
                        else
                            py = 0;
                    }
                    updatePos(px,py,true);
                    if(arrow < 2){
                        distX = 0;
                        distY = 0;
                    }
                    
                }
                else if(!ctrl) {
                    updatePos(px,py,false);
                }
                else{//Accumulate for grid movement
                    distX += px;
                    distY += py;
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
    @:access(EditorInspector,found.object.Object)
    function updatePos(px:Float,py:Float,toGrid:Bool){
        var x = State.active._entities[inspector.index].position.x + px;
        var y = State.active._entities[inspector.index].position.y + py;
        x = toGrid ? Util.snap(Math.floor(x),Found.GRID) : x;
        y = toGrid ? Util.snap(Math.floor(y),Found.GRID) : y;
        var pos = State.active._entities[inspector.index].position;
        switch(arrow){
            case 0:
                State.active._entities[inspector.index].translate(function(data:MoveData){
                    return data;
                },{_positions: new Vector2(x)},true);
                Reflect.setProperty(State.active.raw._entities[inspector.index].position,"x",x);
            case 1:
                State.active._entities[inspector.index].translate(function(data:MoveData){
                    return data;
                },{_positions: new Vector2(pos.x,y)},true);
                Reflect.setProperty(State.active.raw._entities[inspector.index].position,"y",y);
            case 2:
                State.active._entities[inspector.index].translate(function(data:MoveData){
                    return data;
                },{_positions: new Vector2(x,y)},true);
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

    @:access(found.State,EditorHierarchy)
    function openScene(){
        var done = function(path:String){
            if(path == "")return;

            var sep = Fs.sep;
            var name = path.split(sep)[path.split(sep).length-1];
            if(StringTools.contains(name,".json") && Fs.exists(path)){
                name = StringTools.replace(name,'.json',"");
                scenePath = path;
                if(!found.State._states.exists(name)){
                    found.State.addState(name,scenePath);
                }
                
                hierarchy.onSceneSelected();
                found.State.set(name,function(){
                    hierarchy.setSceneData(found.State.active.raw);
                    hierarchy.onSceneSelected();
                });

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