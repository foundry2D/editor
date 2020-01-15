package;


import found.data.Project.Type;
import haxe.ui.events.MouseEvent;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.extended.NodeData;
import haxe.ui.core.Screen;
import haxe.ui.extended.FileSystem;

class ProjectLoader extends Dialog {
    public function new() {
        super();
        title = "Open Project";
        modal = false;
        buttons =  DialogButton.APPLY | DialogButton.CANCEL;
		width = Screen.instance.width*0.75;
        height = Screen.instance.height*0.75;
        this.onDialogClosed = loadProject;

    }

    function loadProject(e:DialogEvent){
        
    }
}