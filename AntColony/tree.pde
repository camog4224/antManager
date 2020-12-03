

class Tree {
  boolean hide = false;
  float  prog = 1;
  boolean  growing = false;
  boolean mutating = false;
  int  randSeed = 80;
  float  randBias = 0;

  float size; 
  int maxLevel;
  float rot;
  float lenRand;
  float branchProb;
  float rotRand;
  float leafProb;

  PVector[] p1;
  PVector[] p2;
  float[] branchWidths;

  ArrayList<PVector> p1T;
  ArrayList<PVector> p2T;
  FloatList branchWidthsT;


  Tree(float[] start) {
    updateVals(start);
    reCreate();
  }

  void reCreate() {
    p1T = new ArrayList<PVector>();
    p2T = new ArrayList<PVector>();
    branchWidthsT = new FloatList();

    startGrow();
    makeBranch(1, 0, new PVector(width/2, 0), 0);
    p1 = PVectorListToArray(p1T);
    p2 = PVectorListToArray(p2T);
    branchWidths = branchWidthsT.array();
    
  }

  void display() {
    for (int i = 0; i < p1.length; i++) {
      stroke(color(32, 100, 0));
      strokeWeight(branchWidths[i]);
      line(p1[i].x, p1[i].y, p2[i].x, p2[i].y);
    }
  }

  void mutate()
  {
    int startTime = millis();

    float n = noise(startTime / 20000) - 0.5;

    randBias = 4 * abs(n) * n * (mutating ? 1 : 0);

    randomSeed(randSeed);
    readInputs(true);

    int diff = millis() - startTime;

    if ( diff < 20 )
      
      mutate();
    else
      
      mutate();
  }

  void readInputs(boolean updateTree)
  {

    if ( updateTree && !growing )
    {
      prog = maxLevel + 1;
      loop();
    }
  }

  void makeBranch(int level, float seed, PVector lastC, float rOld)
  {

    if ( prog < level ) {

      return;
    }
    //randomSeed(seed);

    float seed1 = random(1000);
    float  seed2 = random(1000);

    float growthLevel = (int(prog) - level > 1) || (int(prog) >= maxLevel + 1) ? 1 : (int(prog) - level);

    float lineSize = 22 * pow((float(maxLevel) - float(level) + 1) / float(maxLevel), 2);

    branchWidthsT.append(lineSize);

    float len = growthLevel * size* (1 + rand2() * lenRand);

    p1T.add(lastC.copy());

    PVector newTemp = new PVector(0, len/float(level)).rotate(rOld);
    PVector newC = PVector.add(lastC, newTemp);
    p2T.add(newC);

    boolean doBranch1 = rand() < branchProb;
    boolean doBranch2 = rand() < branchProb;

    boolean doLeaves = rand() < leafProb;


    if ( level < maxLevel )
    {

      float r1 = rot * (1 + rrand() * rotRand);
      float r2 = -rot * (1 - rrand() * rotRand);


      if ( doBranch1 )
      {


        makeBranch(level + 1, seed1, newC, r1 + rOld);
      }
      if ( doBranch2 )
      {

        makeBranch(level + 1, seed2, newC, r2 + rOld);
      }
    }
  }

  void startGrow()
  {
    growing = true;
    prog = 1;
    grow();
  }


  void grow()
  {

    if ( prog > (maxLevel + 3) )
    {
      prog = maxLevel + 3;
      loop();
      growing = false;
      return;
    }

    int startTime = millis();
    loop();
    int diff = millis() - startTime;

    prog += float(maxLevel) / 8 * max(diff, 20) / 1000.;
    grow();
  }


  float rand()
  {
    return random(1000) / 1000;
  }

  float rand2()
  {
    return random(2000) / 1000 - 1;
  }

  float rrand()
  {
    return rand2() + randBias;
  }

  void updateVals(float[] vals) {
    size = vals[0]; //   1 
    maxLevel = int(vals[1]); //  2
    rot = vals[2]; //   3
    lenRand = vals[3]; //  4
    branchProb = vals[4];//5
    rotRand = vals[5];// 6
    leafProb = vals[6];//7
  }
}
