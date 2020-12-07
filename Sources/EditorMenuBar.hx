package;

import found.math.Util;
import found.Input;
import kha.Image;
import found.audio.Music;
import zui.Canvas.TElement;
import found.App;
import zui.Zui;
import zui.Ext;

import EditorMenu;


class EditorMenuBar implements View {

	public static inline var defaultMenubarW = 330;

	var ui:zui.Zui;
	public var workspaceHandle = new Handle({layout: Horizontal});
	public var menuHandle = new Handle({layout: Horizontal});
	public var menubarw = defaultMenubarW;
	public  var y:Float = 0.0;
	
	var visible:Bool = false;
	
	var playImage:kha.Image;
	var pauseImage:kha.Image;
	var mouse:Mouse;
	var delta:Float;
	var current:Float;
	public function new() {

	}
	function shouldRedraw(image:kha.Image,width:Float,height:Float){
		var should = image == null;
		should = should ? should : image.width != width || image.height != height;
		return should;

	}
	function redrawPlay(size:Float,color:kha.Color){
		ui.g.end();
		playImage = Image.createRenderTarget(Std.int(size),Std.int(size));
		playImage.g2.begin(true,kha.Color.Transparent);
		playImage.g2.color = color;
		playImage.g2.fillTriangle(0,0,0,size,size,size*0.5);
		playImage.g2.end();
		ui.g.begin(false);
	}
	function redrawPause(size:Float,color:kha.Color){
		ui.g.end();
		pauseImage = Image.createRenderTarget(Std.int(size),Std.int(size));
		pauseImage.g2.begin(true,kha.Color.Transparent);
		pauseImage.g2.color = color;
		pauseImage.g2.fillRect(0,0,size * 0.15,size);
		pauseImage.g2.fillRect(size * 0.5,0,size * 0.15,size);
		pauseImage.g2.end();
		ui.g.begin(false);
	}
	var animateIn:Bool = false;
	var animateOut:Bool = false;
	@:access(zui.Zui)
	public function render(ui:Zui,element:TElement) {
		this.ui = ui;
		if(mouse == null) mouse = Input.getMouse();

		//Hide or show menu bar
		if(visible && !animateOut && !EditorMenu.show && mouse.y > element.height){
			animateOut = true;
			y = element.y;
			current =  kha.Scheduler.time();
		}
		else if(!animateIn && mouse.y < element.height){
			animateIn = true;
			y = 0;
			visible = true;
			current = kha.Scheduler.time();
		}
			
		if(!visible && !animateIn && !animateOut)return;

		delta = kha.Scheduler.time() -current;
        current =  kha.Scheduler.time();

		if(animateIn){
			y = Util.lerp(0,element.y,delta);
			if(y >= element.y){
				animateIn = false;
			}
		}
		else if(animateOut){
			y = Util.lerp(element.y,0,delta);
			if(y <= 0.1){
				animateOut = false;
				y = 0;
				visible = false;
			}
		}

		//Draw the ui
		ui.inputEnabled = true;
		var WINDOW_BG_COL = ui.t.WINDOW_BG_COL;
		ui.t.WINDOW_BG_COL = ui.t.SEPARATOR_COL;
		if (ui.window(menuHandle, Std.int(element.x), Std.int(this.y), Std.int(element.width),Std.int(element.height))) {
			var w = ui.BUTTON_H() > element.height ? element.height: ui.BUTTON_H();
			if(shouldRedraw(playImage,w,w)){
				redrawPlay(w,ui.t.ACCENT_COL);
			}
			if(shouldRedraw(pauseImage,w,w)){
				redrawPause(w,ui.t.ACCENT_COL);
			}
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
			ui._y =  element.height * 0.1;
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
	public function redraw() {
		menuHandle.redraws = 2;
	}
}
