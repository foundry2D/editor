package;

import haxe.ui.events.MouseEvent;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.extended.NodeData;
import haxe.ui.core.Screen;
import haxe.ui.extended.FileSystem;

@:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/project-creator.xml"))
class ProjectCreator extends Dialog {
    public function new() {
        super();
        title = "New Project";
        modal = false;
        buttons =  DialogButton.APPLY | DialogButton.CANCEL;
		width = Screen.instance.width*0.75;
        height = Screen.instance.height*0.75;
        this.onDialogClosed = createProject;

    }
    
    function createProject(e:DialogEvent){
        if(e.button == DialogButton.APPLY){
            var p = path.text;
            if(FileSystem.isDirectory(p)){
                if(createParDir.selected && name.text != ""){
                    FileSystem.createDirectory(p+FileSystem.sep+name.text);
                }
                
            }
        }
    }

    @:bind(browse,MouseEvent.CLICK)
    function onBrowse(e:MouseEvent) {
        FileBrowserDialog.open(e);
        FileBrowserDialog.inst.onDialogClosed = function(e:DialogEvent){
            if(e.button == DialogButton.APPLY)
                path.text = FileBrowserDialog.inst.fb.path.text;
        }
    }
}