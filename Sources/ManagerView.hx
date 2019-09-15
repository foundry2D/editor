package;

import haxe.ui.containers.Box;

@:build(haxe.ui.macros.ComponentMacros.build("../Assets/project-manager.xml"))
class ManagerView extends Box {
    public function new(data:Array<foundry.data.Project.TProject> =null) {
        super();
        percentWidth = 100;
        percentHeight = 100;
    }
    
}