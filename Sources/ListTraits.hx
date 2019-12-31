package;

import haxe.io.Bytes;
import haxe.macro.Context;
import haxe.macro.Expr;
import kha.FileSystem;
import haxe.Json;

typedef TraitDef = {
	public var type:String;
	public var classname:String;
	@:optional public var parameters:Array<String>; // constructor params
	@:optional public var props:Array<String>; // name - value list
}
typedef Data= {
    var traits:Array<TraitDef>;
}
class ListTraits {
    static var list:Data = null;
    public macro static function build():Array<Field> {
        // var p = new sys.io.Process("pwd", []);
        // var out:String = p.stdout.readAll().toString();
        // p.close();
        // trace(out);
        if(list == null){
            list = Json.parse(sys.io.File.getContent('../Assets/listTraits.json'));
            if(list.traits == null)
                list.traits = [];
        }

        var c = Context.getLocalClass().get();
        if(c.name == "EditorUi") return Context.getBuildFields();
        
        list.traits.push({type: "Script",classname: c.module});

        FileSystem.saveToFile('../Assets/listTraits.json',Bytes.ofString(Json.stringify(list)));
        
        return Context.getBuildFields();
    }
    public macro static function init():Array<Field> {
        FileSystem.saveToFile('../Assets/listTraits.json',Bytes.ofString('{}'));
        return Context.getBuildFields();
    }
}