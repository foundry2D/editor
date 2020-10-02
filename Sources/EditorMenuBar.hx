package;

import found.audio.Music;
import zui.Canvas.TElement;
import found.App;
import zui.Zui;
import zui.Ext;

import EditorMenu;


class EditorMenuBar implements View {

	public static inline var defaultMenubarW = 330;

	public var workspaceHandle = new Handle({layout: Horizontal});
	public var menuHandle = new Handle({layout: Horizontal});
    public var menubarw = defaultMenubarW;
    
	var playImage:kha.Image;
	var pauseImage:kha.Image;
	public function new() {
		playImage = kha.Assets.images.play;
		pauseImage = kha.Assets.images.pause;
	}

	@:access(zui.Zui)
	public function render(ui:Zui,element:TElement) {

		ui.inputEnabled = true;
		var WINDOW_BG_COL = ui.t.WINDOW_BG_COL;
		ui.t.WINDOW_BG_COL = ui.t.SEPARATOR_COL;
		if (ui.window(menuHandle, Std.int(element.x), Std.int(element.y), Std.int(element.width),Std.int(element.height))) {
			var _w = ui._w;
			ui._x += 1; // Prevent "File" button highlight on startup

			var ELEMENT_OFFSET = ui.t.ELEMENT_OFFSET;
			ui.t.ELEMENT_OFFSET = 0;
			var BUTTON_COL = ui.t.BUTTON_COL;
			ui.t.BUTTON_COL = ui.t.SEPARATOR_COL;

			Ext.beginMenu(ui);

			var menuCategories = 5;
			for (i in 0...menuCategories) {
				var categories = [tr("File"), tr("Edit"), tr("Viewport"), tr("Camera"), tr("Help")];
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
			ui._x = element.width * 0.5;
			var origY = ui._y;
			ui._y =  element.height * 0.5 - playImage.height * 0.25;
			var currentImage = App.editorui.isPlayMode ? pauseImage : playImage;
			var state = ui.image(currentImage);
			if(state == zui.Zui.State.Released){
				EditorUi.togglePlayMode();
				Music.stopAll();
			}
			else if(state == zui.Zui.State.Hovered){
			}
			// ui.drawRect(ui._x,)
			ui.t.ELEMENT_OFFSET = ELEMENT_OFFSET;
			ui.t.BUTTON_COL = BUTTON_COL;
		}
		ui.t.WINDOW_BG_COL = WINDOW_BG_COL;
		//This only works if the menu is the first to be drawn; this may be buggy... @:TODO
		ui.inputEnabled = !EditorMenu.show;
	}
}
