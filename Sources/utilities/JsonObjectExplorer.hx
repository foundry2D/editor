package utilities;

import found.data.SceneFormat;
import found.object.Object;

class JsonObjectExplorer {
    public static function getObjectFromJsonObjects(jsonObjects:Array<Object>, pathToJsonObject:String) : {jsonObject:TObj, jsonObjectUid:Int} {
        var split = pathToJsonObject.split("/"); 
        var name = split[0];
        var isLast = split[split.length-1] == name;

        var uid= -1;
        var object:TObj = null;

        for(jsonObject in jsonObjects){
            if((name == jsonObject.name || name == jsonObject.raw.name) && isLast){
                object= jsonObject.raw;
                uid = jsonObject.uid;
            }
        }

        if(uid == -1){
            pathToJsonObject = StringTools.replace(pathToJsonObject,'$name/','');
            return getObjectFromJsonObjects(jsonObjects, pathToJsonObject);
        }

        return {jsonObject: object, jsonObjectUid: uid};
    }

    public static function getFieldValueInJsonObject(jsonObject:TObj, fieldName:String, fieldType:String) {
        var fieldValue = Reflect.field(jsonObject, fieldName);
        if(fieldValue != null){
            return fieldValue;
        }
        
        var defaultFieldValue:Any;
        switch(fieldType){
            case 'Bool':
                defaultFieldValue = fieldName.indexOf("visible") >= 0 || fieldName.indexOf("active") >= 0 ;
            case 'String':
                defaultFieldValue = "";
            case 'Array':
                defaultFieldValue = [];
            case "Typedef":
                defaultFieldValue = {};
            default:
                defaultFieldValue = null;
        }           
        return defaultFieldValue;
    }    
}
