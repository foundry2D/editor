package;

import haxe.ui.events.MouseEvent;
import haxe.ui.extended.Handler;

@:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/project-explorer.xml"))
class ProjectExplorer extends EditorTab {

    var defaultPath:String="/";
    public function new(projectPath:String=null) {
        super();
        if(projectPath == null)
            projectPath = defaultPath;
        Handler.updateData(this.panelRight,projectPath);
        this.panelLeft.brother = this.panelRight;
    }
    @:bind(importAssets,MouseEvent.CLICK)
    function openOnSystem(e:MouseEvent){
        #if kha_html5
        kha.FileSystem.curDir = EditorUi.projectPath+kha.FileSystem.sep+"Assets";
        kha.FileSystem.input.click();
        #else
        #end
    }
}