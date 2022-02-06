import java.util.HashSet;

class Quadtree{ //Data structure for storing objects in 2D
  Quadtree nw,ne,sw,se; //children
  Quadtree parent;
  ArrayList<Target> contents;//contents of THIS branch only, child object contents not included
  float x,y,w,h;//center point, half-width and half-height
  boolean divided;  //false if leaf node
  static final int capacity = 8; //controls maximum capacity all quadtree nodes for case-by-case tuning 
  
  Quadtree(){//By default fills whole screen
    x=0;
    y=0;
    w=(float)width/2f;
    h=(float)height/2f;
    contents = new   ArrayList<Target>();
    }
  Quadtree(float X, float Y, float W, float H){//specify location as rectangle
    x=X;
    y=Y;
    w=W;
    h=H;
    contents = new ArrayList<Target>();
    }
  
  
  Quadtree quadrant(float X, float Y){// returns child containing point(X,Y)   do not call when undivided
      int hPos = ((double)X - (double)x> 0)?1:0;//0 for west 1 for east
      int vPos = ((double)Y - (double)y > 0)?2:0;//0 for north 2 for south
      switch (hPos +vPos){
        case 0://nw
          return nw;
        case 1://ne
          return ne;
        case 2://sw
          return sw;
        case 3://se
          return se;
      }
      return null;//should be unreachable
  }
  
  void add(Target p){//adds a new object to appropriate node's contents
    PVector pos = p.getPos();
    if (!contains(pos.x,pos.y)){
      return;
      //throw new IllegalArgumentException("Point beyond bounds of Quadtree. (" + Float.toString(pos.x) + "," + Float.toString(pos.y) +
      //                                ")\nExpectedRegion x:" + Float.toString(x) + " y:"+ Float.toString(y) + " hw:" + Float.toString(w) +" hh:"+ Float.toString(h) +
      //                                ")\nBounded By w:" + Float.toString(x-w) + " n:"+ Float.toString(y+h) + " e:" + Float.toString(x+w) +" s:"+ Float.toString(y-h));
    }
    if (contents.size() < capacity){
      contents.add(p);
    } else {
      if (!divided){subdivide();}
      quadrant(pos.x,pos.y).add(p);
    }
  }
  
  boolean contains(float pX, float pY){//Do my borders contain the point (pX,pY)
    return (pX <= x+w+0.1) && (pX >= x-w-0.1) 
        && (pY <= y+h+0.1) && (pY >= y-h-0.1);
  }
  
  boolean intersects(float rX, float rY, float rW, float rH){//Do I intersect with the rectangle defined by rX,rY,rW,rH?
    if(rW<=0 || rH <= 0){throw new IllegalArgumentException("Negative width/height region not accepted.");}
    return !(rX-rW >= x+w || rX+rW <= x-w 
          || rY-rH >= y+h || rY+rH <= y-h);}
          
  //return all Targets inside a rectangular region
  HashSet<Target> query(float X, float Y, float W, float H){
    return query(X,Y,W,H,new HashSet<Target>());}
  HashSet<Target> query(float X, float Y, float W, float H, HashSet<Target> found){
    if(W<=0 || H <= 0){throw new IllegalArgumentException("Negative width/height region not accepted.");}
    
    if (!intersects(X,Y,W,H)){ //if no intersection, return arraylist unmodified
      return found;
    } else {  //if intersection, check contents for Targets within the region
      for (Target p : contents){
        PVector pos = p.getPos();
        if ( (pos.x <= X+W) && (pos.x >= X-W) //capitals refer to search region
          && (pos.y <= Y+H) && (pos.y >= Y-H) ){
          found.add(p);}
      }
      if (divided){ //after checking own contents, recursively query children appending to same array
        nw.query(X,Y,W,H,found);
        ne.query(X,Y,W,H,found);
        sw.query(X,Y,W,H,found);
        se.query(X,Y,W,H,found);}
      return found;
    }
  }
  
  void subdivide(){
    if (!divided){
      nw = new Quadtree(x - w/2f,y - h/2f,w/2f,h/2f);
      ne = new Quadtree(x + w/2f,y - h/2f,w/2f,h/2f);
      sw = new Quadtree(x - w/2f,y + h/2f,w/2f,h/2f);
      se = new Quadtree(x + w/2f,y + h/2f,w/2f,h/2f);
      divided = true;
      nw.parent = this;
      ne.parent = this;
      sw.parent = this;
      se.parent = this;
    } else {
      throw new IllegalStateException("Quadtree is already split.");
    }
  }
  
  void debugShow(){
    rectMode(RADIUS);
    noFill();
    stroke(0,200,0,30);
    strokeWeight(.5);
    rect(x,-y,w,h);
    //showContents();
    if (divided){
      nw.debugShow();      ne.debugShow();
      sw.debugShow();      se.debugShow();}
  }
}
