package;

import haxe.ui.components.Label;
import haxe.ui.data.ListDataSource;
import haxe.ui.containers.ListView;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.core.Screen;
import haxe.ui.core.ItemRenderer;
import haxe.ui.core.Component;


@:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/file-browser.xml"))
class FileBrowserDialog extends Dialog {
    public function new(){
        super();
        title = "File Browser";
        modal = false;
        buttons =  DialogButton.APPLY | DialogButton.CANCEL;
		var feed:ListView = this.findComponent('feed',ListView);
		feed.itemRenderer =  haxe.ui.macros.ComponentMacros.buildComponent("../Assets/custom/browser-items.xml");

    }

    public static function open(e:MouseEvent){
        var dialog = new FileBrowserDialog();
        Fs.updateData(dialog,"");
        dialog.width = Screen.instance.width*0.95;
        dialog.height = Screen.instance.height*0.95;
        dialog.show();
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