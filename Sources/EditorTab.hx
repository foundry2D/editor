package;

import haxe.ui.containers.menus.*;
import haxe.ui.containers.TabView;
import haxe.ui.components.TabBar;
import haxe.ui.components.Label;
import haxe.ui.events.MouseEvent;
import haxe.ui.core.Screen;

typedef TItem ={
    var name:String;
    var expands:Bool;
    var onClicked:MouseEvent->Void;
    var ?filter:String;
}

class EditorTab extends TabView {

    var bar:TabBar;
    var titems:Array<TItem> = [];
    public function new(){
        super();
        this.percentWidth = 100.0;
        this.percentHeight = 100.0;
        bar = this.findComponent(TabBar, false);
        bar.registerEvent(MouseEvent.RIGHT_CLICK,onRightclickcall); 
    }
    
    
    function onRightclickcall(e:MouseEvent){
        var menu = new Menu();
        for(i in titems){
            trace(i.name);
            // if(i.filter != null && e.target.id != i.filter)continue;
            var item = new MenuItem();
            item.text  = i.name;
            item.expandable = i.expands;
            item.onClick = i.onClicked;
            menu.addComponent(item);
        }
        menu.show();
        menu.left = e.screenX;
        menu.top = e.screenY;
        Screen.instance.addComponent(menu);
    }
}