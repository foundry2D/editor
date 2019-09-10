package;

import haxe.ui.containers.TabView;
import haxe.ui.core.Screen;
import haxe.ui.containers.VBox;
import haxe.ui.macros.ComponentMacros;
import haxe.ui.extended.Handler;

@:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/project-explorer.xml"))
class ProjectExplorer extends TabView {

    public var projectPath:String="~/Documents/projects/haxeui-kha-extended";
    public function new() {
        super();
        this.width=Screen.instance.width;
        this.height = Screen.instance.height;
        Handler.updateData(this.panelRight,projectPath);
        this.panelLeft.brother = this.panelRight;
    }
}