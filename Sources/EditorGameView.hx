package;

import iron.Trait;
import iron.data.SceneFormat;
import kha.Image;
#if arm_csm
import armory.renderpath.RenderPathCreator;
import iron.RenderPath;
#end
class EditorGameView extends EditorTab {
    var drawTrait:iron.Trait = new iron.Trait();
    public function new(){
        super();
        #if arm_csm
		var cscript = iron.Scene.active.camera.getTrait(armory.trait.internal.CanvasScript);

		iron.Scene.active.root.addTrait(drawTrait);
		drawTrait.notifyOnInit(function(){
			iron.Scene.active.root.addTrait(drawTrait);
			
			drawTrait.notifyOnRender2D(function(g:kha.graphics2.Graphics) {
				if (RenderPathCreator.finalTarget == null) return;
				if(cscript.ready){
					cscript.canvas.x = this.screenX;
					cscript.canvas.y = this.screenY;
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
				// Access final composited image that is afterwards drawn to the screen
				var image = RenderPathCreator.finalTarget.image;
				
				g.color = 0xffffffff;
				if (Image.renderTargetsInvertedY()) {

					g.drawScaledImage(image, this.screenX ,this.screenY +this.height, this.width, -this.height);
				}
				else {
					g.drawScaledImage(image, 0, 0, this.width / 2, this.height / 2);
				}
			});
		});
        
		
        #end
    }
}