package;


#if (kha_html5 &&js)
import js.html.CanvasElement;
import js.Browser.document;
#end

class CodeComponent extends haxe.ui.editors.code.CodeEditor {
    
    // var element:Element = null;
    // var div:js.html.DivElement;
    public function new(){
        super();
        percentWidth = 100;
        percentHeight = 100;
        var div:js.html.DivElement = document.createDivElement();
        document.body.appendChild(div);
        this.element = div;
        
    }
    public override function ready() {
        super.ready();
        // element = Browser.document.getElementById(htmlId);
        // element.style.display = null;
        Toolkit.callLater(function() { // something not quite right here, shouldnt need a 1 frame delay
            syncElementBounds();
        });
    }
    
    public override function onResized() {
        syncElementBounds();
    }
    
    public override function onMoved() {
        syncElementBounds();
    }

    public var offsetX:Float = 8; // location of the canvas on the html page
    public var offsetY:Float = 8;
    private function syncElementBounds() {
        // if (element == null) {
        //     trace("no element");
        //     return;
        // }
        
        element.style.left = (offsetX + screenLeft) + "px";
        element.style.top = (offsetY + screenTop) + "px";
        element.style.width = width + "px";
        element.style.height = height + "px";
    }
}