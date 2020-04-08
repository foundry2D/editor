package;


import kha.Image;
import kha.math.FastMatrix3;
import haxe.ui.core.Component;
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
@:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/editor-gameview.xml"))
class EditorGameView extends EditorTab {
    var drawTrait:Trait = new Trait();
	
	public var x(get,never):Int;
	function get_x() {
		return Math.floor(screenX);
	}
	public var y(get,never):Int;
	function get_y() {  
		return Math.floor(screenY);
	}
	public var w(get,never):Int;
	function get_w() {
		return Math.ceil(cast(this, Component).componentWidth);
	}
	public var h(get,never):Int;
	function get_h() {
		return Math.ceil(cast(this, Component).componentHeight);
	}

    public function new(){
		super();
		this.text = "Game";
        #if arm_csm
		var cscript = iron.Scene.active.camera.getTrait(armory.trait.internal.CanvasScript);
		iron.Scene.active.root.addTrait(drawTrait);
		drawTrait.notifyOnInit(function(){
			iron.Scene.active.root.addTrait(drawTrait);
			drawTrait.notifyOnRender2D(function(g:kha.graphics2.Graphics){
				if(cscript.ready){
					cscript.canvas.x = this.x;
					cscript.canvas.y = this.y;
					var wscale = Std.int(this.width)/cscript.canvas.width;
					var hscale = Std.int(this.height)/cscript.canvas.height;
					for(el in cscript.canvas.elements){
						el.x = el.x*wscale;
						el.y = el.y*hscale;
						el.width = Std.int(el.width*wscale);
						el.height = Std.int(el.height*hscale);
					}
					cscript.canvas.width = Std.int(this.width);
					cscript.canvas.height = Std.int(this.height);
				}
			});
			drawTrait.notifyOnRender2D(drawGameView);
		});
		#elseif found
		found.Found.renderfunc = drawGameView;
        #end

    }
	
	@:access(haxe.ui.core.Component)
	public override function renderTo(g:kha.graphics2.Graphics) {
		if(selectedPage == null)return;
		super.renderTo(g);
		if(selectedPage.text != "Game")return;
		g.drawScaledImage(Found.scenebuffer, x ,y, w, h);
	}
	function drawGameView(g:kha.graphics2.Graphics) {
		#if arm_csm
		if (RenderPathCreator.finalTarget == null) return;			
		// Access final composited image that is afterwards drawn to the screen
		var image = RenderPathCreator.finalTarget.image;

		g.color = 0xffffffff;
		if (Image.renderTargetsInvertedY()) {

			g.drawScaledImage(image, this.screenX ,this.screenY +this.height, this.width, -this.height);

		}
		else {
			g.drawScaledImage(image, this.screenX ,this.screenY +this.height, this.width, this.height);
		}

		#elseif found

		g.end();
		if (Found.scenebuffer == null) Found.scenebuffer = kha.Image.createRenderTarget(Found.backbuffer.width, Found.backbuffer.height);
		if(selectedPage != null && selectedPage.text == "Game"){
			var image = Found.scenebuffer;
			image.g2.begin();
			image.g2.pushTransformation(FastMatrix3.translation(-State.active.cam.position.x,-State.active.cam.position.y));
			EditorTools.drawGrid(image.g2);
			image.g2.popTransformation();
			if (State.active != null){
				State.active.render(image);
			}
			image.g2.pushTransformation(FastMatrix3.translation(-State.active.cam.position.x,-State.active.cam.position.y));
			if(found.App.editorui.inspector != null && found.App.editorui.inspector.index >= 0 ){
				var i = found.App.editorui.inspector.index;
				var e = State.active._entities[i];
				if(e != State.active.cam)
					EditorTools.render(image.g2,e.position.x,e.position.y,w,h);

			}
			image.g2.popTransformation();
			image.g2.end();
			found.App.frameCounter.render(image);
		}
		g.begin();
		haxe.ui.core.Screen.instance.renderTo(g);
		#end
	}
}