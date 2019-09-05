package;

import haxe.ui.core.Component;
import haxe.ui.containers.VBox;
import haxe.ui.events.UIEvent;
import haxe.ui.data.ListDataSource;

@:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/file-browser-ui.xml"))
class FileBrowser extends VBox {
    
	public function new(){
        super();
		feed.itemRenderer =  haxe.ui.macros.ComponentMacros.buildComponent("../Assets/custom/browser-items.xml");
    }

    @:bind(feed, UIEvent.CHANGE)
	function selectedDir(e){
		var folder:Fs.FileData = feed.selectedItem;
		if(folder.file == ".."){
			var path = Fs.curDir;
			var i1 = path.indexOf("/");
			var i2 = path.indexOf("\\");
			var nested =
				(i1 > -1 && path.length - 1 > i1) ||
				(i2 > -1 && path.length - 1 > i2);
			if (nested) {
				path = path.substring(0, path.lastIndexOf(Fs.sep));
				// Drive root
				if (path.length == 2 && path.charAt(1) == ":") path += Fs.sep;
			}
			Fs.updateData(this,path);

		}
		else if(folder.file.split('.')[0] == folder.file){
			var data:ListDataSource<Fs.FileData> = Fs.getFilesData(folder.path);
			if(data.size > 1){
				Fs.updateData(this,folder.path,data);
			}
		}
	}
}