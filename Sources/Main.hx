package;


import kha.System;
import kha.Assets;
import kha.WindowOptions.WindowFeatures;

class Main {
	static var ui:EditorUi = null;
    public static var cwd = "";
	static function update(): Void {
		if(ui != null)
			ui.update();
	}

	static function render(frames: Array<kha.Framebuffer>): Void {
		if(ui != null)
			ui.render(frames[0].g2);
	}

	public static function main() {
		// var title = "Foundry Editor";
		var title = "Project Manager";
		kha.System.start({
			title: title,
			width: 1280,
			height: 1000,
			window: {windowFeatures: WindowFeatures.FeatureMaximizable
			} 
		},
		initialized);
	}
	#if foundry_editor
	static var path = "";
	static function loadProjectList(){
		kha.Assets.loadBlobFromPath(path, function(lblob:kha.Blob) {
			var raw:Array<foundry.data.Project.TProject> = haxe.Json.parse(lblob.toString());
			ui = new EditorUi(raw);
		});
	}
	#end
    static function initialized(window:kha.Window){
		var number = kha.Display.all.length;
		#if foundry_editor
	
        #if kha_krom
        cwd = Krom.getFilesLocation();
		#elseif kha_kore
		cwd = Sys.programPath();
		#elseif kha_webgl
		cwd = untyped require('electron').remote.app.getAppPath()+"/";
		#end
        var files = haxe.ui.extended.FileSystem.getFiles(cwd);
        
        for( f in files){
            if(f.split('.found')[0] != f){
                path = cwd+f;
            }
        }

		if(path == ""){
            var list:Array<foundry.data.Project.TProject> = [];
            var data = haxe.io.Bytes.ofString(haxe.Json.stringify(list));
            path = cwd+"pjml.found";
			haxe.ui.extended.FileSystem.saveToFile(path,data,loadProjectList);
        }
		else{
			loadProjectList();
		}
		
		#else
		ui = new EditorUi();
		#end
        kha.System.notifyOnFrames(render);
		kha.Scheduler.addTimeTask(update, 0, 1 / 60);
    }
}

typedef TPrefs = {
	var path:String;
	var scaleFactor:Float;
	@:optional var window_vsync:Bool;
	@:optional var selectMouseButton:String;
}