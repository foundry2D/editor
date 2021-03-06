package;

import kha.math.Vector4;
import utilities.Config;
import zui.Id;
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
	public var rect:Vector4 = new Vector4();
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
	public function update(dt:Float) {}
	var animateIn:Bool = false;
	var animateOut:Bool = false;
	var lastColor:kha.Color = kha.Color.White;
	@:access(zui.Zui)
	public function render(ui:Zui,element:TElement) {
		this.ui = ui;
		if(mouse == null) mouse = Input.getMouse();
		
		var main = found.App.editorui;

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

		if(main.currentView > 0 || !Config.raw.autoHideMenuBar){
			visible = animateIn = animateOut = true;
		}
		
		if(!visible && !animateIn && !animateOut)return;

		delta = kha.Scheduler.time() -current;
        current =  kha.Scheduler.time();

		if(main.currentView == 0){
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
		}

		//Draw the ui
		ui.inputEnabled = true;
		var WINDOW_BG_COL = ui.t.WINDOW_BG_COL;
		ui.t.WINDOW_BG_COL = ui.t.SEPARATOR_COL;
		rect.x = element.x;
		rect.y = this.y;
		rect.z = element.width;
		rect.w = element.height;
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

			if (menubarw < ui._x + 10) {
				menubarw = Std.int(ui._x + 10);
			}

			ui._w = _w;
			ui._x = element.width * 0.5;
			ui._y =  element.height * 0.1;
			var currentImage = App.editorui.isPlayMode ? pauseImage : playImage;
			var state = ui.image(currentImage,lastColor);
			if(state == zui.Zui.State.Released){
				EditorUi.togglePlayMode();
				Music.stopAll();
			}
			else if(state == zui.Zui.State.Hovered){
				lastColor = kha.Color.Orange;
			}
			else {
				lastColor = kha.Color.White;
			}
			ui._y = 0.0;
			ui._w = Std.int(ui._w + ui.ELEMENT_W());
			main.currentView = Ext.inlineRadio(ui,Id.handle(),["Scene","Code","Draw"]);
			Ext.endMenu(ui);

			ui._x = ui._w-ui.ELEMENT_W() * 2;//This removes a line under the menu bar... its weird.
		}
		ui.t.WINDOW_BG_COL = WINDOW_BG_COL;
		//This only works if the menu is the first to be drawn; this may be buggy... @:TODO
		ui.inputEnabled = !EditorMenu.show;
	}
	public function redraw() {
		menuHandle.redraws = 2;
	}
}
