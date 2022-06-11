import js.html.rtc.DTMFSender;
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
	var dinosaurCD:Collider;
	var dinosaurAnim:AnimationSprite;
	var dinosaurRun:Array<h2d.Tile>;
	var dinosaurJump:Array<h2d.Tile>;
	var groundTiles:Array<h2d.Tile>;
	var ground:Float;
	var treetile:Array<h2d.Tile>;
	var generateTime:Float;
	var timer1:Float;
	var gameRun:Bool = true;
	var onJumping:Int = 0;
	var groundcount:Int = 0;
	var oriPos:Vector2=new Vector2(0,0);

	static function main() {
		Res.initEmbed();
		new Main();
	}

	private function createDinosaur() {
		dinosaurRun = [Res.dinosaur_2.toTile(), Res.dinosaur_3.toTile()];
		dinosaurJump = [Res.dinosaur_jump.toTile()];
		for (i in 0...dinosaurRun.length) {
			dinosaurRun[i].dx = dinosaurRun[i].width / -2;
			dinosaurRun[i].dy = dinosaurRun[i].height / -2;
		}
		dinosaurJump[0].dx = dinosaurJump[0].width / -2;
		dinosaurJump[0].dy = dinosaurJump[0].height / -2;
		/*
			var tile:h2d.Tile;
			tile = Res.dinosaur_2.toTile();
			tile.dx = tile.width/-2;
			tile.dy = -tile.height;
		 */
		dinosaur = new GameObject(s2d, s2d.width * 0.25, ground-500);
		oriPos.x = dinosaur.obj.x;
		oriPos.y = dinosaur.obj.y;
		dinosaurAnim = new AnimationSprite(dinosaur, "run", dinosaurRun, 10, true);
		// new Sprite(dinosaur, tile, false);
		dinosaurRB = new RigidBody(dinosaur, 0, -1000, true);
		var radV = (Math.abs(dinosaurRun[0].x) + Math.abs(dinosaurRun[0].y)) / 2;
		// new CircleCollider(dinosaur, new Vector2(0,0), radV);
		dinosaurCD = new BoxCollider(dinosaur, new Vector2(0, 0), dinosaurRun[0].width, dinosaurRun[0].height);
		//var beCollider:Collider = new BoxCollider(dinasaur, new Vector2(0, 0), dinosaurRun[0].width, dinosaurRun[0].height);
		dinosaurCD.isTrigger = true;
		dinosaurCD.colliderEvents.funcList.add(onground);
	}

	private function generateTree(px:Float=0, py:Float=0, treespeed:Float=-800) {
		var newtreetile:h2d.Tile = treetile[Std.random(100) % 3];
		newtreetile.dx = newtreetile.width / -2;
		newtreetile.dy = newtreetile.height / -2;
		if (px == 0 && py == 0){
			px = s2d.width - newtreetile.width;
			py = ground;
		}
		var newTree:GameObject = new GameObject(s2d, px, py);
		new Sprite(newTree, newtreetile, true);
		new RigidBody(newTree, treespeed, 0, false);
		var radV = (Math.abs(newtreetile.dx) + Math.abs(newtreetile.dy)) / 2;
		// var beCollider:Collider = new CircleCollider(newTree, new Vector2(0, 0), radV);
		//var beCollider:Collider = new BoxCollider(newTree, new Vector2(0, 0), newtreetile.width, newtreetile.height);
		//beCollider.isTrigger = true;
		//beCollider.colliderEvents.funcList.add(gamegg);
	}

	private function generateGround(px:Float, py:Float) {
		var newgroundtile:h2d.Tile = groundTiles[Std.random(100) % 2];
		var newGround:GameObject = new GameObject(s2d, px, ground-py);
		new Sprite(newGround, newgroundtile, true);
		//new RigidBody(newGround, -800, 0, false);
		new RigidBody(newGround, 0, 0, false);
		var beCollider:Collider = new BoxCollider(newGround, new Vector2(0, 0), newgroundtile.width, newgroundtile.height);
		//beCollider.isTrigger = true;
		//beCollider.colliderEvents.funcList.add(onground);
	}

	private function initGround() {
		groundTiles = [Res.ground1.toTile(), Res.ground2.toTile()];
		for (i in 0...groundTiles.length) {
			groundTiles[i].dx = groundTiles[i].width / -2;
			groundTiles[i].dy = groundTiles[i].height / -2;
		}
		var dist = groundTiles[0].width;
		ground = s2d.height * 0.75;
		var gx:Float = 0;
		while (gx <= s2d.width) {
			//generateGround(gx, 0);
			if (gx > 1000 && gx < 1800){
				generateGround(gx, 75);
			}
			if (gx > 1800 && gx < 2800){
				generateGround(gx, 225);
			}
			gx = gx + dist;
			
		}
	}

	override function init() {
		engine.backgroundColor = 0xFFAAAAAA;
		initGround();
		createDinosaur();
		treetile = [Res.tree_1.toTile(), Res.tree_2.toTile(), Res.tree_3.toTile()];
		//Window.getInstance().addEventTarget(interpretEvent);
		generateTime = Std.random(100) * 0.02;
		timer1 = 0.0;
	}
	public function keyAction(){
		if (Key.isDown(Key.RIGHT)){
			//trace('right');
			dinosaurRB.velocity.x = 500;
		}else if (Key.isDown(Key.LEFT)){
			//trace('left');
			dinosaurRB.velocity.x = -500;
		}else{
			dinosaurRB.velocity.x *= 0.8; 
		}
		if (Key.isDown(Key.SPACE)){
			if (onJumping == 0) {
				onJumping = 1;
				dinosaurAnim.changeAnim("jump", dinosaurJump);
				dinosaurRB.velocity.y = -1000;
				dinosaurRB.affectedByGravity = true;
			}
		}
	}
	
	override function update(dt:Float) {
		oriPos.x = dinosaur.obj.x;
		oriPos.y = dinosaur.obj.y;
		if (gameRun) {
			//groundcount += 1;
			//if (groundcount > 6) {
			//	generateGround(s2d.width);
			//	groundcount = 0;
			//}
			keyAction();
			timer1 += dt;
			for (obj in UpdateList) {
				obj.update(dt);
			}
			ColliderSystem.CheckCollide();
			if (dinosaurCD.collidedWith.length == 0){
				dinosaurRB.affectedByGravity = true;
			}
			if (dinosaur.obj.y > ground) {
				dinosaur.obj.y = ground;
				dinosaurRB.velocity.y = 0;
				dinosaurAnim.changeAnim("run", dinosaurRun);
				onJumping = 0;
			}
			dinosaur.obj.rotation = dinosaurRB.velocity.y * 0.01 * 0.02;
			//if (timer1 > generateTime) {
			//	generateTree();
			//	timer1 = 0.0;
			//	generateTime = Std.random(100) * 0.02 + 1;
			//}
		}
	}

	public function interpretEvent(event:hxd.Event) {
		trace(event.kind);
		switch (event.kind) {
			case EKeyDown:
				onKeyDown(event);
			case EPush:
				onMouseClick(event);
			case EKeyUp:
				onKeyRelease(event);
				
			case _:
		}
	}

	public function onKeyRelease(event:hxd.Event) {
		if (event.keyCode == Key.RIGHT || event.keyCode == (Key.LEFT)){
			dinosaurRB.velocity.x *= 0.8;
			if (Math.abs(dinosaurRB.velocity.x) < 1) {
				dinosaurRB.velocity.x = 0 ;
			}
		}
	}

	public function onKeyDown(event:hxd.Event) {
		if (event.keyCode == Key.RIGHT){
			//trace('right');
			dinosaurRB.velocity.x = 500;
		}
		if (event.keyCode == (Key.LEFT)){
			//trace('left');
			dinosaurRB.velocity.x = -500;
		}
		if (event.keyCode == (Key.SPACE)){
			onMouseClick(event);
		}
	}

	public function onMouseClick(event:hxd.Event) {
		// var component: Component = dinosaur.GetComponent("RigidBody");
		// var rb: RigidBody = cast(component, RigidBody);
		// rb.velocity = new Vector2(0, -1200);
		if (gameRun) {
			if (onJumping == 0) {
				onJumping = 1;
				dinosaurAnim.changeAnim("jump", dinosaurJump);
				dinosaurRB.velocity.y = -1000;
				dinosaurRB.affectedByGravity = true;
			}
		} else {
			gameRun = true;
			for (obj in UpdateList) {
				obj.clear();
			}
			initGround();
			dinosaur.obj.x = s2d.width * 0.25;
			dinosaurAnim.changeAnim("jump", dinosaurJump);
			dinosaurRB.velocity.y = -1000;
		}
	}

	private function gamegg(c:Collider) {
		// trace(c.GetCenter());
		trace(c.collidedWith.first().normal);
		c.attachee.obj.x += 2*c.collidedWith.first().normal.x;
        c.attachee.obj.y += 2*c.collidedWith.first().normal.y;
        gameRun = false;
		for (obj in UpdateList) {
			obj.update(0);
		}
		if (c.collideON.y > 0) {
			dinosaurAnim.changeAnim("jump", dinosaurJump);
			dinosaurRB.velocity.y = -1000;
		} else {
			gameRun = false;
		}
	}

	private function onground(c:Collider) {
		// trace(c.GetCenter());
		trace("on");
		for (item in c.collidedWith){
			if (item.collider == dinosaur){
				trace(item.normal, item.err,dinosaurRB.velocity.x);
			}
		}

		dinosaurRB.velocity.y = 0;
		//dinosaurRB.velocity.x = 0;
		dinosaurRB.affectedByGravity = false;
		dinosaurAnim.changeAnim("run", dinosaurRun);
		onJumping = 0;
	}
}
