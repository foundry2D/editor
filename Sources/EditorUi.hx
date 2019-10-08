package;

import iron.Trait;
import haxe.ui.components.Button;
import haxe.ui.core.Component;
import haxe.ui.containers.menus.*;
import haxe.ui.core.Screen;
import haxe.ui.Toolkit;
import iron.data.SceneFormat;
import iron.system.ArmPack;
import haxe.ui.extended.FileSystem;
import iron.format.BlendParser;

class EditorUi extends Trait{
    var editor:EditorView;
    var projectmanager:ManagerView;
    var dialog:FileBrowserDialog;
    static public var raw:TSceneFormat =null;
    static public var projectPath:String = "~/Documents/tests/armory_examples/game_bowling";
    static var bl:BlendParser = null;
    var isBlend = false;
    public function new(plist:Array<foundry.data.Project.TProject> = null){
        super();
        Toolkit.init();
        if(plist != null){
            projectmanager = new ManagerView(plist);
            Screen.instance.addComponent(projectmanager);
        }
        else {
            editor = new EditorView();
            var path = FileSystem.fixPath(projectPath)+"/build_bowling/compiled/Assets/Scene.arm";//"/bowling.blend";
            if(StringTools.endsWith(path,"blend")){
                isBlend = true;
            }//'$path
            iron.data.Data.getBlob(path,createHierarchy);
            
            var tab = new ProjectExplorer(projectPath);
            var menu  = new EditorMenu();
            var button = new Button();
            button.text = "button-test";
            // button.onClick = FileBrowserDialog.open;
            editor.header.addComponent(menu);
            editor.ePanelBottom.addComponent(tab);
            // tab.resize();
            // editor.addToContent(menu);
            // editor.bar.onClick = FileBrowserDialog.open;
            Screen.instance.addComponent(editor);
        }
        

    }
    function createHierarchy(blob:kha.Blob){
        if(isBlend){
            bl = new BlendParser(blob);
            trace(bl.dir("Scene"));
            var scenes = bl.get("Scene");
            trace(scenes.length);
        }else{
            raw = ArmPack.decode(blob.bytes);
            var inspector = new EditorInspector();
            editor.ePanelRight.addComponent(inspector);
            editor.ePanelLeft.addComponent(new EditorHierarchy(raw,inspector));
            editor.ePanelTop.addComponent(new EditorGameView());
        }
        
    }
    public function update(): Void {

    }

    public function render(g:kha.graphics2.Graphics): Void {
        g.begin(true, 0xFFFFFF);
        Screen.instance.renderTo(g);
        g.end();
    }
}