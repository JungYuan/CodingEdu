package ecs;

import haxe.iterators.StringIteratorUnicode;
import utils.ColliderSystem;
import utils.Vector2;

import eventbeacon.Beacon;

class Collider extends Component{
    public var pushOutSpeed : Float = 200;
    public var errTolerance : Float = 2;
    public var colliderTeam : String = "";
    public var hasRb : Bool = false;
    public var isTrigger : Bool = false;
    public var isStatic : Bool = false;
    public var center:Vector2;
    //public var ttest = new Array<{collider: GameObject, normal: Vector2, err: String}>;
    public var collidedWith = new List<{collider: GameObject, normal: Vector2, err: String}>();
    public var collideON : Vector2 = new Vector2(0,0);
    public var collidedByTeam : String;
    public var rb : RigidBody;
    public var colliderEvents : ColliderEvent = new ColliderEvent();

    public function new(attachee:GameObject, center:Vector2, staticity:Bool = false){
        super(attachee);
        type = "Collider";
        this.center = center;
        this.isStatic = staticity;
        utils.ColliderSystem.collidersInScene.add(this);
        var component = attachee.GetComponent("RigidBody");
        
        if(component != null){
            rb = cast(component, RigidBody);
            hasRb = true;
        }
    }

    public function GetTop():Float{
        return 0;
    }

    public function GetBottom():Float{
        return 0;
    }

    public function GetLeft():Float{
        return 0;
    }

    public function GetRight():Float{
        return 0;
    }

    public function GetCenter():Vector2{
        return new Vector2(center.x + attachee.obj.x, center.y + attachee.obj.y);
    }

    public function AddCollided(c:GameObject, normal:Vector2, err: String){
        if(collidedWith.filter( function (cc) return cc.collider == c).length == 0){
            // enter
            collidedWith.add({collider: c, normal: normal, err: err});
            colliderEvents.call(cast(c.GetComponent("Collider"), Collider));
        }else{
            // stay
        }
    }

    public function RemoveCollided(c:GameObject){
        // exit
        collidedWith = collidedWith.filter(function (cc) return cc.collider != c);
    }

    public override function update(dt:Float) { // fixedUpdate() {
        //trace('cllider_update');
        if(!isTrigger) {
            for(c in collidedWith){
                var cc:Collider = cast(c.collider.GetComponent("Collider"), Collider);
                if(!cc.isTrigger)
                    ApplyPushBack(c.normal, c.err);
            }
        }
    }

    private function ApplyPushBack(pv:Vector2, err: String) {
        if(hasRb && !rb.isTrigger){
            //rb.colliderNormals.add({n: pv, err: err});
        }
    }
}