package;


import haxe.io.BytesInput;
import haxe.zip.Reader;

import zui.Id;
import zui.Zui;
import zui.Ext;
import zui.Themes.TTheme;
import zui.Canvas.TElement;

import found.Event;
import found.data.Data;
import found.data.Project.TProject;
import found.trait.internal.CanvasScript;
import utilities.Config;

import khafs.Fs;

class ManagerView extends CanvasScript {
    var projects:Array<TProject> = [];
    var selectedItem:TProject = null;
    public var theme(get,null):TTheme;
    function get_theme(){
        if(canvas == null)return null;
        return zui.Canvas.getTheme(this.canvas.theme);
    }
    var ui:zui.Zui;
    public function new(data:Array<TProject> =null) {
        super("projectView","font_default.ttf",kha.Assets.blobs.get("projectView_json"),true);
        if(!Fs.exists(EditorUi.cwd+Fs.sep+"pjml.found")){
            Fs.saveContent(EditorUi.cwd+Fs.sep+"pjml.found",'{"list":[]}');
        }
        if(data != null){
            projects = data;
        }
        ui = new Zui({font:kha.Assets.fonts.font_default});
        this.addCustomDraw("List",drawView);
        
        Event.add("onRun",runProject);
        Event.add("onNew",createProject);
        Event.add("onImportProject",importProject);
        Event.add("onDeleteAllProjects",deleteAllProjects);
        Event.add("onDelConfig",delConfig);
    }
    var titleElem:TElement = null;
    
    var tabsHandle = Id.handle();
    var listHandle = Id.handle();
    
    function drawView(g: kha.graphics2.Graphics,element:TElement){
        if(titleElem == null){
            titleElem = getElement("Title");
            #if kha_debug_html5
            getElement("Import").visible = false;
            getElement("Delete").visible = false;
            getElement("DelApp").visible = false;
            #end
        }
            
        translate();
        
        
        var elem = element;
        ui.begin(g);
        if(ui.window(Id.handle(),Math.floor(elem.x),Math.floor(elem.y),elem.width,elem.height)){
            
            if(ui.tab(tabsHandle,tr("Projects"))){
                var selected = Ext.list(ui,listHandle,projects,{itemDrawCb: drawItems,getNameCb:projName,removeCb: deleteProject, showAdd: false,showRadio: true,editable: false});
                selectedItem = projects[selected];
            }
            if(ui.tab(tabsHandle,tr("Templates"))){

            }
        }
        ui.end();
    }
    function projName(i:Int){
        if(i < 0)return"";
        return projects[i].name;
    }
    function drawItems(h:zui.Zui.Handle,i:Int){
        if(i < 0) return;
        if(ui.button("Path: "+projects[i].path,Align.Left)){
            listHandle.nest(0).position = i;
            redraw();
        }
    }
    function redraw(){
        tabsHandle.redraws = listHandle.redraws = 2;
    }

    function translate(){
        titleElem.text = "Foundry Engine - "+tr("Project Manager");
        getElement("Run").text = tr("Run");
        getElement("New").text = tr("New Project");
        getElement("Import").text = tr("Import");
        getElement("Delete").text = tr("Delete All Projects");
        getElement("DelApp").text = tr("Delete App Config");
    }
    
    @:access(EditorUi)
    function createProject(){
        ProjectCreator.open(function(){

            #if kha_debug_html5
            projects = EditorUi.getLocalProjects();
            redraw();
            #else
            Fs.getContent(EditorUi.cwd+"/pjml.found", function(blob:String){
                var out:{list:Array<TProject>} = haxe.Json.parse(blob);
                projects = out.list;
            });
            #end
        });
    }


    function runProject(){
        if(selectedItem != null){
            this.visible = false;
            var project:TProject = selectedItem;
            var path = project.scenes[0];
            var sep = Fs.sep;
            var firstName = StringTools.replace(path.split(sep)[path.split(sep).length-1],'.json',"");
            firstName = StringTools.replace(path.split(sep)[path.split(sep).length-1],'_json',"");
            for(i in 0...project.scenes.length){
                path = project.scenes[i];
                name = StringTools.replace(path.split(sep)[path.split(sep).length-1],'.json',"");
                name = StringTools.replace(path.split(sep)[path.split(sep).length-1],'_json',"");
                found.State.addState(name,project.scenes[i]);
            }
            EditorUi.projectName = project.name;
            EditorUi.projectPath = project.path;
            EditorUi.scenePath = project.scenes[0];
            found.State.set(firstName,found.App.editorui.init);//
        }
    }
    
    function deleteProject(i:Int){
        if(i < 0)return;
        var project:TProject = projects[i];
        #if !kha_debug_html5
        Fs.getContent(EditorUi.cwd+"/pjml.found", function(blob:String){
            var out:{list:Array<found.data.Project.TProject>} = haxe.Json.parse(blob);
            var toRemove:TProject = null;
            for(proj in out.list){
                if(proj.name == project.name && proj.path == project.path){
                    toRemove = proj;
                    continue;
                }
                
            }
            out.list.remove(toRemove);
            var data = haxe.Json.stringify(out);
            Fs.saveContent(EditorUi.cwd+"/pjml.found",data,function(){
                Fs.deleteDirectory(project.path,true);
                for(proj in projects){
                    if(proj.name == project.name && proj.path == project.path){
                        projects.remove(proj);
                        break;
                    }
                }
                redraw();
            });
        });
        #else
        for(scenePath in project.scenes){
            Fs.deleteFile(scenePath);    
        }
        Fs.deleteFile(project.path+"_prj");
        #end
         
    }

    function deleteAllProjects() {
        #if kha_webgl
        Fs.dbKeys.clear();
        #end
        for( proj in projects){
            Fs.deleteDirectory(proj.path,true);
        }
        Fs.saveContent(EditorUi.cwd+Fs.sep+"pjml.found",'{"list":[]}');
        projects = [];
        redraw();
    }

    
    //@TODO: Enable checking project version and patching the project if its version is smaller.
    function importProject() {
        #if kha_html5
        Fs.curDir = EditorUi.cwd;
        Fs.onInputDone = function(lastPath:String){
            if(!StringTools.endsWith(lastPath,".zip")){error('Is not a zip file: $lastPath ');return;}
            var p = lastPath.split(Fs.sep);
            p.pop();
            var path = p.join(Fs.sep);
            var project:Null<TProject> = null;
            Data.getBlob(lastPath,function(b:kha.Blob){
                var input = new BytesInput(b.bytes);
                var entries = Reader.readZip(input);
                var dirPath = "";
                for(entry in entries){
                    var data = Reader.unzip(entry);
                    if(data != null){
                        var t = entry.fileName.split(Fs.sep);
                        if(StringTools.endsWith(t.pop(),".prj")){
                            project = haxe.Json.parse(data.toString());
                            continue;
                        }
                        dirPath = t.join(Fs.sep);
                        if(!Fs.isDirectory(dirPath)){
                            Fs.createDirectory(dirPath);
                        }                            
                        Fs.saveContent(path + Fs.sep + entry.fileName,data.toString());
                    }
                    else {
                        var fname = entry.fileName;
                        trace('Item with name $fname is null at path: $lastPath');
                    }
                }
                if(project != null){
                    Fs.getContent(EditorUi.cwd+Fs.sep+"pjml.found", function(blob:String){
                        var out:{list:Array<found.data.Project.TProject>} = haxe.Json.parse(blob);
                        out.list.push(project);
                        Fs.saveContent(EditorUi.cwd+Fs.sep+"pjml.found",haxe.Json.stringify(out),function(){
                            projects.push(project);
                            Fs.deleteFile(lastPath);
                            redraw();
                        });
                        
                    });
                }
                else {
                    trace("Zip did not have a project file. Aborting project creation...\n Project files will still be added to File System");
                }
            });
        }
        Fs.input.click();
        #else
        #end
    }

    function delConfig(){
        Fs.deleteFile("./config.found");
        Config.restore();
    }
    
}