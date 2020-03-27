package;

import kha.System;

import zui.Zui;

import khafs.Fs;

import found.data.SceneFormat;
import found.data.Data;

import utilities.Config;


@:enum abstract MenuCategory(Int) from Int to Int {
	var MenuFile = 0;
	var MenuEdit = 1;
	var MenuViewport = 2;
	var MenuMode = 3;
	var MenuCamera = 4;
	var MenuHelp = 5;
}


// @:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/editor-menu.xml"))
class EditorMenu {
    
    public static var show = false;
	public static var menuCategory = 0;
	public static var menuX = 0;
	public static var menuY = 0;
	public static var menuElements = 0;
	public static var keepOpen = false;
	public static var menuCommands: Zui->Void = null;
	static var changeStarted = false;
	static var showMenuFirst = true;
	static var hideMenu = false;

    public function new() {
    }
    
    @:access(zui.Zui)
    public static function render(ui:Zui){

        // var ui = found.Found.popupZuiInstance;

        var menuW = Std.int(ui.ELEMENT_W() * 2.0);

        var BUTTON_COL = ui.t.BUTTON_COL;
		ui.t.BUTTON_COL = ui.t.SEPARATOR_COL;
		var ELEMENT_OFFSET = ui.t.ELEMENT_OFFSET;
		ui.t.ELEMENT_OFFSET = 0;
        var ELEMENT_H = ui.t.ELEMENT_H;
        ui.t.ELEMENT_H = 28;
        
        ui.beginRegion(ui.g, menuX, menuY, menuW);

        var menuItems = [12, 3, 14,12, 19, 5];
        ui.g.color = ui.t.SEPARATOR_COL;
        ui.g.fillRect( menuX, menuY, menuW, 28 * menuItems[menuCategory] * ui.SCALE());
        
        //Begin
        
        if (menuCategory == MenuFile) {
            if (ui.button("      " + tr("New Scene..."), Left, Config.keymap.file_new)) createScene();
            if (ui.button("      " + tr("Open..."), Left, Config.keymap.file_open)) openScene();
            if (ui.button("      " + tr("Save"), Left, Config.keymap.file_save)) saveProject();
            if (ui.button("      " + tr("Save As..."), Left, Config.keymap.file_save_as)) trace("Implemente me !");
            if (ui.button("      " + tr("Exit"), Left)) System.stop();
        }
        

        //End
        var first = showMenuFirst;
		hideMenu = ui.comboSelectedHandle == null && !changeStarted && !keepOpen && !first && (ui.changed || ui.inputReleased || ui.inputReleasedR || ui.isEscapeDown);
		showMenuFirst = false;
		keepOpen = false;
		if (ui.inputReleased) changeStarted = false;

		ui.t.BUTTON_COL = BUTTON_COL;
		ui.t.ELEMENT_OFFSET = ELEMENT_OFFSET;
		ui.t.ELEMENT_H = ELEMENT_H;
		ui.endRegion();

    }

    @:access(EditorUi)
    static function saveProject(){
        #if html5
        
        #else//use the filesystem
        #end
    }

    static function openScene(){
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
    static function createScene(){
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

    static function loadScene(scene:TSceneFormat){
        found.App.reset();
        found.State.addState(scene.name,scene.name+'.json');
        found.State.set(scene.name);
        found.App.editorui.hierarchy.setFromScene(scene);
    }
}