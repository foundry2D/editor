package;

import haxe.ui.extended.NodeData;
import haxe.ui.data.ListDataSource;
import haxe.ui.containers.TabView;
import iron.data.SceneFormat;

@:build(haxe.ui.macros.ComponentMacros.build("../Assets/custom/editor-hierarchy.xml"))
class EditorHierarchy extends EditorTab {
    public function new(raw:TSceneFormat=null) {
        super();
        setFromScene(raw);

    }
    public function setFromScene(raw:TSceneFormat){
        path.text = raw.name;
        tree.dataSource = getObjData(raw.objects,raw.name);
    }
    function getObjData(objs:Array<TObj>,path:String):ListDataSource<NodeData>{
        path+='/';
        var ds = new ListDataSource<NodeData>();
        for(obj in objs){
            if(Reflect.hasField(obj,"children")){
                trace("had children");
                ds.add({
                    name: obj.name,
                    path: path,
                    type:"img/"+obj.type,
                    childs: getObjData(obj.children,path+obj.name)
                });
            }
            else {
                ds.add({
                    name: obj.name,
                    path: path,
                    type:"img/"+obj.type
                });
            }
        }
        return ds;
    }
}