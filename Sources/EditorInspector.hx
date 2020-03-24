

import found.Scene;
import haxe.ui.core.Component;
import haxe.ui.extended.NodeData;
import haxe.ui.extended.InspectorNode;
import haxe.ui.data.ListDataSource;
import haxe.ui.events.UIEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.containers.menus.MenuItem;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.extended.InspectorField;
import khafs.Fs;
import utilities.JsonObjectExplorer;
#if arm_csm
import iron.data.SceneFormat;
#elseif found
import found.App;
import found.Found;
import found.State;
import found.data.SceneFormat;
import found.object.Object;
import found.math.Util;
#end

@:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/editor-inspector.xml"))
class EditorInspector implements EditorHierarchyObserver extends EditorTab {

    public var x(get,never):Int;
	function get_x() {
        var comp = this.parentComponent !=null ? this.parentComponent: this;
		return Math.floor(this.screenX);
	}
	public var y(get,never):Int;
	function get_y() {
        var comp = this.parentComponent !=null ? this.parentComponent: this;
		return Math.floor(this.screenY);
	}
	public var w(get,never):Int;
	function get_w() {
        var comp = this.parentComponent !=null ? this.parentComponent: this;
		return Math.ceil(this.componentWidth);
	}
	public var h(get,never):Int;
	function get_h() {
        var comp = this.parentComponent !=null ? this.parentComponent: this;
		return Math.ceil(this.componentHeight);
    }

    public var rawData(default,set):TObj;
    function set_rawData(obj:TObj){
        return rawData = obj;
    }
    public var index(default,set):Int = -1;
    function set_index(value:Int){
        return index = value;
    }
    public var currentObject(get,null):Null<Object>;
    function get_currentObject(){
        if(index == -1)return null;
        return State.active._entities[index];
    }
    public var inspector:Inspector;
    public function new(?ui:zui.Zui) {
        super();
        this.text = "Inspector";
        inspector = new Inspector(ui,x,y,w,h);
        inspector.searchImage = browseImage;
        EditorHierarchy.register(this);
    }
    @:access(Inspector)
    public function clear(){
        inspector.scene.resize(0);
        inspector.object.resize(0);
    }
    public function notifyObjectSelectedInHierarchy(selectedObject:TObj,selectedUID:Int) : Void {
        clear();
        index = selectedUID;
        rawData = selectedObject;
        inspector.setObject(rawData,index);
        if(rawData.type == "tilemap_object"){
            found.Found.tileeditor.selectTilemap(index);                
        } 
        else{
            found.Found.tileeditor.selectTilemap(-1);
        }             
    }

    public function render(ui:zui.Zui){
        if(selectedPage.text != "Inspector" || Found.fullscreen ){
            inspector.visible = false;
            return;
        }
        else if(!inspector.visible) {
            inspector.visible = true;
        }
        inspector.setAll(x,y,w,h);
        inspector.render(ui);
    }

    @:access(Inspector,found.Scene)
    public function addTrait(trait:TTrait){
        rawData.traits.push(trait);
        Scene.createTraits([trait],currentObject);
        inspector.changed = true;
        EditorHierarchy.makeDirty();
    }

    public function notifySceneSelect(){
        inspector.selectScene();
    }
       
    function browseImage(){
        var done = function(path:String){
            var error = true;
            var sep = Fs.sep;
            if(path != null){
                var name = path.split(sep)[path.split(sep).length-1];
                var type = name.split('.')[1];
                switch(type){
                    case 'png' | 'jpg':
                        if(index != -1 && rawData != null){
                            Reflect.setProperty(rawData,"imagePath",path);
                            cast(State.active._entities[index],found.anim.Sprite).set(cast(rawData));
                            EditorHierarchy.makeDirty();
                        }
                        error = false;
                    default:
                        trace('Error: file has filetype $type which is not a valid filetype for images ');
                }
            }
            if(error){
                trace('Error: file with name $name is not a valid image name or the path "$path" was invalid ');
            }

        }
        FileBrowserDialog.open(done);
    }
    #if found
    public function updateField(uid:Int,id:String,data:Any){
        if(uid > State.active._entities.length-1) return;
        switch(id){
            case "_positions":
                var x = Util.fround(Reflect.getProperty(data,"x"),2);
                var y = Util.fround(Reflect.getProperty(data,"y"),2);
                if(index == uid){
                    rawData.position.x = x;
                    rawData.position.y = y;
                    inspector.redraw();
                }
            case "_rotations":
                var z = Reflect.getProperty(data,"z");
                if(index == uid){
                    rawData.rotation.z = Util.fround(z,2);
                }
            case "_scales":
                var x = Reflect.getProperty(data,"x");
                var y = Reflect.getProperty(data,"y");
                if(index == uid){
                    rawData.scale.x = Util.fround(x,2);
                    rawData.scale.y = Util.fround(y,2);
                }
            case "imagePath":
                var width =Reflect.getProperty(data,"width");
                var height = Reflect.getProperty(data,"height");
                if(index == uid){
                    rawData.width = width;
                    rawData.height = height;
                }

        }
    }
    #else
    public function updateField(uid:Int,id:String,data:Any){
        trace("Implement me");
    }
    #end
}