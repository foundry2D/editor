package;

import haxe.ui.components.Label;
import haxe.ui.data.ListDataSource;
import haxe.ui.containers.ListView;
import haxe.ui.core.Component;


typedef FileData = {
    >NodeData,
}
typedef NodeData = {
	var path:String;
	var type:String;
	var name:String;
	var ?childs:ListDataSource<NodeData>;
}

class Fs {

    public static var dataPath = "";
    public static var curDir:String = "";
    public static var sep ="/";
	static var lastPath:String = "";
    static public function updateData(comp:Component,path:String, data:ListDataSource<NodeData> = null){
		var feed:ListView = comp.findComponent('feed',ListView);
        feed.dataSource = data != null ? data : getFilesData(path);
		var parPath:Label = comp.findComponent('path',Label);
		var par:NodeData  = feed.dataSource.get(feed.dataSource.size-1);
		if(!parPath.disabled)
			parPath.text = par.path;
		curDir = par.path;
		feed.dataSource.remove(par);
		comp.invalidateComponentLayout();
	}
    static function initPath(systemId: String) {
		switch (systemId){
			case "Windows":
				return "C:\\Users";
			case "Linux":
				return "$HOME";
			default:
				return "/";
		}
		// %HOMEDRIVE% + %HomePath%
		// ~
	}
	static function fixPath(path:String,systemId:String){
		if (path == "") path = initPath(systemId);
		switch (systemId){
			case "Windows":
				return path;
			case "Linux":
				if(path.charAt(0) == "~"){
					var temp = path.split('~');
					var npath = "$HOME";
					for(i in 0...temp.length){
						if(i == 0)
							continue;
						npath+= temp[i];
					}
					path = npath;
				}
				return path;
			default:
				return path;
		}
	}
    static public function getFilesData(path:String, folderOnly = false):ListDataSource<NodeData> {

		var files = getFiles(path,folderOnly);
        if(path=="")
            path = curDir;
        var ds = new ListDataSource<NodeData>();
		ds.add({name: "..",path: "", type: ""});
        // Directory contents
		for (f in files) {
			if (f == "" || f.charAt(0) == ".") continue; // Skip hidden
            var p = path;
            if (path.charAt(path.length - 1) != sep) p += sep;
			if(f.split('.')[0] == f){
            	ds.add({path:p+f,name: f, type: findType(p+f),childs: getFilesData(p+f) });
			}
			else {
				ds.add({path:p+f,name: f, type: findType(p+f)});
			}
		}
		ds.add({name: "",path: path, type: ""});
        return ds;
    }
    
    static function getFiles(path:String, folderOnly =false){

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
		path = fixPath(path,systemId);

		var save = Krom.getFilesLocation() + sep + dataPath + "dir.txt";
		if (path != lastPath) Krom.sysCommand(cmd + '"' + path + '"' + ' > ' + '"' + save + '"');
		lastPath = path;
		var str = haxe.io.Bytes.ofData(Krom.loadBlob(save)).toString();
		var files = str.split("\n");

		#elseif kha_kore

		path = fixPath(path,systemId);
		var files = sys.FileSystem.isDirectory(path) ? sys.FileSystem.readDirectory(path) : [];

		#elseif kha_webgl

		var files:Array<String> = [];

		var userAgent = untyped navigator.userAgent.toLowerCase();
		if (userAgent.indexOf(' electron/') > -1) {
			var pp = untyped window.process.platform;
			var systemId = pp == "win32" ? "Windows" : (pp == "darwin" ? "OSX" : "Linux");
			try {
				path = fixPath(path,systemId);
				if(StringTools.contains(path,"$HOME")){
					var home = untyped process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE;
					path = StringTools.replace(path,"$HOME",home);
				}
				files = untyped require('fs').readdirSync(path);
			}
			catch(e:Dynamic) {
				// Non-directory item selected
			}
		}

		#else

		var files:Array<String> = [];

		#end
        curDir = path;
        return files;
    }
	static function findType(path:String){
		var end = path.split('.');
		if( end[0] == path){
			return "img/folder.png";
		}
		switch (end[end.length-1]){
			case "png" | "jpeg" | "gif":
				return "img/picture_grey.png";
			case "wav"|"ogg"|"mp3":
				return "img/audio-file_grey.png";
			case "txt"|"h"|"hx"|"c"|"cpp"|"md"|"xml"|"json":
				return "img/file_grey.png";
			default:
				return "img/blank.png";
		}
	}
}