package;

import kha.Image;
import kha.Assets;

import haxe.ui.core.Screen;
import haxe.ui.data.ArrayDataSource;
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
            EditorUi.scenePath = project.scenes[0];
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
        dropdown.dataSource = new ArrayDataSource<String>();
        dropdown.dataSource.add("All");

        if(projectslist.selectedItem != null){
            var project:TProject = projectslist.selectedItem;
            cust.info.text = StringTools.replace(proj,"$proj",project.name);
            dropdown.dataSource.add(project.name);
            dropdown.selectedIndex = 1;
            lastIndex = 1;
        }
        else{
            cust.info.text = allProj;
            dropdown.selectedIndex = 0;
        }
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
                    #if kha_webgl
                    kha.FileSystem.dbKeys.clear();
                    #end
                    kha.FileSystem.saveToFile(EditorUi.cwd+"/pjml.found",haxe.io.Bytes.ofString('{"list":[]}'));
                    for( i in 0...projectslist.dataSource.size){
                        var proj:TProject = projectslist.dataSource.get(i);
                        kha.FileSystem.deleteDirectory(proj.path,true);
                    }
                    projectslist.dataSource.clear();
                }
                else {
                    var project:TProject = projectslist.selectedItem;
                    projectslist.dataSource.remove(projectslist.dataSource.get(index-1));
                    kha.FileSystem.deleteDirectory(project.path,true);
                    kha.FileSystem.getContent(EditorUi.cwd+"/pjml.found", function(blob:String){
                        var out:{list:Array<found.data.Project.TProject>} = haxe.Json.parse(blob);
                        out.list.remove(project);
                        var data = haxe.Json.stringify(out);
                        kha.FileSystem.saveToFile(EditorUi.cwd+"/pjml.found",haxe.io.Bytes.ofString(data));
                    });
                }
            }
        };
        cust.show();
    }

    
    @:bind(importProject,MouseEvent.CLICK)
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