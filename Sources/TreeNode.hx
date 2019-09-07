package;

import haxe.ui.containers.VBox;
import haxe.ui.core.ItemRenderer;
import haxe.ui.containers.HBox;
import haxe.ui.components.Label;
import haxe.ui.events.UIEvent;
import haxe.ui.events.MouseEvent;

@:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/tree-node.xml"))
class TreeNode extends ItemRenderer {

    public var parentNode:TreeNode = null;
    private var _expanded:Bool = false;
    private var _tv:TreeView = null;
    private var _label:Label = null;

    public function new(tv:TreeView = null){
        super();
        _tv = tv;
        this.styleString = "spacing: 2;background-color:#1e1e1e";
        // treenode.styleString = "spacing: 0;background-color:#1e1e1e";
        _label = name;
    }

    //node interactions
    @:bind(node, MouseEvent.CLICK)
    function selected(e:UIEvent){
        if (_tv.selectedItem == this) {
            return;
        }
        
        if (_tv.selectedItem != null && _tv.selectedItem.findComponent("node") != null) {
            _tv.selectedItem.findComponent("node").removeClass(":selected");
            _tv.selectedItem = null;
        }
        node.addClass(":selected");
        _tv.selectedItem = this;
        
        var delta = (_tv.selectedNode.screenTop - _tv.screenTop + _tv.vscrollPos);
        if (delta < _tv.vscrollPos || delta > _tv.height - 10) {
            delta -= _tv.selectedNode.height + 10;
            if (delta > _tv.vscrollMax) {
                delta = _tv.vscrollMax;
            }
            _tv.vscrollPos = delta;
        }
        
        _tv.dispatch(new UIEvent(UIEvent.CHANGE));
    }
    @:bind(node,MouseEvent.MOUSE_OVER)
    function onHover(e:MouseEvent){
        node.addClass(":hover");
    }
    @:bind(node,MouseEvent.MOUSE_OUT)
    function onOut(e:MouseEvent){
        node.removeClass(":hover");
    }

    //expander interactions
    @:bind(expander,MouseEvent.CLICK)
    function clicked(e:MouseEvent) {
        trace("was clicked");
        if (_expanded == false) {
            expander.resource = "img/control-270-small.png";
            _expanded = true;
        } 
        else {
            expander.resource = "img/control-000-small.png";
            _expanded = false;
        }
        
        for (c in childComponents) {
            if (c == node) {
                continue;
            }
            
            if (_expanded == false) {
                c.hide();
            } else {
                c.show();
            }
        }
    }

    public var path(get, null):String;
    private function get_path():String {
        var ref = this;
        var parts:Array<String> = [];
        while (ref != null) {
            parts.push(ref._label.text);
            ref = ref.parentNode;
        }
        parts.reverse();
        return parts.join("/");
    }

    public override function get_text():String {
        return name.text;
    }
    
    public override function set_text(value:String):String {
        super.set_text(value);
        name.text = value;
        return value;
    }
    
    public override function get_icon():String {
        return type.resource;
    }
    
    public override function set_icon(value:String):String {
        super.set_icon(value);
        type.resource = value;
        return value;
    }

    public function addNode(text:String, icon:String = null):TreeNode {
        expander.resource = "img/control-000-small.png";
        expander.resource = "img/control-270-small.png";
        node.styleString = "spacing: 0";
        _expanded = true;
        
       var newNode = new TreeNode(_tv);
       newNode.marginLeft = 16;
       newNode.text = text;
       newNode.icon = icon;
       newNode.parentNode = this;
       addComponent(newNode);
       return newNode;
    }
    
    public function findNode(path:String):TreeNode {
        
        var parts = path.split("/");
        var first = parts.shift();
        
        var node:TreeNode = null;
        for (c in childComponents) {
            var label = c.findComponent(Label, true);
            if (label != null && label.text == first) {
                node = cast(c, TreeNode);
                break;
            }
        }
        
        if (parts.length > 0) {
            node = node.findNode(parts.join("/"));
        }
        
        return node;
    }

}