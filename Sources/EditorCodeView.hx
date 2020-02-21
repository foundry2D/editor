package;

import found.App;
import found.Scene;
import found.data.SceneFormat;
import haxe.ui.containers.VBox;
import haxe.ui.core.Component;
import haxe.ui.events.MouseEvent;
import utilities.JsonObjectExplorer;

@:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/editor-code.xml"))
class EditorCodeView implements EditorHierarchyObserver extends EditorTab {
	public var x(get, never):Int;

	function get_x() {
		return Math.floor(topbar.screenX);
	}

	public var y(get, never):Int;

	function get_y() {
		return Math.floor(topbar.screenY + topbar.height);
	}

	public var w(get, never):Int;

	function get_w() {
		return Math.ceil(cast(this, Component).componentWidth);
	}

	public var h(get, never):Int;

	function get_h() {
		return Math.ceil(cast(this, Component).componentHeight - topbar.height);
	}

	var visualEditor:found.tool.NodeEditor;

	// var textEditor:CodeComponent;
	public function new() {
		super();
		percentWidth = 100;
		percentHeight = 100;
		this.text = "Code";
		// textEditor = new CodeComponent();
		// container.addComponent(textEditor);
		// textEditor.hidden = true;
		addVisualCode.onClick = createVisualTrait;
		saveVisualCode.onClick = saveVisualTrait;
		visualEditor = new found.tool.NodeEditor(x, y, w, h);
		visualEditor.visible = true;
		EditorHierarchy.register(this);
	}

	public function notifyObjectSelectedInHierarchy(selectedObjectPath:String):Void {
		// @TODO: should we always load and reparse the data ?
		// (i.e. we already parse the data to determine what to show the UI so maybe we should load if we find a visual script from the UI)
		loadVisualTrait(selectedObjectPath);
	}

	function createVisualTrait(e:MouseEvent) {
		var nData = {
			name: "Name",
			nodes: new zui.Nodes(),
			nodeCanvas: {
				name: "My Nodes",
				nodes: [],
				links: []
			}
		}
		found.tool.NodeEditor.nodesArray.push(nData);
		found.tool.NodeEditor.selectedNode = nData;
	}

	function saveVisualTrait(e:MouseEvent) {
		var nodeData:LogicTreeData = found.tool.NodeEditor.selectedNode;
		var trait:TTrait = {type: "VisualScript", class_name: "./dev/Project/Sources/visualTrait.json"};
		var data = haxe.Json.stringify({name: nodeData.name, nodes: null, nodeCanvas: nodeData.nodeCanvas});
		kha.FileSystem.saveContent(trait.class_name, data, function() {
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
				if (oldTrait.class_name == trait.class_name) {
					alreadyHasTrait = true;
				}
			}
			if (!alreadyHasTrait) {
				currentObject.raw.traits.push(trait);
			}
		} else {
			currentObject.raw.traits = [trait];
		}
		if (!StringTools.contains(App.editorui.hierarchy.path.text, '*'))
			App.editorui.hierarchy.path.text += '*';
	}

	function loadVisualTrait(path:String) {
		var data:{jsonObject:TObj, jsonObjectUid:Int} = JsonObjectExplorer.getObjectFromSceneObjects(path);

		if (data.jsonObject.traits != null) {
			var firstTrait:Null<TTrait> = null;
			var traits:Array<TTrait> = data.jsonObject.traits;
			for (trait in traits) {
				if (trait.type == "VisualScript") {
					firstTrait = trait;
				}
			}
			if (firstTrait != null) {
				kha.FileSystem.getContent(firstTrait.class_name, function(data:String) {
					var visualTraitData:LogicTreeData = haxe.Json.parse(data);
					visualTraitData.nodes = new zui.Nodes();
					found.tool.NodeEditor.nodesArray.push(visualTraitData);
					found.tool.NodeEditor.selectedNode = visualTraitData;
				});
			}
		}
	}

	public override function renderTo(g:kha.graphics2.Graphics) {
		super.renderTo(g);
		if (selectedPage.text != "Code")
			return;
		if (App.editorui.inspector.index != -1) {
			addVisualCode.hidden = false;
		} else {
			addVisualCode.hidden = true;
		}
		// if(codetype.selectedIndex == 0){// Visual
		// textEditor.hidden = true;
		visualEditor.setAll(x, y, w, h);
		visualEditor.render(g);
		// }
		// else {//Textual
		//     textEditor.hidden = false;
		// }
	}
}
