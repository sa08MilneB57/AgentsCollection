//final float inRoot2 = sqrt(0.5);
//final float ELASTIC = .9;
//final float repulse = 1000f;
//final float SHAKESTRENGTH = 160;
//final float deltaTime = 0.125/4f;
//Wall[] obstacles = new Wall[1];
//Agent[] agentiae;
//Flock flock;
//RotatingFrameField wind = new RotatingFrameField(0.0);
//LinearGravityField grav = new LinearGravityField(2);
//ShakerField shake = new ShakerField(0, 2893, 9712);
//boolean recording = false;
//float SPREAD = 0.5f;
//PVector startPoint;
//int FLOCKSIZE = 400;
//float agentColorRate = TAU/(float)FLOCKSIZE;
//float MAXSPEED = 64;
//float AGENTRADIUS = 12;
//float biggestAgent = 0f;
//int bgcolor = 0;

//float circleMass(float r, float density) {
//  return r*r*PI*density;
//}

//void setup() {
//  fullScreen();
//  //size(600,500);
//  //blendMode(BLEND);
//  background(bgcolor);
//  randomSeed(3);
//  obstacles[0] =  new BoxContainer();
//  //obstacles[1] =  new CircleWall(0,0,50,color(10));
//  //obstacles[0].col = color(255);
//  agentiae = new Agent[FLOCKSIZE];
//  for (int i=0; i<FLOCKSIZE; i++) {
//    //PVector r = new PVector(cos(1*i*agentColorRate),
//    //                        sin(1*i*agentColorRate)).mult(0.5*SPREAD*min(width,height) + AGENTRADIUS*sin(FLOCKSIZE/6*i*agentColorRate));
//    PVector r = randomBox(SPREAD*width, SPREAD*height);
//    float agentSize = max(4, AGENTRADIUS + randomGaussian()*2);
//    biggestAgent = max(agentSize*agentSize, biggestAgent);
//    agentiae[i] = new Agent(r.x, r.y, circleMass(agentSize, 1), agentSize);
//    //agentiae[i].vel = agentiae[i].pos.copy().rotate(PI/2);
//    agentiae[i].col = HSL(i*agentColorRate, 1, 0.5, 0.8);
//  }
//  flock = new Flock(agentiae);
//}

//void draw() {
//  //blendMode(BLEND);
//  fill(bgcolor, 120);
//  //filter(BLUR);
//  rect(-1f, -1f, width+2, height+2);
//  translate(width/2f, height/2f);
//  //rotate(-frameCount*deltaTime*0.2);

//  if (mousePressed) {
//    for (int i=0; i<FLOCKSIZE; i++) {
//      agentiae[i].applySelfForce(agentiae[i].seek(mouseX-width/2, height/2-mouseY, agentiae[i].maxForce));
//    }
//  }

//  //blendMode(HARD_LIGHT);

//  flock.followField(grav, wind, shake);
//  flock.drag(0.9, 0.5);

//  //obstacles[0].radius += 0.01;
//  for (Wall o : obstacles) {
//    o.show();
//  }

//  flock.repulsion(biggestAgent, repulse*flock.avgMass*flock.avgRadius);
//  flock.collideDynamic(2*biggestAgent + 1, ELASTIC);
//  flock.collideStatic(obstacles, ELASTIC);

//  //flock.clearTrapped(1000,0);

//  flock.stepTime(deltaTime);
//  flock.show();
//  //if(recording){saveFrame("GravityBallFrames/GravityBall########.png");}
//}

//void keyPressed() {
//  if (key=='r') {
//    recording = !recording; 
//    println(recording);
//  } else if (key=='f') {
//    println("FPS:", frameRate, "Hz\tDeltaTime", 1f/frameRate, "s");
//  } else if (key=='s') {
//    shake.strength = SHAKESTRENGTH;
//  }
//}

//void keyReleased() {
//  if (key=='s') {
//    shake.strength = 0;
//  }
//}
