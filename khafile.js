let project = new Project('editor');
project.addAssets('Assets/*');
project.addAssets("Assets/locale/*", { notinlist: true, destination: "data/locale/{name}" });
project.addAssets("keymap_presets/*", { notinlist: true, destination: "data/keymap_presets/{name}" });
project.addAssets("../zui/examples/SharedAssets/color_wheel.png");
project.addShaders('Shaders/**');
project.addSources('Sources');
project.addLibrary('Libraries/foundsdk/hscript');
project.addDefine("editor");
project.addDefine("tile_editor");
var platform = '"'+process.argv[2]+'"';
project.addParameter(`--macro ListTraits.init(${platform})`);
project.icon = "icon.png"
resolve(project);
