package;

import haxe.ui.data.ListDataSource;
import haxe.ui.components.TextField;
import haxe.ui.containers.ListView;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.core.Screen;


typedef FileData = {
    var type:String;
    var path:String;
}

@:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/file-browser.xml"))
class FileBrowserDialog extends Dialog {
    public function new(){
        super();
        title = "File Browser";
        modal = false;
        buttons =  DialogButton.APPLY | DialogButton.CANCEL;

    }

	public static var dataPath = "";
	static var lastPath:String = "";
    static var sep ="/";
    public static function open(e:MouseEvent){
        var dialog = new FileBrowserDialog();
        var feed:ListView = dialog.findComponent('feed',ListView);
        feed.dataSource = getFiles(lastPath);
        dialog.width = Screen.instance.width*0.95;
        dialog.height = Screen.instance.height*0.95;
        dialog.show();
    }

    @:bind(up, MouseEvent.CLICK)
    function onUpper(e){
        var path = lastPath;
		var i1 = path.indexOf("/");
		var i2 = path.indexOf("\\");
		var nested =
			(i1 > -1 && path.length - 1 > i1) ||
			(i2 > -1 && path.length - 1 > i2);
		if (nested) {
			path = path.substring(0, path.lastIndexOf(sep));
			// Drive root
			if (path.length == 2 && path.charAt(1) == ":") path += sep;
        }
        var feed:ListView = this.findComponent('feed',ListView);
        feed.dataSource = getFiles(lastPath);
    }
    @:bind(path, UIEvent.CHANGE)
    function onTextChange(e){
        lastPath = e.data;
    }
    static function initPath(path: String, systemId: String) {
		path = systemId == "Windows" ? "C:\\Users" : "/";
		// %HOMEDRIVE% + %HomePath%
		// ~
	}
    static function getFiles(path:String, folderdOnly = false){

		#if kha_krom

		var cmd = "ls ";
		var systemId = kha.System.systemId;
		if (systemId == "Windows") {
			cmd = "dir /b ";
			if (foldersOnly) cmd += "/ad ";
			sep = "\\";
			path = StringTools.replace(path, "\\\\", "\\");
			path = StringTools.replace(path, "\r", "");
		}
		if (path == "") initPath(path, systemId);

		var save = Krom.getFilesLocation() + sep + dataPath + "dir.txt";
		if (path != lastPath) Krom.sysCommand(cmd + '"' + path + '"' + ' > ' + '"' + save + '"');
		lastPath = path;
		var str = haxe.io.Bytes.ofData(Krom.loadBlob(save)).toString();
		var files = str.split("\n");

		#elseif kha_kore

		if (path == "") initPath(path, kha.System.systemId);
		var files = sys.FileSystem.isDirectory(path) ? sys.FileSystem.readDirectory(path) : [];

		#elseif kha_webgl

		var files:Array<String> = [];

		var userAgent = untyped navigator.userAgent.toLowerCase();
		if (userAgent.indexOf(' electron/') > -1) {
			if (path == "") {
				var pp = untyped window.process.platform;
				var systemId = pp == "win32" ? "Windows" : (pp == "darwin" ? "OSX" : "Linux");
				initPath(path, systemId);
			}
			try {
				files = untyped require('fs').readdirSync(path);
			}
			catch(e:Dynamic) {
				// Non-directory item selected
			}
		}

		#else

		var files:Array<String> = [];

		#end
        var ds = new ListDataSource<String>();
        // Directory contents
		for (f in files) {
			if (f == "" || f.charAt(0) == ".") continue; // Skip hidden
            var p = path;
            if (path.charAt(path.length - 1) != sep) p += sep;
            ds.add(p+f);
		}
        return ds;
    }
}