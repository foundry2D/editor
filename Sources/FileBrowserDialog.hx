package;

import zui.Zui;
import zui.Id;
import found.Found;

// @:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/fb-dialog.xml"))
class FileBrowserDialog {
    static public var inst:FileBrowserDialog = null;
    public function new(){

    }

    #if debug
    static var defaultPath = ".";
    #else
    static var defaultPath = "/";
    #end
    public static function open(onDone:String->Void,?currentPath:String = ""){
        doneCallback = onDone;
        fbHandle.text = currentPath != "" ? currentPath : EditorUi.cwd; 
        zui.Popup.showCustom(Found.popupZuiInstance, fileBrowserPopupDraw, -1, -1, 600, 500);
    }
    static var doneCallback:String->Void = function(path:String){};
    static var fbHandle:Handle = Id.handle();
    static var textInputHandle = Id.handle();
    @:access(zui.Zui, zui.Popup)
    static function fileBrowserPopupDraw(ui:Zui){
        zui.Popup.boxTitle = "File Browser";

        var selectedFile = CustomExt.fileBrowser(ui,fbHandle);
        if(fbHandle.changed){
            textInputHandle.text = selectedFile;
        }

        var border = zui.Popup.borderW*2 +zui.Popup.borderOffset;

        ui._y = ui._h - ui.t.BUTTON_H - ui.t.ELEMENT_H - border;

        ui.textInput(textInputHandle, "Filename");

        ui.row([0.5,0.5]);
        ui._y = ui._h - ui.t.BUTTON_H - border;
        ui.text("");
        ui.row([0.5, 0.5]);
		if (ui.button("Add")) {
            zui.Popup.show = false;
            doneCallback(textInputHandle.text);
            textInputHandle.text = "";
            doneCallback = function(path:String){};
        }
        if (ui.button("Cancel")) {
            zui.Popup.show = false;
            textInputHandle.text = "";
            doneCallback("");
            doneCallback = function(path:String){};
        }
    }
}