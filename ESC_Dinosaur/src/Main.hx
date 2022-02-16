import h3d.Vector;
import haxe.macro.Expr.Catch;
import h2d.Text;
import hxd.Key;
import haxe.Timer;
import hxd.Res;
import hxd.Window;
import utils.*;
import h2d.Font;
import ecs.*;

class Main extends hxd.App {
    public static var UpdateList = new List<Updatable>();
    public static var fixedDeltaTime = 0;
    
    var dinosaur:GameObject;
    var dinosaurRB:RigidBody;
    var dinosaurAnim : AnimationSprite;
    var dinosaurRun : Array<h2d.Tile>;
    var dinosaurJump : Array<h2d.Tile>;
    var groundTiles : Array<h2d.Tile>;
    var ground:Float;
    var treetile:Array<h2d.Tile>;
    var generateTime:Float;
    var timer1:Float;
    var gameRun : Bool = true; 
    var onJumping : Int = 0; 
    var groundcount : Int = 0;

    static function main() {
        Res.initEmbed();
        new Main();
    }

    private function createDinosaur(){
        dinosaurRun = [Res.dinosaur_2.toTile(), Res.dinosaur_3.toTile()];
        dinosaurJump = [Res.dinosaur_jump.toTile()];
        for(i in 0...dinosaurRun.length){
            dinosaurRun[i].dx = dinosaurRun[i].width/-2;
            dinosaurRun[i].dy = dinosaurRun[i].height/-2;
        }
        dinosaurJump[0].dx = dinosaurJump[0].width/-2;
        dinosaurJump[0].dy = dinosaurJump[0].height/-2;
        /*
        var tile:h2d.Tile;
        tile = Res.dinosaur_2.toTile();
        tile.dx = tile.width/-2;
        tile.dy = -tile.height;
        */
        dinosaur = new GameObject(s2d, s2d.width*0.25, ground);
        dinosaurAnim = new AnimationSprite(dinosaur, "run", dinosaurRun, 10, true);
        //new Sprite(dinosaur, tile, false);
        dinosaurRB = new RigidBody(dinosaur, 0, -1000, true);
        var radV = (Math.abs(dinosaurRun[0].x)+Math.abs(dinosaurRun[0].y))/2;
        new CircleCollider(dinosaur, new Vector2(0,0), radV);
        //new BoxCollider(dinosaur, new Vector2(0,0), Math.abs(dinosaurRun[0].x), Math.abs(dinosaurRun[0].y));
    }

    private function generateTree(){
        var newtreetile:h2d.Tile = treetile[Std.random(100)%3];
        newtreetile.dx = newtreetile.width/-2;
        newtreetile.dy = newtreetile.height/-2;
        var newTree:GameObject = new GameObject(s2d, s2d.width-newtreetile.width, ground);
        new Sprite(newTree, newtreetile, true);
        new RigidBody(newTree, -800, 0, false);
        var radV = (Math.abs(newtreetile.dx)+Math.abs(newtreetile.dy))/2;
        //var beCollider:Collider = new CircleCollider(newTree, new Vector2(0, 0), radV);
        var beCollider:Collider = new BoxCollider(newTree, new Vector2(0, 0), newtreetile.width, newtreetile.height);
        beCollider.isTrigger = true;
        beCollider.colliderEvents.funcList.add(gamegg);
    }
    private function generateGround(px:Float){
        var newgroundtile:h2d.Tile = groundTiles[Std.random(100)%2];
        var newGround:GameObject = new GameObject(s2d, px, ground);
        new Sprite(newGround, newgroundtile, true);
        new RigidBody(newGround, -800, 0, false);
    }
    private function initGround(){
        groundTiles = [Res.ground1.toTile(), Res.ground2.toTile()];
        var dist = groundTiles[0].width;
        ground = s2d.height*0.75;
        var gx:Float = 0;
        while (gx <= s2d.width){
            generateGround(gx);
            gx = gx + dist;
        }
    }

    override function init() {
        engine.backgroundColor = 0xFFAAAAAA;
        initGround();
        createDinosaur();
        treetile = [Res.tree_1.toTile(), Res.tree_2.toTile(), Res.tree_3.toTile()];

        Window.getInstance().addEventTarget(interpretEvent);
        generateTime = Std.random(100)*0.02;
        timer1 = 0.0;
    }

    override function update(dt:Float) {
        if (gameRun){
            groundcount += 1;
            if (groundcount > 6){
                generateGround(s2d.width);
                groundcount=0;
            }
            timer1 += dt;
            ColliderSystem.CheckCollide();
            for (obj in UpdateList){
                obj.update(dt);
            }
            if (dinosaur.obj.y > ground){
                dinosaur.obj.y = ground;
                dinosaurRB.velocity.y = 0;
                dinosaurAnim.changeAnim("run", dinosaurRun);
                onJumping = 0;
            }
            dinosaur.obj.rotation = dinosaurRB.velocity.y * 0.01 * 0.02;
            if (timer1 > generateTime){
                generateTree();
                timer1 = 0.0;
                generateTime = Std.random(100)*0.02 + 1;
            }
        }
    }

    public function interpretEvent(event: hxd.Event){
        switch (event.kind){
            case EKeyDown: onMouseClick(event);
            case EPush: onMouseClick(event);
            case _:
        }
    }

    public function onMouseClick(event: hxd.Event){
        //var component: Component = dinosaur.GetComponent("RigidBody");
        //var rb: RigidBody = cast(component, RigidBody);
        //rb.velocity = new Vector2(0, -1200);
        if (gameRun){
            if (onJumping == 0){
                onJumping = 1;
                dinosaurAnim.changeAnim("jump", dinosaurJump);
                dinosaurRB.velocity.y = -1000;
            }
        }else{
            gameRun = true;
            for (obj in UpdateList){
                obj.clear();
            }
            initGround();
            dinosaur.obj.x = s2d.width*0.25;
            dinosaurAnim.changeAnim("jump", dinosaurJump);
            dinosaurRB.velocity.y = -1000;
        }
    }

    private function gamegg(c:Collider) { 
        trace(c.GetCenter());
        //trace(c.collideON);
        if (c.collideON.y > 0) {
            dinosaurAnim.changeAnim("jump", dinosaurJump);
            dinosaurRB.velocity.y = -1000;
        }else{
            gameRun = false;
        }
    }
}