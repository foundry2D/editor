package;

import found.data.Data;
import khafs.Fs;
import found.data.Project.Type;
import found.data.DataLoader;
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
        // if(!Fs.exists(path+"/khafile.js")){
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
        //     Fs.saveBytes(path+"/khafile.js",out);

        // }

        if(!Fs.exists(path+"/Assets")) Fs.createDirectory(path+"/Assets");
        if(!Fs.exists(path+"/Shaders")) Fs.createDirectory(path+"/Shaders");
        if(!Fs.exists(path+"/Sources")) Fs.createDirectory(path+"/Sources",main2d);
        if(!Fs.exists(path+"/Sources/Scripts")) Fs.createDirectory(path+"/Sources/Scripts");
        if(!Fs.exists(EditorUi.cwd+"/pjml.found")) 
            Fs.saveContent(EditorUi.cwd+"/pjml.found",'{"list":[]}',createDefaults);
        else
            createDefaults();
        
        
        
    }
    static function createDefaults(){
        Fs.getContent(EditorUi.cwd+"/pjml.found", function(blob:String){
            var out:{list:Array<found.data.Project.TProject>} = haxe.Json.parse(blob);
            Reflect.setField(DataLoader,"version",Data.version);

            var scene:Dynamic = DataLoader.parse(kha.Assets.blobs.default_json.toString());
            scene.name = "PlayState";
            var data = DataLoader.stringify(scene);
            khafs.Fs.saveContent(path+"/Assets/PlayState.json",data);

            out.list.push({name: project,dataVersion: Data.version,path: path,scenes:[path+"/Assets/PlayState.json"],type: Type.twoD});
            data = haxe.Json.stringify(out);
            path = EditorUi.cwd+"/pjml.found";
            khafs.Fs.saveContent(path,data);
            if(ProjectInit.done != null)
                ProjectInit.done();

        });
    }
    static function main2d(){
        if(!Fs.exists(path+"/Sources/Main.hx")){
            var out = 'package;\n\n'
            +'import found.Found;\n\n'
            +'class Main {\n'
            +'\tpublic static inline var projectName = \'$project\';\n'
            +'\tpublic static function main() {\n'
            +'\t\tFound.setup({app:Project, title:"untitled", width:1920, height:1080});\n'
            +'\t}\n'
            +'}';
            Fs.saveContent(path+"/Sources/Main.hx",out);
        }
        if(!Fs.exists(path+"/Sources/Project.hx")){
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
            Fs.saveContent(path+"/Sources/Project.hx",out);
        }
    }
    static function generateProject3d(){

    }
} 