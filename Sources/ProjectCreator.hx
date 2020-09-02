package;

import found.data.Project.Type;
import found.Found;
import khafs.Fs;
import zui.Zui;
import zui.Id;

// @:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/project-creator.xml"))
class ProjectCreator {
    static var onDone:Void->Void;

    public static function open(done:Void->Void){
        onDone = done;
        zui.Popup.showCustom(Found.popupZuiInstance, projectCreatorPopupDraw, -1, -1, 600, 500);
    }

    static var pathInputHandle = Id.handle();
    static var nameInputHandle = Id.handle();
    static var typeHandle = Id.handle();
    @:access(zui.Zui, zui.Popup)
    static function projectCreatorPopupDraw(ui:zui.Zui){
        zui.Popup.boxTitle = tr("New Project");

        ui.text(tr("Project Name"));
        ui.row([0.8,0.1,0.1]);
        ui.textInput(nameInputHandle);
        ui.radio(typeHandle,0,"2D");
        ui.enabled = false;//Deactivate for now
        ui.radio(typeHandle,1,"3D");
        ui.enabled = true;

        ui.text(tr("Location"));
        ui.row([0.75,0.25]);
        ui.textInput(pathInputHandle);
        if(ui.button("...")){
            onBrowse();
        }


        ui._y = ui._h - ui.t.BUTTON_H - (zui.Popup.borderW*2 +zui.Popup.borderOffset);

        ui.row([0.5, 0.5]);
		if (ui.button(tr("Apply"))) {
            ProjectCreator.createProject();
            zui.Popup.show = false;
            nameInputHandle.text = "";
            pathInputHandle.text = "";
            onDone = function(){};
        }
        if (ui.button(tr("Cancel"))) {
            zui.Popup.show = false;
            nameInputHandle.text = "";
            pathInputHandle.text = "";
            onDone = function(){};
        }
    
    }
    
    static function createProject(){
        var p = pathInputHandle.text;
        if(Fs.isDirectory(p)){
            var outp = p;
            var type = typeHandle.position == 0 ? Type.twoD: Type.threeD;
            var projName = nameInputHandle.text != "" ? nameInputHandle.text:tr("Project");
            outp = p+Fs.sep+projName;
            Fs.createDirectory(outp);
            ProjectInit.done = onDone;
            ProjectInit.run(outp,type,projName);
        }
        
    }

    
    static function onBrowse() {
        var done = function(passedPath:String){
            if(passedPath != "")
                pathInputHandle.text = passedPath;
            ProjectCreator.open(onDone);
            zui.Popup.show = true;
        }
        FileBrowserDialog.open(done);
        
    }
}