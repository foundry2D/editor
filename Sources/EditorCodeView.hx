package;

import haxe.ui.containers.VBox;
import haxe.ui.core.Component;

@:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/editor-code.xml"))
class EditorCodeView extends VBox {

    public var x(get,never):Int;
	function get_x() {
		return Math.floor(bar.screenX);
	}
	public var y(get,never):Int;
	function get_y() {
		return Math.floor(bar.screenY+bar.height);
	}
	public var w(get,never):Int;
	function get_w() {
		return Math.ceil(cast(this, Component).componentWidth);
	}
	public var h(get,never):Int;
	function get_h() {
		return Math.ceil(cast(this, Component).componentHeight-bar.height);
    }
    
    var visualEditor:found.tool.NodeEditor;
    var textEditor:CodeComponent;
    public function new(){
        super();
        percentWidth = 100;
        percentHeight = 100;
        this.text = "Code";
        textEditor = new CodeComponent();
        container.addComponent(textEditor);
        textEditor.hidden = true;
        visualEditor = new found.tool.NodeEditor(x,y,w,h);
        visualEditor.visible = true;
        var nData = {
            name: "Name",
            nodes: new found.zui.Nodes(),
            nodeCanvas: {
                name: "My Nodes",
                nodes: [],
                links: []
            }
        }
        found.tool.NodeEditor.nodesArray.push(nData);
		found.tool.NodeEditor.selectedNode = nData;
    }
    public override function renderTo(g:kha.graphics2.Graphics) {
        super.renderTo(g);
        if(codetype.selectedIndex == 0){// Visual
            textEditor.hidden = true;
            visualEditor.setAll(x,y,w,h);
            visualEditor.render(g);
        }
        else {//Textual
            textEditor.hidden = false;
        }

	}

}