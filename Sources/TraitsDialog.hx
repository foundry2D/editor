
import haxe.ui.core.Screen;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.data.ListDataSource;
import kha.FileSystem;
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
        buttons =  "Add Trait" | DialogButton.CANCEL;
        feed.itemRenderer =  haxe.ui.macros.ComponentMacros.buildComponent(
			"../Assets/custom/traits-items.xml");
		this.width = Screen.instance.width*0.95;
        this.height = Screen.instance.height*0.95;
        feed.percentHeight = 93.0;
		filename.percentHeight = 4.0;
        // FileSystem.getContent('./Assets/listTraits.json',function(data:String){
            var data = kha.Assets.blobs.get("listTraits_json");
            traits = haxe.Json.parse(data.toString());
            var ds = new ListDataSource<TraitDef>();
            if(traits.traits != null){
                for(trait in traits.traits){
                    ds.add(trait);
                }
            }
            
            feed.dataSource = ds;
            this.invalidateComponentLayout();
            this.show();
        // });
        
    }
    @:access(EditorInspector)
    public static function open(e:UIEvent){
        inst = new TraitsDialog(e.target.text);
        inst.onDialogClosed = function(e:DialogEvent){
            
            if(e.button == "Add Trait"){
                var hasAlready = false;
                for(trait in found.App.editorui.inspector.rawData.traits){
                    if(trait.class_name == inst.filename.text){
                        hasAlready =true;
                        break;
                    }
                }
                if(!hasAlready)
                    found.App.editorui.inspector.updateData(e);
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
