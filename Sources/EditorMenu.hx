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

import haxe.ui.extended.FileSystem;
import coin.data.SceneFormat;
import coin.data.Data;


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
        }
    }
    function openScene(e:UIEvent){
        FileBrowserDialog.open(e);
        FileBrowserDialog.inst.onDialogClosed = function(e:DialogEvent){
            var path = null;
            if(e.button == DialogButton.APPLY)
                path = FileBrowserDialog.inst.fb.filepath.text;
            if(path == null)return;
            var sep = FileSystem.sep;
            var name = path.split(sep)[path.split(sep).length-1];
            if(StringTools.contains(name,".json") && FileSystem.exists(path)){
                EditorUi.scenePath = path;
                Data.getSceneRaw(path,loadScene);

            }
            else{
                trace('Error: file with name $name is not a valid scene name or the path "$path" was invalid ');
            }

        }
    }
    function createScene(e:UIEvent){
        FileBrowserDialog.open(e);
        FileBrowserDialog.inst.onDialogClosed = function(e:DialogEvent){
            var path = null;
            if(e.button == DialogButton.APPLY)
                path = FileBrowserDialog.inst.fb.filepath.text;
            if(path == null)return;
            var sep = FileSystem.sep;
            var name = path.split(sep)[path.split(sep).length-1];
            #if coin
            var scene:TSceneFormat = {
                name: StringTools.replace(name,'.json',""),
                _entities:[],
                _depth: true,
                _Zsort: false,
                traits: [] // Scene root traits
            }
            #end
            EditorUi.scenePath = path;
            FileSystem.saveToFile(path,haxe.io.Bytes.ofString(haxe.Json.stringify(scene)),
            function(){
                Data.getSceneRaw(path,loadScene);
            });
        }
    }
    function loadScene(scene:TSceneFormat){
        coin.App.reset();
        coin.State.addState(scene.name,scene.name+'.json');
        coin.State.set(scene.name);
        coin.App.editorui.hierarchy.setFromScene(scene);
    }
}