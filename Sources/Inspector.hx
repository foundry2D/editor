package;

import echo.Body;
import haxe.ui.events.UIEvent;
import found.data.SceneFormat;
import zui.Zui;
import zui.Id;
import zui.Ext;

enum abstract Handles(Int) from Int to Int {
    var active;
    var xPos;
    var yPos;
    var zRot;
    var xScale;
    var yScale;
    var depth;
    var width;
    var height;
    var imagePath;
}

class Inspector
{
    var ui: Zui;
    public var visible:Bool;
    public var width:Int;
    public var height:Int;
    public var x:Int;
    public var y:Int;
    var windowHandle:zui.Zui.Handle = Id.handle();
    var object:Array<TObj> = [];
    var scene:Array<TSceneFormat> = [];
    var itemsLength:Int = 10;
    var data:TObj = null;
    public var searchImage:Void->Void = null;
    public function new(px:Int,py:Int,w:Int,h:Int) {
        this.visible = false;
        ui = new Zui({font: kha.Assets.fonts.font_default});
        var base = Id.handle();
        for(i in 0...itemsLength){
            objItemHandles.push(base.nest(i));
        }
        setAll(px,py,w,h);
    }
    public function redraw(){
        windowHandle.redraws = 2;
    }
    public function setAll(px:Int,py:Int,w:Int,h:Int){
        x = px;
        y = py;
        width = w;
        height = h;
    }

    public function setObject(objectData:TObj) {
        if(object.length > 0 ){
            object.pop();
        }
        object.push(objectData);
        redraw();
    }

    var objectHandle:Handle = Id.handle();

    
    public function render(g:kha.graphics2.Graphics){
        if(!visible)return;
        g.end();

        ui.begin(g);

        if(ui.window(windowHandle, this.x, this.y, this.width, this.height)){
            if( object.length > 0){ 
                Ext.panelList(ui,objectHandle,object,null,dontDelete,getObjectName,setObjectName,drawObjectItems,true,false);
                var children:Map<Int,Handle> = Reflect.getProperty(objectHandle,"children");
                children.get(0).selected = true; // Make the panel always open
            }
            else if(scene.length > 0){

            } 
            
        }

        ui.end();

        g.begin(false);
    }
    @:keep
    function dontDelete(i:Int) {

    }
    function getObjectName(i:Int){
        return object[i].name;
    }
    function setObjectName(i:Int,name:String) {
        if(name=="")return;
        object[i].name = name;
    }
    public var objItemHandles:Array<zui.Zui.Handle> = [];
    function drawObjectItems(handle:Handle,i:Int){
        data = object[i];
        var changed = false;
        ui.text(data.type);

        var activeHandle = objItemHandles[0];
        var xPosHandle = objItemHandles[1];
        var yPosHandle = objItemHandles[2];
        var zRotHandle = objItemHandles[3];
        var xScaleHandle = objItemHandles[4];
        var yScaleHandle = objItemHandles[5];
        var depthHandle = objItemHandles[6];
        var wHandle = objItemHandles[7];
        var hHandle = objItemHandles[8];
        var imagePathHandle = objItemHandles[9];

        var kinematicHandle = Id.handle();
        var massHandle = Id.handle();
        var elasticityHandle = Id.handle();
        var maxXvelHandle = Id.handle();
        var maxYvelHandle = Id.handle();
        var maxRotVelHandle = Id.handle();
        var dragXHandle = Id.handle();
        var dragYHandle = Id.handle();
        var gravityScaleHandle = Id.handle();

        activeHandle.selected = data.active;
        ui.check(activeHandle,"active: ");
        if(activeHandle.changed){
            data.active = activeHandle.selected;
            changed = true;
        }

        ui.row([0.1,0.45,0.45]);
        ui.text("P");
        xPosHandle.value = data.position.x;
        var px = Ext.floatInput(ui,xPosHandle,"X",Align.Right);
        if(xPosHandle.changed){
            data.position.x = px;
            changed = true;
        }
        yPosHandle.value = data.position.y;
        var py = Ext.floatInput(ui,yPosHandle,"Y",Align.Right);
        if(yPosHandle.changed){
            data.position.y = py;
            changed = true;
        }
        ui.row([0.1,0.99]);
        ui.text("R");
        zRotHandle.value = data.rotation.z;
        var rz = Math.abs(Ext.floatInput(ui,zRotHandle,"",Align.Right));
        if(zRotHandle.changed){
            rz = rz > 360 ? rz-360 : rz;
            data.rotation.z = rz;
            changed = true;
        }
        ui.row([0.1,0.45,0.45]);
        ui.text("S");
        xScaleHandle.value = data.scale != null ? data.scale.x :1.0;
        var sx = Ext.floatInput(ui,xScaleHandle,"X",Align.Right);
        if(xScaleHandle.changed){
            data.scale.x = sx;
            changed = true;
        }

        yScaleHandle.value = data.scale != null ? data.scale.y :1.0;
        var sy = Ext.floatInput(ui,yScaleHandle,"Y",Align.Right);
        if(yScaleHandle.changed){
            data.scale.y = sy;
            changed = true;
        }

        depthHandle.value = data.depth;
        var depth = Ext.floatInput(ui,depthHandle,"Depth: ",Align.Right);
        if(depthHandle.changed){
            data.depth = depth;
            changed = true;
        }

        ui.row([0.5,0.5]);
        wHandle.value = data.width;
        var width = Ext.floatInput(ui,wHandle,"Width: ",Align.Right);
        if(wHandle.changed){
            data.width = width;
            changed = true;
        }

        hHandle.value = data.height;
        var height = Ext.floatInput(ui,hHandle,"Height: ",Align.Right);
        if(hHandle.changed){
            data.height = height;
            changed = true;
        }

        if(Reflect.hasField(data,"imagePath")){
            var sprite:TSpriteData = cast(data);
            ui.row([0.75,0.25]);
            imagePathHandle.text = sprite.imagePath;
            var path = ui.textInput(imagePathHandle,"Image:",Align.Right);
            if(imagePathHandle.changed){
                sprite.imagePath = path;
                changed = true;
            }
            if(ui.button("Browse")){
                //Implement popup in zui
                if(searchImage != null)
                    searchImage();
            }
        }
        
        if(ui.panel(Id.handle(),"Trait: ")){
            ui.indent();
            if(data.traits != null){
                Ext.panelList(ui,Id.handle(),data.traits,addTrait,removeTrait,getTraitName,null,drawTrait,false,true,"New Trait");
            }
            ui.unindent();
        }
        ui.row([0.5,0.5]);
        if(ui.panel(Id.handle(),"Rigidbody: ")){
            if(data.rigidBody != null){

                kinematicHandle.selected = data.rigidBody.kinematic;
                ui.check(kinematicHandle,"is Kinematic");
                if(kinematicHandle.changed){
                    data.rigidBody.kinematic = kinematicHandle.selected;
                }

                massHandle.value = data.rigidBody.mass;
                var mass = Ext.floatInput(ui,massHandle,"Mass:",Align.Right);
                if(massHandle.changed){
                    data.rigidBody.mass = mass;
                }

                elasticityHandle.value = data.rigidBody.elasticity;
                var elasticity = Ext.floatInput(ui,elasticityHandle,"Elasticity:",Align.Right);
                if(elasticityHandle.changed){
                    data.rigidBody.elasticity = elasticity;
                }
                maxXvelHandle.value = data.rigidBody.max_velocity_x;
                var maxVelX = Ext.floatInput(ui,maxXvelHandle,"Max X Velocity:",Align.Right);
                if(maxXvelHandle.changed){
                    data.rigidBody.max_velocity_x =  maxVelX;
                }
                maxYvelHandle.value = data.rigidBody.max_velocity_x;
                var maxVelY = Ext.floatInput(ui,Id.handle(),"Max Y Velocity:",Align.Right);
                if(maxYvelHandle.changed){
                    data.rigidBody.max_velocity_y =  maxVelY;
                }
                maxRotVelHandle.value = data.rigidBody.max_rotational_velocity;
                var maxRot = Ext.floatInput(ui,Id.handle(),"Max Rotation Velocity:",Align.Right);
                if(maxRotVelHandle.changed){
                    data.rigidBody.max_rotational_velocity = maxRot;
                }
                
                dragXHandle.value = data.rigidBody.drag_x;
                var dragX = Ext.floatInput(ui,Id.handle(),"Drag X:",Align.Right);
                if(dragXHandle.changed){
                    data.rigidBody.drag_x = dragX;
                }

                dragYHandle.value = data.rigidBody.drag_y;
                var dragY = Ext.floatInput(ui,Id.handle(),"Drag Y:",Align.Right);
                if(dragYHandle.changed){
                    data.rigidBody.drag_y = dragY;
                }

                gravityScaleHandle.value = data.rigidBody.gravity_scale;
                var gravityScale = Ext.floatInput(ui,gravityScaleHandle,"Gravity Scale:",Align.Right);
                if(gravityScaleHandle.changed){
                    data.rigidBody.gravity_scale = gravityScale;
                }
                
            }
            var text = data.rigidBody != null ? "-": "+";
            if(ui.button(text)){
                if(text == "+"){
                    data.rigidBody = Body.defaults;
                }
                if(text=="-"){
                    data.rigidBody = null;
                }
            }
        }

        if(changed){
            EditorHierarchy.makeDirty();
        }

    }
    function drawTrait(handle:Handle,i:Int){
        var trait = data.traits[i];
        if(trait != null){
            ui.text(trait.class_name);
        }
    }
    function addTrait(name:String){
        TraitsDialog.open(new UIEvent(UIEvent.CHANGE));
    }
    function removeTrait(i:Int){
        //@:TODO the other stuff
        data.traits.splice(i,1);
        EditorHierarchy.makeDirty();
    }
    function getTraitName(i:Int){
        var trait = data.traits[i];
        var name = "";
        if(trait.type == "VisualScript"){
            var t:Array<String> = trait.class_name.split("/");
            name = t[t.length-1].split('.')[0];
        } else {
            var t:Array<String> = trait.class_name.split(".");
            name = t[t.length-1];
        }
        return name;
    }
}