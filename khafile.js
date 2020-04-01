let project = new Project('editor');
project.addAssets('Assets/**');
project.addAssets("locale/*", { notinlist: true, destination: "data/locale/{name}" });
project.addAssets("keymap_presets/*", { notinlist: true, destination: "data/keymap_presets/{name}" });
project.addShaders('Shaders/**');
project.addSources('Sources');
project.addLibrary('Libraries/foundsdk/hscript');
project.addLibrary('Libraries/foundsdk/haxeui-core');
project.addLibrary('Libraries/foundsdk/haxeui-kha');
project.addDefine("debug");
project.addDefine("editor");
project.addDefine("tile_editor");
project.addParameter("--macro ListTraits.init()")
project.addDefine('editor_dev');
resolve(project);
