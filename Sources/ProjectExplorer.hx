package;


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
}