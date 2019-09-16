package;

import haxe.ui.components.Button;
import haxe.ui.core.Component;
import haxe.ui.containers.menus.*;
import haxe.ui.core.Screen;
import haxe.ui.macros.ComponentMacros;
import haxe.ui.Toolkit;

class EditorUi {
    var editor:EditorView;
    var projectmanager:ManagerView;
    var dialog:FileBrowserDialog;
    public function new(plist:Array<foundry.data.Project.TProject> = null){
        Toolkit.init();
        if(plist != null){
            projectmanager = new ManagerView(plist);
            Screen.instance.addComponent(projectmanager);
        }
        else {
            editor = new EditorView();
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
    public function update(): Void {

    }

    public function render(g:kha.graphics2.Graphics): Void {
        g.begin(true, 0xFFFFFF);
        Screen.instance.renderTo(g);
        g.end();
    }
}