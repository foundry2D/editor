package;

import found.App;
import found.data.SceneFormat.TTrait;
import zui.Id;
import zui.Zui;


class ProjectExplorer extends Tab {

	var explorerXBrowserW:Array<Float> = [0.25, 0.75];
	var defaultPath:String = "/";
	var init = false;
	public static var currentPath(default, never):String;

	public function new() {
		
	}

	override function redraw() {
		windowHandle.redraws = windowHandle2.redraws = 2;
	}

	function openOnSystem() {
		#if kha_html5
		khafs.Fs.curDir = EditorUi.projectPath + khafs.Fs.sep + "Assets";
		khafs.Fs.input.click();
		#else
		#end
	}

	var windowHandle:Handle = Id.handle();
	var windowHandle2:Handle = Id.handle();
	var folderExplorerHandle:Handle = Id.handle();
	var fileExplorerHandle:Handle = Id.handle();

	@:access(zui.Zui)
	override public function render(ui:Zui) {
		if(!init && parent != null){
			parent.postRenders.push(renderFolderExplorer);
			parent.postRenders.push(renderFileExplorer);
			init = true;
		}

		if(ui.tab(parent.htab,"Explorer")){
			
		}
	}
	function renderFolderExplorer(ui:zui.Zui){
		if(!active)return;
		var hoffset = Std.int(ui.BUTTON_H()+ui.ELEMENT_OFFSET());
		if (ui.window(windowHandle, parent.x, parent.y+hoffset, Std.int(parent.w * explorerXBrowserW[0]), parent.h-hoffset)) {
			if (ui.button("Import Assets")) {
				openOnSystem();
			}
			folderExplorerHandle.text = ProjectExplorer.currentPath;
			var folder = Cust.fileBrowser(ui, folderExplorerHandle, true);
			if (folderExplorerHandle.changed) {
				Reflect.setField(ProjectExplorer, "currentPath", folder);
				redraw();
			}
		}
	}
	function renderFileExplorer(ui:zui.Zui){
		if(!active)return;

		var hoffset = Std.int(ui.BUTTON_H()+ui.ELEMENT_OFFSET());
		var offset = ui.ELEMENT_OFFSET() * 2;
		if (ui.window(windowHandle2, parent.x + Std.int(parent.w * explorerXBrowserW[0] + offset), parent.y + hoffset, Std.int(parent.w * explorerXBrowserW[1] - offset),parent.h-hoffset)) {
			
			ui.text(ProjectExplorer.currentPath);

			fileExplorerHandle.text = ProjectExplorer.currentPath;
			var file:String = Cust.fileBrowser(ui, fileExplorerHandle);
			if (fileExplorerHandle.changed) {
				Reflect.setField(ProjectExplorer, "currentPath", file);

				if (StringTools.endsWith(file, ".hx") || StringTools.endsWith(file, ".vhx") || StringTools.endsWith(file, ".json") || StringTools.endsWith(file, ".found")) {
					var trait:TTrait = {
						type: (StringTools.endsWith(file, ".vhx")) ? "VisualScript" : "Script",
						classname: file
					}
					App.editorui.codeView.setDisplayedTrait(trait);
				}

				redraw();
			}
		}
	}
}
