package;


import kha.math.FastVector2;
import utilities.Conversion;
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
		super(tr("Game"),0/*vertival*/,false);
	}
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

	public var drawWidth:Float = 0.0;
	public var drawHeight:Float = 0.0;
	
	@:access(EditorPanel,zui.Zui)
	override public function render(ui:zui.Zui) {

		if (Found.scenebuffer == null) Found.scenebuffer = kha.Image.createRenderTarget(Found.backbuffer.width, Found.backbuffer.height);

		if(ui.tab(parent.htab,this.name)){
			var y = ui._y;
			{//Zui insanity related to how images are drawn
				var h:Float = null;
				var iw = Found.scenebuffer.width * ui.SCALE();
				var ih = Found.scenebuffer.height * ui.SCALE();
				var w = Math.min(iw, ui._w);
				var x = ui._x;
				var scroll = ui.currentWindow != null ? ui.currentWindow.scrollEnabled : false;
				var r = ui.curRatio == -1 ? 1.0 : ui.getRatio(ui.ratios[ui.curRatio], 1);
				if (ui.imageScrollAlign) { // Account for scrollbar size
					w = Math.min(iw, ui._w - ui.buttonOffsetY * 2);
					x += ui.buttonOffsetY;
					if (!scroll) {
						w -= ui.SCROLL_W() * r;
						x += ui.SCROLL_W() * r / 2;
					}
				}
				else if (scroll) w += ui.SCROLL_W() * r;

				// Image size
				var ratio:Float = h == null ? w / iw : h / ih;
				h == null ? h = ih * ratio :w = iw * ratio;
				drawWidth = w;
				drawHeight = h;
			}
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
					var tpos = new FastVector2(e.position.x,e.position.y);
					tpos.x -= State.active.cam.position.x;
					tpos.y -= State.active.cam.position.y;
					tpos = Conversion.WorldToScreen(tpos);
					EditorTools.render(ui,tpos.x,tpos.y,y);
				}

			}
			ui._y = y;
		}
		parent.windowHandle.redraws = 2;
	}
}