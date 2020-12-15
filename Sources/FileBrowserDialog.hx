package;

import zui.Zui;
import zui.Id;
import found.Found;

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
        zui.Popup.showCustom(Found.popupZuiInstance, fileBrowserPopupDraw, -1, -1, Std.int(Found.popupZuiInstance.ELEMENT_W() * 4),Std.int(Found.popupZuiInstance.ELEMENT_W() * 3));
    }
    static var doneCallback:String->Void = function(path:String){};
    static var fbHandle:Handle = Id.handle();
    static var textInputHandle = Id.handle();
    @:access(zui.Zui, zui.Popup)
    static function fileBrowserPopupDraw(ui:Zui){
        zui.Popup.boxTitle = tr("File Browser");

        if(ui.button(tr("Import Assets"))){
            #if kha_html5
            khafs.Fs.curDir = EditorUi.projectPath + khafs.Fs.sep + "Assets";
            khafs.Fs.input.click();
            #else
            #end
        }
        var selectedFile = CustomExt.fileBrowser(ui,fbHandle);
        if(fbHandle.changed){
            textInputHandle.text = selectedFile;
        }

        var border = zui.Popup.borderW*2 +zui.Popup.borderOffset;

        ui._y -= border;
        
        ui.endElement();
        
        ui.textInput(textInputHandle, tr("Filename"));

        ui.row([0.5,0.5]);
        // ui._y = ui._h - ui.t.BUTTON_H - border;
        ui.text("");
        ui.row([0.5, 0.5]);
		if (ui.button(tr("Add"))) {
            zui.Popup.show = false;
            doneCallback(textInputHandle.text);
            textInputHandle.text = "";
            doneCallback = function(path:String){};
        }
        if (ui.button(tr("Cancel"))) {
            zui.Popup.show = false;
            textInputHandle.text = "";
            doneCallback("");
            doneCallback = function(path:String){};
        }


        if(ui._y < zui.Popup.modalH)
			ui._y = zui.Popup.modalH;
    }
}