package;

import haxe.ui.components.Button;
import haxe.ui.core.Component;
import kha.Framebuffer;
import haxe.ui.core.Screen;
import haxe.ui.macros.ComponentMacros;
import haxe.ui.Toolkit;

class UiManager {
    var main:Component;
    var dialog:FileBrowserDialog;
    public function new(){
        Toolkit.init();
        main = new MainView();
        var comp:Button = main.findComponent('button-test',Button);
        comp.onClick = FileBrowserDialog.open;
        Screen.instance.addComponent(main);
    }
    public function update(): Void {

    }

    public function render(framebuffers:Array<Framebuffer>): Void {
        var g = framebuffers[0].g2;
        g.begin(true, 0xFFFFFF);

        Screen.instance.renderTo(g);

        g.end();
    }
}