package ecs;

import h2d.Bitmap;
import utils.ColliderSystem;

class Sprite extends Component{
    var bmp : Bitmap;
    var edgeOutKill : Bool;
    public function new(attachee:GameObject, tile:h2d.Tile, edgeOut:Bool=false){
        super(attachee);

        type = "Sprite";
        this.bmp = new Bitmap(tile);
        bmp.setPosition(attachee.obj.x, attachee.obj.y);
        bmp.rotation = attachee.obj.rotation;
        this.edgeOutKill = edgeOut;
        scene.addChild(bmp);
    }

    public override function update(dt:Float){
        bmp.setPosition(attachee.obj.x, attachee.obj.y);
        bmp.rotation = attachee.obj.rotation;

        // for the test game - remove if you're coding a new game
        if((bmp.y < 0 || bmp.y > scene.height || bmp.x < 0 || bmp.y > scene.width) && edgeOutKill) {
            kill();
        }
    }

    public function kill() {
        trace("removing");
        scene.removeChild(bmp);
        var component = attachee.GetComponent("Collider");
        
        if(component != null){
            utils.ColliderSystem.collidersInScene = utils.ColliderSystem.collidersInScene.filter(function (cc) return cc != component);
        }
        Main.UpdateList.remove(attachee);
    }
}