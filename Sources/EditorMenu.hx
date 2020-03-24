package;
import haxe.ui.containers.HBox;
import haxe.ui.containers.menus.*;
import haxe.ui.core.Component;
import haxe.ui.core.Screen;
import haxe.ui.components.DropDown;
import haxe.ui.events.MouseEvent;
import haxe.ui.containers.menus.Menu.MenuEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.containers.dialogs.Dialog;

import khafs.Fs;
import found.data.SceneFormat;
import found.data.Data;



@:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/editor-menu.xml"))
class EditorMenu extends HBox {
    public function new() {
        super();
        id = "editormenu";
        this.width = Screen.instance.width;
    }
    @:bind(mainMenu, MenuEvent.MENU_SELECTED)
    function processMenuChoice(e:MenuEvent){
        switch(e.menuItem.text){
            case "New Scene":
                createScene(e);
            case "Open Scene":
                openScene(e);
            case "Save Project":
                saveProject(e);
        }
    }
    @:access(EditorUi)
    function saveProject(e:UIEvent){
        #if html5
        
        #else//use the filesystem
        #end
    }
    function openScene(e:UIEvent){
        var done = function(path:String){
            var sep = Fs.sep;
            var name = path.split(sep)[path.split(sep).length-1];
            if(StringTools.contains(name,".json") && Fs.exists(path)){
                EditorUi.scenePath = path;
                Data.getSceneRaw(path,loadScene);

            }
            else{
                trace('Error: file with name $name is not a valid scene name or the path "$path" was invalid ');
            }

        }
        FileBrowserDialog.open(done);
    }
    function createScene(e:UIEvent){
        var done = function(path:String){
            var sep = Fs.sep;
            var name = path.split(sep)[path.split(sep).length-1];
            #if found
            var scene:TSceneFormat = {
                name: StringTools.replace(name,'.json',""),
                _entities:[],
                _depth: true,
                _Zsort: false,
                traits: [] // Scene root traits
            }
            #end
            EditorUi.scenePath = path;
            Fs.saveContent(path,haxe.Json.stringify(scene),
            function(){
                Data.getSceneRaw(path,loadScene);
            });
        }
        FileBrowserDialog.open(done);
        
    }
    function loadScene(scene:TSceneFormat){
        found.App.reset();
        found.State.addState(scene.name,scene.name+'.json');
        found.State.set(scene.name);
        found.App.editorui.hierarchy.setFromScene(scene);
    }
}