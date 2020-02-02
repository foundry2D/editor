package;

import kha.Image;
import kha.Assets;

import haxe.ui.core.Screen;
import haxe.ui.data.DataSource;
import haxe.ui.events.MouseEvent;
import haxe.ui.components.DropDown;
import haxe.ui.containers.Box;
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
    static var allProj:String = "Do you really want to delete all your local projects ?";
    static var proj:String = "Do you really want to delete project named $proj ?";
    static var lastIndex:Int = 0;
    @:bind(delete,MouseEvent.CLICK)
    function deleteProject(e:MouseEvent){
        var cust = new CustomDialog({name:"Delete Projects",type:"warning"});
        var dropdown = new DropDown();
        var data:DataSource<String> = new DataSource<String>();
        data.add("All");
        if(projectslist.selectedItem != null){
            var project:TProject = projectslist.selectedItem;
            cust.info.text = StringTools.replace(proj,"$proj",project.name);
            data.add(project.name);
            dropdown.selectedIndex = 1;
            lastIndex = 1;
        }
        else{
            cust.info.text = allProj;
            dropdown.selectedIndex = 0;
        }
        dropdown.dataSource = data;
        cust.container.addComponent(dropdown);
        dropdown.onChange = function(e:haxe.ui.events.UIEvent){
            var curI = dropdown.selectedIndex;
            if(lastIndex != curI){
                if(projectslist.selectedItem != null && curI != 0){
                    var project:TProject = projectslist.selectedItem;
                    cust.info.text = StringTools.replace(proj,"$proj",project.name);
                }
                else{
                    cust.info.text = allProj;
                }
                lastIndex = curI;
            }
        };
        cust.onDialogClosed = function(e:DialogEvent){
            if(e.button == DialogButton.APPLY){
                var index = dropdown.selectedIndex;
                if(index == 0){
                    for( i in 0...projectslist.dataSource.size-1){
                        var proj:TProject = projectslist.dataSource.get(i);
                        trace(proj.path);
                    }
                }
                else {
                    var project:TProject = projectslist.selectedItem;
                    trace(project.path);

                }
            }
        };
        Screen.instance.addComponent(cust);
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