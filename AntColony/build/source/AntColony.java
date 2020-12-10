import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class AntColony extends PApplet {

/*
   use A* algorithm to pathfind ants from tile A to tile B, then use centers of trianlges as targets, use tower defense target
 seeking to move ant from A to B

 use either bezierVertex() or bezierPoint() to proceduraly make the textures for the game


 check if process is stupid in image compression, like if resizing a 900x900 to a
 100x100 makes it look horrible like doing the inverse would do(prob try in dif program)
 */

IntDict imageNameToIndex;

IntDict antNameToIndex;

int[] antColors;

String[] antNames;

int[] tileColors;

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

public void setup() {
  
  int numCols = 30;
  int numRows = 15;
  float xWidth = width/PApplet.parseFloat(numCols);
  float yHeight = height/PApplet.parseFloat(numRows);
  //float xTheta = calcXTheta(xWidth, yHeight);

  colorMode(HSB, 360, 100, 100);
  initializeArrays();

  a = new LandPlot(numCols, numRows, xWidth, yHeight);
  setupAnts();
  float[] start= {175, 7, PI/8, 1, .6f, 0.1f, 0.5f, 0}; // start values for tree

  tree = new Tree(start);
}

public IntList removeFromIntList(IntList lis, int val){
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


public void initializeArrays() {
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
  int[] _antColors = {color(110, 99, 70), color(359, 99, 99), color(61, 99, 99), color(178, 99, 99)};
  antNames = _antNames;
  antColors = _antColors;

  antNameToIndex = new IntDict();

  for (int i = 0; i < antNames.length; i++) {
    antNameToIndex.set(antNames[i], i);
  }
}

public void setupAnts() {
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

public void draw() {

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

public void mouseDragged() {
  // a.changeTriangle(mouseX, mouseY);
}

public void mousePressed() {
  // a.changeTriangle(mouseX, mouseY);
  // println(a.findTriangleIndex(mouseX, mouseY));
}

int start;
int end;

public void keyPressed() {
  // tree.reCreate();
  if(key == 'q'){
start = a.findTriangleIndex(mouseX, mouseY);
  }else if(key == 'w'){
end = a.findTriangleIndex(mouseX, mouseY);
  }else if(key == ' '){
    a.createPath(start, end);
  }

}

public PVector[] PVectorListToArray(ArrayList<PVector> lis) {
  PVector[] temp = new PVector[lis.size()];
  for (int i = 0; i < temp.length; i++) {
    temp[i] = lis.get(i);
  }
  return temp;
}


public PVector centerTrianglePoint(PVector[] vertexes){
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

class Entity {
  boolean dead;
  float maxHealth;
  float currentHealth;
  float damage;
  Entity() {
    dead = false;
    maxHealth = 100;
    currentHealth = maxHealth;
    damage = 10;
  }

  //the enemy changing through time
  public void update() {
  }
  //the enemies
  public void checkCollision() {
  }

  public boolean checkRectCollision(float x, float y, float w, float h) {
    return false;
  }
  public boolean checkCircCollision(float x, float y, float r) {
    return false;
  }

  public void displayHealth(float x, float y, float Length, float Height) {
    float healthBarTotalLength = Length;
    float healthLeft = map(currentHealth, 0, maxHealth, 0, healthBarTotalLength);
    stroke(0);
    strokeWeight(1);
    rectMode(CORNER);
    //green health
    fill(122, 60, 95);
    rect(x, y, healthLeft, Height);
    //red health
    fill(359, 99, 99);
    rect(x+ healthLeft, y, healthBarTotalLength-healthLeft, Height);
  }

  public void checkAlive() {
    if (currentHealth <= 0) {
      dead = true;
    }
  }
}
class Insect extends Entity {
  PVector location, velocity, acceleration;
  float maxSpeed;
  float maxForce;
  float mass;
  PVector currentDir;
  int targetIndex; // in its list of targets, which one is it moving towards currently
  PVector actualTarget;
  PVector pathTarget;
  PVector[] destinations;
  float l, w;
  Insect(PVector _location) {
    super();
    l = 10;
    w = 10;
    location = _location.copy();
    targetIndex = -1;
    velocity = PVector.random2D().setMag(2);
    acceleration = new PVector(0, 0);
    maxSpeed = 2;
    maxForce = 5;
    mass = 1;
  }

  public void displayDebugInfo() {
    stroke(0);
    strokeWeight(1);
    // float len = velocity.mag();
    float stetch = 20.f;
    line(location.x, location.y, location.x + stetch*velocity.x, location.y + stetch*velocity.y);

    stroke(100);
    strokeWeight(20);
    point(actualTarget.x, actualTarget.y);
  }

  public void update() {
    // println(targetIndex, destinations[targetIndex].x, destinations[targetIndex].y);
    if (targetIndex != -1) {
      changeTarget();
      seek(actualTarget);
      move();
    }

    display();
    displayDebugInfo();
    // println(velocity.x, velocity.y);
  }

  public void beginTracking(PVector[] _destinations) {
    targetIndex = 0;
    destinations = _destinations;
    pathTarget = destinations[targetIndex];
    calcTarget();
    seek(actualTarget);
  }
  //dont fill, all child classes will have their own display function
  public void display() {
  }

  public void move() {
    velocity.add(acceleration);
    velocity.limit(maxSpeed);
    location.add(velocity);
    acceleration.mult(0);
  }

  public void applyForce(PVector dir) {
    PVector modified = dir.copy().div(mass);
    acceleration.add(modified);
  }

  public void seek(PVector target) {
    PVector dir = PVector.sub(target, location);
    dir.limit(maxSpeed);
    PVector goodDir = PVector.sub(dir, velocity);
    //tyring to make them turn slowly towards the user
    goodDir.limit(maxForce);
    applyForce(goodDir);
  }

  public void changeTarget() {
    // println("tried");
    if (reached(actualTarget) == true) {
      // println("changed target");
      targetIndex++;
      if (targetIndex >= destinations.length) {
        targetIndex = -1;
      } else {
        pathTarget = destinations[targetIndex].copy();
        calcTarget();
      }
    }
  }

  public void calcTarget() {
    float x = pathTarget.x;
    float y = pathTarget.y;
    float margin = 1;
    x += random(-margin, margin);
    y += random(-margin, margin);
    actualTarget = new PVector(x, y);
  }

  public boolean reached(PVector toGo) {

    float left = location.x - w/2;
    float right = location.x + w/2;
    float top = location.y - l/2;
    float bottom = location.y + l/2;
    float x = toGo.x;
    float y = toGo.y;
    if (x >= left && x <= right && y >= top && y <= bottom) {
      return true;
    }

    return false;
  }
}

class Aphid extends Insect {
  Aphid(PVector _location) {
    super(_location);
  }
}

class Ant extends Insect {
  String antType;
  int c;
  Ant(PVector _location) {
    super(_location);
  }
  public void display() {
    noStroke();
    fill(c);
    ellipse(location.x, location.y, l, w);
  }

  public void setColor() {
    c = antColors[antNameToIndex.get(antType)];
  }
}

//builds/destroys things for colony
class Worker extends Ant {
  Worker(PVector _location) {
    super(_location);
    antType = "worker";
    setColor(); // FIRGURE OUT SOME WAY TO NOT NEED TO CALL THIS MANUALLY IN EVERY CHILD OF THE ANT PARENT CLASS
  }
}
// makes ants
class Queen extends Ant {
  Queen(PVector _location) {
    super(_location);
    antType = "queen";
    setColor();
  }
}
// fights other ants
class Fighter extends Ant {
  Fighter(PVector _location) {
    super(_location);
    antType = "fighter";
    setColor();
  }
}
// looks for resources
class Scouter extends Ant {
  Scouter(PVector _location) {
    super(_location);
    antType = "scouter";
    setColor();
  }
}

class Segment extends Entity {
  PVector start, end;
  PVector currentDir;
  float angle;
  float Length;
  float Width;
  //PVector[] positions;
  Segment(PVector _start, float _Length, float _Width) {
    start = _start.copy();
    Length = _Length;
    Width = _Width;
    end = new PVector(start.x + Length, start.y);
    //positions = new PVector[2];
    //positions[0] = start;
    //positions[1] = end;
    // println("SEGMENT MADE");
  }

  public boolean checkSegmentCollision(float iX, float iY, float iXLen, float iYLen) {
    boolean total = false;
    float x = (start.x + end.x)/2;
    float y = (start.y + end.y)/2;
    PVector dist = PVector.sub(start, end);
    float xLen = abs(dist.x);
    float yLen = abs(dist.y);
    total = rectRectCollision(iX, iY, iXLen, iYLen, x, y, xLen, yLen);
    return total;
  }
  //this is a mess
  public void followTarget(PVector target, int index) {
    PVector direction;
    if (index == 0) {
      direction = PVector.sub(target, start);
    } else {
      direction = PVector.sub(target, end);
    }

    direction.setMag(Length).mult(-1);

    if (index == 0) {
      start = PVector.add(target, direction);
      end = target.copy();
    } else {
      end = PVector.add(target, direction);
      start = target.copy();
    }
  }

  public void update() {
    float speed = 10;
    float x = end.x + speed*randomGaussian();
    float y = end.y + speed*randomGaussian();
    PVector target = new PVector(x, y);
    followTarget(target, 0);
    display();
  }

  public void display() {
    stroke(0, 100);
    strokeWeight(Width);
    line(start.x, start.y, end.x, end.y);
    strokeWeight(5);
    stroke(100);
    point(start.x, start.y);
    //stroke(100);
    point(end.x, end.y);

    // displayHealth(start.x, start.y, Length);
  }

  public void receiveHit(float damage) {
    currentHealth -= damage;
    checkAlive();
  }
}

class WormMob extends Entity {
  Segment[] segments;
  PVector currentDirection;
  float speed = 10;
  PVector begining;
  boolean hasDeadSegment = false;
  int deadSegmentIndex = -1;
  WormMob(PVector _start, int numSegments, float segmentLengths, float segmentWidths) {
    super();
    segments = new Segment[numSegments];
    begining = _start.copy();
    PVector location = new PVector();
    // println("WORM MADE");
    currentDirection = PVector.random2D().mult(speed);
    for (int i = 0; i < segments.length; i++) {
      location.set(begining.x + i*segmentLengths, begining.y);
      segments[i] = new Segment(location, segmentLengths, segmentWidths);
    }
  }
  //this is only used is snakes where new worms are made when the snake is broken at parts
  //so this worm mob cant anchor to anywhere
  WormMob(Segment[] _segments) {

    super();
    segments = _segments;
    currentDirection = PVector.random2D().mult(speed);
    // begining = start.copy();
  }

  public void anchor() {
    int last = 0;
    int first = segments.length-1;

    segments[last].followTarget(begining.copy(), 1);
    //segments[0].follow = begining.copy();
    for (int i = last+1; i <= first; i++) {
      segments[i].followTarget(segments[i-1].end, 1);
    }
  }
  //when a worm is hit
  public void receiveHitWorm(float damage, float x, float y, float xLen, float yLen) {
    //at least 1 segment was hit
    if (checkWormCollision(x, y, xLen, yLen).length > 0) {
      currentHealth -= damage;
      checkAlive();
    }
  }
  //when a snake part is hit
  public void receiveHitSegment(float damage, float x, float y, float xLen, float yLen) {
    int[] targets = checkWormCollision(x, y, xLen, yLen);
    for (int i = 0; i < targets.length; i++) {
      Segment a = segments[targets[i]];
      a.receiveHit(damage);
      if (a.dead == true) {
        hasDeadSegment = true;
        deadSegmentIndex = targets[i];
      }
    }
  }

  //returns the indices of the segment that is colliding with the given rectangle
  public int[] checkWormCollision(float iX, float iY, float iXLen, float iYLen) {
    int[] result;
    IntList indices = new IntList();
    boolean total = false;
    for (int i = 0; i < segments.length; i++) {
      Segment a = segments[i];
      a.checkSegmentCollision(iX, iY, iXLen, iYLen);
      if (a.checkSegmentCollision(iX, iY, iXLen, iYLen) == true) {
        total = true;
        indices.append(i);
      }
    }

    result = indices.array();
    return result;
  }

  public boolean checkInsideStage() {
    //checking to see if all segment indices were returned to be collising with
    Segment last = segments[segments.length - 1];
    PVector point = last.end;
    float margin = 100;
    float leftS = -margin;
    float rightS = width + margin;
    float topS = -margin;
    float bottomS = height + margin;
    if (point.x > rightS || point.x < leftS || point.y > bottomS || point.y < topS) {
      return false;
    }
    return true;
  }

  public void wander(PVector safePlace) {

    if (checkInsideStage() == true) {
      currentDirection.rotate(0.2f*randomGaussian());
    } else {
      PVector toCenter = PVector.sub(segments[segments.length-1].end, safePlace);
      currentDirection = toCenter.copy().normalize().rotate(radians(180)).mult(speed);
    }
  }

  public void move() {
    followTarget(PVector.add(segments[segments.length-1].end, currentDirection));
  }

  public void followTarget(PVector target) {
    segments[segments.length-1].followTarget(target, 0);
    for (int i = segments.length-2; i >= 0; i--) {
      segments[i].followTarget(segments[i+1].start, 0);
    }
  }

  public void display(boolean showEachSegment) {

    for (int i = 0; i < segments.length; i++) {
      Segment a = segments[i];

      float x = a.end.x;
      float y = a.end.y;
      float xLen = a.Length;
      float yLen = a.Width;
      if (showEachSegment == false) {
        displayHealth(x, y, xLen, yLen);
      } else {
        a.displayHealth(x, y, xLen, yLen);
      }

      a.display();
    }
  }

  public void update() {
    if (segments.length > 0) {
      wander(new PVector(0, 0));
      move();
      display(false);
    }
  }
}

class Snake extends Entity {
  ArrayList<WormMob> parts = new ArrayList<WormMob>();
  Snake(PVector start, int segmentNum, float segmentLengths, float segmentWidths) {
    super();
    WormMob first = new WormMob(start, segmentNum, segmentLengths, segmentWidths);
    parts.add(first);
  }


  public void update() {
    for (int i = 0; i < parts.size(); i++) {
      WormMob a = parts.get(i);
      if (a.segments.length > 0) {
        a.wander(new PVector(0, 0));
        a.move();
        a.display(true);
      }
      if (a.hasDeadSegment == true) {
        // println("SOMETHING HAS SPLIT");
        subDivide(i, a.deadSegmentIndex);
      }
    }
  }

  public void subDivide(int wormIndex, int segmentIndex) {
    //this wormsegment dies here
    WormMob parent = parts.get(wormIndex);

    if (parent.segments.length > 2) {
      Segment[] segmentsL = (Segment[]) subset(parent.segments, 0, segmentIndex);
      Segment[] segmentsR = (Segment[]) subset(parent.segments, segmentIndex+1);
      WormMob left = new WormMob(segmentsL);
      WormMob right = new WormMob(segmentsR);
      parts.remove(wormIndex);
      parts.add(wormIndex, left);
      parts.add(wormIndex+1, right);
    } else if (parent.segments.length == 2) {
      Segment[] segs = {parent.segments[PApplet.parseInt(map(segmentIndex, 0, 1, 1, 0))]};
      WormMob newParent = new WormMob(segs);
      parts.set(wormIndex, newParent);
    } else if (parent.segments.length == 1) {
      parts.remove(wormIndex);
    }
  }
}


// CIRCLE/RECTANGLE FOR CENTER RECT
public boolean circleRect(float cx, float cy, float radius, float rx, float ry, float rw, float rh) {

    // temporary variables to set edges for testing
    float testX = cx;
    float testY = cy;


    float rLeft = rx - rw/2;
    float rRight = rx + rw/2;
    float rTop = ry - rh/2;
    float rBottom = ry + rh/2;

    // which edge is closest?
    if (cx < rLeft) testX = rLeft;                                                                                  // test left edge
    else if (cx > rRight) testX = rRight;                                                                                         // right edge
    if (cy < rTop) testY = rTop;                                                                                // top edge
    else if (cy > rBottom) testY = rBottom;                                                                                           // bottom edge

    // get distance from closest edges
    float distX = cx-testX;
    float distY = cy-testY;
    float distance = sqrt( (distX*distX) + (distY*distY) );

    // if the distance is less than the radius, collision!
    if (distance <= radius) {
         return true;
     }
    return false;
}

// RECTANGLE/RECTANGLE GIVEN CENTER RECT
public boolean rectRectCollision(float x1, float y1, float w1, float h1, float x2, float y2, float w2, float h2) {

    float top1 = y1 - h1/2;
    float bottom1 = y1 + h1/2;
    float left1 = x1 - w1/2;
    float right1 = x1 + w1/2;

    float top2 = y2 - h2/2;
    float bottom2 = y2 + h2/2;
    float left2 = x2 - w2/2;
    float right2 = x2 + w2/2;


    if(right1 >= left2 &&
       left1 <= right2 &&
       top1 <= bottom2 &&
       bottom1 >= top2) {
         return true;
     }
    return false;

}


// TRIANGLE/POINT
public boolean triPoint(float x1, float y1, float x2, float y2, float x3, float y3, float px, float py) {

  
  float percentMarginOfError = .001f;
  // get the area of the triangle
  float areaOrig = abs( (x2-x1)*(y3-y1) - (x3-x1)*(y2-y1) );

  // get the area of 3 triangles made between the point
  // and the corners of the triangle
  float area1 =    abs( (x1-px)*(y2-py) - (x2-px)*(y1-py) );
  float area2 =    abs( (x2-px)*(y3-py) - (x3-px)*(y2-py) );
  float area3 =    abs( (x3-px)*(y1-py) - (x1-px)*(y3-py) );

  // if the sum of the three areas equals the original,
  // we're inside the triangle!
  
  float totalTempArea = area1 + area2 + area3;
  if (totalTempArea*(1-percentMarginOfError) <= areaOrig && totalTempArea*(1+percentMarginOfError) >= areaOrig) {
    return true;
  }
  return false;
}


class LandPlot {
 //LandSquare[] plots;
 LandTriangle[] landTriangles;
 Node[] nodes;

 int numRows;
 int numCols;

 float xWidth;
 float yHeight;

int[] tempPath;


 LandPlot(int _numCols, int _numRows, float _xWidth, float _yHeight) {
  numRows = _numRows;
  numCols = _numCols;


  xWidth = _xWidth;
  yHeight = _yHeight;


  landTriangles = new LandTriangle[numRows*numCols*2];
  nodes = new Node[landTriangles.length];
  //whether square is 0,0 - > 1,1 or 1,0 - > 0,1
  int parity = 0;
  int index = 0;
  for (int row = 0; row < numRows; row++) {
    for (int col = 0; col < numCols; col++) {
      // landTriangles[]
      index = ((col+parity)%2); // 0 or 1
      PVector topLeft = new PVector(col*xWidth, row*yHeight);
      //j is for the two triangles in 1 square
      PVector[] temp;
      for (int j = 0; j < 2; j++) {
        temp = new PVector[3];                             //j =  0      1                                         0    1
        for (int i = 0; i < temp.length; i++) {               //0, 2, 1, 3                                     //1,3, 2,4

          temp[i] = squareTriangles[index][i+3*j].copy();
         }
        int typeOfTriangle = index*2 + j;
        landTriangles[row*numCols*2 + col*2 + j] = new LandTriangle(temp, topLeft, xWidth, yHeight, typeOfTriangle);
        // println(row*numSquareCols*2 + col*2 + j);
       }

      // println(index);
     }
    parity = (parity+1)%2;
   }

   for(int i = 0; i < nodes.length; i++){
     nodes[i] = new Node(i, landTriangles[i].center, findAdjecentTriangleIndexes(i));
   }

  // println("size : " + landTriangles.length);
 }

 public float heuristic(int start, int end){
   PVector temp = PVector.sub(nodes[start].location, nodes[end].location);
   return temp.mag();
 }


 public PVector[] randomTriangleCenters(int size) {
  PVector[] lis = new PVector[size];
  for (int i = 0; i < lis.length; i++) {
    int randomTriangleIndex = PApplet.parseInt(random(0, landTriangles.length));
    PVector centerPoint = landTriangles[randomTriangleIndex].center;
    lis[i] = centerPoint;
   }

  return lis;
 }

 public void resetNodeVals(){
   for(int i = 0; i < nodes.length; i++){
     nodes[i].init();
   }
 }

 public void createPath(int start, int end){
   changePath(findTrianglePathFromTriangleToTriangle(start, end));
 }

 public int[] findTrianglePathFromTriangleToTriangle(int startIndex, int endIndex) {
  IntList openSet = new IntList();
  IntList closedSet = new IntList();
  resetNodeVals();
  openSet.append(startIndex);
  int maxNumInterations = 100;
  int interationNum = 0;
  int closestIndex = startIndex;
  while(openSet.size() > 0 && interationNum < maxNumInterations) {
    // println("iteration num : " + interationNum);
    // println("closestIndex num : " + closestIndex);

//set the current node in the open set to the one that has the lowest f value

    float closestVal = width*height;
    for(int i = 0; i < openSet.size(); i++) {
      if(nodes[openSet.get(i)].f < closestVal) {
      closestIndex = openSet.get(i);
      closestVal = nodes[closestIndex].f;
       }
     }

     // Node currentNode = nodes[closestIndex];
     if(closestIndex == endIndex){
       //found the endpoint
       break;//should probably calc the final route to return at the end of the function
     }
     openSet = removeFromIntList(openSet, closestIndex);
     closedSet.append(closestIndex);

int[] tempNeighbors = nodes[closestIndex].neighbors;
for(int i = 0; i < tempNeighbors.length; i++){
  int currentNeighborIndex = tempNeighbors[i];

  if(closedSet.hasValue(currentNeighborIndex) == false){//not in closed set
    // println("found neighbor not in closed list");
    Node neighbor = nodes[currentNeighborIndex];
    float tempG = neighbor.g + 1;
    if(openSet.hasValue(currentNeighborIndex) == true){
      if(tempG < neighbor.g){
        neighbor.g = tempG;
      }

    }else{
      neighbor.g = tempG;
      openSet.append(currentNeighborIndex);
    }

    neighbor.h = heuristic(currentNeighborIndex, endIndex);
    neighbor.f = neighbor.g + neighbor.h;
    neighbor.before = closestIndex;
    nodes[currentNeighborIndex] = neighbor;
  }
}
interationNum++;
// println("open set : " + openSet.size());
// println("closed set : " + closedSet.size());
}
if(interationNum >= maxNumInterations){
  // println("HIT MAX");
}

    return traceBack(endIndex);
   }

   public int[] traceBack(int endIndex){
     IntList steps = new IntList();
     int curIndex = endIndex;
     int interationNum = 0;
     int maxIterationNum = 100;
     while(nodes[curIndex].before != -1 && interationNum < maxIterationNum){//keep going backward until you hit a node that doesnt have a previous node
       steps.append(curIndex);
       curIndex = nodes[curIndex].before;
       interationNum++;
     }
     steps.append(curIndex);
     return steps.array();
   }




 public void highLightSurroundingTriangles(float x, float y) {
  int index = findTriangleIndex(x, y);
  if (index != -1) {
    int[] surroundingTrianglesIndexes =  findAdjecentTriangleIndexes(index);
    for (int i = 0; i < surroundingTrianglesIndexes.length; i++) {
      landTriangles[surroundingTrianglesIndexes[i]].highlight();
     }
   } else {
    // println("ERROR");
    //couldn't find triangle
   }
 }


 PVector[][] adjecentTris = {
  {new PVector(-1, 0, 1),
   new PVector(0, 1, 0), //0 SW CORNER
   new PVector(0, 0, 1)},

  {new PVector(0, -1, 1),
   new PVector(1, 0, 0), //1 NE CORNER
   new PVector(0, 0, 0)},

  {new PVector(-1, 0, 1),
   new PVector(0, -1, 0), //2 NW CORNER
   new PVector(0, 0, 1)},

  {new PVector(0, 1, 1),
   new PVector(1, 0, 0), //3 SE CORNER
   new PVector(0, 0, 0)}

 };

 //x and y refer to the coordinates for the squares, index refers to an additional constant to get the correct triangle inside a square
 public int[] findAdjecentTriangleIndexes(int triangleIndex) {
  IntList triangleIndexes = new IntList();

  int triType = landTriangles[triangleIndex].typeOfTriangle;
  int centerX = PApplet.parseInt((triangleIndex/2))%(numCols);
  int centerY = PApplet.parseInt(triangleIndex/(numCols*2));

  PVector[] adjecentTriIndexCoordinates = adjecentTris[triType];
  for (int i = 0; i < 3; i++) {

    int x = PApplet.parseInt(adjecentTriIndexCoordinates[i].x) + centerX;//add the middle index coordinates to the other coordinates to find the adjecent
    int y = PApplet.parseInt(adjecentTriIndexCoordinates[i].y) + centerY;
    int z = PApplet.parseInt(adjecentTriIndexCoordinates[i].z);
    int tempIndex = x*2 + y*numCols*2 + z;
    if(x >= 0 && x < numCols) {
      if(y >= 0 && y < numRows) {
        if (tempIndex >= 0 && tempIndex < landTriangles.length) {//if the index exists then add it to the adjecent indexes for this triangle // maybe check the x y z components individually if this fails
          triangleIndexes.append(tempIndex);
         }else{
          // println("t");
         }

       }
     }
   }
  return triangleIndexes.array();
 }

 public int findTriangleIndex(float x, float y) {
  if (x < numCols*xWidth && x > 0 && y > 0 && y < numCols*yHeight) {
    //finds square that contains 2 triangles, 1 of them must countain the point
    int squareIndex = PApplet.parseInt(x/xWidth) + PApplet.parseInt((y/yHeight)) * numCols;

    int correctIndex = -1;
    for (int i = 0; i < 2; i++) {

      if (landTriangles[squareIndex*2 + i].pointInside(x, y) == true) {
        correctIndex = squareIndex*2 + i;
       }
     }
    if (correctIndex == -1) {
      // println("POINT NOT INSIDE EITHER TRIAGNLE IN SQUARE");
     }
    return correctIndex;
   } else {
    // println("POINT NOT INSIDE THE SCREEN");
    return -1;
   }
 }

public void changePath(int[] indexes){
  for(int i = 0; i < indexes.length; i++){
    changeTriangle(indexes[i]);
  }
}

 public void changeTriangle(int index) {
  if (index != -1) {
    landTriangles[index].type = "water";
   }
 }

 public void display() {
  for (int i = 0; i < landTriangles.length; i++) {

    landTriangles[i].display(color(0));
   }
 }

 public void highlightLandTriangleSelected(float x, float y) {
  int index = findTriangleIndex(x, y);
  if (index != -1) {
    landTriangles[index].highlight();
   } else {
    // println("ERROR");
    //couldn't find triangle
   }
 }
}


class LandTriangle {
 int curC, oldC;
 String type;
 PVector[] vertexes = new PVector[3];
 PVector[] imageVertexes = new PVector[vertexes.length];
 PVector center;
 boolean hoveredOver;
 int typeOfTriangle;

 LandTriangle(PVector[] _vertexes, PVector topLeft, float xWidth, float yHeight, int _typeOfTriangle) {
  hoveredOver = false;
  //curC = tileColors[tileNameToIndex.get("dirt")];
  oldC = curC;
  type = "dirt";

  imageVertexes = _vertexes;
  float tempX = 0;
  float tempY = 0;
  for (int i = 0; i < imageVertexes.length; i++) {
    float x = topLeft.x + imageVertexes[i].x*xWidth;
    float y = topLeft.y + imageVertexes[i].y*yHeight;
    vertexes[i] =  new PVector(x, y);
    tempX += x;
    tempY += y;

   }


  center = new PVector(tempX/3.f, tempY/3.f);
  typeOfTriangle = _typeOfTriangle;
 }

 public void highlight() {
  hoveredOver = true;
  display(color(60, 100, 100));
 }

 public void display(int c) {
  strokeWeight(4);
  noStroke();
  fill(curC);
  if (hoveredOver == true) {
    noFill();
    stroke(c);
    triangle(vertexes[0].x, vertexes[0].y, vertexes[1].x, vertexes[1].y, vertexes[2].x, vertexes[2].y);
   } else {
    tint(360, imageOpacities[imageNameToIndex.get(type)]);
    beginShape();
    textureMode(NORMAL);
    texture(allImages[imageNameToIndex.get(type)]);
    vertex(vertexes[0].x, vertexes[0].y, imageVertexes[0].x, imageVertexes[0].y);
    vertex(vertexes[1].x, vertexes[1].y, imageVertexes[1].x, imageVertexes[1].y);
    vertex(vertexes[2].x, vertexes[2].y, imageVertexes[2].x, imageVertexes[2].y);
    endShape();
   }
  hoveredOver = false;
  curC = oldC;
 }

 public boolean pointInside(float x, float y) {
  return triPoint(vertexes[0].x, vertexes[0].y, vertexes[1].x, vertexes[1].y, vertexes[2].x, vertexes[2].y, x, y);
 }
}

class Node{
int index;
PVector location;
int[] neighbors;

float f;
float g;
float h;

int before;

Node(int _index, PVector _location, int[] _neighbors){
  index = _index;
  location = _location.copy();
  neighbors = _neighbors;
init();
}

public void init(){
  f = 0;
  g = 0;
  h = 0;
  before = -1;
}

}


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

  public void reCreate() {
    p1T = new ArrayList<PVector>();
    p2T = new ArrayList<PVector>();
    branchWidthsT = new FloatList();

    startGrow();
    makeBranch(1, 0, new PVector(width/2, 0), 0);
    p1 = PVectorListToArray(p1T);
    p2 = PVectorListToArray(p2T);
    branchWidths = branchWidthsT.array();
    
  }

  public void display() {
    for (int i = 0; i < p1.length; i++) {
      stroke(color(32, 100, 0));
      strokeWeight(branchWidths[i]);
      line(p1[i].x, p1[i].y, p2[i].x, p2[i].y);
    }
  }

  public void mutate()
  {
    int startTime = millis();

    float n = noise(startTime / 20000) - 0.5f;

    randBias = 4 * abs(n) * n * (mutating ? 1 : 0);

    randomSeed(randSeed);
    readInputs(true);

    int diff = millis() - startTime;

    if ( diff < 20 )
      
      mutate();
    else
      
      mutate();
  }

  public void readInputs(boolean updateTree)
  {

    if ( updateTree && !growing )
    {
      prog = maxLevel + 1;
      loop();
    }
  }

  public void makeBranch(int level, float seed, PVector lastC, float rOld)
  {

    if ( prog < level ) {

      return;
    }
    //randomSeed(seed);

    float seed1 = random(1000);
    float  seed2 = random(1000);

    float growthLevel = (PApplet.parseInt(prog) - level > 1) || (PApplet.parseInt(prog) >= maxLevel + 1) ? 1 : (PApplet.parseInt(prog) - level);

    float lineSize = 22 * pow((PApplet.parseFloat(maxLevel) - PApplet.parseFloat(level) + 1) / PApplet.parseFloat(maxLevel), 2);

    branchWidthsT.append(lineSize);

    float len = growthLevel * size* (1 + rand2() * lenRand);

    p1T.add(lastC.copy());

    PVector newTemp = new PVector(0, len/PApplet.parseFloat(level)).rotate(rOld);
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

  public void startGrow()
  {
    growing = true;
    prog = 1;
    grow();
  }


  public void grow()
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

    prog += PApplet.parseFloat(maxLevel) / 8 * max(diff, 20) / 1000.f;
    grow();
  }


  public float rand()
  {
    return random(1000) / 1000;
  }

  public float rand2()
  {
    return random(2000) / 1000 - 1;
  }

  public float rrand()
  {
    return rand2() + randBias;
  }

  public void updateVals(float[] vals) {
    size = vals[0]; //   1 
    maxLevel = PApplet.parseInt(vals[1]); //  2
    rot = vals[2]; //   3
    lenRand = vals[3]; //  4
    branchProb = vals[4];//5
    rotRand = vals[5];// 6
    leafProb = vals[6];//7
  }
}
  public void settings() {  fullScreen(P2D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "AntColony" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
