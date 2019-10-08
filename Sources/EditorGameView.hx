package;

import iron.Trait;
import iron.data.SceneFormat;
#if arm_csm
import armory.renderpath.RenderPathCreator;
#end
class EditorGameView extends EditorTab {
    var drawTrait:iron.Trait = new iron.Trait();
    public function new(){
        super();
        #if arm_csm
        drawTrait.notifyOnRender2D(function(g:kha.graphics2.Graphics) {
			if (RenderPathCreator.finalTarget == null) return;

			// Access final composited image that is afterwards drawn to the screen
			var image = RenderPathCreator.finalTarget.image;

			g.color = 0xffffffff;
			if (image.g4.renderTargetsInvertedY()) {
				g.drawScaledImage(image, this.width/2 , this.height / 2, this.width / 2, -this.height / 2);
			}
			else {
				g.drawScaledImage(image, 0, 0, this.width / 2, this.height / 2);
			}
		});
        #end
    }
}