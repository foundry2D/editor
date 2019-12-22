
import haxe.ui.core.Screen;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.data.ListDataSource;
import haxe.ui.extended.FileSystem;
import ListTraits.Data;
import ListTraits.TraitDef;

@:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/traits-dialog.xml"))
class TraitsDialog extends Dialog {
    static public var inst:TraitsDialog = null;
    static var traits:Data;
    var selected:TraitDef;
    public function new(?button:String){
        super();
        // sys.io.File.getContent();
        id = "traits";
        title = "Traits";
        modal = false;
        buttons =  button | DialogButton.CANCEL;
        feed.itemRenderer =  haxe.ui.macros.ComponentMacros.buildComponent(
			"../Assets/custom/traits-items.xml");
		this.width = Screen.instance.width*0.95;
        this.height = Screen.instance.height*0.95;
        feed.percentHeight = 93.0;
		filename.percentHeight = 4.0;
        FileSystem.getContent('./Assets/listTraits.json',function(data:String){
            traits = haxe.Json.parse(data);
            var ds = new ListDataSource<TraitDef>();
            trace(traits);
            for(trait in traits.traits){
                ds.add(trait);
            }
            feed.dataSource = ds;
            this.invalidateComponentLayout();
            this.show();
        });
        
    }
    @:access(EditorInspector)
    public static function open(e:UIEvent){
        inst = new TraitsDialog(e.target.text);
        inst.onDialogClosed = function(e:DialogEvent){
            
            if(e.button == "Add Trait"){
                var hasAlready = false;
                for(trait in coin.App.editorui.inspector.rawData.traits){
                    if(trait.class_name == inst.filename.text){
                        hasAlready =true;
                        break;
                    }
                }
                if(!hasAlready)
                    coin.App.editorui.inspector.updateData(e);
            }
                
        }
        // inst.show();
    }

    @:bind(feed, UIEvent.CHANGE)
	function selectedScript(e){
		inst.selected = feed.selectedItem;
        filename.text = inst.selected.classname;
    }
}
