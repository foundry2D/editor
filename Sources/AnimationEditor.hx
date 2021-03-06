package;


import found.App;
import kha.FastFloat;
import found.math.Vec2;
import found.math.Util;
import found.data.SceneFormat;
import found.anim.Animation;

import zui.Id;
import zui.Zui;
import zui.Ext;

@:access(zui.Zui)
class AnimationEditor {
        var ui: Zui;

        public static var width:Int;
        public static var height:Int;
        public static var x:Int;
        public static var y:Int;
        static var timeline:kha.Image = null;
        static var dot:kha.Image = null;
        var curSprite:found.anim.Sprite;
        public var selectedUID(default,set):Int = -1;
        var windowHandle:zui.Zui.Handle = Id.handle();
        var timelineHandle:zui.Zui.Handle = Id.handle();
        var parent:EditorPanel;
        var ownerTab:Tab;
        public function new(panel:EditorPanel,animTab:Tab) {
            parent = panel;
            ownerTab = animTab;
            setAll(parent.x,parent.y,parent.w,parent.h);
            parent.windowHandle.scrollEnabled = true;
            panel.postRenders.push(renderTimeline);
        }
    
        public function setAll(px:Int,py:Int,w:Int,h:Int){
            x = px;
            y = py;
            width = w;
            height = h;
        }

        var oldUid = -1;
        @:access(found.anim.Sprite,found.anim.Animation)
        function set_selectedUID(value:Int):Int{
            var oldUid = selectedUID;
            if(value < 0 || value > found.State.active._entities.length){
                selectedUID = -1;
            }
            else{
                var object = found.State.active._entities[value];
                if(object.raw.type == "sprite_object"){
                    curSprite = cast(object);
                    selectedUID = value;
                    curFrames = curSprite.data.animation._frames;
                    animations.resize(0);
                    for(anim in curSprite.data.raw.anims)
                    {
                        animations.push(anim.name);
                    }
                    animIndex = curSprite.data.curAnim;
                }
                else {
                    selectedUID = -1;
                    if(curSprite != null){
                        curFrames = curSprite.data.animation._frames.copy();
                        lastImage = "";
                        curSprite = null;
                        animIndex = -1;
                    }
                    curFrames.resize(0);
                    animations.resize(0);
                }
            }
            if(oldUid != selectedUID){
                timelineHandle.redraws = windowHandle.redraws = 2;
                oldUid = selectedUID;
            }
            return selectedUID;
        }

        var delta = 0.0;
        var lastImage:String = "";
        var doUpdate:Bool = false;
        var numberOfFrames:Float = 67.0;
        var animAction:Array<Float> = [];
        var curFrames(default,set):Array<TFrame> = [];
        function set_curFrames(data:Array<TFrame>){
            if(curFrames.length != data.length || oldUid != selectedUID){
                frameHandles = [];
                for(frame in data){
                    var handles = [];
                    for(i in 0...5){
                        handles.push(new zui.Zui.Handle({value:0}));
                    }
      
                    frameHandles.push(handles);
                }
            }
            return curFrames = data; 
        }
        var animations:Array<String> = [];
        var animIndex:Int  = -1;
        var animHandle:zui.Zui.Handle = new zui.Zui.Handle();
        var fpsHandle:zui.Zui.Handle =  new zui.Zui.Handle();
        var viewHeight:Int = 0;
        var renameState:Bool = false;
        @:access(found.anim.Sprite,found.data.SpriteData,found.anim.Animation,EditorUi)
        public function render(ui:zui.Zui){

            this.ui = ui;
            var sc = ui.SCALE();
            var timelineLabelsHeight = Std.int(30 * sc);
            var timelineFramesHeight = Std.int(40 * sc);

            if(timeline==null || timeline.height != timelineLabelsHeight + timelineFramesHeight){
                drawTimeline(timelineLabelsHeight, timelineFramesHeight);
                drawDot();
            }

            numberOfFrames = timeline.width / (11 * sc)-1;

            if(curSprite != null && lastImage != curSprite.data.raw.imagePath){
                lastImage = curSprite.data.raw.imagePath; 
                if(curSprite.data.raw.anims.length > 0 && curSprite.data.raw.anims.length != animations.length ){
                    for(anim in curSprite.data.raw.anims){
                        animations.push(anim.name);
                    }
                    animIndex = curSprite.data.curAnim;
                    curFrames = curSprite.data.animation._frames;
                }
                else if(curSprite.data.raw.anims.length == 0) {
                    // curFrames.resize(0);
                    animations.resize(0);
                }
                 
                timelineHandle.redraws = windowHandle.redraws = 2;//redraw
            }
            viewHeight = AnimationEditor.height - timeline.height;
            if(ui.tab(parent.htab,ownerTab.name)){
                ui.row([0.40,0.15,0.15,0.15,0.15]);
                animHandle.position = animIndex;
                if(animations.length  > 0){
                    if(!renameState){
                        animIndex = ui.combo(animHandle,animations);
                        if(animHandle.changed){
                            timelineHandle.redraws = 2;
                        }
                    }
                    else{
                        var last:kha.Color = ui.t.ACCENT_COL;
                        ui.t.ACCENT_COL = kha.Color.fromFloats(1.0,0.0,0.0,0.7); 
                        var txtHandle = Id.handle();
                        if(animIndex < 0)
                            error('animIndex is bad at number: $animIndex');
                        txtHandle.text = animations[animIndex];
                        ui.textInput(txtHandle);
                        if(txtHandle.changed){
                            animations[animIndex] = txtHandle.text;
                            curSprite.data.anims[animIndex].name = txtHandle.text;
                            renameState = false;
                        }
                        ui.t.ACCENT_COL = last;
                    }
                }

                if(curSprite != null && animHandle.changed){
                    curSprite.data.curAnim = animIndex;
                    curFrames = curSprite.data.animation._frames;

                }
                if(ui.button(tr("Rename"))){
                    renameState = !renameState;
                }
                if(ui.button(tr("New Animation")) && curSprite != null){
                    var id = animations.length;
                    animIndex = animations.push('Animation $id')-1;
                    if(animIndex == 0){
                        var frame:TFrame = {id:0,start:0.0,tw:Std.int(curSprite.data.raw.width),th:Std.int(curSprite.data.raw.height)};
                        curSprite.data.animation.take(Animation.create(frame));
                        curFrames = curSprite.data.animation._frames;

                    }
                    else {
                        curSprite.data.curAnim = curSprite.data.addSubSprite(0);
                        curFrames = curSprite.data.animation._frames;
                    }
                    for(frame in curFrames){
                        var handles = [];
                        for(i in 0...5){
                            handles.push(new zui.Zui.Handle({value:0}));
                        }
                        frameHandles.push(handles);
                    }
                    curSprite.data.animation.name = animations[animIndex];
                    timelineHandle.redraws = 2;
                }

                if(ui.button(tr("Delete Animation")) && animations.length > 0){
                    animations.splice(animIndex,1);
                    curSprite.data.anims.splice(animIndex,1);
                }

                if(ui.button("Save Animations") && curSprite != null){
                    saveAnimations(true);
                    #if editor
                    EditorHierarchy.getInstance().makeDirty();
                    App.editorui.saveSceneData();
                    #end
                }

                if(animIndex > -1 && animations.length > 0){
                    var editable = true;
                    fpsHandle.text = ""+curSprite.data.animation._speeddiv;
                    ui.textInput(fpsHandle,"Fps",Align.Left,editable);
                    if(fpsHandle.changed){
                        curSprite.data.animation._speeddiv = Std.parseInt(fpsHandle.text);
                    }
                }
                ui.row([0.5,0.5]);
                if(delta > numberOfFrames){
                    delta = numberOfFrames;
                    doUpdate = false;
                }
                var state:String = doUpdate ? "Pause": "Play";
                if(ui.button(state)){
                    if(doUpdate){
                        doUpdate = false;
                    }
                    else if (delta >= numberOfFrames) {
                        delta = 0.0;
                        doUpdate = true;
                    }
                    else {
                        doUpdate = true;
                    }
                }
                if(ui.button("Reset")){
                    delta = 0.0;
                    doUpdate = false;
                    timelineHandle.redraws = 2;
                }
                var div = (ui.ELEMENT_W()/parent.w) * 2;
                ui.row([1.0- div,div]);

                ui.panel(Id.handle({selected: true}),'',false,false,false);
                var oldY = ui._y;
                if(animations.length == 0){
                    ui.text("");
                }
                else {
                    Ext.panelList(ui,Id.handle({selected: true,layout:0}),curFrames,addItem,removeItem,getName,setName,drawItem,false);
                }
                animationPreview(delta,AnimationEditor.width,viewHeight,oldY);

            }

            
            
        }
        @:access(found.anim.Sprite,found.anim.Animation)
        function renderTimeline(ui:zui.Zui){
            if(!ownerTab.active)return;
            var sc = ui.SCALE();
            var timelineLabelsHeight = Std.int(30 * sc);
            var timelineFramesHeight = Std.int(40 * sc);
            if(ui.window(timelineHandle,AnimationEditor.x, AnimationEditor.y+viewHeight,AnimationEditor.width, timeline.height)){
                
                ui.imageScrollAlign =false;// This makes its so that we can cheat the image drawing to draw well to make it easier to have valid input
                var state = ui.image(timeline);
                

                if(state == zui.Zui.State.Down ) {
                    var fid = Math.floor(Math.abs(ui._windowX-ui.inputX) / 11 / ui.SCALE());
                    curSprite.data.animation.setIndex(fid);
                    delta = fid;
                }
                //Select Frame
                ui.g.color = 0xff205d9c;
                ui.g.fillRect(delta*11*sc,timelineLabelsHeight, 10 * sc, timelineFramesHeight);

                // Show selected frame number
                ui.g.font = kha.Assets.fonts.font_default;
                ui.g.fontSize = Std.int(16 * sc);

                var frameIndicatorMargin = 4 * sc;
                var frameIndicatorPadding = 4 * sc;
                var frameIndicatorWidth = 30 * sc;
                var frameIndicatorHeight = timelineLabelsHeight - frameIndicatorMargin * 2;

                var frameTextWidth = kha.Assets.fonts.font_default.width(ui.g.fontSize, "" + 99.00 );
                
                // Scale the indicator if the contained text is too long
                if (frameTextWidth > frameIndicatorWidth + frameIndicatorPadding) {
                    frameIndicatorWidth = frameTextWidth + frameIndicatorPadding;
                }
                ui.g.fillRect(delta * 11 * sc + 5 * sc - frameIndicatorWidth / 2,frameIndicatorMargin, frameIndicatorWidth, frameIndicatorHeight);
                ui.g.color = 0xffffffff;
                ui.g.drawString("" + Util.fround(delta,2), delta * 11 * sc + 5 * sc - frameTextWidth / 2,timelineLabelsHeight / 2 - ui.g.fontSize / 2);

                ui.g.color = kha.Color.fromBytes(255,100,100,255);
                var old = new Vec2(ui._x,ui._y);
                for(frame in curFrames){
                    var frameWidth = 10 * sc;
                    ui._x = frame.start * 11 * sc;
                    ui._y = timelineLabelsHeight*0.5 + timelineFramesHeight*0.5+frameWidth*0.75;
                    var state = ui.image(dot,0xffffffff,frameWidth,0,0,Std.int(frameWidth),Std.int(frameWidth));
                    ui._x = frame.start * 11 * sc;
                    ui._y = timelineLabelsHeight*0.5 + timelineFramesHeight*0.5 + frameWidth*0.75;
                    if(ui.getHover()){
                        ui.tooltip("Frame: " + frame.id);
                    }
                    
                    // ui.g.drawString(, frame.start * 11 * sc + 5 * sc - frameTextWidth / 2 +frameWidth* 0.25,timeline.height*0.5+frameWidth*0.5);
                }
                ui._x = old.x;
                ui._y = old.y;
                ui.imageScrollAlign =true;
            }
        }
        @:access(found.anim.Sprite,found.anim.Animation)
        function addItem(name:String){
            if(animIndex < 0) return;
            for(frame in  curFrames){
                if(frame.start == delta){
                    //@TODO: Implement warning popup in zui or in editor
                    return;
                }
            }

            var frame:TFrame =  {id:0,start:delta,tw:Std.int(curSprite.data.raw.width),th:Std.int(curSprite.data.raw.height)};
            var id = curFrames.push(frame)-1; // @:TODO: We seem to add the frames back when we reload( I.e. doubling the frames we should investigate here)
            var handles = [];
            for(i in 0...5){
                handles.push(new zui.Zui.Handle({value:0}));
            }

            frameHandles.push(handles);
            frame.id = id;

            if( curFrames.length > 1){
                var firstFrame = curFrames[0];
                curSprite.data.animation._speeddiv = Std.int(Math.abs(firstFrame.start-frame.start)*10);
            }

            timelineHandle.redraws = 2;
        }
        function removeItem(i:Int){
            curFrames.splice(i,1);
            for( index in 0...curFrames.length){
                if(curFrames[index].id != index){
                    curFrames[index].id = index;
                }
            }
            frameHandles.splice(i,1);
            timelineHandle.redraws = 2;
        }
        function getName(i:Int){
            return "Index : "+curFrames[i].id;
        }
        function setName(i:Int,name:String){
            return;
        }
        var frameHandles:Array<Array<zui.Zui.Handle>> = [];
        function drawItem(handle:Handle,i:Int){
            if(frameHandles.length == 0)return;
            var cur:TFrame = curFrames[i];
            
            var startHandle = frameHandles[i][0];
            var xHandle = frameHandles[i][1];
            var yHandle = frameHandles[i][2];
            var wHandle = frameHandles[i][3];
            var hHandle = frameHandles[i][4];

            startHandle.value = cur.start;
            cur.start = Std.int(Ext.floatInput(ui,startHandle,"Start"));

            xHandle.value = cur.tx != null ? cur.tx :0;
            cur.tx = Std.int(Ext.floatInput(ui,xHandle,"Tile X"));

            yHandle.value = cur.ty != null ? cur.ty :0;
            cur.ty = Std.int(Ext.floatInput(ui,yHandle,"Tile Y"));

            wHandle.value = cur.tw;
            cur.tw = Std.int(Ext.floatInput(ui,wHandle,"Tile Width"));

            hHandle.value = cur.th;
            cur.th = Std.int(Ext.floatInput(ui,hHandle,"Tile Height"));

        }
        @:access(found.anim.Sprite,found.data.SpriteData,found.anim.Animation)
        public function update(dt:Float) {
            if(!ownerTab.active)return;

            if(doUpdate && curSprite != null){
                curSprite.animate();
                var currentCount = curSprite.data.animation._speeddiv - (curSprite.data.animation._count % curSprite.data.animation._speeddiv); 
                delta = currentCount/curSprite.data.animation._speeddiv;
                timelineHandle.redraws = windowHandle.redraws = 1;//redraw
            }
        }
        var canvas:kha.Image;
        var origDimensions:Vec2 = new Vec2();
        var oldRotation:FastFloat = 0.0;
        @:access(found.anim.Sprite,found.data.SpriteData,found.anim.Animation)
        function animationPreview(delta:Float,width:Int,height:Int,oldY:Float){

            var size = (width > height ? width:height)*0.25;
            var rx = width*0.5 - size * 0.5;
            
            if(canvas == null){
                canvas = kha.Image.createRenderTarget(Std.int(width*0.25),Std.int(height*0.25));
            }

            if(selectedUID > 0){
                var scale = 1.0;
                if(width > height){
                    scale = curSprite.width > width*0.25 ? width*0.125/curSprite.width:1.0;
                }
                else{
                    scale = curSprite.height > height*0.25 ? height*0.125/curSprite.height:1.0;
                }
                origDimensions.x = curSprite.scale.x;
                origDimensions.y = curSprite.scale.y;
                oldRotation = curSprite.rotation.z;
                curSprite.rotation.z = 0.0;
                curSprite.scale.x = scale;
                curSprite.scale.y = scale;
                canvas.g2.pushTranslation(rx+size*0.25,oldY+size*0.25);
                if(!doUpdate){
                    curSprite.data.animation._count = 0;
                }
                curSprite.render(canvas);
                if( doUpdate && curSprite.data.animation._index == 0){
                    this.delta = 0.0;
                    timelineHandle.redraws = 2;
                }
                canvas.g2.popTransformation();

                curSprite.scale.x = origDimensions.x;
                curSprite.scale.y = origDimensions.y;
                curSprite.rotation.z = oldRotation;
            }

            ui.image(canvas,0xffffffff,size,Std.int(rx),Std.int(oldY));
            ui.g.drawRect(rx,oldY,size,size);
            
        }
        function onResize(width:Int,height:Int){
            canvas = kha.Image.createRenderTarget(Std.int(width*0.25),Std.int(height*0.25));
            canvas.g2.clear(kha.Color.Transparent);
        }
        function drawDot(){
            var frameWidth = Std.int(10 * ui.SCALE());
            dot = kha.Image.createRenderTarget(frameWidth, frameWidth);
            var g = dot.g2;
            ui.g.end();
            g.begin(true,kha.Color.Transparent);
            g.color = kha.Color.fromString("#FFE8432E");
            g.fillTriangle(0,frameWidth,frameWidth*0.5,0,frameWidth,frameWidth);
            g.end();
            ui.g.begin(false);
        }
        function drawTimeline(timelineLabelsHeight:Int, timelineFramesHeight:Int) {
            var sc = ui.SCALE();
    
            var timelineHeight = timelineLabelsHeight + timelineFramesHeight;
    
            timeline = kha.Image.createRenderTarget(AnimationEditor.width, timelineHeight);
    
            var g = timeline.g2;
            ui.g.end();
            g.begin(true, ui.t.ACCENT_COL - 1118481 * 2);
            g.font = kha.Assets.fonts.font_default;
            g.fontSize = Std.int(16 * sc);
    
            // Labels
            var frames = Std.int(timeline.width / (11 * sc));
            for (i in 0...Std.int(frames / 5) + 1) {
                var frame = i * 5;
    
                var frameTextWidth = kha.Assets.fonts.font_default.width(g.fontSize, frame + "");
                g.drawString(frame + "", i * 55 * sc + 5 * sc - frameTextWidth / 2, timelineLabelsHeight / 2 - g.fontSize / 2);
            }
    
            // Frames
            for (i in 0...frames) {
                g.color = i % 5 == 0 ? ui.t.ACCENT_COL : ui.t.ACCENT_COL - 1118481;
                g.fillRect(i * 11 * sc, timelineHeight - timelineFramesHeight, 10 * sc, timelineFramesHeight);
            }
    
            g.end();
            ui.g.begin(false);
        }

        @:access(found.anim.Sprite,found.data.SpriteData,found.anim.Animation,EditorUi)
        public function saveAnimations(saveScene:Bool = false){
            if(curSprite == null)return;
            var animations:Array<TAnimation> = [];
            for(anim in curSprite.data.anims){
                var isWholeImage = anim._frames.length == 1 && anim._frames[0].tw == curSprite.data.image.width && anim._frames[0].th == curSprite.data.image.height;   
                if(!isWholeImage){
                    var out:TAnimation = {name: anim.name,frames: anim._frames,fps: anim._speeddiv,time:0.0};
                    for( frame in out.frames){
                        if(out.time < frame.start) out.time = frame.start;
                    }
                    animations.push(out);
                    curSprite.dataChanged = true;
                }
            }

            curSprite.data.raw.anims = animations;
            if(saveScene)
                App.editorui.saveSceneData();
        }
}