
import kha.Image;
import found.anim.Tile;
import kha.Blob;
import kha.graphics2.GraphicsExtension;
import khafs.Fs;

import zui.Id;
import zui.Zui;

import found.Found;
import found.App;
import found.Scene;
import found.anim.Sprite;
import found.anim.Tilemap;
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
	static var tile:Tile;
	static var shouldTileInit:Bool =false;

	@:access(found.anim.Sprite)
	public static function open(?p_sprite:Sprite,?p_tile:Tile) {
		sprite = p_sprite;
		tile = p_tile;
		if(sprite != null){
			image = p_sprite.data.image;
		}
		else if(tile != null){
			shouldTileInit = true;
		}
		else {
			trace("Error: CollisionEditor can not be opened without a Tile or a Sprite");
			found.App.editorui.ui.enabled = true;
			zui.Popup.show = false;
		}
		found.App.editorui.ui.enabled = false;
		zui.Popup.showCustom(Found.popupZuiInstance, collisionEditorPopupDraw, -1, -1, 600, 500);
	}
	@:access(found.anim.Tile)
	static function initTileImage(ui:Zui){
		ui.g.end();
		shouldTileInit = false;
		image = Image.createRenderTarget(Std.int(tile._w),Std.int(tile._h));
		image.g2.begin();
		tile.render(image,new kha.math.Vector2());
		image.g2.end();
		ui.g.begin(false);
	}
	@:access(zui.Zui, zui.Popup,found.anim.Sprite,found.anim.Tile)
	static function collisionEditorPopupDraw(ui:Zui) {
		if(shouldTileInit)
			initTileImage(ui);
		zui.Popup.boxTitle = "Edit collision";
		var border = 2 * zui.Popup.borderW + zui.Popup.borderOffset;
		var initX = ui._x;
		var data:Dynamic =  sprite != null ? sprite:tile;
		
		var shapes:Array<echo.data.Options.ShapeOptions> = [];
		if(sprite != null && data.raw.rigidBody.shapes != null){
			shapes = data.raw.rigidBody.shapes;
		}
		else if(tile != null && tile.raw.rigidBodies.exists(tile.tileId)){
			shapes = tile.raw.rigidBodies.get(tile.tileId).shapes;
		}
		//@:TODO make it possible to add multiple shape collisions
		
		var shape:Null<echo.data.Options.ShapeOptions> = null;
		if(shapes != null && shapes.length > 0){
			shape = shapes[0];
			comboBoxHandle.position = shape.type;
		}
		else {
			shape = echo.Shape.defaults;
			shape.offset_x = image.width * 0.5;
			shape.offset_y = image.height * 0.5;
			shape.width = image.width; 
			shape.height = image.height;
			shape.type = ShapeType.RECT;
			shapes.push(shape);
		}

		var selectedCollisionTypeIndex:Int = ui.combo(comboBoxHandle, collisionTypes, "Collision Type");

		if(comboBoxHandle.changed){
			if(selectedCollisionTypeIndex == ShapeType.RECT){
				shape = echo.Shape.defaults;
				shape.offset_x = image.width * 0.5;
				shape.offset_y = image.height * 0.5;
				shape.width = image.width; 
				shape.height = image.height;
				shape.type = ShapeType.RECT;
			}
			if(selectedCollisionTypeIndex == ShapeType.CIRCLE) {
				var radius = 0.5 * (image.width > image.height ? image.width : image.height);
				shape = echo.Shape.defaults;
				shape.offset_x = image.width*0.5;
				shape.offset_y = image.height*0.5;
				shape.radius = radius;
				shape.type = ShapeType.CIRCLE;
			}
			if(selectedCollisionTypeIndex == ShapeType.POLYGON) {

				var verts = [for(i in 0...4)new hxmath.math.Vector2(0,0)];
				verts[1].x = image.width;
				verts[2].x = image.width;
				verts[2].y = image.height;
				verts[3].y = image.height;
				shape = echo.Shape.defaults;
				shape.offset_x = shape.offset_y = 0;
				shape.rotation = 0;
				shape.vertices = verts;
				shape.type = ShapeType.POLYGON;
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
		
		
		var r = ui.curRatio == -1 ? 1.0 : ui.ratios[ui.curRatio];
		var px = ui._x+ui.buttonOffsetY+ui.SCROLL_W() * r*0.5;
		var py = ui._y;

		var tempX = ui._x;
		ui._x -= ui.buttonOffsetY+ui.SCROLL_W() * r / 2;
		var tempH = tile != null ? image.height:null;//dont change image height in ui.image
		var state = ui.image(image,0xffffffff,tempH,0,0,image.width,image.height);
		ui._x = tempX;

		ui._y += ui.ELEMENT_OFFSET() * 2;

		if(shape != null){
			var color = kha.Color.fromBytes(255,0,0,128);
			switch(shape.type){
				case ShapeType.RECT:

					var xHandle = Id.handle();
					xHandle.value = shape.offset_x;
					var x = ui.slider(xHandle,"X",data._w *0.5,data._w + data._w *0.5);
					if(xHandle.changed){
						shape.offset_x = x;
					}

					var yHandle = Id.handle();
					yHandle.value = shape.offset_y;
					var y = ui.slider(yHandle,"Y",data._h *0.5,data._h + data._h *0.5);
					if(yHandle.changed){
						shape.offset_y = y;
					}

					var widthHandle = Id.handle();
					widthHandle.value = shape.width;
					var w = ui.slider(widthHandle,"Width",0.1,data._w);
					if(widthHandle.changed){
						shape.width = w;
					}

					var heightHandle = Id.handle();
					heightHandle.value = shape.height;
					var h = ui.slider(heightHandle,"Height",0.1,data._h);
					if(heightHandle.changed){
						shape.height = h;
					}
					ui.g.color = color;
					ui.g.fillRect(ui._x+shape.offset_x-data._w*0.5,initY+shape.offset_y-data._h*0.5,shape.width,shape.height);
					ui.g.color = kha.Color.White;
				case ShapeType.CIRCLE:

					var xHandle = Id.handle();
					xHandle.value = shape.offset_x;
					var x = ui.slider(xHandle,"X",0,data._w);
					if(xHandle.changed){
						shape.offset_x = x;
					}

					var yHandle = Id.handle();
					yHandle.value = shape.offset_y;
					var y = ui.slider(yHandle,"Y",0,data._h);
					if(yHandle.changed){
						shape.offset_y = y;
					}

					var radiusHandle = Id.handle();
					radiusHandle.value = shape.radius;
					var maxRadius = 0.5 * (data._w < data._h ? data._w : data._h);
					var radius = ui.slider(radiusHandle,"Radius",1,maxRadius);
					if(radiusHandle.changed){
						shape.radius = radius;
					}
					ui.g.color = color;
					GraphicsExtension.fillCircle(ui.g,ui._x+shape.offset_x,initY+shape.offset_y,shape.radius);
					ui.g.color = kha.Color.White;
				case ShapeType.POLYGON:
					ui.text('Number of vertices: '+shape.vertices.length);
					ui.g.color = color;
					GraphicsExtension.fillPolygon(ui.g,ui._x+shape.offset_x,initY+shape.offset_y,cast(shape.vertices));
					var col = kha.Color.fromBytes(0,0,255,128);
					var selectedCol = kha.Color.fromBytes(0,0,255,255);
					for(vert in shape.vertices){
						ui.g.color = col;
						var w = 10;
						var addX = ui._x + (vert.x > 0 ? -w : 0.0);
						var addY = initY + (vert.y > 0 ? -w : 0.0);
						//@:TODO add double click to create a new point for the shape
						if(state == State.Down){
							var x = Math.abs(ui._windowX - ui.inputX) - px ;
							var y = Math.abs(ui._windowY - ui.inputY) - py ;
							var tempX = addX- ui._x;
							var tempY = addY -initY;

							if(x >= vert.x + tempX - w *2 &&  x <= vert.x + tempX + w * 2 && y >= vert.y + tempY - w *2 && y <= vert.y + tempY + w *2 ){
								ui.g.color = selectedCol;
								var tx = Math.min(x,data._w);
								var ty = Math.min(y,data._h);
								vert.x = Math.max(0,tx);
								vert.y = Math.max(0,ty);
							} 
						}
						ui.g.fillRect( vert.x + addX,vert.y + addY ,w,w);
					}
					ui.g.color = kha.Color.White;
			}
		}

		ui._x = initX;
		ui._y = ui._h - ui.t.BUTTON_H - border;
		ui.row([0.33, 0.33,0.33]);
		if (ui.button("Done")) {

			if(sprite != null){
				data.raw.rigidBody.shapes = shapes;
			}
			else {
				tile.raw.rigidBodies.get(tile.tileId).shapes = shapes;
			}
			data.body.clear_shapes();
			var i=0;
			while(i < shapes.length){
				data.body.create_shape(shapes[i]);
				i++;
			}

			if(tile != null){
				tile.map.removeBodies(found.State.active,tile.tileId);
				tile.map.makeBodies(found.State.active,tile.tileId);
			}
			
			sprite != null ? sprite.dataChanged = true:tile.map.dataChanged =true;
			EditorHierarchy.getInstance().makeDirty();
			exit();
		}
		if(ui.button("Remove")){
			if(sprite != null){
				data.raw.rigidBody.shapes = [];
			}
			else {
				tile.raw.rigidBodies.get(tile.tileId).shapes = [];
				tile.map.removeBodies(found.State.active,tile.tileId);
			}
			data.body.clear_shapes();
			sprite != null ? sprite.dataChanged = true:tile.map.dataChanged =true;
			EditorHierarchy.getInstance().makeDirty();
			exit();
		}
		if (ui.button("Cancel")) {
			exit();
		}
	}
	static function exit(){
		found.App.editorui.ui.enabled = true;
		zui.Popup.show = false;
	}
	@:access(echo.Shape)
	static function toOptions(shape:echo.Shape){
		var def = echo.Shape.get_defaults();
		def.type = shape.type;
		def.offset_x = shape.x;
		def.offset_y = shape.y;
		def.rotation = shape.rotation;
		def.solid = shape.solid;
		if(Std.is(shape,Rect)){
			var t = cast(shape,Rect);
			def.width = t.width;
			def.height = t.height;
		}
		else if(Std.is(shape,Circle)){
			def.radius = cast(shape,Circle).radius;
		}
		else if(Std.is(shape,Polygon)){
			def.vertices = cast(shape,Polygon).vertices;
		}
		return def;
	}
	
}
