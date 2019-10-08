package;


import haxe.ui.extended.FileSystem;
import foundry.data.Project.TProject;
import kha.System;
import kha.Assets;
import kha.WindowOptions.WindowFeatures;
import iron.object.Object;
import iron.Scene;
import iron.RenderPath;

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

	public static var projectName:String;
    public static inline var projectPackage = 'arm';
	static var project(default,set):foundry.data.Project.TProject;
	static function set_project(p:TProject){
		var scene = FileSystem.fixPath(p.path+p.scenes[0]);
		projectName = p.name;
		EditorUi.projectPath = p.path;
		ui = new EditorUi();
		#if arm_csm
		iron.object.BoneAnimation.skinMaxBones = 8;
        iron.object.LightObject.cascadeCount = 4;
        iron.object.LightObject.cascadeSplitFactor = 0.800000011920929;
        armory.system.Starter.main(
            scene,
            1,
            false,
            true,
            false,
            960,
            540,
            1,
            true,
            armory.renderpath.RenderPathCreator.get
        );
		#end
		return p;
	}
	public static function main() {
		initialized();
	}
	
	static var path = "";
	static function loadProjectList(){
		kha.Assets.loadBlobFromPath(path, function(lblob:kha.Blob) {
			var raw:Array<foundry.data.Project.TProject> = haxe.Json.parse(lblob.toString());
			project = raw[0];
			ui = new EditorUi(raw);
		});
	}
	static function initialized(){
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
	
		
        // kha.System.notifyOnFrames(render);  
		// kha.Scheduler.addTimeTask(update, 0, 1 / 60);
    }
}

typedef TPrefs = {
	var path:String;
	var scaleFactor:Float;
	@:optional var window_vsync:Bool;
	@:optional var selectMouseButton:String;
}