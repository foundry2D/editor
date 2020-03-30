package;

import found.App;
import kha.System;
import zui.Zui;
import zui.Id;

import haxe.ui.containers.HBox;
import haxe.ui.core.Component;

import EditorMenu;


class EditorMenuBar extends HBox  {

    public var x(get, never):Int;

	function get_x() {
		return Math.floor(screenX);
	}

	public var y(get, never):Int;

	function get_y() {
		return Math.floor(screenY);
	}

	public var w(get, never):Int;

	function get_w() {
		return Math.ceil(this.parentComponent.componentWidth);
	}

	public var h(get, never):Int;

	function get_h() {
		return Math.ceil(this.parentComponent.componentHeight);
    }

	public static inline var defaultMenubarW = 330;

	public var workspaceHandle = new Handle({layout: Horizontal});
	public var menuHandle = new Handle({layout: Horizontal});
    public var menubarw = defaultMenubarW;
    
	var playImage:kha.Image;
	var pauseImage:kha.Image;
	public function new() {
		super();
		playImage = kha.Assets.images.play;
		pauseImage = kha.Assets.images.pause;
	}

	@:access(zui.Zui)
	public function render(ui:Zui) {

		var WINDOW_BG_COL = ui.t.WINDOW_BG_COL;
		ui.t.WINDOW_BG_COL = ui.t.SEPARATOR_COL;
		if (ui.window(menuHandle, this.x, this.y, this.w, this.h)) {
			var _w = ui._w;
			ui._x += 1; // Prevent "File" button highlight on startup

			var ELEMENT_OFFSET = ui.t.ELEMENT_OFFSET;
			ui.t.ELEMENT_OFFSET = 0;
			var BUTTON_COL = ui.t.BUTTON_COL;
			ui.t.BUTTON_COL = ui.t.SEPARATOR_COL;

			menuButton(ui,tr("File"), MenuFile);
			menuButton(ui,tr("Edit"), MenuEdit);
			menuButton(ui,tr("Viewport"), MenuViewport);
			menuButton(ui,tr("Mode"), MenuMode);
			menuButton(ui,tr("Camera"), MenuCamera);
			menuButton(ui,tr("Help"), MenuHelp);

			if (menubarw < ui._x + 10) {
				menubarw = Std.int(ui._x + 10);
			}

			ui._w = _w;
			ui._x = this.w * 0.5;
			ui._y =  this.h * 0.5 - playImage.height * 0.25;
			var currentImage = App.editorui.isPlayMode ? pauseImage : playImage;
			var state = ui.image(currentImage);
			if(state == zui.Zui.State.Released){
				if(App.editorui.isPlayMode){
					App.editorui.isPlayMode = false;
				}
				else{
					App.editorui.isPlayMode = true;
				}
			}
			else if(state == zui.Zui.State.Hovered){
				trace("Hovered");
			}
			ui.t.ELEMENT_OFFSET = ELEMENT_OFFSET;
			ui.t.BUTTON_COL = BUTTON_COL;
		}
        ui.t.WINDOW_BG_COL = WINDOW_BG_COL; 
	}

	@:access(zui.Zui)
	function menuButton(ui:Zui,name: String, category: Int) {
		
		ui._w = Std.int(ui.ops.font.width(ui.fontSize, name) + 25);
		var pressed = ui.button(name);
		if(pressed && EditorMenu.show){
			EditorMenu.show = false;
		}
		else if (pressed || (EditorMenu.show && EditorMenu.menuCommands == null && ui.isHovered)) {
			EditorMenu.show = true;
			EditorMenu.menuCategory = category;
			EditorMenu.menuX = Std.int(ui._x - ui._w);
			EditorMenu.menuY = this.h;
		}
	}
}
