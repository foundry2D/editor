let project = new Project('editor');
project.addAssets('Assets/**');
//@Cleanup does nothing but maybe a solution
//project.addAssets('/home/jsnadeau/foundsdk/haxeui-kha-extended/haxe/ui/extended/_modules/styles/dark/**', { notinlist: true });
project.addShaders('Shaders/**');
project.addSources('Sources');
// project.addSources('editor');
project.addLibrary('/home/jsnadeau/foundsdk/hscript');
project.addLibrary('/home/jsnadeau/foundsdk/haxeui-core');
project.addLibrary('/home/jsnadeau/foundsdk/haxeui-kha');
project.addLibrary('/home/jsnadeau/foundsdk/haxeui-kha-extended');
project.addLibrary('/home/jsnadeau/foundsdk/haxeui-code-editor');
project.addDefine("debug");
project.addDefine("editor");
project.addDefine("tile_editor");
project.addParameter("--macro ListTraits.init()")
// project.addLibrary('/home/jsnadeau/foundsdk/foundry');
// project.addLibrary('/home/jsnadeau/foundsdk/iron');
// project.addLibrary('/home/jsnadeau/foundsdk/iron_format');
// project.addDefine('foundry_editor');
project.addDefine('editor_dev');
resolve(project);
