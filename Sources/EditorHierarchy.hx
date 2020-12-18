package;

import found.Found;
import found.data.SceneFormat;
import found.object.Object;
import zui.Zui;
import zui.Id;
import zui.Zui.Handle;

class EditorHierarchy extends Tab {
	static var instance:EditorHierarchy;

	var observers:Array<EditorHierarchyObserver> = [];
	var selectedObjectUID:Int = -1;

	var sceneName = "";
	var scene:TSceneFormat;

	var sceneNameHandle:Handle = Id.handle();
	var objectWithNameAlreadyExists = false;
	var textInputHandle = Id.handle();
	var objectTypeHandle = Id.handle();
	var handles:Array<Handle> = [];
	var sceneNameDoubleClickTime:Float = 0.0;
	var objectNameDoubleClickTime:Float = 0.0;

	var objectTypes:Array<String> = ["None", "object", "sprite_object", "tilemap_object"];
	var typeDescr:Array<String> = [
		"object:\nAn object that has positional and collision information.\nTo detect collisions or have a trigger zone make sure to create a rigidbody on the object.",
		"sprite_object:\nAn Object that has a visual representation in the scene.\nCan be animated or have a parallax effect be applied to it.",
		"tilemap_object:\nAn object which can have multiple tiles/images that can be drawn on screen based on this objects position.\nIn the futur tiles will be animatable and Auto-tilling will be supported."
	];

	private function new() {
		super(tr("Hierarchy"));

		setSceneData(found.State.active.raw);
	}

	public static function getInstance():EditorHierarchy {
		if (instance == null) {
			instance = new EditorHierarchy();
		}

		return instance;
	}

	public function register(observer:EditorHierarchyObserver):Void {
		observers.push(observer);
	}

	public function unregister(observer:EditorHierarchyObserver):Void {
		observers.remove(observer);
	}

	private function onSceneSelected():Void {
		for (item in observers) {
			item.notifySceneSelectedInHierarchy();
		}
	}

	private function onObjectSelected(uid:Int, obj:TObj):Void {
		selectedObjectUID = uid;

		for (item in observers) {
			item.notifyObjectSelectedInHierarchy(obj, uid);
		}
	}

	public function setSceneData(raw:TSceneFormat) {
		sceneName = raw.name;
		scene = raw;
		redraw();
	}

	public function makeDirty() {
		if (!isDirty())
			sceneName += '*';

		redraw();

		// TODO: hierarchy should not be in charge of setting dataChanged to true: the class calling the makeDirty function should have already set it.
		if (selectedObjectUID == -1)
			return;
		found.State.active._entities[selectedObjectUID].dataChanged = true;
	}

	public function isDirty():Bool {
		return StringTools.endsWith(sceneName, '*');
	}

	public function makeClean() {
		sceneName = StringTools.replace(sceneName, '*', '');
		redraw();
	}

	override public function redraw() {
		if (parent != null)
			parent.windowHandle.redraws = 2;

		sceneNameHandle.redraws = 2;
	}

	@:access(zui.Zui)
	override public function render(ui:zui.Zui) {
		super.render(ui);

		if (scene == null)
			return;

		if(ui.panel(Id.handle({selected: true}),this.name)){
			sceneNameHandle.text = scene.name;
			if (kha.Scheduler.time() - sceneNameDoubleClickTime > ui.TOOLTIP_DELAY()) {
				sceneNameHandle.position = 0;
				sceneNameDoubleClickTime = 0.0;
			}
			if (ui.getReleased()) {
				onSceneSelected();
				sceneNameDoubleClickTime = kha.Scheduler.time();
				if (sceneNameHandle.position > 0) {
					sceneNameHandle.position = 0;
				} else if (sceneNameHandle.position < 1) {
					sceneNameHandle.position++;
					ui.deselectText();
					ui.inputReleased = false;
				}
			}
			var label = isDirty() ? tr("Scene(changed)") : tr("Scene");
			label += ": ";
			var name = ui.textInput(sceneNameHandle, label, Align.Right);
			if (sceneNameHandle.changed) {
				sceneName = StringTools.replace(sceneName, scene.name, name);
				scene.name = name;
			}
			if (scene._entities.length > handles.length) {
				while (handles.length != scene._entities.length) {
					handles.push(new Handle());
				}
			}
			var i = 0;
			while (i < scene._entities.length) {
				var itemHandle = handles[i];
				i = itemDrawCb(ui, itemHandle, i, scene._entities);
			}
		}
		if (ui.button(tr("New Object"))) {
			zui.Popup.showCustom(Found.popupZuiInstance, objectCreationPopupDraw, -1, -1, Std.int(Found.popupZuiInstance.ELEMENT_W() * 4),Std.int(Found.popupZuiInstance.ELEMENT_W() * 3));
		}
		
	}

	@:access(zui.Zui, zui.Popup)
	function objectCreationPopupDraw(ui:Zui) {
		zui.Popup.boxTitle = tr("Add an Object");
		var border = 2 * zui.Popup.borderW + zui.Popup.borderOffset;
		if (ui.panel(Id.handle({selected: true}), tr("Object Types") + ":", true)) {
			var index = 0;
			for (type in objectTypes) {
				if (type == "None")
					continue;
				var drawHint = false;
				if (ui.getHover()) {
					drawHint = true;
				}
				if (ui.button(type)) {
					objectTypeHandle.position = index + 1;
					if (textInputHandle.text == "") {
						var name = type.split('_')[0];
						textInputHandle.text = name.charAt(0).toUpperCase() + name.substring(1, name.length);
						objectWithNameAlreadyExists = found.State.active.getObject(textInputHandle.text) != null;
					}
				}
				if (drawHint) {
					ui.text(tr(typeDescr[index]));
				}
				index++;
			}
		}

		ui._y = ui._h - ui.t.BUTTON_H * 2 - border;

		ui.row([0.5, 0.5]);
		var before = ui.t.LABEL_COL;
		if (objectWithNameAlreadyExists) {
			ui.t.LABEL_COL = ui.t.TEXT_COL = kha.Color.Red;
		}

		ui.textInput(textInputHandle, tr("Name"));
		if (textInputHandle.changed) {
			objectWithNameAlreadyExists = found.State.active.getObject(textInputHandle.text) != null;
		}
		ui.t.LABEL_COL = ui.t.TEXT_COL = before;

		ui.combo(objectTypeHandle, objectTypes, tr("Type"), true, Align.Left);

		ui._y = ui._h - ui.t.BUTTON_H - border;
		ui.row([0.5, 0.5]);

		ui.enabled = !objectWithNameAlreadyExists && textInputHandle.text != "" && objectTypeHandle.position != 0 /*None*/;
		if (ui.button(tr("Add"))) {
			addData2Scn(found.data.Creator.createType(textInputHandle.text, objectTypes[objectTypeHandle.position]));
			closeObjectCreationPopup();
		}
		ui.enabled = true;
		if (ui.button(tr("Cancel"))) {
			closeObjectCreationPopup();
		}
	}

	function addData2Scn(data:TObj) {
		found.State.active.raw._entities.push(data);
		found.State.active.addEntity(data,function(ent:Object){
			onObjectSelected(ent.uid,ent.raw);
		}, true);
		makeDirty();
	}

	function closeObjectCreationPopup() {
		zui.Popup.show = false;
		objectTypeHandle.text = textInputHandle.text = "";
		redraw();
	}

	@:access(found.object.Object, found.object.Executor, found.Scene)
	function rmvData2Scn(uid:Int) {
		found.State.active.raw._entities.splice(uid, 1);
		var entity = found.State.active._entities[uid];
		entity.spawned = true;//Will make it so we really delete it and call onRemove for Traits.
		found.State.active.remove(entity);

		if (found.State.active.physics_world != null) {
			found.State.active.physics_world.reset_quadtrees();
		}

		for (exe in found.object.Executor.executors) {
			var modified:Array<Any> = Reflect.field(found.object.Object, exe.field);
			modified.splice(uid, 1);
		}

		Object.uidCounter--;
		for (i in 0...found.State.active._entities.length) {
			Reflect.setProperty(found.State.active._entities[i], "uid", i);
			found.State.active._entities[i].dataChanged = true;
		}

		if (uid == selectedObjectUID) {
			onObjectSelected(-1, null);
		}

		makeDirty();
	}

	@:access(zui.Zui)
	function itemDrawCb(ui:Zui, itemHandle:Handle, i:Int, raw:Array<TObj>) {
		ui.row([0.12, 0.68, 0.2]);
		ui.text("");
		var expanded = false; // ui.panel(itemHandle, "") && raw[i].children != null;

		itemHandle.text = raw[i].name;
		if (kha.Scheduler.time() - objectNameDoubleClickTime > ui.TOOLTIP_DELAY()) {
			itemHandle.position = 0;
			objectNameDoubleClickTime = 0.0;
		}
		if (ui.getReleased()) {
			objectNameDoubleClickTime = kha.Scheduler.time();
			if (itemHandle.position > 0) {
				itemHandle.position = 0;
			} else if (itemHandle.position < 1) {
				itemHandle.position++;
				ui.deselectText();
				ui.inputReleased = false;
				onObjectSelected(i, raw[i]);
			}
		}
		var color = ui.t.FILL_ACCENT_BG;
		ui.t.FILL_ACCENT_BG = ui.t.FILL_WINDOW_BG;
		var out = ui.textInput(itemHandle);
		ui.t.FILL_ACCENT_BG = color;

		if (itemHandle.changed) {
			raw[i].name = out;
			makeDirty();
		}

		if (i > 0 && raw[i].type != "camera_object") {
			if (ui.button("X")) {
				rmvData2Scn(i);
			} else
				i++;
		} else {
			ui.text("");
			i++;
		}

		if (expanded) {
			var y = 0;
			while (i < raw[i].children.length) {
				y = itemDrawCb(ui, itemHandle.nest(i), y, raw[i].children);
			}
		}
		return i;
	}
}
