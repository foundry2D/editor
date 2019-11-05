package;


import kha.Image;
#if arm_csm
import iron.Trait;
import iron.data.SceneFormat;
import armory.renderpath.RenderPathCreator;
import iron.RenderPath;
#end
#if coin
import coin.Trait;
import coin.data.SceneFormat;
import coin.State;
import coin.Coin;
import kha.Scaler;
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
				#elseif coin
				if (Coin.scenebuffer == null) Coin.scenebuffer = kha.Image.createRenderTarget(Std.int(this.width),Std.int(this.height));
				Coin.BUFFERWIDTH = Std.int(this.width);
				Coin.BUFFERHEIGHT = Std.int(this.height);
				// Coin.scenebuffer.g2.pushTransformation(kha.math.FastMatrix3.translation(this.screenX ,this.screenY));
				Coin.scenebuffer.g2.pushTransformation(Scaler.getScaledTransformation(Coin.WIDTH,Coin.HEIGHT,Std.int(this.width),Std.int(this.height), kha.System.screenRotation));
				Coin.scenebuffer.g2.color = Coin.backgroundcolor;
				Coin.scenebuffer.g2.fillRect(this.screenX,this.screenY,this.width,this.height);
				if (State.active != null){
					State.active.render(Coin.scenebuffer);
				}
				
				var image = Coin.scenebuffer;
				// g.drawImage(image, 0 ,0);
				#end
				g.color = 0xffffffff;
				if (Image.renderTargetsInvertedY()) {

					g.drawScaledImage(image, this.screenX ,this.screenY +this.height, this.width, -this.height);

				}
				else {
					g.drawScaledImage(image, this.screenX ,this.screenY +this.height, this.width, this.height);
				}
				#if coin
				Coin.scenebuffer.g2.popTransformation();
				#end
			}
}