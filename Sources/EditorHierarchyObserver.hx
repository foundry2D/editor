package; 

interface EditorHierarchyObserver {
    function notifyObjectSelectedInHierarchy(selectedObjectPath : String) : Void;
}