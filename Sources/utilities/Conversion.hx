package utilities;

import found.Found;
import found.State;
import kha.math.FastVector2;
import kha.math.FastMatrix3;

class Conversion {
    public static function WorldToScreen(position:FastVector2,?test:FastMatrix3):FastVector2 {
        var screen:FastVector2 = new FastVector2();
        var x = found.App.editorui.gameView.x;
        var y = found.App.editorui.gameView.y;
        var width = found.App.editorui.gameView.w;
        var height = found.App.editorui.gameView.h;
        var worldScale = FastMatrix3.scale(1.0/Found.WIDTH,1.0/Found.HEIGHT);
        var result = worldScale.multmat(FastMatrix3.translation(position.x,position.y));

        screen.x = x+width*result._20;
        screen.y = y+height*result._21;
        return screen;
    }
    public static function ScreenToWorld(position:FastVector2){
        var world:FastVector2 = new FastVector2();
        var x = State.active.cam.position.x;
        var y = State.active.cam.position.y;
        var width = found.App.editorui.gameView.w;
        var height = found.App.editorui.gameView.h;
        var viewTranslation = FastMatrix3.translation(position.x,position.y);
        var viewScale = FastMatrix3.scale(1.0/width,1.0/height);

        return world;
    }
}