package;

import zui.Ext;
import zui.Id;
import kha.System;

import zui.Zui;

import khafs.Fs;

import found.data.SceneFormat;
import found.data.Data;
import found.math.Util;
import found.Url;

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
    
    static var drawGridHandle:Handle = Id.handle({selected:true});
    static var camControlLeftHandle:Handle = Id.handle();
    static var camControlRightHandle:Handle = Id.handle();
    static var camControlUpHandle:Handle = Id.handle();
    static var camControlDownHandle:Handle = Id.handle();
    @:access(zui.Zui)
    public static function render(g:kha.graphics2.Graphics){

        var ui = found.Found.popupZuiInstance;

        var menuW = Std.int(ui.ELEMENT_W() * 2.0);

        var BUTTON_COL = ui.t.BUTTON_COL;
		ui.t.BUTTON_COL = ui.t.SEPARATOR_COL;
		var ELEMENT_OFFSET = ui.t.ELEMENT_OFFSET;
		ui.t.ELEMENT_OFFSET = 0;
        var ELEMENT_H = ui.t.ELEMENT_H;
        ui.t.ELEMENT_H = 28;
        g.begin(false);
        ui.beginRegion(g, menuX, menuY, menuW);

        var menuItemsCount = [5, 2, 2,12, 19, 5];
        var sepw = menuW / ui.SCALE();
        ui.g.color = ui.t.SEPARATOR_COL;
        ui.g.fillRect( menuX, menuY, menuW, 28 * menuItemsCount[menuCategory] * ui.SCALE());
        
        //Begin
        
        if (menuCategory == MenuFile) {
            if (ui.button("      " + tr("New Scene..."), Left, Config.keymap.file_new)){
                createScene();
                show = false;
            }
            if (ui.button("      " + tr("Open..."), Left, Config.keymap.file_open)){
                openScene();
                show = false;
            }
            if (ui.button("      " + tr("Save"), Left, Config.keymap.file_save)){
                saveProject();
                show = false;
            }
            if (ui.button("      " + tr("Save As..."), Left, Config.keymap.file_save_as)){
                trace("Implemente me !");
                show = false;
            }
            if (ui.button("      " + tr("Export Project..."), Left)){
                show = false;
            }
            ui.fill(0, 0, sepw, 1, ui.t.ACCENT_SELECT_COL);
            if (ui.button("      " + tr("Exit"), Left)){ 
                System.stop();
                show = false;
            }
        }
        else if (menuCategory == MenuEdit) {
            if (ui.button("      " + tr("Scene Settings"), Left)){
                trace("Implement me");
            }
            if (ui.button("      " + tr("Preferences..."), Left, Config.keymap.edit_prefs)){
                show = false;
                ConfigSettingsDialog.open();
            }
        }
        else if (menuCategory == MenuViewport) {
            if(ui.check(drawGridHandle,tr("Draw Grid"))){
                if(drawGridHandle.changed){
                    show = false;
                }
                drawGridHandle.value = found.Found.GRID; 
                var size = Ext.floatInput(ui,drawGridHandle,tr("Grid size"));
                if(drawGridHandle.changed){
                    found.Found.GRID = Std.int(Util.snap(size,8));
                } 
            }
        }
        else if (menuCategory == MenuCamera) {

            ui.text("Camera Movement Input");
            ui.fill(0, 0, sepw, 1, ui.t.ACCENT_SELECT_COL);
            var keyCode = Ext.keyInput(ui,camControlLeftHandle,tr("Left Input"));
            if(camControlLeftHandle.changed){

            }

            keyCode = Ext.keyInput(ui,camControlRightHandle,tr("Right Input"));
            if(camControlRightHandle.changed){
                
            }

            keyCode = Ext.keyInput(ui,camControlUpHandle,tr("Up Input"));
            if(camControlUpHandle.changed){
                
            }

            keyCode = Ext.keyInput(ui,camControlDownHandle,tr("Down Input"));
            if(camControlDownHandle.changed){
                
            }
            ui.fill(0, 0, sepw, 1, ui.t.ACCENT_SELECT_COL);

        }
        else if (menuCategory == MenuHelp) {
            if (ui.button("      " + tr("Manual"), Left)) {
                Url.explorer("https://armorpaint.org/manual");
            }
            if (ui.button("      " + tr("Issue Tracker"), Left)) {
                Url.explorer("https://github.com/armory3d/armorpaint/issues");
            }
            if (ui.button("      " + tr("Report Bug"), Left)) {
                var url = "https://github.com/armory3d/armorpaint/issues/new?labels=bug&template=bug_report.md&body=*ArmorPaint%20" + Main.version + "-" + Main.sha + ",%20" + System.systemId + "*";
                Url.explorer(url);
            }
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
        g.end();
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