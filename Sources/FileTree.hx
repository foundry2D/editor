// package;

// import haxe.ui.core.Component;
// import haxe.ui.containers.VBox;
// import haxe.ui.events.UIEvent;
// import haxe.ui.data.ListDataSource;
// import haxe.ui.containers.ListView;

// @:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/file-tree-ui.xml"))
// class FileTree extends VBox {
//     var _brother:FileBrowser = null;
// 	public var brother(get,set):FileBrowser;
// 	function get_brother(){
// 		return _brother;
// 	}
// 	function set_brother(fb:FileBrowser){
// 		//  = cast(fb.feed.dataSource);
// 		_brother = fb;
// 		return _brother;
// 	}
// 	public function new(){
//         super();
// 		path.disabled = true;
// 		path.text=" ";
//     }

//     @:bind(feed, UIEvent.CHANGE)
// 	function selectedDir(e){
// 		var folder:Fs.NodeData = feed.selectedItem;
//         var dataHolder = brother != null ? brother:this;
// 		if(folder.name == ".."){
// 			var path = Fs.curDir;
// 			var i1 = path.indexOf("/");
// 			var i2 = path.indexOf("\\");
// 			var nested =
// 				(i1 > -1 && path.length - 1 > i1) ||
// 				(i2 > -1 && path.length - 1 > i2);
// 			if (nested) {
// 				path = path.substring(0, path.lastIndexOf(Fs.sep));
// 				// Drive root
// 				if (path.length == 2 && path.charAt(1) == ":") path += Fs.sep;
// 			}
// 			Fs.updateData(dataHolder,path);

// 		}
// 		else if(folder.name.split('.')[0] == folder.name){
// 			if(Reflect.hasField(folder,"childs")){
// 				Fs.updateData(dataHolder,folder.path,folder.childs);
// 			}
// 		}
// 	}
// }