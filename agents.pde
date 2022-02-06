interface Target {
  PVector getPos();
}
interface MovingTarget extends Target {
  PVector getVel();
}
interface Collider{
  boolean collision(Agent a);//returns true if collision detected
  PVector normal(Agent a);//returns unit surface normal
}


class Agent implements MovingTarget , Collider{  
  PVector pos, vel, acc, force;
  float mass, radius, lifetime;
  float maxForce = 500;
  color col;
  int staticCollisionCount,agentCollisionCount;
  boolean highlight;
  Agent(float x, float y, float m, float r) {
    pos = new PVector(x,y);
    vel = new PVector(0,0);
    acc = new PVector(0f, 0f);
    force = new PVector(0f, 0f);//for self produced forces, not external ones, like drag. They should apply directly to acceleration.
    mass=m; 
    radius=r; 
    lifetime=0; 
    staticCollisionCount=0;
    agentCollisionCount=0;
    highlight = false;
    col = color(255);
  }
  PVector getPos(){return pos.copy();}
  PVector getVel(){return vel.copy();}
  float getKE(){return 0.5*mass*vel.magSq();}

  void show() {
    fill(col);
    if(highlight){
      strokeWeight(1);
      stroke(color(255));
    } else {
      noStroke();
    }
    circle(pos.x, -pos.y, 2*radius);
    
    //strokeWeight(1);
    //stroke(col);
    //line(pos.x, -pos.y, pos.x + vel.x, -pos.y - vel.y);
    highlight = false;
  }
  
  void applyOutsideForce(PVector f) {
    acc = PVector.add(acc, f.div(mass));
  }
  void applyOutsideForce(PVector... fs) {
    for (PVector f : fs) {acc = PVector.add(acc, f.div(mass));}
  }
  
  void applySelfForce(PVector f) {
    force = PVector.add(force, f);
  }
  void applySelfForce(PVector... fs) {
    for (PVector f : fs) {force = PVector.add(force, f);}
  }

  PVector steering(PVector desiredVelocity) {
    PVector steer = desiredVelocity.sub( vel );
    return steer;
  }

  void stepTime(float dt) {
    acc = PVector.add(acc, PVector.mult(force.limit(maxForce), 1f/mass));
    vel = PVector.add(vel, PVector.mult(acc, dt) );
    pos = PVector.add(pos, PVector.mult(vel, dt));
    if(pos.x == Float.NaN || pos.y == Float.NaN){
      println("Pos:",pos);
      println("Vel:",vel);
      println("Acc:",acc);
      println("Frc:",force);
    }
    acc = new PVector(0f, 0f);
    force = new PVector(0f,0f);
    lifetime += dt;
  }

  ///===============Exterior Forces======================
  PVector drag(float lin, float quad){
    PVector direction = PVector.mult(vel,-1).normalize();
    float mag2 = vel.magSq();
    return PVector.add(PVector.mult(direction,lin*sqrt(mag2)) , PVector.mult(direction,quad*mag2) );
  }
  
  boolean trapped(int stat,int dyn){
    if (stat < 1){stat=Integer.MAX_VALUE;}
    if (dyn < 1){dyn=Integer.MAX_VALUE;}
    return staticCollisionCount > stat || agentCollisionCount > dyn;
  }
  
  PVector repulsion(Agent repeller,float strength){
    PVector r = PVector.sub(pos,repeller.pos);
    float rmag = r.mag();
    float mult = strength/max(1,rmag*rmag*rmag);
    r = PVector.mult(r,mult);
    return r;
  }
  
  PVector attraction(Agent repeller,float range,float strength){return attraction(repeller,0,range,strength);}
  PVector attraction(Agent repeller,float minRange,float maxRange,float strength){
    if (minRange >= maxRange){throw new IllegalArgumentException("minrange must be less than maxRange.");}
    float midpoint = 0.5*(minRange + maxRange);
    float dscaling = 0.5*(maxRange - minRange);
    PVector r = PVector.sub(repeller.pos,pos);
    float rmag = r.mag();
    float d = ((rmag - midpoint)/dscaling);
    float mag = strength*max(0, 1 - d*d );
    r = PVector.mult(r,mag/rmag);
    return r;
  }
  
  
  //=============COLLISIONS Run after applying forces, but before stepTime===========
  void collideStatic(Collider o){collideStatic(o,1);}
  void collideStatic(Collider o,float elasticity){
    staticCollisionCount++;
    PVector n = o.normal(this);
    if (PVector.dot(n,vel) > 0){return;}
    if (PVector.dot(n,acc) < 0){acc = PVector.sub(acc,PVector.mult(n,PVector.dot(n,acc)));}
    vel = PVector.add(vel, PVector.mult(n, -2*PVector.dot(vel, n))).mult(elasticity);
  }
  
  void collideStatic(Collider[] o){collideStatic(o,1);}
  void collideStatic(Collider[] obstacles,float elasticity) {
    for (Collider o : obstacles) {
      if (o.collision(this)) {
        collideStatic(o,elasticity);
        return;
      }
    }
    staticCollisionCount = 0;
  }
  void collideAgent(Agent o){collideAgent(o,1,true);}
  void collideAgent(Agent o,float elasticity){collideAgent(o,elasticity,true);}
  void collideAgent(Agent o,float elasticity, boolean applyToOther){
    PVector normal = normal(o);
    PVector tangent = new PVector(-normal.y,normal.x);
    PVector v1 = getVel();
    PVector v2 = o.getVel();
    float v1n = PVector.dot(v1,normal);
    
    if (PVector.dot(PVector.sub(v1,v2),normal) < 0) {return;}
    if (PVector.dot(normal,acc) < 0){acc = PVector.sub(acc,PVector.mult(normal,PVector.dot(normal,acc)));}
    agentCollisionCount++;
    
    float v1t = PVector.dot(v1,tangent);
    float v2n = PVector.dot(v2,normal);
    
    if (applyToOther){o.collideAgent(this,elasticity,false);}
    
    v1n = elasticity * (v1n*(mass-o.mass) + 2*o.mass*v2n) / (mass + o.mass);
    vel = PVector.add( PVector.mult(normal,v1n) , PVector.mult(tangent,v1t));
  }
  void collideAgent(Agent[] others){collideAgent(others,1);}
  void collideAgent(Agent[] others,float elasticity){
    boolean collided = false;
    for(Agent o : others){
      if (this!=o && o.collision(this)){
        collideAgent(o,elasticity);
        collided = true;
        //return;
      }
    }
    if(!collided){agentCollisionCount = 0;}
  }
  boolean collision(Agent other){
    float thresh = radius + other.radius;
    thresh *= thresh;
    float dist2 = PVector.sub(getPos(),other.getPos()).magSq();
    return dist2 <= thresh;
  }
  PVector normal(Agent a){return PVector.sub(a.getPos(),getPos()).normalize();}
  
  ///===============Self-Propulsion======================
  PVector seek(float x, float y, float targetSpeed) {return seek(new PVector(x, y), targetSpeed);}
  PVector seek(Target tgt, float targetSpeed) {return seek(tgt.getPos(), targetSpeed);}
  PVector seek(PVector tgt, float targetSpeed) {return steering(PVector.sub(tgt, getPos()).normalize().mult(targetSpeed));}

  PVector flee(float x, float y, float targetSpeed) {return seek(x, y, -targetSpeed);}
  PVector flee(Target tgt, float targetSpeed) {return seek(tgt, -targetSpeed);}
  PVector flee(PVector tgt, float targetSpeed) {return seek(tgt, -targetSpeed);}

  PVector pursue(MovingTarget tgt, float targetSpeed){return pursue(tgt,targetSpeed,1);}
  PVector pursue(MovingTarget tgt, float targetSpeed, float maxPredictionTime) {
    float ETA = PVector.sub(tgt.getPos(), getPos()).mag() / PVector.sub(getVel(), tgt.getVel()).mag();//rough calculation assumes velocity is perfectly approaching the tgt
    PVector estimate = PVector.add(tgt.getPos(), PVector.mult(tgt.getVel(), min(ETA,maxPredictionTime)));//where tgt'd be if this arrived
    return seek(estimate, targetSpeed);
  }
  PVector evade(MovingTarget tgt, float targetSpeed) {return pursue(tgt,-targetSpeed,1);}
  PVector evade(MovingTarget tgt, float targetSpeed, float maxPredictionTime) {return pursue(tgt, -targetSpeed, maxPredictionTime);}
  
  PVector perturb(float strength){return getVel().rotate(PI/2f).mult(strength*0.5*randomGaussian());}
  PVector jiggle(float strength){return PVector.random2D().mult(strength);}
  //PVector wander(){}
  //PVector arrival(Agent tgt,float thresholdDistance){}
  //PVector seperation(){}
  //PVector alignment(){}
  //PVector cohesion(){}
  //PVector obstacleAvoidance(){}
  //PVector containment(){}
  //PVector followWall(Wall wall){}
  //PVector followPath(Path path){}
  PVector followField(Field field){return field.force(this);}
  PVector followField(Field... fields){
    PVector out = new PVector(0,0);
    for(Field field:fields){
      out.add(field.force(this));
    }
    return out;
  }
}
