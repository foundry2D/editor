
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.core.Screen;
import haxe.ui.extended.Handler;
import haxe.ui.extended.FileSystem;
import ListTraits.Data;

@:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/traits-dialog.xml"))
class TraitsDialog extends Dialog {
    static public var inst:TraitsDialog = null;
    static var traits:Data;
    public function new(){
        super();
        // sys.io.File.getContent();
        title = "Traits";
        modal = false;
        buttons =  DialogButton.APPLY | DialogButton.CANCEL;
		this.width = Screen.instance.width*0.95;
        this.height = Screen.instance.height*0.95;
        // traits = haxe.Json.parse(kha.Assets.blobs);
    }
    public static function open(e:UIEvent){
        inst = new TraitsDialog();
        
        inst.show();
    }
}
