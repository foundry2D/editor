package;

import zui.Zui;
import zui.Id;
import found.Found;
import utilities.Translator;
import utilities.Config;

class ConfigSettingsDialog {

    public static function open(){
        languages  = Translator.getSupportedLocales();
        var index = 0;
        for(lang in languages){
            if(lang == Config.raw.locale){
                localeHandle.position = index;
            }
            index++;
        }
        zui.Popup.showCustom(Found.popupZuiInstance, configSettingsPopupDraw, -1, -1, 600, 500);
    }
    static var localeHandle:Handle = Id.handle();
    static var languages:Array<String> = [];
    static var playModeHandle = Id.handle();
    @:access(zui.Zui, zui.Popup)
    static function configSettingsPopupDraw(ui:Zui){
        zui.Popup.boxTitle = tr("Edit Config Settings");
        
        ui.text(tr("Localization")+": ");
        var selected = ui.combo(localeHandle,languages);
        if(localeHandle.changed){
            Config.raw.locale = languages[selected];
        }

        playModeHandle.selected = Config.raw.defaultPlayMode;
        var value = ui.check(playModeHandle,tr("Boot in Play Mode"));
        if(playModeHandle.changed){
            Config.raw.defaultPlayMode = value;
        }
        var border = zui.Popup.borderW*2 +zui.Popup.borderOffset;

        ui._y = ui._h - ui.t.BUTTON_H - ui.t.ELEMENT_H - border;

        ui.row([0.5,0.5]);
        ui._y = ui._h - ui.t.BUTTON_H - border;
        ui.text("");
        ui.row([0.5, 0.5]);
		if (ui.button("Save Settings")) {
            zui.Popup.show = false;
            Config.save();
        }
        if (ui.button("Cancel")) {
            zui.Popup.show = false;
        }
    }
}