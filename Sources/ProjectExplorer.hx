package;

import haxe.ui.events.MouseEvent;
import haxe.ui.extended.Handler;

@:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/project-explorer.xml"))
class ProjectExplorer extends EditorTab {

    var defaultPath:String="/";
    public function new(projectPath:String=null) {
        super();
        this.text = "Explorer";
        if(projectPath == null)
            projectPath = defaultPath;
        Handler.updateData(this.panelRight,projectPath);
        this.panelLeft.brother = this.panelRight;
    }
    @:bind(panelLeft.importAssets,MouseEvent.CLICK)
    function openOnSystem(e:MouseEvent){
        #if kha_html5
        khafs.Fs.curDir = EditorUi.projectPath+khafs.Fs.sep+"Assets";
        khafs.Fs.input.click();
        #else
        #end
    }
}