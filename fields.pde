
interface Field{PVector force(Agent a);}

class RotatingWindField implements Field{
  float strength;
  RotatingWindField(float s){strength = s;}
  PVector force(Agent a){
    return a.pos.copy().rotate(PI/2f).normalize().mult(strength);
  }
}

class RotatingFrameField implements Field{
  float frequency;
  RotatingFrameField(float w){frequency = w;}
  PVector force(Agent a){
    return a.pos.copy().rotate(PI/2f).mult(-frequency*a.mass);
  }
}

class PointGravityField implements Field{
  PVector center;
  float g;
  PointGravityField(float _g){center=new PVector(0,0);g = _g;}
  PointGravityField(float centx, float centy,float _g){center=new PVector(centx,centy);g = _g;}
  PointGravityField(PVector cent,float _g){center=cent;g = _g;}
  PVector force(Agent a){
    PVector r = PVector.sub(center,a.pos);
    return r.normalize().mult(g*a.mass/r.magSq());
  }
}


class LinearGravityField implements Field{
  PVector g;
  LinearGravityField(PVector _g){g = _g;}
  LinearGravityField(float strength){g = new PVector(0,-strength);}
  LinearGravityField(float strength, float angle){g = PVector.fromAngle(angle).mult(strength);}
  PVector force(Agent a){
    return PVector.mult(g,a.mass);
  }
}

class ShakerField implements Field{
  float strength;
  float curX,curY;
  int lastFrame;
  long xseed,yseed;
  final long a = 75;
  final long c = 74;
  final long m = (2 << 16) + 1;
  ShakerField(float _strength,long Xseed,long Yseed){
    strength = _strength;
    xseed=Xseed;
    yseed=Yseed;
    lastFrame = 0;
  }
  
  long rndLong(long seed){
    return (a*seed + c) % m;
  }
  void updateFloats(){
    double dblX = (double)(xseed - m/2) / ((double)m/2d);
    double dblY = (double)(yseed - m/2) / ((double)m/2d);
    curX = (float)dblX*strength;
    curY = (float)dblY*strength;
  }
  
  PVector force(Agent a){
    if(frameCount > lastFrame){
      xseed = rndLong(xseed);
      yseed = rndLong(yseed);
      lastFrame = frameCount;
      updateFloats();
    }
    return new PVector(curX,curY).mult(a.mass);
  }
}
