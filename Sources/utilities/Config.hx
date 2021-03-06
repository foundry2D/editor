package utilities;


import found.Found;
import found.App;
import haxe.Json;
import haxe.io.Bytes;
import kha.Display;
import found.data.Data;
import utilities.ConfigFormat;

class Config {

	public static var raw: TConfig = null;
	public static var keymap: Dynamic;
	public static var configLoaded = false;

	public static function load(done: Void->Void) {
		try {
			Data.getBlob("./config.found", function(blob: kha.Blob) {
				configLoaded = true;
				raw = Json.parse(blob.toString());
				done();
			});
		}
		catch (e: Dynamic) { warn("Failed to load, will load defaults");done(); }
	}

	public static function save() {
		// Use system application data folder
		// when running from protected path like "Program Files"
		var path ="./config.found";
		var bytes = Bytes.ofString(Json.stringify(raw));
		khafs.Fs.saveBytes(path, bytes);
	}

	public static function init() {
		if (!configLoaded || raw == null) {
			raw = {};
			raw.locale = "system";
			raw.window_mode = 0;
			raw.window_resizable = true;
			raw.window_minimizable = true;
			raw.window_maximizable = true;
			raw.window_w = 1600;
			raw.window_h = 900;
			raw.window_x = -1;
			raw.window_y = -1;

			var w = Found.WIDTH;
			var h = Found.HEIGHT; 
			
			if(w > 1920 && h  > 1080){
				raw.window_scale = 1.2;
			}
			else if(w == 1280 && h == 720){
				raw.window_scale = 0.75;
			}
			else if(w == 800 && h == 600){
				raw.window_scale = 0.6;
			}
			else if(w < 800 || h < 600){
				warn('Unsupported screen size of $w x $h for editor.');
			}
			else {
				raw.window_scale = 1.0;
			}

			raw.window_vsync = true;
			var disp = Display.primary;
			if (disp != null && disp.width >= 3000 && disp.height >= 2000) {
				raw.window_scale = 2.0;
			}
			#if (krom_android || krom_ios)
			raw.window_scale = 2.0;
			#end

			raw.version = Data.version+"";
			raw.sha = found.Found.sha;
			raw.bookmarks = [];
			raw.plugins = [];
			raw.keymap = "default.json";
			raw.theme = "dark.json";
			raw.defaultPlayMode = false;
			raw.autoHideMenuBar = false;
			raw.undo_steps = 4;
			raw.pressure_radius = true;
			raw.pressure_hardness = true;
			raw.pressure_angle = false;
			raw.pressure_opacity = false;
			raw.pressure_sensitivity = 1.0;
			raw.brush_live = false;
		}
        
		loadKeymap();
	}

	public static function restore() {
		zui.Zui.Handle.global = new zui.Zui.Handle(); // Reset ui handles
		configLoaded = false;
		init();
		Translator.loadTranslations(raw.locale);
		found.App.editorui.isPlayMode = raw.defaultPlayMode;
		found.App.editorui.setUIScale(raw.window_scale);
	}


	public static function loadKeymap() {
		var done = function(blob: kha.Blob) {
			keymap = Json.parse(blob.toString());
		}
		try{
			Data.getBlob("./data/keymap_presets/" + raw.keymap, done);
		}
		catch (e: Dynamic) { 
			kha.Assets.loadBlobFromPath("./data/keymap_presets/" + raw.keymap,done);
		}
	}

	public static function saveKeymap() {
		var path = "./data/keymap_presets/" + raw.keymap;
		var bytes = Bytes.ofString(Json.stringify(keymap));
		khafs.Fs.saveBytes(path, bytes);
    }
    
}
