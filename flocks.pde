
class Flock{
  Agent[] agents;
  float extentW,extentH;
  float avgMass,avgRadius;
  Flock(Agent[] _agents){
    agents = _agents;
    extentW = 0;
    extentH = 0;
    for (Agent a : agents){
      extentW = max(extentW, abs(a.pos.x));
      extentH = max(extentH, abs(a.pos.y));
      avgMass += a.mass;
      avgRadius += a.radius;
    }
    avgMass /= agents.length;
    avgRadius /= agents.length;
  }
  
  Quadtree qtree(){
    Quadtree qtree = new Quadtree(0,0,extentW + 10f, extentH + 10f);
    for (Agent a:agents){qtree.add(a);}
    //qtree.debugShow();
    return qtree;
  }
  
  
  void show(){for (Agent a:agents){a.show();}}
  
  void clearTrapped(int stat, int dyn){
    for (Agent a:agents){
      if (a.trapped(stat,dyn)){
        a.pos = randomBox(extentW,extentH);
      }
    }
  }
  
  void stepTime(float dt){
    extentW = 0;
    extentH = 0;
    for (Agent a:agents){
      a.stepTime(dt);
      extentW = max(extentW, abs(a.pos.x));
      extentH = max(extentH, abs(a.pos.y));
    }
  }
  
  void collideDynamic(float checkRange){collideDynamic(this,checkRange,1);}
  void collideDynamic(Flock colliders, float checkRange){collideDynamic(colliders,checkRange,1);}
  void collideDynamic(float checkRange,float elasticity){collideDynamic(this,checkRange,elasticity);}
  void collideDynamic(Flock colliders, float checkRange,float elasticity){
    Quadtree qtree = colliders.qtree();
    //qtree.debugShow();
    for (Agent a : agents){
      Agent[] query = qtree.query(a.pos.x,a.pos.y,checkRange,checkRange).toArray(new Agent[0]);
      for(Agent b:query){
        if (a!=b && a.collision(b)){
          a.collideAgent(b,elasticity);
        }
      }
    }
  }
  
  void collideStatic(Collider[] walls){collideStatic(walls,1);}
  void collideStatic(Collider[] walls,float elasticity){for (Agent a : agents){a.collideStatic(walls,elasticity);}}
  
  void drag(float lin, float quad){for (Agent a : agents){a.applyOutsideForce(a.drag(lin,quad));}}
  
  
  void attraction(float range, float strength){attraction(this,range,strength);}
  void attraction(Flock repellers,float range,float strength){
    Quadtree qtree = repellers.qtree();
    float r2 = range*range;
    //qtree.debugShow();
    for (Agent a : agents){
      Agent[] query = qtree.query(a.pos.x,a.pos.y,range+1,range+1).toArray(new Agent[0]);
      for(Agent b:query){
        if (a!=b && PVector.sub(a.pos,b.pos).magSq() <= r2){
          a.applyOutsideForce(a.attraction(b,range,strength));
        }
      }
    }
    
  }
  
  
  void repulsion(float range, float strength){repulsion(this,range,strength);}
  void repulsion(Flock repellers, float range, float strength){
    Quadtree qtree = repellers.qtree();
    float r2 = range*range;
    //qtree.debugShow();
    for (Agent a : agents){
      Agent[] query = qtree.query(a.pos.x,a.pos.y,range+1,range+1).toArray(new Agent[0]);
      for(Agent b:query){
        if (a!=b && PVector.sub(a.pos,b.pos).magSq() <= r2){
          a.applyOutsideForce(a.repulsion(b,strength));
        }
      }
    }
  }
  
  void followField(Field... fields){for (Agent a:agents){a.applyOutsideForce(a.followField(fields));}}
  
  
}
