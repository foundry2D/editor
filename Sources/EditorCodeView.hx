package;

import found.data.SceneFormat.LogicTreeData;
import found.App;
import found.Scene;
import haxe.ui.events.MouseEvent;
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
    // var textEditor:CodeComponent;
    public function new(){
        super();
        percentWidth = 100;
        percentHeight = 100;
        this.text = "Code";
        // textEditor = new CodeComponent();
        // container.addComponent(textEditor);
        // textEditor.hidden = true;
        addVisualCode.onClick = createVisualTrait;
        saveVisualCode.onClick = saveVisualTrait;
        visualEditor = new found.tool.NodeEditor(x,y,w,h);
        visualEditor.visible = true;
        
        
    }
    
    function createVisualTrait(e:MouseEvent){
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
        saveVisualTrait(new MouseEvent(MouseEvent.CLICK));
    }

    @:access(found.Scene)
    function saveVisualTrait(e:MouseEvent){
        var nodeData:LogicTreeData = found.tool.NodeEditor.selectedNode;
        var trait = {type:"VisualScript",class_name:"./dev/Project/Sources/visualTrait.json"};
        trace(nodeData);
        var data = haxe.Json.stringify(nodeData);
        kha.FileSystem.saveContent(trait.class_name,data,function(){
            Scene.createTraits([trait],App.editorui.inspector.currentObject);
            if(App.editorui.inspector.currentObject.raw.traits != null){
                App.editorui.inspector.currentObject.raw.traits.push(trait);
            }
            else {
                App.editorui.inspector.currentObject.raw.traits = [trait];
            }
            if(!StringTools.contains(App.editorui.hierarchy.path.text,'*'))
			    App.editorui.hierarchy.path.text+='*';
        });
    }
    public override function renderTo(g:kha.graphics2.Graphics) {
        super.renderTo(g);
        if(App.editorui.inspector.index != -1){
            addVisualCode.hidden = false;
        }
        else {
            addVisualCode.hidden = true;
        }
        // if(codetype.selectedIndex == 0){// Visual
            // textEditor.hidden = true;
            visualEditor.setAll(x,y,w,h);
            visualEditor.render(g);
        // }
        // else {//Textual
        //     textEditor.hidden = false;
        // }

	}

}