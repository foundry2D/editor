package;
#if macro
import haxe.io.Bytes;
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
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
        var props:Array<String> = [];
        for(f in haxe.macro.Context.getBuildFields()){
            for(m in f.meta){
                if(m.name == "prop"){
                    props.push(f.name);
                }
            }
        }
        
        var tdef:TraitDef = {type: "Script",classname: c.module};
        if(props.length > 0){
            tdef.props = props;
        }
        list.traits.push(tdef);

        sys.io.File.saveContent('../Assets/listTraits.json',Json.stringify(list));
        
        return Context.getBuildFields();
    }
    public macro static function init():Array<Field> {
        sys.io.File.saveContent('../Assets/listTraits.json','{}');
        return Context.getBuildFields();
    }
}
#end