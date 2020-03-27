package;

import zui.Zui;
import zui.Zui.Handle;
import khafs.Fs;

class Cust {
    static var lastFiles:Array<String> = [];
    static var lastFolders:Array<String> = [];
    @:access(zui.Zui)
    public static function fileBrowser(ui: Zui, handle: Handle, foldersOnly = false): String {
        var ratios = [0.04,0.96];
        var sep = "/";

        var files:Array<String> = Fs.isDirectory(handle.text) ? Fs.readDirectory(handle.text,foldersOnly) : (foldersOnly ? lastFolders: lastFiles);
        
		// Up directory
		var i1 = handle.text.indexOf("/");
		var i2 = handle.text.indexOf("\\");
		var nested =
			(i1 > -1 && handle.text.length - 1 > i1) ||
			(i2 > -1 && handle.text.length - 1 > i2);
        handle.changed = false;
        if(nested){
            var image = getRessourceImage("");
            ratios[0]  = ui._w*ratios[0] < image.width ? ui._w/image.width*0.01: ratios[0];
            ratios[1] = 1.0 - ratios[0];
            ui.row(ratios);
            ui.image(image);
            if (ui.button("..", Align.Left)) {
                handle.changed = ui.changed = true;
                if(!Fs.isDirectory(handle.text))
                    handle.text = handle.text.substring(0, handle.text.lastIndexOf(sep));
                handle.text = handle.text.substring(0, handle.text.lastIndexOf(sep));
                // Drive root
                if (handle.text.length == 2 && handle.text.charAt(1) == ":") handle.text += sep;
            }
        }

		// Directory contents
		for (f in files) {
            if (f == "" || f.charAt(0) == ".") continue; // Skip hidden
            var image = getRessourceImage(handle.text+'$sep$f');
            ratios[0]  = ui._w*ratios[0] < image.width ? ui._w/image.width*0.01: ratios[0];
            ratios[1] = 1.0 - ratios[0];
            ui.row(ratios);
            ui.image(image);
			if (ui.button(f, Align.Left)) {
                handle.changed = ui.changed = true;
                if(!Fs.isDirectory(handle.text)) handle.text = handle.text.substring(0, handle.text.lastIndexOf(sep));
				if (handle.text.charAt(handle.text.length - 1) != sep) handle.text += sep;
				handle.text += f;
			}
        }
        
        if(foldersOnly){
            lastFolders = files;
        }
        else{
            lastFiles = files;
        }
        

		return handle.text;
    }
    static function getRessourceImage(filepath:String){
        var name = "blank";
        if(Fs.isDirectory(filepath)){
            name = "folder";
        }
        else {
            var end = filepath.substr(filepath.lastIndexOf('.'));
            switch(end){
                case ".found" | ".txt":
                    name = "file_grey";
                case ".json" | ".hx" | ".vhx":
                    name = "script";
                case ".png" | ".jpg":
                    name = "picture_grey";
                case ".mp3" | ".wav":
                    name = " audio-file_grey";
            }
        }
        return kha.Assets.images.get(name);
    }
}