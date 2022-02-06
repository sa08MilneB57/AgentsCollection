final float inroot2 = 1f/sqrt(2);

abstract class Wall implements Collider{ //Abstract class for static colliders
  void show(){}
};

class BoxContainer extends Wall{
  //defines outer walls, like a room. set to screen size for wallbouncing
  private float x1,y1,x2,y2;
  BoxContainer(){
    x2 = width/2;
    x1 = -x2;
    y2 = height/2;
    y1 = -y2;
  }
  BoxContainer(float _x1,float _y1, float _x2, float _y2){
    x1=min(_x1,_x2);
    x2=max(_x1,_x2);
    y1=min(_y1,_y2);
    y2=max(_y1,_y2);
  }
  
  void show(){}
  
  boolean collision(Agent a){
    return (a.pos.x-a.radius <= x1) ||(a.pos.x+a.radius >= x2) ||(a.pos.y-a.radius <= y1) ||(a.pos.y+a.radius >= y2);
  }
  
  PVector normal(Agent a){
    //if (!collision(a)){
    //  println("Warning- Dont check normal if not definitely a collision.");
    //  return new PVector(0,0);
    //} else {
      int kase = ((a.pos.x-a.radius <= x1)?8:0) + ((a.pos.x+a.radius >= x2)?4:0) +((a.pos.y-a.radius <= y1)?2:0) + ((a.pos.y+a.radius >= y2)?1:0);
      switch(kase){
        case 9:
          return PVector.mult(new PVector(1,-1),inroot2);
        case 1:
          return new PVector(0,-1);
        case 5:
          return PVector.mult(new PVector(-1,-1),inroot2);
        case 4:
          return new PVector(-1,0);
        case 6:
          return PVector.mult(new PVector(-1,1),inroot2);
        case 2:
          return new PVector(0,1);
        case 10:
          return PVector.mult(new PVector(1,1),inroot2);
        case 8:
          return new PVector(1,0);
        default:
          println("Weird normal error on bounding walls. Kase=" + kase);
          //a.highlight = true;
          return new PVector(0,0);
      }
    //}
  }
}

class CircleContainer extends Wall{
 private PVector pos;
 private float radius;
 private PImage imgOut;
 private color col;
 CircleContainer(float x, float y, float r, color clr){
   pos = new PVector(x,y);
   radius = r;
   col = clr;
   imgOut = createImage(width,height,ARGB);
   genImage();
 }
 
 private void genImage(){
   imgOut.loadPixels();
   for (int j=0;j<height;j++){
     for (int i=0;i<width;i++){
       int index = j*width + i;
       float relX = (i - width/2) - pos.x;
       float relY = (height/2 - j) - pos.y;
       float d = sqrt(relX*relX + relY*relY);
       if (d < radius){
         imgOut.pixels[index] = color(0,0,0,0);
       } else {
         imgOut.pixels[index] = col;         
       }
     }
   }
   imgOut.updatePixels();
 }
 
 void show(){
   pushMatrix();
   image(imgOut,-width/2,-height/2);
   popMatrix();
 }
 
 
 void setRadius(float r){
   radius = r;
   genImage();
 }
 
 boolean collision(Agent a){
   return PVector.sub(pos,a.pos).mag() >= radius - a.radius;
 }
 PVector normal(Agent a){
   return PVector.sub(pos,a.pos).normalize();
 }
 
}

class CircleWall extends Wall{
  private PVector pos;
  private float radius;
  private color col;
  CircleWall(float x, float y, float r,color clr){
    pos = new PVector(x,y);
    radius = r;
    col = clr;
  }
  void show(){
    fill(col);
    circle(pos.x,pos.y,2*radius);
  }
  
  boolean collision(Agent a){
    return PVector.sub(a.pos,pos).mag() < a.radius + radius;
  }
  
  PVector normal(Agent a){
    return PVector.sub(a.pos,pos).normalize();
  }
}
