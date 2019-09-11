package;

import haxe.ui.events.UIEvent;
import haxe.ui.containers.TabView;
import haxe.ui.core.Screen;
import haxe.ui.containers.VBox;
import haxe.ui.macros.ComponentMacros;
import haxe.ui.extended.Handler;

typedef Dim = {
    var width:Float;
    var height:Float;
}
@:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/project-explorer.xml"))
class ProjectExplorer extends TabView {

    public var projectPath:String="~/Documents/projects/haxeui-kha-extended";
    public function new() {
        super();
        this.percentWidth = 100.0;
        this.percentHeight = 100.0;
        Handler.updateData(this.panelRight,projectPath);
        this.panelLeft.brother = this.panelRight;
    }
    public function resize(){
        width = container.width = parentComponent.width;
        height = container.height= parentComponent.height;
        for(c in container.childComponents){
            var d:Dim = {width: this.width,height:this.height};
            c.dispatch(new UIEvent(UIEvent.RESIZE,false,d));
        }
    }

}