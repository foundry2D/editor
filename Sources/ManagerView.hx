package;

import kha.Image;
import kha.Assets;
import haxe.ui.containers.Box;
import haxe.ui.events.MouseEvent;
import haxe.ui.containers.dialogs.Dialog;
import found.data.Project.TProject;

@:build(haxe.ui.macros.ComponentMacros.build("../Assets/project-manager.xml"))
class ManagerView extends Box {
    public function new(data:Array<TProject> =null) {
        super();
        percentWidth = 100;
        percentHeight = 100;
        projectslist.itemRenderer =  haxe.ui.macros.ComponentMacros.buildComponent(
			"../Assets/custom/projectlist-items.xml");
        if(data != null){
            // projectslist.dataSource
            for(proj in data){
                projectslist.dataSource.add(proj);
            }
        }
    }

    @:bind(newproject,MouseEvent.CLICK)
    function creator(e:MouseEvent){
        var inst = new ProjectCreator(function(){

            kha.FileSystem.getContent(EditorUi.cwd+"/pjml.found", function(blob:String){
                var out:{list:Array<TProject>} = haxe.Json.parse(blob);
                projectslist.dataSource.add(out.list.pop());
            });
        });
        inst.show();
    }

    @:bind(run,MouseEvent.CLICK)
    function runProject(e:MouseEvent){
        if(projectslist.selectedItem != null){
            var project:TProject = projectslist.selectedItem;
            found.State.addState('default',project.scenes[0]);
            EditorUi.projectPath = project.path;
            found.State.set('default',found.App.editorui.init);//
        }
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