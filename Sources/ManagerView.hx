package;

import found.Event;
import zui.Zui;
import zui.Ext;
import zui.Themes.TTheme;
import kha.Image;
import kha.Assets;

import utilities.Config;
import zui.Id;
import zui.Canvas.TElement;

import found.data.Project.TProject;
import found.trait.internal.CanvasScript;


class ManagerView extends CanvasScript {
    var projects:Array<TProject>;
    var selectedItem:TProject = null;
    public var theme(get,null):TTheme;
    function get_theme(){
        if(canvas == null)return null;
        return zui.Canvas.getTheme(this.canvas.theme);
    }
    var ui:zui.Zui;
    public function new(data:Array<TProject> =null) {
        super("projectView","font_default.ttf",kha.Assets.blobs.get("projectView_json"));
        if(data != null){
            projects = data;
        }
        this.addCustomDraw("List",drawView);
        ui = new Zui({font:kha.Assets.fonts.font_default});
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
        if(titleElem == null)
            titleElem = getElement("Title");
        titleElem.text = "Foundry Engine - Project Manager";
        
        

        ui.begin(g);
        if(ui.window(Id.handle(),Std.int(element.x),Std.int(element.y),Std.int(element.width),Std.int(element.height))){
            
            if(ui.tab(tabsHandle,"Projects")){
                var selected = Ext.list(ui,listHandle,projects,{itemDrawCb: drawItems,getNameCb:projName,removeCb: deleteProject, showAdd: false,showRadio: true,editable: false});
                selectedItem = projects[selected];
            }
            if(ui.tab(tabsHandle,"Templates")){

            }
        }
        ui.end();
    }
    function projName(i:Int){
        if(i < 0)return"";
        return projects[i].name;
    }
    function drawItems(h:zui.Zui.Handle,i:Int){
        if(ui.button("Path: "+projects[i].path,Align.Left)){
            listHandle.nest(0).position = i;
            redraw();
        }
    }
    function redraw(){
        tabsHandle.redraws = listHandle.redraws = 2;
    }
    
    function createProject(){
        ProjectCreator.open(function(){

            khafs.Fs.getContent(EditorUi.cwd+"/pjml.found", function(blob:String){
                var out:{list:Array<TProject>} = haxe.Json.parse(blob);
                projects = out.list;
            });
        });
    }


    function runProject(){
        this.visible = false;
        if(selectedItem != null){
            var project:TProject = selectedItem;
            found.State.addState('default',project.scenes[0]);
            EditorUi.projectPath = project.path;
            EditorUi.scenePath = project.scenes[0];
            found.State.set('default',found.App.editorui.init);//
        }
    }
    
    function deleteProject(i:Int){
        if(i < 0)return;
        var project:TProject = projects[i];
        khafs.Fs.getContent(EditorUi.cwd+"/pjml.found", function(blob:String){
            var out:{list:Array<found.data.Project.TProject>} = haxe.Json.parse(blob);
            var toRemove = null;
            for(proj in out.list){
                if(proj.name == project.name && proj.path == project.path){
                    toRemove = proj;
                    continue;
                }
                
            }
            out.list.remove(toRemove);
            var data = haxe.Json.stringify(out);
            khafs.Fs.saveContent(EditorUi.cwd+"/pjml.found",data,function(){
                khafs.Fs.deleteDirectory(project.path,true);
            });
        });
         
    }

    function deleteAllProjects() {
        #if kha_webgl
        khafs.Fs.dbKeys.clear();
        #end
        for( proj in projects){
            khafs.Fs.deleteDirectory(proj.path,true);
        }
        khafs.Fs.saveContent(EditorUi.cwd+"/pjml.found",'{"list":[]}');
    }

    
    function importProject() {
        #if kha_html5
        khafs.Fs.curDir = EditorUi.cwd;
        khafs.Fs.input.click();
        #else
        // FileBrowserDialog.open(e);
        // FileBrowserDialog.inst.onDialogClosed = function(e:DialogEvent){
            // if(e.button == DialogButton.APPLY)
                // path.text = FileBrowserDialog.inst.fb.path.text;
        // }
        #end
        // kha.Assets.loadImageFromPath
        // Image.fromEncodedBytes(haxe.io.Bytes.ofString(""),"",function(img:kha.Image){},function(img:String){},true);
    }

    function delConfig(){
        khafs.Fs.deleteFile("./config.found");
        Config.restore();
    }
    
}