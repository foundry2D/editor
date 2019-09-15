package;


import kha.WindowOptions.WindowFeatures;

class Main {
	static var ui:EditorUi;
    public static var prefs:TPrefs = null;
    public static var cwd = ""; // Canvas path
	static function update(): Void {
		ui.update();
	}

	static function render(frames: Array<kha.Framebuffer>): Void {
		ui.render(frames[0].g2);
	}

	public static function main() {
		kha.System.start({title: "Project Manager", width: 1024, height: 768,window: {windowFeatures: WindowFeatures.None} },initialized);
	}

    static function initialized(window:kha.Window){

        #if kha_krom
        prefs = { path: Krom.getFilesLocation(), scaleFactor: 1.0 };
        var files = haxe.ui.extended.FileSystem.getFiles(prefs.path);
        
		var path = "";
        for( f in files){
            if(f.split('.found')[0] != f){
                path = prefs.path+f;
            }
        }
        if(path == ""){
            var list:Array<foundry.data.Project.TProject> = [];
            var data = haxe.io.Bytes.ofString(haxe.Json.stringify(list)).getData();
            path = prefs.path+"pjml.found";
            Krom.fileSaveBytes(path,data);
        }
		kha.Assets.loadBlobFromPath(path, function(lblob:kha.Blob) {
			var raw:Array<foundry.data.Project.TProject> = haxe.Json.parse(lblob.toString());
			ui = new EditorUi(raw);
		});

		#else
        trace("Project Manager should be used with Krom; Shutting down");
        kha.System.stop();
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