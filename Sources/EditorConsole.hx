package;

import found.tool.Log;
import kha.Color;
import kha.Assets;

typedef ConsoleOutput = {
    var type:Int;
    var content:String;
}

class EditorConsole extends Tab {
    var content:Array<ConsoleOutput>= [];
    var typeImages:Array<kha.Image> = [];
    var outputTypes:Array<String>;
    final options:zui.Ext.ListOpts;
    function log(v:Dynamic, ?infos:Null<haxe.PosInfos>){
        var type = 0; 
        if (infos != null && infos.customParams != null){
            var index = 0;
			for (v in infos.customParams){
                if(Std.string(v).contains("Warn")){
                    type =1;
                    break;
                }
                else if(Std.string(v).contains("Error")){
                    type =2;
                    break;
                }
                index++;
            }
            if(index < infos.customParams.length){
                infos.customParams.splice(index,1);
            }
        }
        if(active)
            redraw();
        var str = haxe.Log.formatOutput(v,infos);
        content.push({type:type,content: str});
    }
    
    public function new() {
        super(tr("Console"));
        Log.addCustomLogging(log);
        typeImages.push(Assets.images.information);
        typeImages.push(Assets.images.warning);
        typeImages.push(Assets.images.warning);
        options = {
            showAdd: false,
            editable: false,
            itemDrawCb: drawItem,
            showRadio: true,
            getNameCb: function(id:Int) {
                if(id < 0 || content[id] == null)return "";
                ui.t.TEXT_COL = content[id].type == 2 ? 0xffe34320 : content[id].type == 1 ? kha.Color.Yellow : 0xffe8e7e5;
                return content[id].content;
            },
            removeCb: function(id:Int){
                if(id < 0)return;
                content.splice(id,1);
            },
        }
        translate();
    }

    public function translate(){
        outputTypes = [tr("All"),tr("Information"),tr("Warnings"),tr("Errors")];
    }
    override function redraw(){
         parent.windowHandle.redraws = parent.htab.redraws = handle.redraws = 2;
    }
    var ui:zui.Zui;
    @:access(zui.Zui)
    function drawItem(h:zui.Zui.Handle,id:Int){
        if(id < 0 || content[id] == null)return;
        var out = content[id];
        ui._y -= ui.BUTTON_H();
        ui.image(typeImages[out.type],0xffffffff,lineHeight);
    }
    var handle = zui.Id.handle();
    var checkH = zui.Id.handle();
    var comboH = zui.Id.handle();
    var lineHeight:Float = 0.0;
    @:access(zui.Zui)
    override public function render(pui:zui.Zui) {
        this.ui =  pui;
        if (ui.tab(parent.htab,tr(this.name))) {
            ui.row([0.11,0.11,0.11,0.67]);
            if(ui.button(tr("Clear"))){
                clear();
            }
            ui.check(checkH,tr("Clear on Play"));
            var pos = ui.combo(comboH,outputTypes);
            ui.text("");

            var trie = function(co:ConsoleOutput){
                if(co.type + 1 == pos || pos == 0) return true; 
                return false;
            };
            var contents = content.filter(trie);


            var col = ui.t.ACCENT_COL;
            var hover = ui.t.ACCENT_HOVER_COL;
            var select = ui.t.ACCENT_SELECT_COL;

            ui.t.ACCENT_SELECT_COL = ui.t.ACCENT_HOVER_COL = ui.t.ACCENT_COL = Color.Transparent;

            lineHeight = ui.ELEMENT_H()*0.65;
            var tCol = ui.t.TEXT_COL;
            var lastFnt = ui.FONT_SIZE();
            ui.fontSize = Math.ceil(lineHeight);
            zui.Ext.list(ui,handle,contents,options);
            ui.t.TEXT_COL = tCol;
            ui.fontSize = lastFnt;

            ui.t.ACCENT_COL = col;
            ui.t.ACCENT_HOVER_COL = hover;
            ui.t.ACCENT_SELECT_COL = select;

        }
    }
    public function clear(?callbyPlay=false){
        if(callbyPlay && (!checkH.selected || !found.App.editorui.isPlayMode))return;
        content.splice(0,content.length);
    }
}