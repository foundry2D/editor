package;

import found.Found;
import echo.World;
import echo.Body;
import haxe.ui.events.UIEvent;
import found.data.SceneFormat;
import found.math.Util;
import found.object.Object;
import zui.Zui;
import zui.Id;
import zui.Ext;



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

    
    var objectHandle:Handle = Id.handle();
    var sceneHandle:Handle = Id.handle();

    public var searchImage:Void->Void = null;

    public var index(default,set):Int = -1;
    function set_index(value:Int){
        return index = value;
    }
    public var currentObject(get,null):Null<Object>;
    function get_currentObject(){
        if(index == -1)return null;
        return found.State.active._entities[index];
    }

    public function new(px:Int,py:Int,w:Int,h:Int) {
        this.visible = false;
        ui = new Zui({font: kha.Assets.fonts.font_default});
        var base = Id.handle();
        for(i in 0...itemsLength){
            objItemHandles.push(base.nest(i));
        }
        setAll(px,py,w,h);
        objectHandle.nest(0); // Pre create children
        ui.t.FILL_WINDOW_BG = true;
    }
    public function redraw(){
        windowHandle.redraws = 2;
        objectHandle.redraws = 2;
    }
    public function setAll(px:Int,py:Int,w:Int,h:Int){
        x = px;
        y = py;
        width = w;
        height = h;
    }

    public function setObject(objectData:TObj,i:Int) {
        if(object.length > 0 ){
            object.pop();
        }
        object.push(objectData);
        index = i;
        redraw();
    }
    public function selectScene(){
        if(object.length > 0 ){
            object.pop();
        }
        if(scene.length > 0){
            scene.pop();
        }
        scene.push(found.State.active.raw);
        redraw();
    }
    
    @:access(zui.Zui)
    public function render(g:kha.graphics2.Graphics){
        if(!visible)return;
        g.end();

        ui.begin(g);

        if(ui.window(windowHandle, this.x, this.y, this.width, this.height)){
            if( object.length > 0){
                
                var children:Map<Int,Handle> = Reflect.getProperty(objectHandle,"children");
                children.get(0).selected = true; // Make the panel always open
                children.get(0).text =  object[0].name; //Set object name in texInput field
                
                Ext.panelList(ui,objectHandle,object,null,dontDelete,getName,setObjectName,drawObjectItems,true,false);
                                    
            }
            else if(scene.length > 0){
                Ext.panelList(ui,sceneHandle,scene,null,dontDelete,getName,setSceneName,drawSceneItems,true,false);
                var children:Map<Int,Handle> = Reflect.getProperty(sceneHandle,"children");
                children.get(0).selected = true; // Make the panel always open
                children.get(0).text =  scene[0].name; //Set scene name in texInput field
            } 
            
        }

        ui.end();

        g.begin(false);
    }
    @:keep
    function dontDelete(i:Int) {
    }
    function getName(i:Int){
        return "";
    }

    function setSceneName(i:Int,name:String){
        if(name=="")return;
        scene[i].name = name;
    }

    var depthSortText:String = "If active will draw based on depth order";
    var zSortText:String = "If active will zsort instead of Y sort";

    @:access(found.Scene,zui.Zui)
    function drawSceneItems(handle:Handle,i:Int){
        if(i == -1)return;
        var data = scene[i];
        var current = found.State.active;

        var depthSortHandle = Id.handle();
        var zsortHandle = Id.handle();
        var widthHandle = Id.handle();
        var heightHandle = Id.handle();
        var gravityXHandle = Id.handle();
        var gravityYHandle = Id.handle();
        var iterationsHandle = Id.handle();
        var historyHandle = Id.handle();

        if(ui.getHover())
            ui.tooltip(depthSortText);
        depthSortHandle.selected = data._depth != null ? data._depth : false;
        ui.check(depthSortHandle," Depth Sort");
        if(depthSortHandle.changed){
            data._depth = depthSortHandle.selected;
            current._depth = data._depth;
            changed = true;
        }

        if(data._depth){

            if(ui.getHover())
                ui.tooltip(zSortText);
            zsortHandle.selected = data._Zsort != null ? data._Zsort : true;
            ui.check(zsortHandle," Z sort");
            if(zsortHandle.changed){
                data._Zsort = zsortHandle.selected;
                Reflect.setProperty(found.Scene,"zsort",data._Zsort);
                changed = true;
            }
        }

        ui.row([0.5,0.5]);
        
        var text = data.physicsWorld != null ? "-": "+";
        var addPhysWorld = function(state:String){
            if(state == "+"){
                data.physicsWorld = {width: Found.WIDTH,height: Found.HEIGHT,iterations: 5,gravity_y: 50};
                if(found.State.active.physics_world == null)
                    found.State.active.addPhysicsWorld(data.physicsWorld);
                for(object in found.State.active._entities){
                    if(object.body != null){
                        found.State.active.physics_world.add(object.body);
                    }
                }
            }
            else if(state=="-"){
                data.physicsWorld = null;
                found.State.active.physicsUpdate = function(f:Float){};
                found.State.active.physics_world = null;
            }
            changed = true;
        };
        if(ui.panel(Id.handle(),"Physics World: ")){
            if(ui.button(text)){
                addPhysWorld(text);
            }
            if(data.physicsWorld != null){

                widthHandle.value = data.physicsWorld.width;
                var width = Ext.floatInput(ui,widthHandle,"Width:",Align.Right);
                if(widthHandle.changed){
                    data.physicsWorld.width = width;
                    found.State.active.physics_world.width = width;
                    changed = true;
                }

                heightHandle.value = data.physicsWorld.height;
                var height = Ext.floatInput(ui,heightHandle,"Height:",Align.Right);
                if(heightHandle.changed){
                    data.physicsWorld.height = height;
                    found.State.active.physics_world.height = height;
                    changed = true;
                }

                gravityXHandle.value = data.physicsWorld.gravity_x != null ? data.physicsWorld.gravity_x: 0 ;
                var gravityX = Ext.floatInput(ui,gravityXHandle,"Gravity X:",Align.Right);
                if(gravityXHandle.changed){
                    data.physicsWorld.gravity_x = gravityX;
                    found.State.active.physics_world.gravity.x =gravityX;
                    changed = true;
                }
                
                gravityYHandle.value = data.physicsWorld.gravity_y;
                var gravityY = Ext.floatInput(ui,gravityYHandle,"Gravity Y:",Align.Right);
                if(gravityYHandle.changed){
                    data.physicsWorld.gravity_y = gravityY;
                    found.State.active.physics_world.gravity.y =gravityY;
                    changed = true;
                }

                iterationsHandle.value = data.physicsWorld.iterations;
                var iterations = Std.int(ui.slider(iterationsHandle,"No. of iterations",1,20,false,1));
                if(iterationsHandle.changed){
                    data.physicsWorld.iterations = iterations;
                    found.State.active.physics_world.iterations =iterations;
                    changed = true;
                }

                historyHandle.value = data.physicsWorld.history != null ? data.physicsWorld.history: 500;
                var history = Std.int(ui.slider(historyHandle,"History",1,1000,false,1/100));
                if(historyHandle.changed){
                    data.physicsWorld.history = history;
                    found.State.active.physics_world.history = new echo.util.History(history);
                    changed = true;
                }
            }
        }
        else {
            if(ui.button(text)){
                addPhysWorld(text);
            }
        }

        if(changed){
            EditorHierarchy.makeDirty();
        }

    }

    function setObjectName(i:Int,name:String) {
        if(name=="")return;
        object[i].name = name;
    }
    public var objItemHandles:Array<zui.Zui.Handle> = [];
    var changed = false;
    function drawObjectItems(handle:Handle,i:Int){
        if(i == -1)return;
        data = object[i];
        changed = false;
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
        ui.check(activeHandle," active");
        if(activeHandle.changed){
            data.active = activeHandle.selected;
            currentObject.active = data.active;
            currentObject.dataChanged = true;
            changed = true;
        }

        ui.row([0.1,0.45,0.45]);
        ui.text("P");
        xPosHandle.value = Util.fround(data.position.x,2);
        var px = Ext.floatInput(ui,xPosHandle,"X",Align.Right);
        if(xPosHandle.changed){
            data.position.x = Util.fround(px,2);
            currentObject.position.x = data.position.x;
            currentObject.dataChanged = true;
            changed = true;
        }
        yPosHandle.value = Util.fround(data.position.y,2);
        var py = Ext.floatInput(ui,yPosHandle,"Y",Align.Right);
        if(yPosHandle.changed){
            data.position.y = Util.fround(py,2);
            currentObject.position.y = data.position.y;
            currentObject.dataChanged = true;
            changed = true;
        }
        ui.row([0.1,0.99]);
        ui.text("R");
        zRotHandle.value = data.rotation.z;
        var rz = Math.abs(Ext.floatInput(ui,zRotHandle,"",Align.Right));
        if(zRotHandle.changed){
            rz = rz > 360 ? rz-360 : rz;
            data.rotation.z = rz;
            currentObject.rotation.z = data.rotation.z;
            currentObject.dataChanged = true;
            changed = true;
        }
        ui.row([0.1,0.45,0.45]);
        ui.text("S");
        xScaleHandle.value = data.scale != null ? data.scale.x :1.0;
        var sx = Ext.floatInput(ui,xScaleHandle,"X",Align.Right);
        if(xScaleHandle.changed){
            data.scale.x = sx;
            currentObject.scale.x = data.scale.x;
            currentObject.dataChanged = true;
            changed = true;
        }

        yScaleHandle.value = data.scale != null ? data.scale.y :1.0;
        var sy = Ext.floatInput(ui,yScaleHandle,"Y",Align.Right);
        if(yScaleHandle.changed){
            data.scale.y = sy;
            currentObject.scale.y = data.scale.y;
            currentObject.dataChanged = true;
            changed = true;
        }

        depthHandle.value = data.depth;
        var depth = Ext.floatInput(ui,depthHandle,"Depth: ",Align.Right);
        if(depthHandle.changed){
            data.depth = depth;
            currentObject.depth = data.depth;
            currentObject.dataChanged = true;
            changed = true;
        }

        ui.row([0.5,0.5]);
        wHandle.value = data.width;
        var width = Ext.floatInput(ui,wHandle,"Width: ",Align.Right);
        if(wHandle.changed){
            data.width = width;
            currentObject.width = data.width;
            currentObject.dataChanged = true;
            changed = true;
        }

        hHandle.value = data.height;
        var height = Ext.floatInput(ui,hHandle,"Height: ",Align.Right);
        if(hHandle.changed){
            data.height = height;
            currentObject.height = data.height;
            currentObject.dataChanged = true;
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
        
        if(ui.panel(Id.handle(),"Traits: ")){
            ui.indent();
            var traits:Array<TTrait> = data.traits != null ? data.traits : [];
            Ext.panelList(ui,Id.handle(),traits,addTrait,removeTrait,getTraitName,null,drawTrait,false,true,"New Trait");
            data.traits = traits;
            ui.unindent();
        }
        ui.row([0.5,0.5]);
        var text = data.rigidBody != null ? "-": "+";
        var addRigidbody = function(state:String){
            if(state == "+"){
                data.rigidBody = Body.defaults;
                if(currentObject.body == null)
                    currentObject.body = new echo.Body(data.rigidBody);
                if(found.State.active.physics_world != null){
                    found.State.active.physics_world.add(currentObject.body);
                }
                
            }
            else if(state=="-"){
                data.rigidBody = null;
                if(found.State.active.physics_world != null){
                    found.State.active.physics_world.remove(currentObject.body);
                }
                currentObject.body = null;
            }
            currentObject.dataChanged = true;
            changed = true;
        };
        if(ui.panel(Id.handle(),"Rigidbody: ")){
            if(ui.button(text)){
                addRigidbody(text);
            }
            if(data.rigidBody != null){

                kinematicHandle.selected = data.rigidBody.kinematic;
                ui.check(kinematicHandle,"is Kinematic");
                if(kinematicHandle.changed){
                    data.rigidBody.kinematic = kinematicHandle.selected;
                    currentObject.body.kinematic = data.rigidBody.kinematic;
                    currentObject.dataChanged = true;
                    changed = true;
                }

                massHandle.value = data.rigidBody.mass;
                var mass = Ext.floatInput(ui,massHandle,"Mass:",Align.Right);
                if(massHandle.changed){
                    data.rigidBody.mass = mass;
                    currentObject.body.mass = data.rigidBody.mass;
                    currentObject.dataChanged = true;
                    changed = true;
                }

                elasticityHandle.value = data.rigidBody.elasticity;
                var elasticity = Ext.floatInput(ui,elasticityHandle,"Elasticity:",Align.Right);
                if(elasticityHandle.changed){
                    data.rigidBody.elasticity = elasticity;
                    currentObject.body.elasticity = data.rigidBody.elasticity;
                    currentObject.dataChanged = true;
                    changed = true;
                }
                maxXvelHandle.value = data.rigidBody.max_velocity_x;
                var maxVelX = Ext.floatInput(ui,maxXvelHandle,"Max X Velocity:",Align.Right);
                if(maxXvelHandle.changed){
                    data.rigidBody.max_velocity_x =  maxVelX;
                    currentObject.body.max_velocity.x = data.rigidBody.max_velocity_x;
                    currentObject.dataChanged = true;
                    changed = true;
                }
                maxYvelHandle.value = data.rigidBody.max_velocity_x;
                var maxVelY = Ext.floatInput(ui,Id.handle(),"Max Y Velocity:",Align.Right);
                if(maxYvelHandle.changed){
                    data.rigidBody.max_velocity_y =  maxVelY;
                    currentObject.body.max_velocity.y = data.rigidBody.max_velocity_y;
                    currentObject.dataChanged = true;
                    changed = true;
                }
                maxRotVelHandle.value = data.rigidBody.max_rotational_velocity;
                var maxRot = Ext.floatInput(ui,Id.handle(),"Max Rotation Velocity:",Align.Right);
                if(maxRotVelHandle.changed){
                    data.rigidBody.max_rotational_velocity = maxRot;
                    currentObject.body.max_rotational_velocity = data.rigidBody.max_rotational_velocity;
                    currentObject.dataChanged = true;
                    changed = true;
                }
                
                dragXHandle.value = data.rigidBody.drag_x;
                var dragX = Ext.floatInput(ui,Id.handle(),"Drag X:",Align.Right);
                if(dragXHandle.changed){
                    data.rigidBody.drag_x = dragX;
                    currentObject.body.drag.x = data.rigidBody.drag_x;
                    currentObject.dataChanged = true;
                    changed = true;
                }

                dragYHandle.value = data.rigidBody.drag_y;
                var dragY = Ext.floatInput(ui,Id.handle(),"Drag Y:",Align.Right);
                if(dragYHandle.changed){
                    data.rigidBody.drag_y = dragY;
                    currentObject.body.drag.y = data.rigidBody.drag_y;
                    currentObject.dataChanged = true;
                    changed = true;
                }

                gravityScaleHandle.value = data.rigidBody.gravity_scale;
                var gravityScale = Ext.floatInput(ui,gravityScaleHandle,"Gravity Scale:",Align.Right);
                if(gravityScaleHandle.changed){
                    data.rigidBody.gravity_scale = gravityScale;
                    currentObject.body.gravity_scale = data.rigidBody.gravity_scale;
                    currentObject.dataChanged = true;
                    changed = true;
                }
                
            }
        }
        else {
            if(ui.button(text)){
                addRigidbody(text);
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
        //@:TODO the other stuff to update objects in realtime
        currentObject.height = data.height;
        var out = data.traits.splice(i,1);
        if(out[0].type == "Script"){
            var trait = currentObject.getTrait(Type.resolveClass(out[0].class_name));
            if(trait != null)
                currentObject.removeTrait(trait);
        }
        currentObject.dataChanged = true;
        changed = true;
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