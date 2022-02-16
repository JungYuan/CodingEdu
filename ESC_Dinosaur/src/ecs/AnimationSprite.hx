package ecs;

import h2d.Anim;

class AnimationSprite extends Component{
    var animation : h2d.Anim;
    var edgeOutKill : Bool;
    var currentAnim : String;
    public function new(attachee:GameObject, animName:String, tilelist:Array<h2d.Tile>, fspeed:Int = 15, edgeOut:Bool=false){
        super(attachee);
        this.currentAnim = animName;
        type = "AnimationSprite";
        this.animation = new Anim(tilelist, fspeed);
        animation.setPosition(attachee.obj.x, attachee.obj.y);
        animation.rotation = attachee.obj.rotation;
        this.edgeOutKill = edgeOut;
        scene.addChild(animation);
    }

    public override function update(dt:Float){
        animation.setPosition(attachee.obj.x, attachee.obj.y);
        animation.rotation = attachee.obj.rotation;

        // for the test game - remove if you're coding a new game
        if((animation.y < 0 || animation.y > scene.height || animation.x < 0 || animation.y > scene.width) && edgeOutKill) {
            kill();
        }
    }

    public function kill() {
        trace("removing");
        scene.removeChild(animation);
        Main.UpdateList.remove(attachee);
    }

    public function changeAnim(animName : String, tileList : Array<h2d.Tile>){
        if (animName != this.currentAnim){
            this.currentAnim = animName;
            animation.play(tileList);
        }
    }
}