import found.tool.TileEditor;
import zui.Id;
import zui.Zui;
import zui.Ext;

import found.Found;
import found.anim.Tilemap;

@:access(found.tool.TileEditor)
class GridSizeDialog {
    static var map:Tilemap;
    public static function open(p_map:Tilemap) {
        map = p_map;
        zui.Popup.showCustom(Found.popupZuiInstance, gridSizePopupDraw, -1, -1, 600, 500);
        TileEditor.ui.enabled = false;
    }

    @:access(zui.Zui, zui.Popup)
	static function gridSizePopupDraw(ui:Zui) {
        zui.Popup.boxTitle = tr("Grid Size");
        
        var border = 2 * zui.Popup.borderW + zui.Popup.borderOffset;
        
        var gridSizeH = Id.handle({value: Found.GRID});
        Ext.floatInput(ui, gridSizeH, tr("Grid Size"));

        var changeGrid = Id.handle();
        ui.check(changeGrid,tr("Affect main Grid"));
        

        ui._y = ui._h - ui.t.BUTTON_H - border;
		ui.row([0.5, 0.5]);
		if (ui.button(tr("Apply"))) {
			
            map.tw = map.th = Std.int(gridSizeH.value);
            if(changeGrid.selected){
                Found.GRID = map.tw;
            }
            zui.Popup.show = false;
            map = null;
            TileEditor.ui.enabled = true;
		}
		if (ui.button(tr("Cancel"))) {
            zui.Popup.show = false;
            map = null;
            TileEditor.ui.enabled = true;
		}
    }
}