package;


import haxe.ui.extended.Handler;

@:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/project-explorer.xml"))
class ProjectExplorer extends EditorTab {

    public var projectPath:String="~/Documents/projects/haxeui-kha-extended";
    public function new() {
        super();
        Handler.updateData(this.panelRight,projectPath);
        this.panelLeft.brother = this.panelRight;
    }
}