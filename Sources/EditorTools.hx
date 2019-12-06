package;

import haxe.ui.core.Component;
import haxe.ui.core.Screen;
import haxe.ui.events.MouseEvent;
import kha.graphics2.Graphics;

class EditorTools {
    static public var vArrow:Arrow;
    static public var hArrow:Arrow;
    public function new(){
        vArrow = new Arrow(1);
        hArrow = new Arrow(0);
    }
    static public function render(g:Graphics,w:Float,h:Float){
        var x = hArrow.x*(w/Screen.instance.width);
        var y = hArrow.y*(h/Screen.instance.height);
        hArrow.set(x,y);
        vArrow.set(x,y);
        hArrow.renderTo(g);
        vArrow.renderTo(g);
        g.color = kha.Color.White;
    }
}
class Arrow extends Component{
    var type:Int =0;// 0 = right 1 = up
    public var x:Float = 0;
    public var y:Float =0;
    public var size:Float= 15;
    public function new(?type:Int){
        super();
        this.type = type;
        this.percentWidth = 15.0;
        this.percentHeight = 15.0;
        this.componentWidth = type == 0 ? size*5:size;
        this.componentHeight = type == 1 ? size*5:2.0;
        this.registerEvent(MouseEvent.CLICK,test);
    }
    public function set(x:Float,y:Float,?size:Float=15.0){
        this.x = x;
        this.y = y;
        this.left = x;
        this.top = y -this.componentHeight;
        var w = size*5;
		var h = w;
        this.size = size;
        
    }
    function test(e:MouseEvent){
        trace('Clicked an Arrow with type: $type');
    }
    public override function renderTo(g:Graphics){
        var w = size*5;
		var h = w;
        if(type == 0){
            //Horizontal Line
			g.color = kha.Color.Green;
			g.fillRect(x,y,w,2.0);
			g.fillTriangle(x+w,y+size,x+w,y-size,x+w+size*2,y);
        }
        else{
            //Rect
            g.color = kha.Color.Yellow;
            g.fillRect(x,y,size*1.5,-size*1.5);
			//Vertical Line
			g.color = kha.Color.Red;
			g.fillRect(x,y-h,2.0,h);
			g.fillTriangle(x+size,y-h,x-size,y-h,x,y-h-size*2);
        }
    }
}