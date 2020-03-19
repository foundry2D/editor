package;

import found.data.SceneFormat;
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
                trace("Implement me");
            }
        }
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

        if (ui.button("X")) raw.splice(i,1);
        else i++;

        if (expanded){
            var y = 0;
            while (i < raw[i].children.length) {
                y = itemDrawCb(ui,itemHandle.nest(i), y,raw[i].children);
            }
        }
        return i;
    }
}