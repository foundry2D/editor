package;

import haxe.ui.extended.FileSystem;
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
    static function generateProject2d(){
        if(!FileSystem.exists(path+"/khafile.js")){
            #if editor_dev
            var cwd = "/home/jsnadeau/foundsdk";
            #else
            var cwd = Main.cwd;
            #end
            var out  = haxe.io.Bytes.ofString(
            'let project = new Project("$project");\n'
			+ 'project.addAssets(\'Assets/**\');\n'
			+ 'project.addShaders(\'Shaders/**\');\n'
			+ 'project.addSources(\'Sources\');\n'
            + 'project.addLibrary(\'$cwd/hscript\');\n'
            + 'project.addLibrary(\'$cwd/haxeui-core\');\n'
            + 'project.addLibrary(\'$cwd/haxeui-kha\');\n'
            + 'project.addLibrary(\'$cwd/haxeui-kha-extended\');\n'
            + 'project.addLibrary(\'$cwd/foundry\');\n'
            + 'project.addLibrary(\'$cwd/iron\');\n'
            + 'project.addDefine(\'foundry_editor\');\n'
			+ 'resolve(project);\n');
            FileSystem.saveToFile(path+"/khafile.js",out);

        }

        if(!FileSystem.exists(path+"/Assets")) FileSystem.createDirectory(path+"/Assets");
        if(!FileSystem.exists(path+"/Shaders")) FileSystem.createDirectory(path+"/Shaders");
        if(!FileSystem.exists(path+"/Sources")) FileSystem.createDirectory(path+"/Sources",main2d);
        if(!FileSystem.exists(path+"/Sources/found")) FileSystem.createDirectory(path+"/Sources/found");

        #if kha_krom
        #else
        kha.Assets.loadBlobFromPath(Main.cwd+"/pjml.found", function(blob:kha.Blob){
            var list:Array<foundry.data.Project.TProject> = haxe.Json.parse(blob.toString());
            
            list.push({name: project,path: path,scenes:[],type: Type.twoD});
            var data = haxe.io.Bytes.ofString(haxe.Json.stringify(list));
            path = Main.cwd+"/pjml.found";
			haxe.ui.extended.FileSystem.saveToFile(path,data);

        });
        
        #end
    }
    static function main2d(){
        if(!FileSystem.exists(path+"/Sources/Main.hx")){
            var out = haxe.io.Bytes.ofString(
            'package;\n\n'
            +'import foundry.system.Starter;\n'
            +'import foundry.renderpath.RenderPathCreator;\n\n'
            +'class Main {\n'
            +'\tpublic static inline var projectName = \'$project\';\n'
            +'\tpublic static inline var projectPackage = \'foundry2d-editor\';\n'
            +'\t#if foundry_editor\n'
            +'\tpublic static var ui:EditorUi;\n'
            +'\t#end\n'
            +'\tpublic static function main() {\n'
            +'\t\t#if foundry_editor\n'
            +'\t\tui = new EditorUi();\n'
            +'\t\t#end\n'
            +'\t\tStarter.main(\n'
            +'\t\t\t\'Scene\',\n'
            +'\t\t\t0,\n'
            +'\t\t\ttrue,\n'
            +'\t\t\tfalse,\n'
            +'\t\t\ttrue,\n'
            +'\t\t\t1920,\n'
            +'\t\t\t1080,\n'
            +'\t\t\t1,\n'
            +'\t\t\tfalse,\n'
            +'\t\t\tRenderPathCreator.get\n'
            +'\t\t);\n'
            +'\t}\n'
            +'}');

            FileSystem.saveToFile(path+"/Sources/Main.hx",out);
        }
    }
    static function generateProject3d(){

    }
} 