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
#elseif coin
import coin.Trait;
import coin.data.SceneFormat;
#end
// import iron.format.BlendParser;

class EditorUi extends Trait{
    var editor:EditorView;
    var projectmanager:ManagerView;
    var dialog:FileBrowserDialog;
    var gameView:EditorGameView; 
    static public var raw:TSceneFormat =null;
    static public var projectPath:String = "~/Documents/tests/armory_examples/game_bowling";
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
            coin.Coin.render = function(g:kha.graphics2.Graphics){
                g.begin();
                Screen.instance.renderTo(g);
                g.end();
            };
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
            var inspector = new EditorInspector();
            editor.ePanelRight.addComponent(inspector);
            var temp = new EditorHierarchy(blob,inspector);
            editor.ePanelLeft.addComponent(temp);
            editor.ePanelTop.addComponent(gameView);
        // }
        
    }
    public function update(): Void {

    }

    public function render(g:kha.graphics2.Graphics): Void {
        g.end();
        Screen.instance.renderTo(g);
        g.begin(false);
    }
}