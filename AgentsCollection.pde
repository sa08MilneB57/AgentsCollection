boolean recording = false;
final float Delta_Time = 0.125;
long lastseed;

Wall[] walls = new Wall[1];

ParticleLife sim;

PVector randomBox(float w, float h) {return new PVector(random(w)-0.5*w, random(h)-0.5*h);}
  

void setup(){
  //fullScreen();
  size(1920,1080,P2D);
  walls[0] =  new BoxContainer();
  reseed();
}

void draw(){
  fill(0, 48);
  //filter(BLUR);
  rect(-1f, -1f, width+2, height+2);
  translate(width/2,height/2);
  sim.show();
  sim.stepTime(Delta_Time);
  if(recording){saveFrame("ParticleLifeFrames/frame########.png");}
}

void reseed(){reseed((long)random(2<<24));}
void reseed(long seed){
  println(seed);
  randomSeed(seed);
  lastseed = seed;
  sim = new ParticleLife(12,500,0.5,3);
  background(0);
}

void keyPressed(){
  if(key=='s'){
    reseed();
  } else if(key=='r'){
    recording = !recording;
    if(recording){reseed(lastseed);};
  }
}
