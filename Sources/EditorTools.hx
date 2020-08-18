package;

import kha.Image;
import kha.math.Vector2;
import found.Found;
import kha.graphics2.Graphics;
import found.math.Util;


class EditorTools {
    static public var vArrow:Arrow;
    static var vertColl:Arrow;
    static public var hArrow:Arrow;
    static public var rect:Arrow;
    static public var redrawArrows:Bool = true;
    public function new(editor:EditorView){
        vArrow = new Arrow(3);
        hArrow = new Arrow(0);
        rect = new Arrow(2);
        vertColl = new Arrow(1);

    }
    @:access(zui.Zui)
    static public function render(ui:zui.Zui,p_x:Float,p_y:Float,resetY:Float){
        var x = p_x +ui._x;
        var y = p_y+resetY-vArrow.size;
        

        ui._x = x - rect.size * 0.75;
        ui._y = y - rect.size *10.5;
        vertColl.render2Scene(ui);
        ui._x = x - rect.size * 0.5;
        ui._y = y + rect.size*1.5;
        ui.g.pushRotation(Util.degToRad(-90),ui._x,ui._y);
        vArrow.render2Scene(ui);
        ui.g.popTransformation();
        ui._x = x ;
        ui._y = y;
        hArrow.render2Scene(ui);
        ui._x = x + rect.size *0.5 ;
        ui._y = y - rect.size *0.5;
        rect.render2Scene(ui);
        if(redrawArrows)
            EditorTools.redrawArrows = false;
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
class Arrow {
    var type:Int =0;// 0 = right 1 = up
    public var x:Float = 0;
    public var y:Float =0;
    public var size:Float= 8.0;
    public function new(?type:Int){
        this.type = type;
    }
    function activate(){
        if(found.App.editorui.inspector.index < 0 || found.App.editorui.inspector.index == found.State.active.cam.uid)return;
        EditorUi.arrow = type;
        switch(type){
            case 0:
                EditorUi.minusX = size*10;
            case 1:
                EditorUi.minusY = -size*8.5;
            case 2:
                EditorUi.minusX = 0;
                EditorUi.minusY = 0;
        }
        trace('Clicked an Arrow with type: $type with click');
    }

   
    var vertical:Image;
    var horizontal:Image;
    var rect:Image;
    var vertCollider:Image;
    @:access(zui.Zui)
    public function render2Scene(ui:zui.Zui){
        if(found.App.editorui.inspector.index < 0)return;
        var w = size*10;
        var h = w;
        var ty = size;
        if(type == 0){
            if(horizontal == null)
                horizontal = kha.Image.createRenderTarget(Std.int(w+size*2), Std.int(size*2));
            //Horizontal Line
            if(EditorTools.redrawArrows){
                ui.g.end();
                horizontal.g2.begin(true,kha.Color.Transparent);
                horizontal.g2.color = kha.Color.Green;
                horizontal.g2.fillRect(0,ty,w,2.0);
                if(EditorUi.arrowMode == 0){
                    horizontal.g2.fillTriangle(w,ty+size,w,ty+-size,w+size*2,ty);
                }
                else {
                    horizontal.g2.fillRect(w,0,size*2,size*2);
                }
                horizontal.g2.end();
                ui.g.begin(false);
            }
            if(ui.image(horizontal) == zui.Zui.State.Down){
                activate();
            }
        }
        else if( type == 2){
            if(rect == null){
                rect = kha.Image.createRenderTarget(Std.int(size*2),Std.int(size*2));
                ui.g.end();
                rect.g2.begin(true,kha.Color.Transparent);
                rect.g2.color = kha.Color.Yellow;
                rect.g2.fillRect(0,0,size*2,size*2);
                rect.g2.end();
                ui.g.begin(false);
            }
            if(ui.image(rect) == zui.Zui.State.Down){
                activate();
            }
        }
        else if(type == 3){
            if(vertical == null)
                vertical = kha.Image.createRenderTarget(Std.int(w+size*2), Std.int(size*2));
            //Vertical Line
            if(EditorTools.redrawArrows){
                ui.g.end();
                vertical.g2.begin(true,kha.Color.Transparent);
                vertical.g2.color = kha.Color.Red;
                vertical.g2.fillRect(0,ty,w,2.0);
                if(EditorUi.arrowMode == 0){
                    vertical.g2.fillTriangle(w,ty+size,w,ty+-size,w+size*2+2.0,ty);
                }
                else {
                    vertical.g2.fillRect(w,0,size*2,size*2);
                }
                vertical.g2.end();
                ui.g.begin(false);
            }
            ui.image(vertical);
            
        }
        else if(type ==1){
            if(vertCollider == null)
                vertCollider = kha.Image.createRenderTarget(Std.int(size*2), Std.int(w+size*2));
            //Vertical Line
            if(EditorTools.redrawArrows){
                ui.g.end();
                vertCollider.g2.begin(true,kha.Color.Transparent);
                vertCollider.g2.end();
                ui.g.begin(false);
            }
            if(ui.image(vertCollider) == zui.Zui.State.Down){
                activate();
            }
        }
    }
    
}