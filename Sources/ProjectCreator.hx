package;

import found.data.Project.Type;
import haxe.ui.events.MouseEvent;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.core.Screen;
import khafs.Fs;

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
            if(Fs.isDirectory(p)){
                var outp = p;
                var type = twoD.selected ? Type.twoD: Type.threeD;
                var projName = name.text != null ? name.text:"Project";
                outp = p+Fs.sep+projName;
                Fs.createDirectory(outp);
                ProjectInit.done = onDone;
                ProjectInit.run(outp,type,projName);
            }
        }
    }

    @:bind(browse,MouseEvent.CLICK)
    function onBrowse(e:MouseEvent) {
        var done = function(passedPath:String){
                path.text = passedPath;
        }
        FileBrowserDialog.open(done);
        
    }
}