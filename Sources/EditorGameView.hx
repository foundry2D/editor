package;

import kha.Image;
import found.Found;
import found.State;
import found.Trait;

class EditorGameView extends Tab {
	var drawTrait:Trait = new Trait();
	public var scenebuffer:Image;

    public function new(){
		super(tr("Game"));
		this.scenebuffer = kha.Image.createRenderTarget(Found.backbuffer.width, Found.backbuffer.height);
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
	
	@:access(EditorPanel,zui.Zui)
	override public function render(ui:zui.Zui) {

		if(ui.tab(parent.htab,this.name)){

			ui.image(scenebuffer);
			ui.g.end();
			parent.windowHandle.redraws = 1;
			scenebuffer.g2.begin();
			if (State.active != null){
				State.active.render(scenebuffer);
			}
			scenebuffer.g2.end();
			found.App.frameCounter.render(scenebuffer);
			ui.g.begin(false);
		}
		parent.htab.redraws = 2;
	}
}