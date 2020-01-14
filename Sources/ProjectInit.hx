package;

import kha.FileSystem;
import foundry.data.Project.Type;

class ProjectInit {

    static var path = "";
    static var project = "";
    static public function run(p_path:String,type:foundry.data.Project.Type,p_project:String ="") {
        path = p_path;
        if(type == Type.twoD){
            project = p_project != "" ? p_project: "Foundry Project";
            generateProject2d();
        }
        else{
            project = p_project != "" ? p_project: "Armory Project";
            generateProject3d();
        }
    }
    static var hasHaxeui:Bool = true;
    static function generateProject2d(){
        // if(!FileSystem.exists(path+"/khafile.js")){
        //     #if editor_dev
        //     var cwd = "/home/jsnadeau/foundsdk";
        //     #else
        //     var cwd = EditorUi.cwd;
        //     #end
        //     var haxeui = hasHaxeui ? 'project.addLibrary(\'$cwd/hscript\');\n'
        //     + 'project.addLibrary(\'$cwd/haxeui-core\');\n'
        //     + 'project.addLibrary(\'$cwd/haxeui-kha\');\n'
        //     + 'project.addLibrary(\'$cwd/haxeui-kha-extended\');\n':'';
        //     var out  = haxe.io.Bytes.ofString(
        //     'let project = new Project("$project");\n'
		// 	+ 'project.addAssets(\'Assets/**\');\n'
		// 	+ 'project.addShaders(\'Shaders/**\');\n'
		// 	+ 'project.addSources(\'Sources\');\n'
        //     +  haxeui
        //     + 'project.addLibrary(\'$cwd/foundry\');\n'
        //     + 'await project.addProject(\'$cwd/found\');\n'
        //     + 'await project.addProject(\'$cwd/editor\');\n'
        //     + 'project.addDefine(\'foundry_editor\');\n'
		// 	+ 'resolve(project);\n');
        //     FileSystem.saveToFile(path+"/khafile.js",out);

        // }

        if(!FileSystem.exists(path+"/Assets")) FileSystem.createDirectory(path+"/Assets");
        if(!FileSystem.exists(path+"/Shaders")) FileSystem.createDirectory(path+"/Shaders");
        if(!FileSystem.exists(path+"/Sources")) FileSystem.createDirectory(path+"/Sources",main2d);
        if(!FileSystem.exists(path+"/Sources/scripts")) FileSystem.createDirectory(path+"/Sources/scripts");
        if(!FileSystem.exists(EditorUi.cwd+"/pjml.found")) FileSystem.saveToFile(EditorUi.cwd+"/pjml.found",haxe.io.Bytes.ofString("{[]}"));
        
        FileSystem.getContent(EditorUi.cwd+"/pjml.found", function(blob:String){
            var list:Array<foundry.data.Project.TProject> = haxe.Json.parse(blob);
            
            list.push({name: project,path: path,scenes:[],type: Type.twoD});
            var data = haxe.io.Bytes.ofString(haxe.Json.stringify(list));
            path = EditorUi.cwd+"/pjml.found";
			kha.FileSystem.saveToFile(path,data);

        });
        
    }
    static function main2d(){
        if(!FileSystem.exists(path+"/Sources/Main.hx")){
            var out = haxe.io.Bytes.ofString(
            'package;\n\n'
            +'import found.Found;\n\n'
            +'class Main {\n'
            +'\tpublic static inline var projectName = \'$project\';\n'
            +'\tpublic static function main() {\n'
            +'\t\tFound.setup({app:Project, title:"untitled", width:1920, height:1080});\n'
            +'\t}\n'
            +'}');
            FileSystem.saveToFile(path+"/Sources/Main.hx",out);
        }
        if(!FileSystem.exists(path+"/Sources/Project.hx")){
            var out = haxe.io.Bytes.ofString(
            'package;\n\n'
            +'import kha.Canvas;\n'
            +'import found.App;\n'
            +'import found.State;\n\n'
            +'class Project extends App {\n'
            +'\t public function new(){\n'
            +'\t\tsuper(function(){\n'
            +'\t\t\tState.addState("play","./$project/Assets/PlayState.json");\n'
            +'\t\t\tState.set("play");\n'
            +'\t\t});\n'
            +'\t}\n'
            +'\t override function render(canvas:Canvas){\n'
            +'\t\tsuper.render(canvas);\n'    
            +'\t}\n'
            +'}');
        }
    }
    static function generateProject3d(){

    }
} 