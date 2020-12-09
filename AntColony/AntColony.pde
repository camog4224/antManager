/*
   use A* algorithm to pathfind ants from tile A to tile B, then use centers of trianlges as targets, use tower defense target
 seeking to move ant from A to B

 use either bezierVertex() or bezierPoint() to proceduraly make the textures for the game


 check if process is stupid in image compression, like if resizing a 900x900 to a
 100x100 makes it look horrible like doing the inverse would do(prob try in dif program)
 */

IntDict imageNameToIndex;

IntDict antNameToIndex;

color[] antColors;

String[] antNames;

color[] tileColors;

PImage[] allImages;

String[] imageNames;

int[] imageOpacities;

LandPlot a;
PImage background;

PVector[] multipleTargets;

// Worker ant;

Worker[] ants;


PVector[][] squareTriangles = {
  {new PVector(0, 0), new PVector(1, 1), new PVector(0, 1), new PVector(0, 0), new PVector(1, 1), new PVector(1, 0)}, //0 //1
  {new PVector(0, 1), new PVector(1, 0), new PVector(0, 0), new PVector(0, 1), new PVector(1, 0), new PVector(1, 1)}  //1 //3

};
// north, east, south, west
int[] triangleDirections = {
  0,
  0,
  1,
  1,
  2,
  2,
  3,
  3,
};

float[] angles = new float[8];

Tree tree;

void setup() {
  fullScreen(P2D);
  int numCols = 10;
  int numRows = 7;
  float xWidth = width/float(numCols);
  float yHeight = height/float(numRows);
  //float xTheta = calcXTheta(xWidth, yHeight);

  colorMode(HSB, 360, 100, 100);
  initializeArrays();

  a = new LandPlot(numCols, numRows, xWidth, yHeight);
  setupAnts();
  float[] start= {175, 7, PI/8, 1, .6, 0.1, 0.5, 0}; // start values for tree

  tree = new Tree(start);
}

IntList removeFromIntList(IntList lis, int val){
int[] tempArray = lis.array();
int valIndex = -1;
for(int i = 0; i < tempArray.length; i++){
  if(tempArray[i] == val){
    valIndex = i;
}
}
lis.remove(valIndex);
return lis;
}


void initializeArrays() {
  imageNameToIndex = new IntDict();

  String[] _imageNames = {"background", "dirt", "stone", "water"};
  int[] oTemp =              {255, 255, 255, 100};
  //load all images
  imageNames = _imageNames;
  allImages = new PImage[imageNames.length];
  imageOpacities = oTemp;
  for (int i = 0; i < imageNames.length; i++) {
    imageNameToIndex.set(imageNames[i], i);
    allImages[i] = loadImage(imageNames[i] + "_100.png");
  }

  background = allImages[imageNameToIndex.get("background")].copy();
  background.resize(width, height);

  String[] _antNames = {"worker", "queen", "fighter", "scouter"};
  color[] _antColors = {color(110, 99, 70), color(359, 99, 99), color(61, 99, 99), color(178, 99, 99)};
  antNames = _antNames;
  antColors = _antColors;

  antNameToIndex = new IntDict();

  for (int i = 0; i < antNames.length; i++) {
    antNameToIndex.set(antNames[i], i);
  }
}

void setupAnts() {
  multipleTargets = new PVector[10];
  ants = new Worker[10];
  for (int i = 0; i < ants.length; i++) {
    PVector[] tempTargets = new PVector[10];
    //for (int j = 0; j < tempTargets.length; j++) {
    //  tempTargets[j] = new PVector(random(width), random(height));
    //}
    ants[i] = new Worker(new PVector(random(width), random(height)));
    tempTargets = a.randomTriangleCenters(multipleTargets.length);
    ants[i].beginTracking(tempTargets);
  }
}

void draw() {

  //background(32, 100, 20);



  noTint();
  image(background, 0, 0);
  a.display();
  //a.highlightLandTriangleSelected(mouseX, mouseY);
  a.highLightSurroundingTriangles(mouseX, mouseY);
  //tree.display();

  // for (int i = 0; i < ants.length; i++) {
  //   ants[i].update();
  // }
}

void mouseDragged() {
  // a.changeTriangle(mouseX, mouseY);
}

void mousePressed() {
  // a.changeTriangle(mouseX, mouseY);
  // println(a.findTriangleIndex(mouseX, mouseY));
}

void keyPressed() {
  // tree.reCreate();
  a.createPath(int(random(0,20)), int(random(20,40)));
}

PVector[] PVectorListToArray(ArrayList<PVector> lis) {
  PVector[] temp = new PVector[lis.size()];
  for (int i = 0; i < temp.length; i++) {
    temp[i] = lis.get(i);
  }
  return temp;
}


PVector centerTrianglePoint(PVector[] vertexes){
  PVector centerPoint;
  float tempX = 0;
  float tempY = 0;
  for(int i = 0; i < 3; i++){
    tempX += vertexes[i].x;
    tempY += vertexes[i].y;
  }
  centerPoint = new PVector(tempX/3, tempY/3);
  return centerPoint;
}
