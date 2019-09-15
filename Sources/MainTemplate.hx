
package;

import foundry.system.Starter;
import foundry.renderpath.RenderPathCreator;

class Main {
    public static inline var projectName = 'foundry2d-editor';
    public static inline var projectPackage = 'foundry2d-editor';
	#if editor
	public static var ui:EditorUi;
	#end
	public static function main() {
		#if editor
		ui = new EditorUi();
		#end
		Starter.main(
			'Scene',
			0,
			true,
			false,
			true,
			1024,
			768,
			1,
			false,
			RenderPathCreator.get
		);
	}
}
