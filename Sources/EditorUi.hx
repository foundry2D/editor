package;

import haxe.ui.components.Button;
import haxe.ui.core.Component;
import haxe.ui.containers.menus.*;
import haxe.ui.core.Screen;
import haxe.ui.macros.ComponentMacros;
import haxe.ui.Toolkit;
import iron.data.SceneFormat;

class EditorUi {
    var editor:EditorView;
    var projectmanager:ManagerView;
    var dialog:FileBrowserDialog;
    public var raw:TSceneFormat;
    public function new(plist:Array<foundry.data.Project.TProject> = null){
        Toolkit.init();
        if(plist != null){
            projectmanager = new ManagerView(plist);
            Screen.instance.addComponent(projectmanager);
        }
        else {
            editor = new EditorView();
            kha.Assets.loadBlobFromPath("/home/jsnadeau/foundsdk/scene.json",createHierarchy,function(f:kha.AssetError){
                trace(f.error);
            });
            var tab = new ProjectExplorer();
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
        raw = haxe.Json.parse(blob.toString());
        editor.ePanelLeft.addComponent(new EditorHierarchy(raw));
    }
    public function update(): Void {

    }

    public function render(g:kha.graphics2.Graphics): Void {
        g.begin(true, 0xFFFFFF);
        Screen.instance.renderTo(g);
        g.end();
    }
}