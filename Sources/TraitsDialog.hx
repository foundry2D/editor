
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.core.Screen;
import haxe.ui.extended.Handler;

@:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/traits-dialog.xml"))
class TraitsDialog extends Dialog {
    public function new(){
        
    }
    public static function open(e:UIEvent){
        inst = new TraitsDialog();
        // Handler.updateData(inst,defaultPath);
        inst.show();
    }
}
