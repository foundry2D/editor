package;
import haxe.ui.containers.HBox;
import haxe.ui.containers.menus.*;
import haxe.ui.core.Component;
import haxe.ui.core.Screen;
import haxe.ui.components.DropDown;

@:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/editor-menu.xml"))
class EditorMenu extends HBox {
    public function new() {
        super();
        id = "editormenu";
        this.width = Screen.instance.width;
    }
}