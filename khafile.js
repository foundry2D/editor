let project = new Project('editor');
project.addAssets('Assets/**');
project.addShaders('Shaders/**');
project.addSources('Sources');
project.addLibrary('Libraries/foundsdk/hscript');
project.addLibrary('Libraries/foundsdk/haxeui-core');
project.addLibrary('Libraries/foundsdk/haxeui-kha');
project.addLibrary('Libraries/foundsdk/haxeui-kha-extended');
project.addLibrary('Libraries/foundsdk/coineditor');
project.addDefine("debug");
project.addDefine("editor");
project.addDefine("tile_editor");
project.addParameter("--macro ListTraits.init()")
project.addDefine('editor_dev');
resolve(project);
