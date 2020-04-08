import kha.Blob;
import khafs.Fs;

import zui.Id;
import zui.Zui;

import found.Found;
import found.App;
import found.Scene;
import found.anim.Sprite;
import found.data.SceneFormat;

import echo.data.Types.ShapeType;

class CollisionEditorDialog {
	static var textInputHandle:Handle = Id.handle();
	static var comboBoxHandle:Handle = Id.handle();
	static var collisionTypes = ["Rect", "Circle","Polygon"];
	static var image:kha.Image;
	static var sprite:Sprite;

	@:access(found.anim.Sprite)
	public static function open(p_sprite:Sprite) {
		sprite = p_sprite;
		image = p_sprite.data.image;
		found.App.editorui.ui.enabled = false;
		zui.Popup.showCustom(Found.popupZuiInstance, collisionEditorPopupDraw, -1, -1, 600, 500);
	}

	@:access(zui.Zui, zui.Popup,found.anim.Sprite)
	static function collisionEditorPopupDraw(ui:Zui) {
		zui.Popup.boxTitle = "Edit collision";
		var border = 2 * zui.Popup.borderW + zui.Popup.borderOffset;
		var initX = ui._x;
		
		var shapes = sprite.body.shapes;
		var shape:Null<echo.Shape> = null;
		if(shapes.length > 0){
			shape = shapes[0];
			comboBoxHandle.position = shape.type;
		}
		else {
			shape = echo.Shape.rect(0,0,image.width,image.height);
			shapes.push(shape);
		}
		var selectedCollisionTypeIndex:Int = ui.combo(comboBoxHandle, collisionTypes, "Collision Type");
				
		var initY = ui._y;
		
		var ratio = 1.0;
		if(image.width > ui._windowW){
			ratio = ui._windowW/image.width;
		}
		if(image.height > ui._windowH ){
			ratio = ui._windowH/image.height;
		}
		// ui._x = ui._windowW * 0.5 - image.width * ratio * 0.5;
		var r = ui.curRatio == -1 ? 1.0 : ui.ratios[ui.curRatio];
		var px = ui._x+ui.buttonOffsetY+ui.SCROLL_W() * r*0.5;
		var py = ui._y;
		var state = ui.image(image,0xffffffff,null,0,0,image.width,image.height);

		// var drawX = ui._x;
		// var drawY = initY;
		// if(state == State.Down){
		// 	var x = Math.abs(ui._windowX - ui.inputX) - px;
		// 	var y = Math.abs(ui._windowY - ui.inputY) - py;
		// 	trace('x: $x, y: $y');

		// 	drawX = x + ui._x;
		// 	drawY = y + initY;
		// 	trace('draw x: $drawX, draw y: $drawY');
		// }
		// ui.g.color = kha.Color.Red;
		// ui.drawRect(ui.g,true,drawX,drawY,10,10);
		ui._y += ui.ELEMENT_OFFSET() * 2;

		if(shape != null){
			switch(shape.type){
				case ShapeType.RECT:
					var rect:echo.shape.Rect = cast(shape);

					var widthHandle = Id.handle();
					widthHandle.value = rect.width;
					var w = ui.slider(widthHandle,"Width",0.1,sprite.width);
					if(widthHandle.changed){
						rect.width = w;
					}

					var heightHandle = Id.handle();
					heightHandle.value = rect.height;
					var h = ui.slider(heightHandle,"Height",0.1,sprite.height);
					if(heightHandle.changed){
						rect.height = h;
					}

					var xHandle = Id.handle();
					xHandle.value = rect.x;
					var x = ui.slider(xHandle,"X",0,sprite.width);
					if(xHandle.changed){
						rect.x = x;
					}

					var yHandle = Id.handle();
					yHandle.value = rect.y;
					var y = ui.slider(yHandle,"X",0,sprite.height);
					if(yHandle.changed){
						rect.y = y;
					}
					ui.g.color = kha.Color.fromBytes(255,0,0,128);
					ui.g.fillRect(ui._x+rect.x,initY+rect.y,rect.width,rect.height);
					ui.g.color = kha.Color.White;
				case ShapeType.CIRCLE:
				case ShapeType.POLYGON:

			}
		}

		ui._x = initX;
		ui._y = ui._h - ui.t.BUTTON_H - border;
		ui.row([0.5, 0.5]);
		if (ui.button("Done")) {
			//Set raw data to collision data based on what we just changed
            found.App.editorui.ui.enabled = true;
			zui.Popup.show = false;
		}
		if (ui.button("Cancel")) {
            found.App.editorui.ui.enabled = true;
			zui.Popup.show = false;
		}
	}
	
}
