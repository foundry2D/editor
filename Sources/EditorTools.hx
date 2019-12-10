package;

import coin.Coin;
import haxe.ui.core.Component;
import haxe.ui.core.Screen;
import haxe.ui.events.MouseEvent;
import kha.graphics2.Graphics;

class EditorTools {
    static public var arrows:Container;
    static public var vArrow:Arrow;
    static public var hArrow:Arrow;
    static public var rect:Arrow;
    public function new(editor:EditorView){
        arrows = new Container();
        vArrow = new Arrow(1);
        hArrow = new Arrow(0);
        rect = new Arrow(2);

        editor.addComponent(arrows);
        editor.addComponent(vArrow);
        editor.addComponent(hArrow);
        editor.addComponent(rect);
        // arrows.addComponent(vArrow);
        // arrows.addComponent(hArrow);
        // arrows.set(vArrow.size*5,vArrow.size*5);
    }
    static public function render(g:Graphics,p_x:Float,p_y:Float,w:Float,h:Float){
        var x = arrows.left;
        var y = arrows.top; 
        arrows.left = (arrows.left)/Coin.WIDTH*Math.ceil(w)+Math.floor(p_x);
        arrows.top = (arrows.top)/Coin.HEIGHT*Math.ceil(h)+Math.floor(p_y);
        vArrow.renderGraph(g,x,y);
        hArrow.renderGraph(g,x,y);
        rect.renderGraph(g,x,y);
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
        EditorUi.activeMouse = true;
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
    public function renderGraph(g:Graphics,x:Float,y:Float){
        if(coin.App.editorui.inspector.index < 0)return;
        var w = size*10;
		var h = w;
        if(type == 0){
            //Horizontal Line
			g.color = kha.Color.Green;
			g.fillRect(x,y,w,2.0);
			g.fillTriangle(x+w,y+size,x+w,y-size,x+w+size*2,y);
        }
        else if( type == 2){
            g.color = kha.Color.Yellow;
            g.fillRect(x,y,size*2,-size*2);
        }
        else{
			//Vertical Line
			g.color = kha.Color.Red;
			g.fillRect(x,y-h,2.0,h);
			g.fillTriangle(x+size,y-h,x-size,y-h,x,y-h-size*2);
        }
    }
    public override function renderTo(g:Graphics){
        if(coin.App.editorui.inspector.index < 0)return;
        var x = EditorTools.arrows.left;
        var y = EditorTools.arrows.top;
        var w = size*5;
		var h = w;
        
        if(type ==1){
            this.set(x-this.componentWidth*0.5,y-this.componentHeight*0.5-size*5);
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