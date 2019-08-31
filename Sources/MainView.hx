package;

import haxe.ui.containers.Box;

@:build(haxe.ui.macros.ComponentMacros.build("../Assets/main.xml"))
class MainView extends Box {
    public function new() {
        super();
        percentWidth = 100;
        percentHeight = 100;
    }
}