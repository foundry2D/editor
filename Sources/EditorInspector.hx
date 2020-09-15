import echo.Body;
import found.App;
import found.Found;
import found.Scene;
import found.State;
import found.anim.Tilemap;
import found.data.SceneFormat;
import found.math.Util;
import found.object.Object;
import khafs.Fs;
import zui.Id;
import zui.Zui;
import zui.Ext;

// @:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/editor-inspector.xml"))
class EditorInspector implements EditorHierarchyObserver extends Tab {
	// Unnecessary?
	var ui:Zui;

	var changed = false;

	var selectedObjectData:TObj;
	var selectedSceneData:TSceneFormat;
	var itemsLength:Int = 11;
	var objItemHandles:Array<zui.Zui.Handle> = [];

	var objectHandle:Handle = Id.handle();
	var sceneHandle:Handle = Id.handle();
	var traitListHandle:Handle = Id.handle();
	var traitListOpts:ListOpts;
	var updateSelectedTraitIndex:Bool = false;
	var objectTraitsChanged:Bool = false;

	var layersHandle = Id.handle();
	var layerItemHandles:Array<Array<zui.Zui.Handle>> = [];

	var depthSortText:String = "If active will draw based on depth order";
	var zSortText:String = "If active will zsort instead of Y sort";

	public var index(default, set):Int = -1;

	function set_index(value:Int) {
		return index = value;
	}

	public var currentObject(get, null):Null<Object>;

	function get_currentObject() {
		if (index == -1)
			return null;
		return found.State.active._entities[index];
	}

	var layers(get, null):Array<TLayer> = [];

	function get_layers() {
		var data = found.State.active.raw;
		if (data != null && data.layers == null)
			data.layers = layers;
		return data != null ? data.layers : layers;
	}

	var layersName(get, null):Array<String> = [];

	function get_layersName() {
		while (layers.length > layersName.length) {
			layersName.push(layers[layersName.length].name);
		}
		return layersName;
	}

	public function new() {
		super(tr("Inspector"));
		
		var base = Id.handle();
		for (i in 0...itemsLength) {
			objItemHandles.push(base.nest(i));
		}

		objectHandle.nest(0); // Pre create children

		traitListOpts = {
			addCb: addTrait,
			removeCb: removeTrait,
			getNameCb: getTraitName,
			setNameCb: null,
			getLabelCb: null,
			itemDrawCb: drawTrait,
			showRadio: true,
			editable: false,
			showAdd: true,
			addLabel: "New Trait"
		}

		EditorHierarchy.getInstance().register(this);
	}

	override public function redraw() {
		if (parent != null)
			parent.windowHandle.redraws = 2;
		objectHandle.redraws = 2;
		sceneHandle.redraws = 2;
		layersHandle.redraws = 2;
	}

	public function setObject(objectData:TObj, i:Int) {
		selectedSceneData = null;

		if (i != -1) {
			selectedObjectData = objectData;
			index = i;
			traitListHandle.nest(0).position = 0;
		} else {
			selectedObjectData = null;
		}

		redraw();
	}

	public function selectScene() {
		selectedObjectData = null;

		selectedSceneData = found.State.active.raw;

		redraw();
	}


	public function notifySceneSelectedInHierarchy() : Void {
		selectScene();		
	}

	public function notifyObjectSelectedInHierarchy(selectedObject:TObj, selectedUID:Int):Void {
		index = selectedUID;
		setObject(selectedObject, index);

		if (index != -1 && selectedObject.type == "tilemap_object") {
			found.Found.tileeditor.selectTilemap(index);
		} else {
			found.Found.tileeditor.selectTilemap(-1);
		}

		redraw();
	}

	override public function render(ui:zui.Zui) {
		super.render(ui);

		this.ui = ui;

		changed = false;
		if (ui.tab(parent.htab, this.name)) {
			ui.t.FILL_WINDOW_BG = true;
			if (selectedObjectData != null) {
				drawSelectedObjectItems(ui);
			} else if (selectedSceneData != null) {
				drawSelectedSceneItems(ui);
			}
		}
	}

	@:access(zui.Zui, found.anim.Sprite)
	function drawSelectedObjectItems(ui:Zui) {
		var activeHandle = objItemHandles[0];
		var xPosHandle = objItemHandles[1];
		var yPosHandle = objItemHandles[2];
		var zRotHandle = objItemHandles[3];
		var xScaleHandle = objItemHandles[4];
		var yScaleHandle = objItemHandles[5];
		var layerHandle = objItemHandles[6];
		var depthHandle = objItemHandles[7];
		var wHandle = objItemHandles[8];
		var hHandle = objItemHandles[9];
		var imagePathHandle = objItemHandles[10];

		var kinematicHandle = Id.handle();
		var massHandle = Id.handle();
		var elasticityHandle = Id.handle();
		var maxXvelHandle = Id.handle();
		var maxYvelHandle = Id.handle();
		var maxRotVelHandle = Id.handle();
		var dragXHandle = Id.handle();
		var dragYHandle = Id.handle();
		var gravityScaleHandle = Id.handle();

		// Object name field
		var objectNameHandle = Id.handle();
		objectNameHandle.text = selectedObjectData.name;

		ui.textInput(objectNameHandle, "");

		if (objectNameHandle.changed && objectNameHandle.text != "") {
			selectedObjectData.name = objectNameHandle.text;
			currentObject.name = objectNameHandle.text;
			currentObject.dataChanged = true;
			changed = true;
		}

		// Object type field
		ui.text(selectedObjectData.type);

		// Active checkbox
		activeHandle.selected = selectedObjectData.active;
		ui.check(activeHandle, " active");
		if (activeHandle.changed) {
			selectedObjectData.active = activeHandle.selected;
			currentObject.active = selectedObjectData.active;
			currentObject.dataChanged = true;
			changed = true;
		}

		ui.row([0.1, 0.45, 0.45]);
		ui.text("P");
		xPosHandle.value = Util.fround(selectedObjectData.position.x, 2);
		var px = Ext.floatInput(ui, xPosHandle, "X", Align.Right);
		if (xPosHandle.changed) {
			selectedObjectData.position.x = Util.fround(px, 2);
			currentObject.position.x = selectedObjectData.position.x;
			currentObject.dataChanged = true;
			changed = true;
		}
		yPosHandle.value = Util.fround(selectedObjectData.position.y, 2);
		var py = Ext.floatInput(ui, yPosHandle, "Y", Align.Right);
		if (yPosHandle.changed) {
			selectedObjectData.position.y = Util.fround(py, 2);
			currentObject.position.y = selectedObjectData.position.y;
			currentObject.dataChanged = true;
			changed = true;
		}
		ui.row([0.1, 0.9]);
		ui.text("R");
		zRotHandle.value = selectedObjectData.rotation.z;
		var rz = Math.abs(Ext.floatInput(ui, zRotHandle, "", Align.Right));
		if (zRotHandle.changed) {
			rz = rz > 360 ? rz - 360 : rz;
			selectedObjectData.rotation.z = rz;
			currentObject.rotation.z = selectedObjectData.rotation.z;
			currentObject.dataChanged = true;
			changed = true;
		}
		ui.row([0.1, 0.45, 0.45]);
		ui.text("S");
		xScaleHandle.value = Util.fround(selectedObjectData.scale != null ? selectedObjectData.scale.x : 1.0, 2);
		var sx = Ext.floatInput(ui, xScaleHandle, "X", Align.Right);
		if (xScaleHandle.changed) {
			selectedObjectData.scale.x = sx;
			currentObject.scale.x = selectedObjectData.scale.x;
			currentObject.dataChanged = true;
			changed = true;
		}

		yScaleHandle.value = Util.fround(selectedObjectData.scale != null ? selectedObjectData.scale.y : 1.0, 2);
		var sy = Ext.floatInput(ui, yScaleHandle, "Y", Align.Right);
		if (yScaleHandle.changed) {
			selectedObjectData.scale.y = sy;
			currentObject.scale.y = selectedObjectData.scale.y;
			currentObject.dataChanged = true;
			changed = true;
		}
		ui.row([0.15, 0.85]);
		ui.text("Layer: ");
		if (found.State.active.raw.layers != null) {
			layerHandle.position = selectedObjectData.layer;
			var layer = ui.combo(layerHandle, layersName);
			if (layerHandle.changed) {
				selectedObjectData.layer = layer;
				currentObject.layer = selectedObjectData.layer;
				currentObject.dataChanged = true;
				changed = true;
				layerHandle.changed = false;
			}
			var isZsort:Null<Bool> = found.State.active.raw._Zsort;
			if (isZsort != null && isZsort) {
				ui.indent();
				ui.row([0.35, 0.65]);
				ui.text("Order in layer:");
				depthHandle.value = selectedObjectData.depth;
				var depth = Ext.floatInput(ui, depthHandle);
				if (depthHandle.changed) {
					selectedObjectData.depth = depth;
					currentObject.depth = selectedObjectData.depth;
					currentObject.dataChanged = true;
					changed = true;
				}
				ui.unindent();
			}
		} else {
			if (ui.button("Create Layers")) {
				selectScene();
			}
		}

		ui.row([0.5, 0.5]);
		wHandle.value = selectedObjectData.width;
		var width = Ext.floatInput(ui, wHandle, "Width: ", Align.Right);
		if (wHandle.changed) {
			selectedObjectData.width = width;
			currentObject.width = selectedObjectData.width;
			currentObject.dataChanged = true;
			changed = true;
		}

		hHandle.value = selectedObjectData.height;
		var height = Ext.floatInput(ui, hHandle, "Height: ", Align.Right);
		if (hHandle.changed) {
			selectedObjectData.height = height;
			currentObject.height = selectedObjectData.height;
			currentObject.dataChanged = true;
			changed = true;
		}

		if (Reflect.hasField(selectedObjectData, "imagePath")) {
			var sprite:TSpriteData = cast(selectedObjectData);
			ui.row([0.75, 0.25]);
			imagePathHandle.text = sprite.imagePath;
			var path = ui.textInput(imagePathHandle, "Image:", Align.Right);
			if (imagePathHandle.changed) {
				sprite.imagePath = path;
				changed = true;
			}
			if (ui.button("Browse")) {
				browseImage();
			}
		}

		if (ui.panel(Id.handle(), "Traits: ")) {
			ui.indent();
			var traits:Array<TTrait> = selectedObjectData.traits != null ? selectedObjectData.traits : [];
			var lastSelectedTraitIndex:Int = traitListHandle.nest(0).position;
			var selectedTraitIndex:Int = Ext.list(ui, traitListHandle, traits, traitListOpts);
			if (selectedTraitIndex != lastSelectedTraitIndex || objectTraitsChanged || updateSelectedTraitIndex) {
				if (objectTraitsChanged) {
					objectTraitsChanged = false;
				} else if (updateSelectedTraitIndex) {
					traitListHandle.nest(0).position = traitListHandle.nest(0).position - 1;
					selectedTraitIndex = traitListHandle.nest(0).position;
					updateSelectedTraitIndex = false;
				}

				App.editorui.codeView.setDisplayedTrait(traits[selectedTraitIndex]);
			}
			selectedObjectData.traits = traits;
			ui.unindent();
		}

		if (found.State.active.raw.physicsWorld != null) {
			ui.row([0.5, 0.5]);
			var text = selectedObjectData.rigidBody != null ? "-" : "+";
			var addRigidbody = function(state:String) {
				if (state == "+") {
					selectedObjectData.rigidBody = Body.defaults;
					if (currentObject.body == null)
						currentObject.body = new echo.Body(selectedObjectData.rigidBody);
					if (currentObject.body.shapes == null && currentObject.body.shapes.length == 0) {
						currentObject.body.shapes.push(echo.Shape.rect(0, 0, currentObject.width, currentObject.height));
					}
					if (found.State.active.physics_world != null) {
						found.State.active.physics_world.add(currentObject.body);
					}
				} else if (state == "-") {
					selectedObjectData.rigidBody = null;
					if (found.State.active.physics_world != null) {
						found.State.active.physics_world.remove(currentObject.body);
					}
					currentObject.body = null;
				}
				currentObject.dataChanged = true;
				changed = true;
			};
			if (ui.panel(Id.handle(), "Rigidbody: ")) {
				if (ui.button(text)) {
					addRigidbody(text);
				}
				if (selectedObjectData.rigidBody != null) {
					kinematicHandle.selected = selectedObjectData.rigidBody.kinematic;
					ui.check(kinematicHandle, "is Kinematic");
					if (kinematicHandle.changed) {
						selectedObjectData.rigidBody.kinematic = kinematicHandle.selected;
						currentObject.body.kinematic = selectedObjectData.rigidBody.kinematic;
						currentObject.dataChanged = true;
						changed = true;
					}

					massHandle.value = selectedObjectData.rigidBody.mass;
					var mass = Ext.floatInput(ui, massHandle, "Mass:", Align.Right);
					if (massHandle.changed) {
						selectedObjectData.rigidBody.mass = mass;
						currentObject.body.mass = selectedObjectData.rigidBody.mass;
						currentObject.dataChanged = true;
						changed = true;
					}

					elasticityHandle.value = selectedObjectData.rigidBody.elasticity;
					var elasticity = Ext.floatInput(ui, elasticityHandle, "Elasticity:", Align.Right);
					if (elasticityHandle.changed) {
						selectedObjectData.rigidBody.elasticity = elasticity;
						currentObject.body.elasticity = selectedObjectData.rigidBody.elasticity;
						currentObject.dataChanged = true;
						changed = true;
					}
					maxXvelHandle.value = selectedObjectData.rigidBody.max_velocity_x;
					var maxVelX = Ext.floatInput(ui, maxXvelHandle, "Max X Velocity:", Align.Right);
					if (maxXvelHandle.changed) {
						selectedObjectData.rigidBody.max_velocity_x = maxVelX;
						currentObject.body.max_velocity.x = selectedObjectData.rigidBody.max_velocity_x;
						currentObject.dataChanged = true;
						changed = true;
					}
					maxYvelHandle.value = selectedObjectData.rigidBody.max_velocity_x;
					var maxVelY = Ext.floatInput(ui, Id.handle(), "Max Y Velocity:", Align.Right);
					if (maxYvelHandle.changed) {
						selectedObjectData.rigidBody.max_velocity_y = maxVelY;
						currentObject.body.max_velocity.y = selectedObjectData.rigidBody.max_velocity_y;
						currentObject.dataChanged = true;
						changed = true;
					}
					maxRotVelHandle.value = selectedObjectData.rigidBody.max_rotational_velocity;
					var maxRot = Ext.floatInput(ui, Id.handle(), "Max Rotation Velocity:", Align.Right);
					if (maxRotVelHandle.changed) {
						selectedObjectData.rigidBody.max_rotational_velocity = maxRot;
						currentObject.body.max_rotational_velocity = selectedObjectData.rigidBody.max_rotational_velocity;
						currentObject.dataChanged = true;
						changed = true;
					}

					dragXHandle.value = selectedObjectData.rigidBody.drag_x;
					var dragX = Ext.floatInput(ui, Id.handle(), "Drag X:", Align.Right);
					if (dragXHandle.changed) {
						selectedObjectData.rigidBody.drag_x = dragX;
						currentObject.body.drag.x = selectedObjectData.rigidBody.drag_x;
						currentObject.dataChanged = true;
						changed = true;
					}

					dragYHandle.value = selectedObjectData.rigidBody.drag_y;
					var dragY = Ext.floatInput(ui, Id.handle(), "Drag Y:", Align.Right);
					if (dragYHandle.changed) {
						selectedObjectData.rigidBody.drag_y = dragY;
						currentObject.body.drag.y = selectedObjectData.rigidBody.drag_y;
						currentObject.dataChanged = true;
						changed = true;
					}

					gravityScaleHandle.value = selectedObjectData.rigidBody.gravity_scale;
					var gravityScale = Ext.floatInput(ui, gravityScaleHandle, "Gravity Scale:", Align.Right);
					if (gravityScaleHandle.changed) {
						selectedObjectData.rigidBody.gravity_scale = gravityScale;
						currentObject.body.gravity_scale = selectedObjectData.rigidBody.gravity_scale;
						currentObject.dataChanged = true;
						changed = true;
					}

					if (ui.button("Edit Collision")) {
						CollisionEditorDialog.open(cast(currentObject));
					}
				}
			} else {
				if (ui.button(text)) {
					addRigidbody(text);
				}
			}
		} else {
			ui.row([0.25, 0.75]);
			ui.text("Rigidbody: ");
			if (ui.button("Create Physics World")) {
				selectScene();
			}
		}

		if (changed) {
			EditorHierarchy.getInstance().makeDirty();
		}
	}

	@:access(found.Scene, zui.Zui)
	function drawSelectedSceneItems(ui:Zui) {
		// Scene name field
		var sceneNameHandle = Id.handle();
		sceneNameHandle.text = selectedSceneData.name != null ? selectedSceneData.name : "Unavailable";

		ui.textInput(sceneNameHandle, "");

		if (sceneNameHandle.changed && sceneNameHandle.text != "" && sceneNameHandle.text != "Unavailable") {
			selectedSceneData.name = sceneNameHandle.text;
			changed = true;
		}

		// Depth sort checkbox
		var depthSortHandle = Id.handle();
		depthSortHandle.selected = selectedSceneData._depth != null ? selectedSceneData._depth : false;

		if (ui.getHover())
			ui.tooltip(depthSortText);

		ui.check(depthSortHandle, " Depth Sort");

		if (depthSortHandle.changed) {
			selectedSceneData._depth = depthSortHandle.selected;
			Reflect.setProperty(found.State.active, "_depth", depthSortHandle.selected);
			changed = true;
		}

		// Z sort checkbox
		if (selectedSceneData._depth) {
			var zsortHandle = Id.handle();
			zsortHandle.selected = selectedSceneData._Zsort != null ? selectedSceneData._Zsort : true;

			if (ui.getHover())
				ui.tooltip(zSortText);

			ui.check(zsortHandle, " Z sort");

			if (zsortHandle.changed || selectedSceneData._Zsort != zsortHandle.selected) {
				selectedSceneData._Zsort = zsortHandle.selected;
				Reflect.setProperty(found.Scene, "zsort", zsortHandle.selected);
				changed = true;
			}
		}

		var cullHandle = Id.handle();
		var cull = ui.check(cullHandle, "Cull");
		if (cullHandle.changed && !cull) {
			selectedSceneData.cullOffset = null;
			Reflect.setProperty(found.State.active, "cullOffset", 0);
			changed = true;
		}
		if (cull) {
			if (selectedSceneData.cullOffset == null) {
				selectedSceneData.cullOffset = 1;
				Reflect.setProperty(found.State.active, "cullOffset", selectedSceneData.cullOffset);
				changed = true;
			}
			var cullOffsetHandle = Id.handle();
			cullOffsetHandle.value = selectedSceneData.cullOffset;
			var offset = ui.slider(cullOffsetHandle, "Cull offset", 1, 500);
			if (cullOffsetHandle.changed) {
				selectedSceneData.cullOffset = Std.int(offset);
				Reflect.setProperty(found.State.active, "cullOffset", selectedSceneData.cullOffset);
				changed = true;
			}
		}

		// Physics World section
		ui.row([0.5, 0.5]);

		var text = selectedSceneData.physicsWorld != null ? "-" : "+";

		if (ui.panel(Id.handle(), "Physics World: ")) {
			if (ui.button(text)) {
				addPhysWorld(text, selectedSceneData);
			}
			if (selectedSceneData.physicsWorld != null) {
				var widthHandle = Id.handle();
				widthHandle.value = selectedSceneData.physicsWorld.width;
				var width = Ext.floatInput(ui, widthHandle, "Width:", Align.Right);
				if (widthHandle.changed) {
					selectedSceneData.physicsWorld.width = width;
					found.State.active.physics_world.width = width;
					changed = true;
				}

				var heightHandle = Id.handle();
				heightHandle.value = selectedSceneData.physicsWorld.height;
				var height = Ext.floatInput(ui, heightHandle, "Height:", Align.Right);
				if (heightHandle.changed) {
					selectedSceneData.physicsWorld.height = height;
					found.State.active.physics_world.height = height;
					changed = true;
				}

				var gravityXHandle = Id.handle();
				gravityXHandle.value = selectedSceneData.physicsWorld.gravity_x != null ? selectedSceneData.physicsWorld.gravity_x : 0;
				var gravityX = Ext.floatInput(ui, gravityXHandle, "Gravity X:", Align.Right);
				if (gravityXHandle.changed) {
					selectedSceneData.physicsWorld.gravity_x = gravityX;
					found.State.active.physics_world.gravity.x = gravityX;
					changed = true;
				}

				var gravityYHandle = Id.handle();
				gravityYHandle.value = selectedSceneData.physicsWorld.gravity_y;
				var gravityY = Ext.floatInput(ui, gravityYHandle, "Gravity Y:", Align.Right);
				if (gravityYHandle.changed) {
					selectedSceneData.physicsWorld.gravity_y = gravityY;
					found.State.active.physics_world.gravity.y = gravityY;
					changed = true;
				}

				var iterationsHandle = Id.handle();
				iterationsHandle.value = selectedSceneData.physicsWorld.iterations;
				var iterations = Std.int(ui.slider(iterationsHandle, "No. of iterations", 1, 20, false, 1));
				if (iterationsHandle.changed) {
					selectedSceneData.physicsWorld.iterations = iterations;
					found.State.active.physics_world.iterations = iterations;
					changed = true;
				}

				var historyHandle = Id.handle();
				historyHandle.value = selectedSceneData.physicsWorld.history != null ? selectedSceneData.physicsWorld.history : 500;
				var history = Std.int(ui.slider(historyHandle, "History", 1, 1000, false, 1 / 100));
				if (historyHandle.changed) {
					selectedSceneData.physicsWorld.history = history;
					found.State.active.physics_world.history = new echo.util.History(history);
					changed = true;
				}
			}
		} else {
			if (ui.button(text)) {
				addPhysWorld(text, selectedSceneData);
			}
		}

		// Layers section
		ui.text("Layers:");
		ui.indent();
		Ext.panelList(ui, layersHandle, layers, addLayer, deleteLayer, getLayerName, setLayerName, drawLayerItems, false, true, "New Layer");
		ui.unindent();

		if (changed || layersHandle.changed) {
			EditorHierarchy.getInstance().makeDirty();
		}
	}

	@:access(found.Scene)
	function addPhysWorld(state:String, sceneData:TSceneFormat) {
		if (state == "+") {
			sceneData.physicsWorld = {
				width: Found.WIDTH,
				height: Found.HEIGHT,
				iterations: 5,
				gravity_y: 3000
			};

			if (found.State.active.physics_world == null)
				found.State.active.addPhysicsWorld(sceneData.physicsWorld);

			for (object in found.State.active._entities) {
				if (object.body != null) {
					found.State.active.physics_world.add(object.body);
				}
				if (Std.is(object, Tilemap)) {
					cast(object, Tilemap).makeBodies(found.State.active);
				}
			}
		} else if (state == "-") {
			sceneData.physicsWorld = null;
			found.State.active.physicsUpdate = function(f:Float) {};
			found.State.active.physics_world.dispose();
			found.State.active.physics_world = null;
		}
		changed = true;
	}

	function addLayer(name:String) {
		if (name == "")
			return;
		var out = name;
		for (layer in layers) {
			if (layer.name == out) {
				out += layers.length + 1;
			}
		}
		layersHandle.changed = true;
		layers.push({name: out, zIndex: layers.length, speed: 1.0});
		redraw();
	}

	function deleteLayer(index:Int) {
		layersHandle.changed = true;
		layers.splice(index, 1);
		layersName.splice(index, 1);
		for (entity in found.State.active._entities) {
			if (entity.layer == index) {
				entity.layer = entity.raw.layer = 0;
			}
		}
	}

	function getLayerName(index:Int) {
		return layersName[index];
	}

	function setLayerName(index:Int, name:String) {
		if (name == "")
			return;
		layersHandle.changed = true;
		layers[index].name = name;
		layersName[index] = name;
	}

	function drawLayerItems(handle:Handle, index:Int) {
		if (index == -1)
			return;
		var layer = layers[index];
		while (layers.length > layerItemHandles.length) {
			var handles = [];
			for (i in 0...3) {
				handles.push(new Handle());
			}
			layerItemHandles.push(handles);
		}

		var nameHandle = layerItemHandles[index][0];
		var zIndexHandle = layerItemHandles[index][1];
		var paralaxHandle = layerItemHandles[index][2];

		nameHandle.text = layer.name;
		var name = ui.textInput(nameHandle, "Name:", Align.Right);
		if (nameHandle.changed) {
			layer.name = name;
			layersName[index] = name;
			changed = true;
		}

		paralaxHandle.value = layer.speed * 100;
		var speed = ui.slider(paralaxHandle, "Parallax", 1, 100);
		if (paralaxHandle.changed) {
			layer.speed = speed * 0.01;
			changed = true;
		}

		if (changed) {
			EditorHierarchy.getInstance().makeDirty();
		}
	}

	function drawTrait(handle:Handle, i:Int) {
		var trait = currentObject.raw.traits[i];
		if (trait != null) {
			ui.text(trait.classname);
		}
	}

	function addTrait(name:String) {
		TraitsDialog.open();
	}

	public function setObjectTraitsChanged() {
		objectTraitsChanged = true;

		currentObject.dataChanged = true;
		EditorHierarchy.getInstance().makeDirty();

		redraw();
	}

	@:access(found.object.Object)
	function removeTrait(i:Int) {
		var removedTrait = currentObject.raw.traits.splice(i, 1);
		if (removedTrait[0].type == "VisualScript") {
			currentObject.removeTrait(currentObject.traits[i]);
		} else if (removedTrait[0].type == "Script") {
			var trait = currentObject.getTrait(Type.resolveClass(removedTrait[0].classname));
			if (trait != null) {
				currentObject.removeTrait(trait);
			}
		}

		if (traitListHandle.nest(0).position > 0 && i <= traitListHandle.nest(0).position) {
			updateSelectedTraitIndex = true;
		} else {
			objectTraitsChanged = true;
		}

		currentObject.dataChanged = true;
		EditorHierarchy.getInstance().makeDirty();
	}

	function getTraitName(i:Int) {
		var trait = currentObject.raw.traits[i];
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

	@:access(found.Scene)
	public function addTraitToCurrentObject(trait:TTrait) {
		selectedObjectData.traits.push(trait);
		Scene.createTraits([trait], currentObject);
		changed = true;
		EditorHierarchy.getInstance().makeDirty();
	}

	public function notifySceneSelect() {
		selectScene();
	}

	function browseImage() {
		var done = function(path:String) {
			if (path == "")
				return;

			var error = true;
			var sep = Fs.sep;
			if (path != null) {
				var name = path.split(sep)[path.split(sep).length - 1];
				var type = name.split('.')[1];
				switch (type) {
					case 'png' | 'jpg':
						if (index != -1 && selectedObjectData != null) {
							Reflect.setProperty(selectedObjectData, "imagePath", path);
							cast(found.State.active._entities[index], found.anim.Sprite).set(cast(selectedObjectData));
							EditorHierarchy.getInstance().makeDirty();
						}
						error = false;
					default:
						trace('Error: file has filetype $type which is not a valid filetype for images ');
				}
				if (error) {
					trace('Error: file with name $name is not a valid image name or the path "$path" was invalid ');
				}
			}
		}
		FileBrowserDialog.open(done);
	}

	public function updateField(uid:Int, id:String, data:Any) {
		if (uid > found.State.active._entities.length - 1)
			return;
		switch (id) {
			case "_positions":
				var x = Util.fround(Reflect.getProperty(data, "x"), 2);
				var y = Util.fround(Reflect.getProperty(data, "y"), 2);
				if (index == uid) {
					selectedObjectData.position.x = x;
					selectedObjectData.position.y = y;
					redraw();
				}
			case "_rotations":
				var z = Reflect.getProperty(data, "z");
				if (index == uid) {
					selectedObjectData.rotation.z = Util.fround(z, 2);
				}
			case "_scales":
				var x = Reflect.getProperty(data, "x");
				var y = Reflect.getProperty(data, "y");
				if (index == uid) {
					selectedObjectData.scale.x = Util.fround(x, 2);
					selectedObjectData.scale.y = Util.fround(y, 2);
				}
			case "imagePath":
				var width = Reflect.getProperty(data, "width");
				var height = Reflect.getProperty(data, "height");
				if (index == uid) {
					selectedObjectData.width = width;
					selectedObjectData.height = height;
				}
		}
	}
}
