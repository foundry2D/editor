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
	var currentlyDisplayedTrait:TTrait = null;

	var traitNameWindowHandle = Id.handle();
	var codeScriptWindowHandle = Id.handle();
	var codeScriptTextAreaHandle = Id.handle();

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
		traitNameWindowHandle.redraws = codeScriptWindowHandle.redraws = codeScriptTextAreaHandle.redraws = 2;
		visualEditor.redraw();
	}

	@:access(zui.Zui)
	public function render(ui:zui.Zui) {
		if (selectedPage == null || selectedPage.text != "Code")
			return;

		updateDisplayedTraitData();

		if (ui.window(traitNameWindowHandle, x, y, w, h)) {
			if (currentlyDisplayedTrait != null) {
				ui.row([0.7, 0.3]);
				ui.text(currentlyDisplayedTrait.classname);
				if (ui.button("Save")) {
					saveDisplayedTraitData();
				}
			}
		}

		if (currentlyDisplayedTrait == null || currentlyDisplayedTrait.type == "VisualScript") {
			visualEditor.setAll(x, y + ui.t.BUTTON_H + ui.t.ELEMENT_OFFSET, w, h - ui.t.BUTTON_H - ui.t.ELEMENT_OFFSET);
			visualEditor.render(ui);
		} else {
			if (ui.window(codeScriptWindowHandle, x, y + ui.t.BUTTON_H + ui.t.ELEMENT_OFFSET, w, h - ui.t.BUTTON_H - ui.t.ELEMENT_OFFSET)) {
				var isEditable:Bool = StringTools.endsWith(currentlyDisplayedTrait.classname, ".hx");
				Ext.textArea(ui, codeScriptTextAreaHandle, zui.Zui.Align.Left, isEditable);
			}
		}
	}

	function updateDisplayedTraitData() {
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
						codeScriptTextAreaHandle.text = data;
					});
				}
			} else {
				found.tool.NodeEditor.selectedNode = null;
			}
			lastDisplayedTrait = currentlyDisplayedTrait;
		}
	}

	function saveDisplayedTraitData() {
		var traitData:String = "";
		if (currentlyDisplayedTrait.type == "VisualScript") {
			var nodeData:LogicTreeData = found.tool.NodeEditor.selectedNode;
			traitData = haxe.Json.stringify({name: nodeData.name, nodes: null, nodeCanvas: nodeData.nodeCanvas});
		} else {
			traitData = codeScriptTextAreaHandle.text;
		}

		khafs.Fs.saveContent(currentlyDisplayedTrait.classname, traitData, function() {
			saveTraitOnCurrentObject(currentlyDisplayedTrait);
		});
	}

	@:access(found.Scene)
	function saveTraitOnCurrentObject(trait:TTrait) {
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
}
