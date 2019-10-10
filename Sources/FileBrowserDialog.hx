package;

import haxe.ui.events.MouseEvent;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.core.Screen;
import haxe.ui.extended.Handler;

@:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/fb-dialog.xml"))
class FileBrowserDialog extends Dialog {
    static public var inst:FileBrowserDialog = null;
    public function new(){
        super();
        title = "File Browser";
        modal = false;
        buttons =  DialogButton.APPLY | DialogButton.CANCEL;
		this.width = Screen.instance.width*0.95;
        this.height = Screen.instance.height*0.95;
    }

    public static function open(e:MouseEvent){
        inst = new FileBrowserDialog();
        Handler.updateData(inst,"");
        inst.show();
    }
}