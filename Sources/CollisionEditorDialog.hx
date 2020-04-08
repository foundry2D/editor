
import kha.Blob;
import kha.graphics2.GraphicsExtension;
import khafs.Fs;

import zui.Id;
import zui.Zui;

import found.Found;
import found.App;
import found.Scene;
import found.anim.Sprite;
import found.data.SceneFormat;

import echo.data.Types.ShapeType;
import echo.shape.Rect;
import echo.shape.Circle;
import echo.shape.Polygon;

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

		if(comboBoxHandle.changed){
			if(selectedCollisionTypeIndex == ShapeType.RECT){
				shape = echo.Shape.rect(0,0,image.width,image.height);
			}
			if(selectedCollisionTypeIndex == ShapeType.CIRCLE) {
				var radius = 0.5 * (image.width > image.height ? image.width : image.height);
				shape = echo.Shape.circle(image.width*0.5,image.height*0.5,radius);
			}
			if(selectedCollisionTypeIndex == ShapeType.POLYGON) {

				var verts = [for(i in 0...4)new hxmath.math.Vector2(0,0)];
				verts[1].x = image.width;
				verts[2].x = image.width;
				verts[2].y = image.height;
				verts[3].y = image.height;
				shape = Polygon.get_from_vertices(0,0,0,verts);
			}
			
			if(shapes.length > 0){
				shapes[0] = shape;
			}
			else {
				shapes.push(shape);
			}
		}
				
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

		// ui.g.color = kha.Color.Red;
		// ui.drawRect(ui.g,true,drawX,drawY,10,10);
		ui._y += ui.ELEMENT_OFFSET() * 2;

		if(shape != null){
			var color = kha.Color.fromBytes(255,0,0,128);
			switch(shape.type){
				case ShapeType.RECT:
					var rect:Rect = cast(shape);

					var xHandle = Id.handle();
					xHandle.value = rect.x;
					var x = ui.slider(xHandle,"X",0,sprite.width);
					if(xHandle.changed){
						rect.x = x;
					}

					var yHandle = Id.handle();
					yHandle.value = rect.y;
					var y = ui.slider(yHandle,"Y",0,sprite.height);
					if(yHandle.changed){
						rect.y = y;
					}

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
					ui.g.color = color;
					ui.g.fillRect(ui._x+rect.x,initY+rect.y,rect.width,rect.height);
					ui.g.color = kha.Color.White;
				case ShapeType.CIRCLE:
					var circle:Circle = cast(shape);

					var xHandle = Id.handle();
					xHandle.value = circle.x;
					var x = ui.slider(xHandle,"X",0,sprite.width);
					if(xHandle.changed){
						circle.x = x;
					}

					var yHandle = Id.handle();
					yHandle.value = circle.y;
					var y = ui.slider(yHandle,"Y",0,sprite.height);
					if(yHandle.changed){
						circle.y = y;
					}

					var radiusHandle = Id.handle();
					radiusHandle.value = circle.radius;
					var maxRadius = 0.5 * (sprite.width < sprite.height ? sprite.width : sprite.height);
					var radius = ui.slider(radiusHandle,"Radius",1,maxRadius);
					if(radiusHandle.changed){
						circle.radius = radius;
					}
					ui.g.color = color;
					GraphicsExtension.fillCircle(ui.g,ui._x+circle.x,initY+circle.y,circle.radius);
					ui.g.color = kha.Color.White;
				case ShapeType.POLYGON:
					var poly:Polygon = cast(shape);
					ui.text('Number of vertices: '+poly.vertices.length);
					ui.g.color = color;
					GraphicsExtension.fillPolygon(ui.g,ui._x+poly.x,initY+poly.y,cast(poly.vertices));
					var col = kha.Color.fromBytes(0,0,255,128);
					var selectedCol = kha.Color.fromBytes(0,0,255,255);
					for(vert in poly.vertices){
						ui.g.color = col;
						var w = 10;
						var addX = ui._x + (vert.x > 0 ? -w : 0.0);
						var addY = initY + (vert.y > 0 ? -w : 0.0);
						if(state == State.Down){
							var x = Math.abs(ui._windowX - ui.inputX) - px ;
							var y = Math.abs(ui._windowY - ui.inputY) - py ;
							var tempX = addX- ui._x;
							var tempY = addY -initY;
							// selectX = x + ui._x;
							// selectY = y + initY;
							trace("Vert X: "+ (vert.x + tempX)+"VertY: " + (vert.y + tempY ));
							trace('X: $x Y: $y');
							if(x >= vert.x + tempX &&  x <= vert.x + tempX + w && y >= vert.y + tempY && y <= vert.y + tempY + w){
								ui.g.color = selectedCol;
								vert.x = Math.max(0,Math.min(x,image.width));
								vert.y = Math.max(0,Math.min(y,image.height));
							} 
						}
						ui.g.fillRect( vert.x + addX,vert.y + addY ,w,w);
					}
					ui.g.color = kha.Color.White;
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
