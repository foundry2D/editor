package;


import kha.Image;
#if arm_csm
import iron.Trait;
import iron.data.SceneFormat;
import armory.renderpath.RenderPathCreator;
import iron.RenderPath;
#end
#if coin
import kha.Scaler;
import kha.math.Vector2;
import coin.Coin;
import coin.State;
import coin.Trait;
import coin.data.SceneFormat;
#end
class EditorGameView extends EditorTab {
    var drawTrait:Trait = new Trait();
    public function new(){
        super();
        #if arm_csm
		var cscript = iron.Scene.active.camera.getTrait(armory.trait.internal.CanvasScript);
		iron.Scene.active.root.addTrait(drawTrait);
		drawTrait.notifyOnInit(function(){
			iron.Scene.active.root.addTrait(drawTrait);
			drawTrait.notifyOnRender2D(function(g:kha.graphics2.Graphics){
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
			});
			drawTrait.notifyOnRender2D(drawGameView);
		});
		#elseif coin
		coin.Coin.renderfunc = drawGameView;
        #end

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

				#elseif coin

				g.end();
				var image = Coin.scenebuffer;
				image.g2.begin();
				if (State.active != null){
					State.active.render(image);
				}
				image.g2.end();

				g.begin();

				haxe.ui.core.Screen.instance.renderTo(g);
				g.drawScaledImage(image, this.screenX ,this.screenY, this.width, this.height);
				#end
			}
}