package;

import haxe.ui.core.Screen;
import haxe.ui.containers.dialogs.Dialog;

#if js
typedef DialogDef = {
#else
@:structInit class DialogDef {
#end
    public var name:String;
    public var type:String;
    @:optional public var buttons:Array<String>;
} 
@:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/custom-dialog.xml"))
class CustomDialog extends Dialog {
    public function new(def:DialogDef = null) {
        super();
        if(def == null)def ={name:"Info",type:"warning"}; 
        title = def.name;
        this.width = Screen.instance.width*0.95;
        this.height = Screen.instance.height*0.60;
        // type.resource = def.type; @TODO: Add this when default icons are added to extended
        // modal = false;
        buttons =  DialogButton.APPLY | DialogButton.CANCEL;
    }
}