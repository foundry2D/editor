package;

import haxe.ui.components.Button;
import haxe.ui.core.Component;
import haxe.ui.containers.menus.*;
import haxe.ui.core.Screen;
import haxe.ui.Toolkit;
import haxe.ui.extended.FileSystem;
#if arm_csm
import iron.Trait;
import iron.data.SceneFormat;
import iron.system.ArmPack;
// import iron.format.BlendParser;
#elseif coin
import coin.Trait;
import coin.State;
import coin.data.SceneFormat;
#end

class EditorUi extends Trait{
    public var keys:{ctrl:Bool,alt:Bool,shift:Bool} = {ctrl:false,alt:false,shift:false};
    public var editor:EditorView;
    public var inspector:EditorInspector;
    public var hierarchy:EditorHierarchy;
    var projectmanager:ManagerView;
    var dialog:FileBrowserDialog;
    var gameView:EditorGameView; 
    static public var raw:TSceneFormat =null;
    static public var scenePath:String = "";
    static public var projectPath:String = "~/Documents/projects/raccoon-tests/";
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
        var tools = new EditorTools();
        editor.addComponent(EditorTools.vArrow);
        editor.addComponent(EditorTools.hArrow);
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