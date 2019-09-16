package;


import kha.WindowOptions.WindowFeatures;

class Main {
	static var ui:EditorUi = null;
    public static var prefs:TPrefs = null;
    public static var cwd = "";
	static function update(): Void {
		if(ui != null)
			ui.update();
	}

	static function render(frames: Array<kha.Framebuffer>): Void {
		ui.render(frames[0].g2);
	}

	public static function main() {
		kha.System.start({title: "Project Manager", width: 1024, height: 768,window: {windowFeatures: WindowFeatures.None} },initialized);
	}

    static function initialized(window:kha.Window){

		var path = "";
        #if kha_krom
        cwd = Krom.getFilesLocation();
        var files = haxe.ui.extended.FileSystem.getFiles(cwd);
        
        for( f in files){
            if(f.split('.found')[0] != f){
                path = cwd+f;
            }
        }
		if(path == ""){
            var list:Array<foundry.data.Project.TProject> = [];
            var data = haxe.io.Bytes.ofString(haxe.Json.stringify(list)).getData();
            path = cwd+"pjml.found";
            Krom.fileSaveBytes(path,data);
        }
		#end
		#if kha_webgl
        if(path == ""){
            var list:Array<foundry.data.Project.TProject> = [];
            var data = haxe.io.Bytes.ofString(haxe.Json.stringify(list)).getData();
            path = cwd+"pjml.found";
            untyped require('fs').writeFile(path,data,function (err){
				if(err) throw err;
				trace("Was saved");
			});
        }
		#end
		kha.Assets.loadBlobFromPath(path, function(lblob:kha.Blob) {
			var raw:Array<foundry.data.Project.TProject> = haxe.Json.parse(lblob.toString());
			ui = new EditorUi(raw);
		});
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