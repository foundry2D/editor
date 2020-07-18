package;

import found.App;
import zui.Zui;
import zui.Ext;

import haxe.ui.containers.HBox;

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

	@:access(zui.Zui,found.Scene,found.object.Object,found.Trait)
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

			Ext.beginMenu(ui);

			var menuCategories = 6;
			for (i in 0...menuCategories) {
				var categories = [tr("File"), tr("Edit"), tr("Viewport"), tr("Mode"), tr("Camera"), tr("Help")];
				var pressed = Ext.menuButton(ui, categories[i]);
				if(pressed && EditorMenu.show){
					EditorMenu.show = false;
				}
				else if (pressed || (EditorMenu.show && EditorMenu.menuCommands == null && ui.isHovered)) {
					EditorMenu.show = true;
					EditorMenu.menuCategory = i;
					EditorMenu.menuX = Std.int(ui._x - ui._w);
					EditorMenu.menuY = Std.int(Ext.MENUBAR_H(ui));
				}
			}

			Ext.endMenu(ui);

			if (menubarw < ui._x + 10) {
				menubarw = Std.int(ui._x + 10);
			}

			ui._w = _w;
			ui._x = this.w * 0.5;
			var origY = ui._y;
			ui._y =  this.h * 0.5 - playImage.height * 0.25;
			var currentImage = App.editorui.isPlayMode ? pauseImage : playImage;
			var state = ui.image(currentImage);
			if(state == zui.Zui.State.Released){
				if(App.editorui.isPlayMode){
					for(object in found.State.active.activeEntities){
						for (t in object.traits){
							if (t._remove != null) {
								for (f in t._remove) f();
							}
						}
					}
					App.editorui.isPlayMode = false;
				}
				else{
					for(object in found.State.active.activeEntities){
						for (t in object.traits){
							if (t._init != null) {
								for (f in t._init) App.notifyOnInit(f);
							}
						}
					}
					App.editorui.isPlayMode = true;
				}
			}
			else if(state == zui.Zui.State.Hovered){
			}
			// ui.drawRect(ui._x,)
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
