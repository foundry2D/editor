import kha.Blob;
import khafs.Fs;
import found.App;
import found.Scene;
import found.data.SceneFormat;
import zui.Id;
import zui.Zui;
import found.Found;

class TraitsDialog {
	static var textInputHandle:Handle = Id.handle();
	static var comboBoxHandle:Handle = Id.handle();
	static var traitsFolderPath = "";
	static var traitTypes = ["Visual Trait", "Script Trait"];
	static var traitTypeExtensions = ["vhx", "hx"];
	static var camelCaseRegex:EReg = ~/([A-Z][a-z0-9]+)((\d)|([A-Z0-9][a-z0-9]+))*([A-Z])?/;
	static var arrayOfTraits:Array<TTrait> = [];
	static var fullFileName:String = "";

	public static function open() {
		traitsFolderPath = EditorUi.projectPath + "/Sources/Scripts/";
		textInputHandle.text = "NewTrait";
		zui.Popup.showCustom(Found.popupZuiInstance, traitCreationPopupDraw, -1, -1, 600, 500);
	}

	@:access(zui.Zui, zui.Popup)
	static function traitCreationPopupDraw(ui:Zui) {
		zui.Popup.boxTitle = "Add a trait";

		if (ui.panel(Id.handle({selected: true}), "Existing Traits", true)) {
			var precompiledTraits = loadPrecompiledTraits();
			var userCreatedTraits = loadUserCreatedTraits(traitsFolderPath);
			arrayOfTraits = precompiledTraits.concat(userCreatedTraits);

			for (trait in arrayOfTraits) {
				if (ui.button(trait.classname, Align.Left)) {
					textInputHandle.text = getTraitNameFromTraitDef(trait);
					if (trait.type == "Script") {
						comboBoxHandle.position = 1;
					} else {
						comboBoxHandle.position = 0;
					}
				}
			}
		}

		var border = 2 * zui.Popup.borderW + zui.Popup.borderOffset;

		ui._y = ui._h - ui.t.BUTTON_H - 2 * ui.t.ELEMENT_H - 3 * ui.t.ELEMENT_OFFSET - border;
		ui.row([0.6, 0.4]);
		ui.textInput(textInputHandle, "Script Name");
		var selectedTraitTypeIndex:Int = ui.combo(comboBoxHandle, traitTypes, "Trait Type");

		ui._y = ui._h - ui.t.BUTTON_H - ui.t.ELEMENT_H - 2 * ui.t.ELEMENT_OFFSET - border;
		if (textInputHandle.text != "") {
			if (camelCaseRegex.match(textInputHandle.text) && camelCaseRegex.matched(0) == textInputHandle.text) {
				fullFileName = traitsFolderPath + textInputHandle.text + "." + traitTypeExtensions[selectedTraitTypeIndex];
				ui.text(fullFileName);
			} else {
				fullFileName = "Error: Trait name is invalid. Please enter a trait name that respects camel case.";
				ui.text(fullFileName, Align.Left, 0xff0000);
			}
		}

		ui._y = ui._h - ui.t.BUTTON_H - border;
		ui.row([0.5, 0.5]);
		if (ui.button("Add")) {
			if (camelCaseRegex.match(textInputHandle.text) && camelCaseRegex.matched(0) == textInputHandle.text) {
				var trait:TTrait = findExistingTrait(textInputHandle.text, arrayOfTraits);

				if (trait != null) {
					saveTraitOnCurrentObject(trait);
				} else {
					if (traitTypeExtensions[selectedTraitTypeIndex] == "vhx") {
						saveNewVisualTrait(textInputHandle.text, fullFileName);
					} else {
						saveNewScriptTrait(textInputHandle.text, fullFileName);
					}
				}

				zui.Popup.show = false;
			}
		}
		if (ui.button("Cancel")) {
			zui.Popup.show = false;
		}
	}

	static function loadPrecompiledTraits():Array<TTrait> {
		var blob:Blob = kha.Assets.blobs.get("listTraits_json");
		var data:{traits:Array<TTrait>} = haxe.Json.parse(blob.toString());

		if (data.traits != null) {
			return data.traits;
		} else {
			return [];
		}
	}

	static function loadUserCreatedTraits(traitsFolderPath:String):Array<TTrait> {
		var arrayOfTraits:Array<TTrait> = [];

		var files:Array<String> = Fs.readDirectory(traitsFolderPath);
		for (file in files) {
			var traitType:String = "";
			var t:Array<String> = file.split(".");
			var fileExtension = t[t.length - 1];
			if (fileExtension == "vhx") {
				traitType = "VisualScript";
			} else {
				traitType = "Script";
			}

			arrayOfTraits.push({type: traitType, classname: traitsFolderPath + file});
		}

		return arrayOfTraits;
	}

	static function getTraitNameFromTraitDef(trait:TTrait) {
		var name = "";
		if (trait.type == "VisualScript") {
			var t:Array<String> = trait.classname.split("/");
			name = t[t.length - 1].split('.')[0];
		} else if (trait.type == "Script") {
			if (StringTools.endsWith(trait.classname, ".hx")) {
				var t:Array<String> = trait.classname.split("/");
				name = t[t.length - 1].split('.')[0];
			} else {
				var t:Array<String> = trait.classname.split(".");
				name = t[t.length - 1];
			}
		}
		return name;
	}

	static function findExistingTrait(newTraitName:String, arrayOfTraits:Array<TTrait>):TTrait {
		for (trait in arrayOfTraits) {
			var traitName:String = getTraitNameFromTraitDef(trait);
			if (traitName == newTraitName) {
				return trait;
			}
		}
		return null;
	}

	static function saveNewVisualTrait(traitName:String, traitSavePath:String) {
		#if kha_debug_html5
		var t = traitSavePath.split(Fs.sep);
		traitSavePath = t[t.length-1].replace(".","_");
		#end
		var trait:TTrait = {
			type: "VisualScript",
			classname: traitSavePath
		}

		var visualTraitData:LogicTreeData = {
			name: traitName,
			nodes: null,
			nodeCanvas: {
				name: traitName + " Nodes",
				nodes: [],
				links: []
			}
		};
		var visualTraitDataAsJson = haxe.Json.stringify(visualTraitData);

		if (!Fs.exists(EditorUi.projectPath + "/Sources/Scripts"))
			Fs.createDirectory(EditorUi.projectPath + "/Sources/Scripts");

		Fs.saveContent(traitSavePath, visualTraitDataAsJson, function() {
			saveTraitOnCurrentObject(trait);
		});
	}

	static function saveNewScriptTrait(traitName:String, traitSavePath:String) {
		if (!Fs.exists(traitSavePath)) {
			var trait:TTrait = {
				type: "Script",
				classname: traitSavePath
			}

			var scriptTraitData = 
				'package;\n\n' 
				+ 'class $traitName extends found.Trait {\n' 
				+ '\tpublic function new () {\n' 
				+ '\t\tsuper();\n\n'
				+ '\t\tnotifyOnInit(function() {\n' 
				+ '\t\t\t// Insert code here\n' 
				+ '\t\t});\n\n' 
				+ '\t\tnotifyOnUpdate(function(dt:Float) {\n'
				+ '\t\t\t// Insert code here\n' 
				+ '\t\t});\n' 
				+ '\t}\n' 
				+ '}';
			
			if (!Fs.exists(EditorUi.projectPath + "/Sources/Scripts"))
				Fs.createDirectory(EditorUi.projectPath + "/Sources/Scripts");

			Fs.saveContent(traitSavePath, scriptTraitData, function() {
				saveTraitOnCurrentObject(trait);
			});
		}
	}

	@:access(found.Scene)
	static function saveTraitOnCurrentObject(trait:TTrait) {
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

		App.editorui.inspector.setObjectTraitsChanged();		
	}
}
