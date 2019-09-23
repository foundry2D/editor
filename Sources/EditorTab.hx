package;

import haxe.ui.containers.menus.*;
import haxe.ui.containers.TabView;
import haxe.ui.components.TabBar;
import haxe.ui.components.Label;
import haxe.ui.events.MouseEvent;
import haxe.ui.core.Screen;

class EditorTab extends TabView {

    var bar:TabBar;
    public function new(){
        super();
        this.percentWidth = 100.0;
        this.percentHeight = 100.0;
        bar = this.findComponent(TabBar, false);
        bar.registerEvent(MouseEvent.RIGHT_CLICK,onRightclickcall); 
    }
    
    
    function onRightclickcall(e:MouseEvent) {
        var menu = new Menu();
        var item = new MenuItem();
        item.text  = "Jello";
        item.expandable = false;
        menu.addComponent(item);
        menu.show();
        menu.left = e.screenX;
        menu.top = e.screenY;
        Screen.instance.addComponent(menu);
    }
}