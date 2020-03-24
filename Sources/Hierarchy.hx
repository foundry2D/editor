package;

import kha.math.Vector2;
import kha.math.Vector3;

import found.data.SceneFormat;
import found.object.Object;
import found.Found;

import zui.Zui;
import zui.Ext;
import zui.Id;
import zui.Zui.Handle;

class Hierarchy {

    public var width:Int;
    public var height:Int;
    public var x:Int;
    public var y:Int;
    public var parent:EditorHierarchy;

    var windowHandle:zui.Zui.Handle = Id.handle();

    public function new(px:Int,py:Int,w:Int,h:Int) {
        setAll(px,py,w,h);
        windowHandle.scrollEnabled = true;
    }

    public function redraw(){
        windowHandle.redraws = 2;
        // objectHandle.redraws = 2;
    }

    public function setAll(px:Int,py:Int,w:Int,h:Int){
        x = px;
        y = py;
        width = w;
        height = h;
    }

    var sceneNameHandle:Handle = Id.handle();
    var handles:Array<Handle> = [];
    var scndoubleClickTime:Float = 0.0;
    @:access(zui.Zui)
    public function render(ui:zui.Zui,raw:TSceneFormat){
        if(ui.window(windowHandle, this.x, this.y, this.width, this.height)){

            sceneNameHandle.text = raw.name;
            if(kha.Scheduler.time() - scndoubleClickTime > ui.TOOLTIP_DELAY()){
                sceneNameHandle.position = 0;
                scndoubleClickTime = 0.0;
            }
            if(ui.getReleased()){
                parent.selectScene();
                scndoubleClickTime = kha.Scheduler.time();
                if( sceneNameHandle.position > 0){
                    sceneNameHandle.position = 0;
                }
                else if(sceneNameHandle.position < 1){
                    sceneNameHandle.position++;
                    ui.deselectText();
                    ui.inputReleased = false;
                }
            }
            var label = StringTools.endsWith(EditorHierarchy.sceneName,"*") ? "Scene(changed): ": "Scene: ";
            var name = ui.textInput(sceneNameHandle,label,Align.Right);
            if(sceneNameHandle.changed){
                EditorHierarchy.sceneName = StringTools.replace(EditorHierarchy.sceneName,raw.name,name);
                raw.name = name;
            }
            if(raw._entities.length > handles.length){
                while(handles.length != raw._entities.length){
                    handles.push(new Handle());
                } 
            }
            var i = 0;
            while (i < raw._entities.length) {
                var itemHandle = handles[i];
                i = itemDrawCb(ui,itemHandle,i,raw._entities);
            }
            if (ui.button("New Object")) {
                zui.Popup.showCustom(Found.popupZuiInstance, objectCreationPopupDraw, -1, -1, 600, 500);
            }
        }
    }

    var objectTypes:Array<String> = ["object","sprite_object","tilemap_object"];
    var typeDescr:Array<String> = ["object:\nAn object that has positional and collision information.\nTo detect collisions or have a trigger zone make sure to create a rigidbody on the object.",
    "sprite_object:\nAn Object that has a visual representation in the scene.\nCan be animated or have a parallax effect be applied to it.",
    "tilemap_object:\nAn object which can have multiple tiles/images that can be drawn on screen based on this objects position.\nIn the futur tiles will be animatable and Auto-tilling will be supported."];
    var textInputHandle = Id.handle();
    var objectTypeHandle = Id.handle();

    @:access(zui.Zui, zui.Popup)
    function objectCreationPopupDraw(ui:Zui){

        if (ui.panel(Id.handle({selected: true}), "Object Types:", true)) {
            var index = 0;
            for(type in objectTypes){
                var drawHint = false;
                if(ui.getHover()){
                    drawHint = true;
                }
                if(ui.button(type)){
                    objectTypeHandle.text = type;
                    if(textInputHandle.text == ""){
                        var name = type.split('_')[0];
                        textInputHandle.text = name.charAt(0).toUpperCase()+name.substring(1,name.length);
                    }
                }
                if(drawHint){
                    ui.text(typeDescr[index]);
                }
                index++;
            }
        }

        zui.Popup.boxTitle = "Add an Object";

        ui._y = ui._h - ui.t.BUTTON_H - ui.t.ELEMENT_H - 20;

        ui.row([0.5,0.5]);
        ui.textInput(textInputHandle, "Name");
        ui.textInput(objectTypeHandle, "Type",Align.Left,false);

        ui._y = ui._h - ui.t.BUTTON_H - 10;
        ui.row([0.5, 0.5]);
		if (ui.button("Add")) {
            addData2Scn(found.data.Creator.createType(textInputHandle.text,objectTypeHandle.text));
            zui.Popup.show = false;
            objectTypeHandle.text = textInputHandle.text = "";
        }
        if (ui.button("Cancel")) {
            zui.Popup.show = false;
            objectTypeHandle.text = textInputHandle.text = "";
		}
        
    }

    function addData2Scn(data:TObj){
        found.State.active.raw._entities.push(data);
        found.State.active.addEntity(data,true);
        EditorHierarchy.makeDirty();
    }

    @:access(found.object.Object,found.object.Executor)
    function rmvData2Scn(uid:Int){

        found.State.active._entities[uid].active  = false;
        for(exe in found.object.Executor.executors){
			var modified:Array<Any> = Reflect.field(found.object.Object,exe.field);
			modified.splice(uid,1);
		}

        found.State.active.raw._entities.splice(uid,1);
        found.State.active._entities.splice(uid,1);
        
        // Reset scene
        Object.uidCounter--;
        for(i in 0...found.State.active._entities.length){
            Reflect.setProperty(found.State.active._entities[i],"uid",i);
            found.State.active._entities[i].dataChanged = true;
        }
        if(EditorHierarchy.inspector.index == uid){
            EditorHierarchy.inspector.index = -1;
            EditorHierarchy.inspector.inspector.setObject(null,-1);
        }

        EditorHierarchy.makeDirty();
    }

    var doubleClickTime:Float = 0.0;
    @:access(zui.Zui)
    function itemDrawCb(ui:Zui,itemHandle:Handle,i:Int,raw:Array<TObj>){
        ui.row([0.12, 0.68, 0.2]);
        ui.text("");
        var expanded = false;//ui.panel(itemHandle, "") && raw[i].children != null;

        itemHandle.text = raw[i].name;
        if(kha.Scheduler.time() - doubleClickTime > ui.TOOLTIP_DELAY()){
            itemHandle.position = 0;
            doubleClickTime = 0.0;
        }
        if(ui.getReleased()){
            trace(itemHandle.position);
            doubleClickTime = kha.Scheduler.time();
            if( itemHandle.position > 0){
                itemHandle.position = 0;
            }
            else if(itemHandle.position < 1){
                itemHandle.position++;
                ui.deselectText();
                ui.inputReleased = false;
                parent.onSelected(i,raw[i]);
            }
        }
        var color = ui.t.FILL_ACCENT_BG;
        ui.t.FILL_ACCENT_BG = ui.t.FILL_WINDOW_BG;
        var out = ui.textInput(itemHandle);
        ui.t.FILL_ACCENT_BG = color;
        
        if(itemHandle.changed){
            raw[i].name = out;
            EditorHierarchy.makeDirty();
        }

        if(i > 0 && raw[i].type != "camera_object"){
            if (ui.button("X")){
                rmvData2Scn(i);
            }
            else i++;
        }
        else{
            ui.text("");
            i++;
        } 

        if (expanded){
            var y = 0;
            while (i < raw[i].children.length) {
                y = itemDrawCb(ui,itemHandle.nest(i), y,raw[i].children);
            }
        }
        return i;
    }
}