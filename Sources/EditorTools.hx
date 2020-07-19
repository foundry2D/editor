package;

import kha.math.Vector2;
import found.Found;
import haxe.ui.core.Component;
import haxe.ui.events.MouseEvent;
import kha.graphics2.Graphics;

import utilities.Conversion;

class EditorTools {
    static public var arrows:Container;
    static public var vArrow:Arrow;
    static public var hArrow:Arrow;
    static public var rect:Arrow;
    static var position:Vector2 = new Vector2();
    public function new(editor:EditorView){
        arrows = new Container();
        vArrow = new Arrow(1);
        hArrow = new Arrow(0);
        rect = new Arrow(2);

        editor.addComponent(arrows);
        editor.addComponent(vArrow);
        editor.addComponent(hArrow);
        editor.addComponent(rect);
    }
    static public function render(g:Graphics,p_x:Float,p_y:Float,w:Float,h:Float){
        var x = p_x;
        var y = p_y;
        position.x = x-found.State.active.cam.position.x;
        position.y = y-found.State.active.cam.position.y;
        // arrows.left = x;//(arrows.left)/Found.WIDTH*Math.ceil(w)+Math.floor(p_x);
        // arrows.top = ;//(arrows.top)/Found.HEIGHT*Math.ceil(h)+Math.floor(p_y);
        vArrow.render2Scene(g,x,y);
        hArrow.render2Scene(g,x,y);
        rect.render2Scene(g,x,y);
    }
    static public function drawGrid(g:Graphics){
        if(!Found.drawGrid)return;
        var size:Int = found.Found.GRID;
        var str = 3.0;
        var x = found.State.active.cam.position.x;
        x += (Found.GRID-(x % Found.GRID));
        x += -Found.GRID*2;
        var y = found.State.active.cam.position.y;
        y += (Found.GRID-(y % Found.GRID));
        y += -Found.GRID*2;
        var width = Math.abs(x)+Found.WIDTH+Found.GRID*2;
        var height = Math.abs(y)+Found.HEIGHT+Found.GRID*2;
        g.color = 0xff282828;
        while(x < width){
            g.drawRect(x,y,size,size,str);
            x+=size;
            if(g.color == 0xff282828){
                g.color = 0xff323232;
            } else{
                g.color = 0xff282828;
            }
            if(x >= width && y < height){
                y+=size;
                x = found.State.active.cam.position.x;
                x += (Found.GRID-(x % Found.GRID));
                x += -Found.GRID*2;
            }
        }
        g.color = kha.Color.White;
    }
}
class Container  extends Component{
    public function new(){
        super();
    }
    public override function renderTo(g:Graphics){
        
        g.color = kha.Color.fromBytes(128,128,128,64);
        g.fillRect(left,top,this.componentWidth,this.componentHeight);
        // for(comp in childComponents){
        //     comp.renderTo(g);
        // }
        g.color = kha.Color.White;
    }
    
} 
class Arrow extends Component{
    var type:Int =0;// 0 = right 1 = up
    public var x:Float = 0;
    public var y:Float =0;
    public var size:Float= 8.0;
    public function new(?type:Int){
        super();
        this.type = type;
        this.componentWidth = type==2 ? size*1.5: size*2;
        this.componentHeight = type==2 ? size*1.5:size*2;
        this.registerEvent(MouseEvent.MOUSE_DOWN,activate);
    }
    function activate(e:MouseEvent){
        if(found.App.editorui.inspector.index < 0 || found.App.editorui.gameView.selectedPage.text != "Game" || found.App.editorui.inspector.index == found.State.active.cam.uid)return;
        EditorUi.arrow = type;
        switch(type){
            case 0:
                EditorUi.minusX = size*5;
            case 1:
                EditorUi.minusY = -size*5;
            case 2:
                EditorUi.minusX = 0;
                EditorUi.minusY = 0;
        }
        trace('Clicked an Arrow with type: $type with click'+e.type);
    }

    public function set(x:Float,y:Float,?size:Float=8.0){
        var w = size*5;
		var h = w;
        this.x = x;
        this.y = y;
        this.left = x;
        this.top = y;
        this.size = size;
        
    }
    public function render2Scene(g:Graphics,x:Float,y:Float){
        if(found.App.editorui.inspector.index < 0)return;
        var w = size*10;
		var h = w;
        if(type == 0){
            //Horizontal Line
			g.color = kha.Color.Green;
			g.fillRect(x,y,w,2.0);
            if(EditorUi.arrowMode == 0){
			    g.fillTriangle(x+w,y+size,x+w,y-size,x+w+size*2,y);
            }
            else {
                g.fillRect(x+w,y+size,size*2,-size*2);
            }
        }
        else if( type == 2){
            g.color = kha.Color.Yellow;
            g.fillRect(x,y,size*2,-size*2);
        }
        else{
			//Vertical Line
			g.color = kha.Color.Red;
			g.fillRect(x,y-h,2.0,h);
            if(EditorUi.arrowMode == 0){
                g.fillTriangle(x+size,y-h,x-size,y-h,x,y-h-size*2);
            } 
            else{
                g.fillRect(x-size,y-h,size*2,-size*2);
            }
			
        }
    }
    @:access(EditorTools)
    //Debug render and set ui collision
    public override function renderTo(g:Graphics){
        if(found.App.editorui.inspector.index < 0 || found.App.editorui.gameView.selectedPage.text != "Game" || found.App.editorui.inspector.index == found.State.active.cam.uid)return;
        var pos = Conversion.WorldToScreen(cast(EditorTools.position));
        var x = pos.x;
        var y = pos.y;
        var w = size*5;
		var h = w;
        
        if(type ==1){
            this.set(x-this.componentWidth*0.5,y-this.componentHeight*0.5-size*4);
            #if debug_editor
            g.color = kha.Color.fromBytes(255,128,128,128);
            g.fillRect(this.left,this.top,this.componentWidth,this.componentHeight);
            #end
        }
        else if(type == 0){
            this.set(x+size*5,y-this.componentHeight*0.5);
            #if debug_editor
            g.color = kha.Color.fromBytes(128,255,128,128);
            g.fillRect(this.left,this.top,this.componentWidth,this.componentHeight);
            #end
        }
        else if(type == 2){
            this.set(x,y-this.componentHeight);
            #if debug_editor
            //Rect
            g.color = kha.Color.Yellow;
            g.fillRect(this.left,this.top,this.componentWidth,this.componentHeight);
            #end
        }
        
    }
}