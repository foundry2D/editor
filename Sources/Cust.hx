package;

import zui.Zui;
import zui.Zui.Handle;
import kha.FileSystem;

class Cust {

    public static function fileBrowser(ui: Zui, handle: Handle, foldersOnly = false): String {
        var sep = "/";


        var files:Array<String> = FileSystem.isDirectory(handle.text) ? FileSystem.readDirectory(handle.text,foldersOnly) : []; 
        
		// Up directory
		var i1 = handle.text.indexOf("/");
		var i2 = handle.text.indexOf("\\");
		var nested =
			(i1 > -1 && handle.text.length - 1 > i1) ||
			(i2 > -1 && handle.text.length - 1 > i2);
        handle.changed = false;
        if(nested){
            ui.row([0.03,0.97]);
            ui.image(getRessourceImage(""));
            if (ui.button("..", Align.Left)) {
                handle.changed = ui.changed = true;
                handle.text = handle.text.substring(0, handle.text.lastIndexOf(sep));
                // Drive root
                if (handle.text.length == 2 && handle.text.charAt(1) == ":") handle.text += sep;
            }
        }

		// Directory contents
		for (f in files) {
            if (f == "" || f.charAt(0) == ".") continue; // Skip hidden
            ui.row([0.03,0.97]);
            ui.image(getRessourceImage(f));
			if (ui.button(f, Align.Left)) {
				handle.changed = ui.changed = true;
				if (handle.text.charAt(handle.text.length - 1) != sep) handle.text += sep;
				handle.text += f;
			}
		}

		return handle.text;
    }
    static function getRessourceImage(filepath:String){
        var name = "blank";
        if(FileSystem.isDirectory(filepath)){
            name = "folder";
        }
        else {
            var end = filepath.substr(filepath.lastIndexOf('.'));
            trace(end);
        }
        return kha.Assets.images.get(name);
    }
}