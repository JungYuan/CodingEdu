package utils;

import ecs.*;

class ColliderSystem{
    public static var collidersInScene = new List<Collider>();
    private static var c1Normal : Vector2;
    private static var c2Normal : Vector2;
    private static var err : String;

    public static function CheckCollide(){
        for(c1 in collidersInScene){
            if(!c1.hasRb){
                continue;
            }

            for(c2 in collidersInScene){
                if(c1 != c2){
                    if(DoCollide(c1, c2)){
                        c1.AddCollided(c2.attachee, c2Normal, err);
                        c1.collideON.x = c1Normal.x;
                        c1.collideON.y = c1Normal.y;
                        c2.AddCollided(c1.attachee, c1Normal, err);
                        c2.collideON.x = c2Normal.x;
                        c2.collideON.y = c2Normal.y;
                    }
                    else{
                        c1.RemoveCollided(c2.attachee);
                        c2.RemoveCollided(c1.attachee);
                    }
                }
            }
        }
    }

    public static function DoCollide(c1:Collider, c2:Collider):Bool{
        if(c1.isStatic && c2.isStatic){
            return false;
        }

        if(Std.isOfType(c1, CircleCollider)){
            var cc1:CircleCollider = cast(c1, CircleCollider);
            if(Std.isOfType(c2, CircleCollider)){
                var cc2:CircleCollider = cast(c2, CircleCollider);
                return DoCollide_Circle(cc1, cc2);
            }else if(Std.isOfType(c2, BoxCollider)){
                var cc2:BoxCollider = cast(c2, BoxCollider);
                return DoCollide_CircleBox(cc1, cc2);
            }
        }

        if(Std.isOfType(c1, BoxCollider)){
            var cc1:BoxCollider = cast(c1, BoxCollider);
            if(Std.isOfType(c2, BoxCollider)){
                var cc2:BoxCollider = cast(c2, BoxCollider);
                return DoCollide_Box(cc1, cc2);
            }else if(Std.isOfType(c2, CircleCollider)){
                var cc2:CircleCollider = cast(c2, CircleCollider);
                return DoCollide_CircleBox(cc2, cc1);
            }
        }

        return false;
    }

    public static function DoCollide_Circle(c1:CircleCollider, c2:CircleCollider):Bool{
        var center1 = c1.GetCenter();
        var center2 = c2.GetCenter();
        if(Distance(center1, center2) <= (c1.radius  + c2.radius) ){
            c1Normal = new Vector2(center1.x - center2.x, center1.y - center2.y).Normalized();
            c2Normal = new Vector2(center2.x - center1.x, center2.y - center1.y).Normalized();
            err = "";
            return true;
        }
        else{
            return false;
        }
    }

    public static function DoCollide_Box(c1: BoxCollider, c2: BoxCollider):Bool {
        var c2Center = c2.GetCenter();
        var c1Center = c1.GetCenter();
        var widthLimit = (c1.width+c2.width)/2;
        var heightLimit = (c1.height+c2.height)/2;

        var hitVector2c1 = new Vector2(c2Center.x-c1Center.x, c2Center.y-c1Center.y);
        
        if (Math.abs(hitVector2c1.x) <= widthLimit && Math.abs(hitVector2c1.y) <= heightLimit){
            c1Normal = hitVector2c1;
            c2Normal = new Vector2(-1*c1Normal.x, -1*c1Normal.y);
            var vx1:Float;
            var vx2:Float;
            var vy1:Float;
            var vy2:Float;
            if (c1.isStatic){
                vx1=0;
                vy1=0;
            }else{
                vx1 = c1.rb.velocity.x;
                vy1 = c1.rb.velocity.y;
            }
            if (c2.isStatic){
                vx2=0;
                vy2=0;
            }else{
                vx2 = c2.rb.velocity.x;
                vy2 = c2.rb.velocity.y;
            }
            var vxr = Math.abs(vx1-vx2);
            var vyr = Math.abs(vy1-vy2);
            //trace("v", vxr, vyr);
            if (vxr < 1e-5){
                if (vy2 < 0) err="T";
                else err="B";
            }else if(vyr < 1e-5){
                if (vx2 < 0) err="L";
                else err="R";
            }else{
                var tx:Float = (widthLimit-Math.abs(hitVector2c1.x))/vxr;
                var ty:Float = (heightLimit-Math.abs(hitVector2c1.y))/vyr;
                if (tx >= ty) {
                    if (vx2 < 0) err="L";
                    else err="R";
                }else{
                    if (vy2 < 0) err="T";
                    else err="B";
                }
            }
            

            //trace(hitVector2c1, err);
            return true;
        }
        return false;
    } 

    public static function DoCollide_CircleBox(c1: CircleCollider, c2: BoxCollider):Bool {
        var c2Center = c2.GetCenter();
        var c1Center = c1.GetCenter();
        var widthLimit = c1.radius+c2.width/2;
        var heightLimit = c1.radius+c2.height/2;
        var hitVector2c1 = new Vector2(c2Center.x-c1Center.x, c2Center.y-c1Center.y);
        if ((Math.abs(hitVector2c1.x) < widthLimit) && (Math.abs(hitVector2c1.y) < heightLimit)){
            c1Normal = hitVector2c1.Normalized();
            c2Normal = new Vector2(-1*c1Normal.x, -1*c1Normal.y);
            err = "";
            return true;
        } 
        return false;
    }


    // min = 1 means u1_upper was chosen in min as err and -1 means l1_lower
    // err is amount of intersection in collider we always fix the minimum err with pushing things out of each other xD
    public static function CheckBoxIntersection(upper:Float, lower: Float, u1: Float, l1: Float):{err: Float, min: Int, intersection: Int} {
        var u1_upper = u1 - upper;
        var u1_lower = u1 - lower;

        var l1_upper = l1 - upper;
        var l1_lower = l1 - lower;

        var upper_measure = Math.min(
            Math.abs(u1_upper),
            Math.abs(u1_lower)
        );

        var lower_measure = Math.min(
            Math.abs(l1_upper),
            Math.abs(l1_lower)
        );

        // are the signs same?
        // if not, it means intersection
        var s_u = (u1_upper > 0) != (u1_lower > 0);
        var s_l = (l1_upper > 0) != (l1_lower > 0);
        
        if(s_u || s_l){
            var error : Float = 0;
            var choice : Int = 0;
            if(upper_measure < lower_measure){
                error = Math.abs(upper_measure);
                choice = 1;
            }
            else{
                error = Math.abs(lower_measure);
                choice = -1;
            }
            return{ err: error,  min: choice, intersection: s_u && s_l ? 2 : 1};
        }
        else{
            return { err: 0, min: 0, intersection: 0 };
        }
    }

    public static function Distance(v1:Vector2, v2:Vector2){
        var x:Float = Math.abs(v1.x - v2.x);
        var y:Float = Math.abs(v1.y - v2.y);
        
        x *= x;
        y *= y;

        return Math.sqrt(x + y);
    }
}