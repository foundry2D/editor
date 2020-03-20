package;

import found.App;
import found.Scene;
import found.data.SceneFormat;
import found.tool.NodeEditor;
import zui.Id;
import haxe.ui.containers.VBox;
import haxe.ui.core.Component;
import haxe.ui.events.MouseEvent;
import utilities.JsonObjectExplorer;

// @:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/editor-code.xml"))
class EditorCodeView implements EditorHierarchyObserver extends EditorTab {
	public var x(get, never):Int;

	function get_x() {
		return Math.floor(screenX);
	}

	public var y(get, never):Int;

	function get_y() {
		return Math.floor(screenY);
	}

	public var w(get, never):Int;

	function get_w() {
		return Math.ceil(cast(this, Component).componentWidth);
	}

	public var h(get, never):Int;

	function get_h() {
		return Math.ceil(cast(this, Component).componentHeight);
	}

	var visualEditor:found.tool.NodeEditor;

	// var textEditor:CodeComponent;
	public function new(?ui:zui.Zui) {
		super();
		percentWidth = 100;
		percentHeight = 100;
		this.text = "Code";
		// textEditor = new CodeComponent();
		// container.addComponent(textEditor);
		// textEditor.hidden = true;
		visualEditor = new found.tool.NodeEditor(x, y, w, h);
		visualEditor.visible = true;
		EditorHierarchy.register(this);
	}

	public function notifyObjectSelectedInHierarchy(selectedObject:TObj, selectedUID:Int):Void {
		// @TODO: should we always load and reparse the data ?
		// (i.e. we already parse the data to determine what to show the UI so maybe we should load if we find a visual script from the UI)
		loadVisualTrait(selectedObject);
	}

	function saveVisualTrait() {
		var nodeData:LogicTreeData = found.tool.NodeEditor.selectedNode;
		var trait:TTrait = {type: "VisualScript", classname: "./dev/Project/Sources/Scripts/visualTrait.vhx"};
		var data = haxe.Json.stringify({name: nodeData.name, nodes: null, nodeCanvas: nodeData.nodeCanvas});
		kha.FileSystem.saveContent(trait.classname, data, function() {
			saveVisualTraitOnCurrentObject(trait);
		});
	}

	@:access(found.Scene)
	function saveVisualTraitOnCurrentObject(trait:TTrait) {
		Scene.createTraits([trait], App.editorui.inspector.currentObject);
		var currentObject = App.editorui.inspector.currentObject;
		if (currentObject.raw.traits != null) {
			var alreadyHasTrait = false;
			for (oldTrait in currentObject.raw.traits) {
				if (oldTrait.classname == trait.classname) {
					alreadyHasTrait = true;
				}
			}
			if (!alreadyHasTrait) {
				currentObject.raw.traits.push(trait);
			}
		} else {
			currentObject.raw.traits = [trait];
		}

		currentObject.dataChanged = true;
		
		EditorHierarchy.makeDirty();
	}

	function loadVisualTrait(obj:TObj) {
		var data = obj;

		if (data.traits != null) {
			var firstTrait:Null<TTrait> = null;
			var traits:Array<TTrait> = data.traits;
			for (trait in traits) {
				if (trait.type == "VisualScript") {
					firstTrait = trait;
				}
			}
			if (firstTrait != null) {
				kha.FileSystem.getContent(firstTrait.classname, function(data:String) {
					var visualTraitData:LogicTreeData = haxe.Json.parse(data);
					visualTraitData.nodes = new zui.Nodes();
					found.tool.NodeEditor.nodesArray.push(visualTraitData);
					found.tool.NodeEditor.selectedNode = visualTraitData;
				});
			}
		}
	}
	var optionsHandle:zui.Zui.Handle = Id.handle();
	public var codeype:Int = 0; 
	@:access(zui.Zui)
	public function render(ui:zui.Zui){
		if (selectedPage == null || selectedPage.text != "Code")
			return;
		// optionsHandle.selected = true;
		
			// if(codetype == 0){// Visual
				visualEditor.setAll(x, y, w,h);
				visualEditor.render(ui);
			// }
			// else {//Textual

			// }
		
	}
}
