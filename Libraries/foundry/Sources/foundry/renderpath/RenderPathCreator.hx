package foundry.renderpath;

class RenderPathCreator {

	public static function get():iron.RenderPath {
		var path = new iron.RenderPath();
		path.commands = function() {
			path.setTarget(""); // Draw to framebuffer
			path.clearTarget(0xffffffff, 1.0); // Clear color & depth
			path.drawMeshes("mesh"); // Draw all visible meshes
		};
		return path;
	}
}