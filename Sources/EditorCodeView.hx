package;

import haxe.ui.containers.VBox;


@:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/editor-code.xml"))
class EditorCodeView extends VBox {

    public function new(){
        super();
        percentWidth = 100;
        percentHeight = 100;
        this.text = "Code";
    }

}