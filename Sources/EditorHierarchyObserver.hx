package; 

import found.data.SceneFormat.TObj;

interface EditorHierarchyObserver {
    function notifyObjectSelectedInHierarchy(selectedObject : TObj, selectedUID:Int) : Void;
}