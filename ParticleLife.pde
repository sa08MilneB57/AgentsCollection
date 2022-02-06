class ParticleLife {
  Flock[] species;
  Wall[] colliders = new Wall[1];
  int numOfSpecies;
  float[][] attractForceMatrix;
  float[][] attractRangeMatrix;
  float baseForce, biggest, heaviest;
  ParticleLife(int _numOfSpecies,int flockSize,float baseSize,float sizeRange){
    numOfSpecies = _numOfSpecies;
    colliders[0] = new BoxContainer();
    species = new Flock[numOfSpecies];
    attractForceMatrix = new float[numOfSpecies][numOfSpecies];
    attractRangeMatrix = new float[numOfSpecies][numOfSpecies];
    float colrate = TAU/numOfSpecies;
    heaviest = 0;
    biggest = 0;
    for(int i=0; i<numOfSpecies; i++){
      float radius = baseSize + random(sizeRange);
      float mass = radius*radius*PI;
      biggest = max(radius,biggest);
      heaviest = max(mass,heaviest);
      float Y = random(0.6) + 0.1;
      float Co = 0.5*cos(i*colrate);
      float Cg = 0.5*sin(i*colrate);
      species[i] = generateSpecies(flockSize,mass,radius,YCoCg(Y,Co,Cg,0.8));
    }
    for(int i=0; i<numOfSpecies; i++){
      for (int j=0; j<numOfSpecies; j++){
        attractForceMatrix[i][j] = heaviest * randomGaussian();
        attractRangeMatrix[i][j] = biggest * (1 + random(9f));
      }
    }
  }
  
  Flock generateSpecies(int numOfAgents,float mass,float radius,color col){
    Agent[] flock = new Agent[numOfAgents];
    for (int i=0;i<numOfAgents;i++){
      flock[i] = new Agent(random(width) - 0.5*width, random(height) - 0.5*height,mass,radius);
      flock[i].vel = randomBox(10,10);
      flock[i].col = col;
    }
    return new Flock(flock);
  }
  
  void stepTime(float dt){
    for(int i=0; i<numOfSpecies; i++){
      Flock f = species[i];
      for (int j=0; j<numOfSpecies; j++){
        Flock g = species[j];
        f.attraction(g,attractRangeMatrix[i][j],attractForceMatrix[i][j]);
        f.repulsion(g,biggest*4,16*heaviest);
      }
      for (int j=0; j<numOfSpecies; j++){
        Flock g = species[j];
        f.collideDynamic(g,3*biggest);
      }
      f.collideStatic(colliders);
      f.drag(1, 0.8);
      f.stepTime(dt);
    }
  }
  
  void clearTrapped(int stat, int dyn){
    for (Flock f : species){
      f.clearTrapped(stat,dyn);
    }
  }
  
  void show(){
    for (Flock flock : species){
      flock.show();
    }
  }
}
