package;

import zui.Zui;
import kha.Image;
import kha.math.Vector2;
import found.Found;
import kha.graphics2.Graphics;
import found.math.Util;


class EditorTools {
    static public var redrawArrows:Bool = true;
    static public function drawGrid(g:Graphics){
        if(!Found.drawGrid)return;
        var size:Int = found.Found.GRID;
        var str = 3.0;
        var x = found.State.active.cam.position.x;
        x += (Found.GRID-(x % Found.GRID));
        x += -Found.GRID*1.5;
        var y = found.State.active.cam.position.y;
        y += (Found.GRID-(y % Found.GRID));
        y += -Found.GRID*2;
        var width = Math.abs(x)+Found.WIDTH + Found.GRID*2;
        var height = Math.abs(y)+Found.HEIGHT + Found.GRID*2;
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
                x += -Found.GRID*1.5;
            }
        }
        g.color = kha.Color.White;
    }
} 