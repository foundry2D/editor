package;

import zui.Id;
import zui.Zui;
import haxe.ui.events.MouseEvent;
import haxe.ui.extended.Handler;
import haxe.ui.core.Component;

// @:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/project-explorer.xml"))
class ProjectExplorer extends EditorTab {

    public var x(get, never):Int;

	function get_x() {
		return Math.floor(screenX);
	}

	public var y(get, never):Int;

	function get_y() {
		return Math.floor(screenY);
	}

	public var w(get, never):Int;

	function get_w() {
		return Math.ceil(cast(this, Component).componentWidth);
	}

	public var h(get, never):Int;

	function get_h() {
		return Math.ceil(cast(this, Component).componentHeight);
	}
    var explorerXBrowserW:Array<Float> = [0.25,0.75];
    var defaultPath:String="/";
    public static var currentPath(default,never):String;
    public function new() {
        super();
        this.text = "Explorer";
    }

    function redraw(){

        windowHandle.redraws = windowHandle2.redraws = 2;

    }

    function openOnSystem(){
        #if kha_html5
        khafs.Fs.curDir = EditorUi.projectPath+khafs.Fs.sep+"Assets";
        khafs.Fs.input.click();
        #else
        #end
    }

    var windowHandle:Handle = Id.handle();
    var windowHandle2:Handle = Id.handle();
    var folderExplorerHandle:Handle = Id.handle();
    var fileExplorerHandle:Handle = Id.handle();
    @:access(zui.Zui)
    public function render(ui:Zui){
        if(ui.window(windowHandle, this.x+Std.int(ui.ELEMENT_OFFSET()), this.y, Std.int(this.w*explorerXBrowserW[0]), this.h)){
            if(ui.button("Import Assets")){
                openOnSystem();
            }

            folderExplorerHandle.text = ProjectExplorer.currentPath;
            var folder = Cust.fileBrowser(ui,folderExplorerHandle,true);
            if(folderExplorerHandle.changed){
                Reflect.setField(ProjectExplorer,"currentPath",folder);
                redraw();
            }
        }
        var offset = ui.ELEMENT_OFFSET()*2;
        if(ui.window(windowHandle2, this.x+Std.int(this.w*explorerXBrowserW[0]+offset), this.y,Std.int(this.w*explorerXBrowserW[1]-offset), this.h)){
            ui.text(ProjectExplorer.currentPath);
            fileExplorerHandle.text = ProjectExplorer.currentPath;
            var file = Cust.fileBrowser(ui,fileExplorerHandle);
            if(fileExplorerHandle.changed){
                Reflect.setField(ProjectExplorer,"currentPath",file);
                redraw();
            }
        }
    }
}