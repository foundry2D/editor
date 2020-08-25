package;

import zui.Id;
import zui.Ext;
import found.App;
import found.Scene;
import found.data.SceneFormat;
import found.tool.NodeEditor;

class EditorCodeView implements EditorHierarchyObserver extends Tab {
	var visualEditor:found.tool.NodeEditor;

	var lastDisplayedTrait:TTrait = null;
	var currentlyDisplayedTrait:TTrait = null;

	var traitNameWindowHandle = Id.handle();
	var codeScriptWindowHandle = Id.handle();
	var codeScriptTextAreaHandle = Id.handle();

	public function new() {
		EditorHierarchy.register(this);
	}

	public function notifyObjectSelectedInHierarchy(selectedObject:TObj, selectedUID:Int):Void {
		// @TODO: should we always load and reparse the data ?
		// (i.e. we already parse the data to determine what to show the UI so maybe we should load if we find a visual script from the UI)
		var traits:Array<TTrait> = selectedObject.traits != null ? selectedObject.traits : [];
		if (traits.length > 0)
			setDisplayedTrait(traits[0]);
	}

	public function setDisplayedTrait(trait:TTrait):Void {
		currentlyDisplayedTrait = trait;
		if (this.active) {
			traitNameWindowHandle.redraws = codeScriptWindowHandle.redraws = codeScriptTextAreaHandle.redraws = 2;
			visualEditor.redraw();
		}
	}

	@:access(zui.Zui)
	override public function render(ui:zui.Zui) {
		if (visualEditor == null) {
			visualEditor = new found.tool.NodeEditor(ui, parent.x, parent.y, parent.w, parent.h);
			visualEditor.visible = false;
			parent.postRenders.push(visualEditor.render);
		}
		visualEditor.setAll(parent.x, parent.y + (ui.t.BUTTON_H + ui.t.ELEMENT_OFFSET) * 2, parent.w, parent.h - (ui.t.BUTTON_H + ui.t.ELEMENT_OFFSET) * 2);
		var isActive = ui.tab(parent.htab, "Code");
		if (isActive) {
			if (currentlyDisplayedTrait != null) {
				ui.row([0.7, 0.3]);
				ui.text(currentlyDisplayedTrait.classname);
				if (ui.button("Save")) {
					saveDisplayedTraitData();
				}
				updateDisplayedTraitData();
				if (currentlyDisplayedTrait.type != "VisualScript") {
					visualEditor.visible = false;
					var isEditable:Bool = StringTools.endsWith(currentlyDisplayedTrait.classname, ".hx");
					Ext.textArea(ui, codeScriptTextAreaHandle, zui.Zui.Align.Left, isEditable);
				} else {
					visualEditor.visible = true;
				}
			}
		} else {
			visualEditor.visible = false;
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
					if (StringTools.startsWith(currentlyDisplayedTrait.classname, "found.trait.internal")) {
						trace("need to load internal trait");
					} else {
						khafs.Fs.getContent(currentlyDisplayedTrait.classname, function(data:String) {
							codeScriptTextAreaHandle.text = data;
						});
					}
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
