package utilities;

import found.Found;
import found.State;
import kha.math.FastVector2;

class Conversion {
    public static function WorldToScreen(position:FastVector2):FastVector2 {
        var x = found.App.editorui.gameView.x;
        var y = found.App.editorui.gameView.y;
        var width = found.App.editorui.gameView.width;
        var height = found.App.editorui.gameView.drawHeight;
        position.x = position.x * (1.0/Found.WIDTH);
        position.y = position.y * (1.0/Found.HEIGHT);
        position.x = width*position.x;
        position.y = height*position.y;
        return position;
    }
    public static function ScreenToWorld(position:FastVector2){
        var world:FastVector2 = new FastVector2();
        var gv = found.App.editorui.gameView;
        position.x = (position.x-gv.x)*1.0/gv.width; 
        position.y = (position.y-gv.y)*1.0/gv.drawHeight;
        world.x = Found.WIDTH*position.x;
        world.y = Found.HEIGHT*position.y;
        return world;
    }
}