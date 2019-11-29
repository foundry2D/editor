package;
import haxe.ui.containers.HBox;
import haxe.ui.containers.menus.*;
import haxe.ui.core.Component;
import haxe.ui.core.Screen;
import haxe.ui.components.DropDown;
import haxe.ui.events.MouseEvent;
import haxe.ui.containers.dialogs.Dialog;


@:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/editor-menu.xml"))
class EditorMenu extends HBox {
    public function new() {
        super();
        id = "editormenu";
        this.width = Screen.instance.width;
        trace(this.newScene.text);
    }
    @:bind(iScene,MouseEvent.CLICK)
    function createScene(e:MouseEvent){
        // FileBrowserDialog.open(e);
        // FileBrowserDialog.inst.onDialogClosed = function(e:DialogEvent){
        //     var path = null;
        //     if(e.button == DialogButton.APPLY)
        //         path = FileBrowserDialog.inst.fb.path.text;
        //     if(path == null)return;
        //     var name = path.split('/')[path.split('/').length-1];
        //     trace(name);
        //     #if coin
        //     // var scene = {
        //     //     @:optional public var name:String;
        //     //     @:optional public var  _entities:Array<TObj>;
        //     //     @:optional public var _depth:Bool;
        //     //     @:optional public var _Zsort:Bool;
        //     //     @:optional public var traits:Array<TTrait>; // Scene root traits
        //     // }
        //     #end
        // }
    }
}