package;


import kha.Image;
import kha.math.FastMatrix3;
#if arm_csm
import iron.Trait;
import iron.data.SceneFormat;
import armory.renderpath.RenderPathCreator;
import iron.RenderPath;
#end
#if found
import kha.Scaler;
import kha.math.Vector2;
import found.Found;
import found.State;
import found.Trait;
import found.data.SceneFormat;
#end

class EditorGameView extends Tab {
    var drawTrait:Trait = new Trait();

    public function new(){
		// Found.renderfunc = rendrer;
	}
	// function rendrer(g:kha.graphics2.Graphics){
	// 	haxe.ui.core.Screen.instance.renderTo(g);
	// }
	public var x(get,null):Float;
	function get_x(){
		return parent.x;
	}

	public var y(get,null):Float;
	function get_y(){
		return parent.y;
	}

	public var width(get,null):Float;
	function get_width(){
		return parent.w;
	}

	public var height(get,null):Float;
	function get_height(){
		return parent.h;
	}
	
	@:access(EditorPanel,zui.Zui)
	override public function render(ui:zui.Zui) {

		if (Found.scenebuffer == null) Found.scenebuffer = kha.Image.createRenderTarget(Found.backbuffer.width, Found.backbuffer.height);

		if(ui.tab(parent.htab,"Game")){
			var y = ui._y;
			ui.image(Found.scenebuffer);
			ui.g.end();
			parent.windowHandle.redraws = 1;
			var image = Found.scenebuffer;
			image.g2.begin();
			image.g2.pushTransformation(FastMatrix3.translation(-State.active.cam.position.x,-State.active.cam.position.y));
			EditorTools.drawGrid(image.g2);
			image.g2.popTransformation();
			if (State.active != null){
				State.active.render(image);
			}
			image.g2.end();
			found.App.frameCounter.render(image);
			ui.g.begin(false);
			if(found.App.editorui.inspector != null && found.App.editorui.inspector.index >= 0 ){
				var i = found.App.editorui.inspector.index;
				var e = State.active._entities[i];
				if(e != State.active.cam){
					EditorTools.render(ui,e.position.x,e.position.y,parent.w,parent.h,y);
				}

			}
		}
		parent.windowHandle.redraws = 2;
	}
}