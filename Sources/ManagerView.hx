package;

import kha.Image;
import kha.Assets;
import haxe.ui.containers.Box;
import haxe.ui.events.MouseEvent;
import haxe.ui.containers.dialogs.Dialog;

@:build(haxe.ui.macros.ComponentMacros.build("../Assets/project-manager.xml"))
class ManagerView extends Box {
    public function new(data:Array<foundry.data.Project.TProject> =null) {
        super();
        percentWidth = 100;
        percentHeight = 100;
        if(data != null){
            for(proj in data){
                projectslist.dataSource.add(proj);
            }
        }
    }

    @:bind(newproject,MouseEvent.CLICK)
    function creator(e:MouseEvent){
        var inst = new ProjectCreator();
        inst.show();
    }

    @:bind(open,MouseEvent.CLICK)
    function openProject(e:MouseEvent) {
        FileBrowserDialog.open(e);
        FileBrowserDialog.inst.onDialogClosed = function(e:DialogEvent){
            // if(e.button == DialogButton.APPLY)
                // path.text = FileBrowserDialog.inst.fb.path.text;
        }
        // kha.Assets.loadImageFromPath
        // Image.fromEncodedBytes(haxe.io.Bytes.ofString(""),"",function(img:kha.Image){},function(img:String){},true);
    }
    
}