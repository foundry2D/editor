package;

import haxe.ui.containers.TabView;
import haxe.ui.core.Screen;
import haxe.ui.containers.VBox;
import haxe.ui.macros.ComponentMacros;

@:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/project-explorer.xml"))
class ProjectExplorer extends TabView {

    public var projectPath:String="";
    public function new() {
        super();
        this.width=Screen.instance.width*0.95;
        this.height = Screen.instance.height*0.95;
        Fs.updateData(this.panelRight,projectPath);
        this.panelLeft.brother = this.panelRight;
        // Fs.updateData(this.panelLeft,projectPath);
    }
}