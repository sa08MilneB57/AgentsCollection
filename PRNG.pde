class PRNG{
  long seed;
  final long a = 1140671485;
  final long c = 12820163;
  final long m = 1 << 30;
  PRNG(long _seed){seed = _seed;}
  
  void setSeed(long _seed){seed = _seed;}
  long getSeed(){return seed;}
  
  long rndLong(){
    seed = (a*seed + c) % m;
    return seed;}
  int rndInt(int size){return (int)(size * rndLong()/m);}
  double rndDouble(double size){return size*(double)(rndLong() / (double)m);}
  float rndFloat(float size){return (float)rndDouble(size);}
  
}
