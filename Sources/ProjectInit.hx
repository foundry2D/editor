package;

import kha.FileSystem;
import found.data.Project.Type;
import found.data.SceneFormat;

class ProjectInit {
    public static var done:Void->Void;
    static var path = "";
    static var project = "";
    static public function run(p_path:String,type:found.data.Project.Type,p_project:String ="") {
        path = p_path;
        if(type == Type.twoD){
            project = p_project != "" ? p_project: "found Project";
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
        //     FileSystem.saveBytes(path+"/khafile.js",out);

        // }

        if(!FileSystem.exists(path+"/Assets")) FileSystem.createDirectory(path+"/Assets");
        if(!FileSystem.exists(path+"/Shaders")) FileSystem.createDirectory(path+"/Shaders");
        if(!FileSystem.exists(path+"/Sources")) FileSystem.createDirectory(path+"/Sources",main2d);
        if(!FileSystem.exists(path+"/Sources/Scripts")) FileSystem.createDirectory(path+"/Sources/Scripts");
        if(!FileSystem.exists(EditorUi.cwd+"/pjml.found")) 
            FileSystem.saveContent(EditorUi.cwd+"/pjml.found",'{"list":[]}',createDefaults);
        else
            createDefaults();
        
        
        
    }
    static function createDefaults(){
        FileSystem.getContent(EditorUi.cwd+"/pjml.found", function(blob:String){
            var out:{list:Array<found.data.Project.TProject>} = haxe.Json.parse(blob);

            var scene:TSceneFormat = haxe.Json.parse(kha.Assets.blobs.default_json.toString());
            scene.name = "PlayState";
            var data = haxe.Json.stringify(scene);
            kha.FileSystem.saveContent(path+"/Assets/PlayState.json",data);

            out.list.push({name: project,path: path,scenes:[path+"/Assets/PlayState.json"],type: Type.twoD});
            data = haxe.Json.stringify(out);
            path = EditorUi.cwd+"/pjml.found";
            kha.FileSystem.saveContent(path,data);
            if(ProjectInit.done != null)
                ProjectInit.done();

        });
    }
    static function main2d(){
        if(!FileSystem.exists(path+"/Sources/Main.hx")){
            var out = 'package;\n\n'
            +'import found.Found;\n\n'
            +'class Main {\n'
            +'\tpublic static inline var projectName = \'$project\';\n'
            +'\tpublic static function main() {\n'
            +'\t\tFound.setup({app:Project, title:"untitled", width:1920, height:1080});\n'
            +'\t}\n'
            +'}';
            FileSystem.saveContent(path+"/Sources/Main.hx",out);
        }
        if(!FileSystem.exists(path+"/Sources/Project.hx")){
            var out ='package;\n\n'
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
            +'}';
            FileSystem.saveContent(path+"/Sources/Project.hx",out);
        }
    }
    static function generateProject3d(){

    }
} 