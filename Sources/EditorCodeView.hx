package;

import zui.Id;
import zui.Ext;
import found.App;
import found.Scene;
import found.data.SceneFormat;
import found.tool.NodeEditor;
import haxe.ui.core.Component;

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

	var lastDisplayedTrait:TTrait = null;

	static var currentlyDisplayedTrait:TTrait = null;

	static var codeScriptWindowHandle = Id.handle();

	static var codeScriptTextAreaHandle = Id.handle();

	var currentScriptTraitText = "";

	public function new(?ui:zui.Zui) {
		super();
		this.percentWidth = 100;
		this.percentHeight = 100;
		this.text = "Code";

		visualEditor = new found.tool.NodeEditor(x, y, w, h);
		visualEditor.visible = true;

		EditorHierarchy.register(this);
	}

	public function notifyObjectSelectedInHierarchy(selectedObject:TObj, selectedUID:Int):Void {
		// @TODO: should we always load and reparse the data ?
		// (i.e. we already parse the data to determine what to show the UI so maybe we should load if we find a visual script from the UI)
		var traits:Array<TTrait> = selectedObject.traits != null ? selectedObject.traits : [];
		setDisplayedTrait(traits[0]);
	}

	public function setDisplayedTrait(trait:TTrait):Void {
		currentlyDisplayedTrait = trait;
		codeScriptWindowHandle.redraws = codeScriptTextAreaHandle.redraws = 2;
	}

	function saveVisualTrait() {
		var nodeData:LogicTreeData = found.tool.NodeEditor.selectedNode;
		var trait:TTrait = {type: "VisualScript", classname: "./dev/Project/Sources/Scripts/visualTrait.vhx"};
		var data = haxe.Json.stringify({name: nodeData.name, nodes: null, nodeCanvas: nodeData.nodeCanvas});
		khafs.Fs.saveContent(trait.classname, data, function() {
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
				khafs.Fs.getContent(firstTrait.classname, function(data:String) {
					var visualTraitData:LogicTreeData = haxe.Json.parse(data);
					visualTraitData.nodes = new zui.Nodes();
					found.tool.NodeEditor.nodesArray.push(visualTraitData);
					found.tool.NodeEditor.selectedNode = visualTraitData;
				});
			}
		}
	}

	@:access(zui.Zui)
	public function render(ui:zui.Zui) {
		if (selectedPage == null || selectedPage.text != "Code")
			return;

		if (currentlyDisplayedTrait != lastDisplayedTrait) {
			if (currentlyDisplayedTrait != null) {
				if (currentlyDisplayedTrait.type == "VisualScript") {
					khafs.Fs.getContent(currentlyDisplayedTrait.classname, function(data:String) {
						var visualTraitData:LogicTreeData = haxe.Json.parse(data);
						visualTraitData.nodes = new zui.Nodes();
						found.tool.NodeEditor.selectedNode = visualTraitData;
					});
				} else {
					khafs.Fs.getContent(currentlyDisplayedTrait.classname, function(data:String) {
						currentScriptTraitText = data;
					});
				}
			} else {
				found.tool.NodeEditor.selectedNode = null;
			}
			lastDisplayedTrait = currentlyDisplayedTrait;
		}
		
		if (currentlyDisplayedTrait == null || currentlyDisplayedTrait.type == "VisualScript") {
			visualEditor.setAll(x, y, w, h);
			visualEditor.render(ui);
		} else {
			if (ui.window(codeScriptWindowHandle, x, y, w, h)) {
				codeScriptTextAreaHandle.text = currentScriptTraitText;
				var isEditable:Bool = StringTools.endsWith(currentlyDisplayedTrait.classname, ".hx");
				Ext.textArea(ui, codeScriptTextAreaHandle, zui.Zui.Align.Left, isEditable);
			}
		}
	}
}
