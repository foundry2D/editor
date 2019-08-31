package;


class UiManager {
    public function new(){
        Toolkit.init();
    }
    public function update(): Void {

    }

    public function render(framebuffers:Array<Framebuffer>): Void {
        var g = framebuffers[0].g2;
        g.begin(true, 0xFFFFFF);

        Screen.instance.renderTo(g);

        g.end();
    }
}