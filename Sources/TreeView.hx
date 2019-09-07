package;

import haxe.ui.containers.ScrollView;
import haxe.ui.data.ListDataSource;
import haxe.ui.containers.ListView;
import haxe.ui.components.Label;
import haxe.ui.containers.VBox;
import haxe.ui.events.UIEvent;
import Fs.NodeData;

// @:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/file-tree-ui.xml"))
class TreeView extends ListView {

    public var selectedNode:TreeNode = null;

    public function new() {
        super();
        // path.disabled = true;
		// path.text=" ";
        styleString = "padding: 1px;border: 0px solid #ABABAB;border-radius: 1px;";
    }

    var _brother:FileBrowser = null;
	public var brother(get,set):FileBrowser;
	function get_brother(){
		return _brother;
	}
	function set_brother(fb:FileBrowser){
        var ds = new ListDataSource<TreeNode>();
		for( i in 0...fb.feed.dataSource.size){
            ds.add(addNode(fb.feed.dataSource.get(i)));
        }
		_brother = fb;
		return _brother;
	}

    // @:bind(feed, UIEvent.CHANGE)
	function selectedDir(e){
		// var folder:Fs.NodeData = feed.selectedItem;
        // var dataHolder = brother != null ? brother:this;
		// if(folder.name == ".."){
		// 	var path = Fs.curDir;
		// 	var i1 = path.indexOf("/");
		// 	var i2 = path.indexOf("\\");
		// 	var nested =
		// 		(i1 > -1 && path.length - 1 > i1) ||
		// 		(i2 > -1 && path.length - 1 > i2);
		// 	if (nested) {
		// 		path = path.substring(0, path.lastIndexOf(Fs.sep));
		// 		// Drive root
		// 		if (path.length == 2 && path.charAt(1) == ":") path += Fs.sep;
		// 	}
		// 	Fs.updateData(dataHolder,path);

		// }
		// else if(folder.name.split('.')[0] == folder.name){
		// 	if(Reflect.hasField(folder,"childs")){
		// 		Fs.updateData(dataHolder,folder.path,folder.childs);
		// 	}
		// }
	}

    public function addNode(data:NodeData):TreeNode {
        var node  = new TreeNode(this);
        node.text = data.name;
        node.icon = data.type;
        addComponent(node);
        // trace(feed.itemCount);
       return node;
    }
    
    public function clear() {
        selectedNode = null;
        this.removeAllComponents();
    }
    
    public function findNode(path:String):TreeNode {
        var parts = path.split("/");
        var first = parts.shift();
        
        var node:TreeNode = null;
        for (c in this.childComponents) {
            var label = c.findComponent(Label, true);
            if (label != null && label.text == first) {
                node = cast(c, TreeNode);
                break;
            }
        }
        
        if (parts.length > 0 && node != null) {
            node = node.findNode(parts.join("/"));
        }
        
        return node;
    }
}