package; 

import found.data.SceneFormat.TObj;

interface EditorHierarchyObserver {
    function notifySceneSelectedInHierarchy() : Void;
    function notifyObjectSelectedInHierarchy(selectedObject : TObj, selectedUID:Int) : Void;
}