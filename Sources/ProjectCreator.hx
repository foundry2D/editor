package;

import found.data.Project.Type;
import haxe.ui.events.MouseEvent;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.extended.NodeData;
import haxe.ui.core.Screen;
import kha.FileSystem;

@:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/project-creator.xml"))
class ProjectCreator extends Dialog {
    var onDone:Void->Void;
    public function new(done:Void->Void=null) {
        super();
        onDone = done;
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
                var outp = p;
                var type = twoD.selected ? Type.twoD: Type.threeD;
                var projName = name.text != null ? name.text:"Project";
                outp = p+FileSystem.sep+projName;
                FileSystem.createDirectory(outp);
                ProjectInit.done = onDone;
                ProjectInit.run(outp,type,projName);
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