

class LandPlot {
 //LandSquare[] plots;
 LandTriangle[] landTriangles;
 int numRows;
 int numCols;

 float xWidth;
 float yHeight;

 PVector center;


 LandPlot(int _numCols, int _numRows, float _xWidth, float _yHeight) {
  numRows = _numRows;
  numCols = _numCols;


  xWidth = _xWidth;
  yHeight = _yHeight;


  landTriangles = new LandTriangle[numRows*numCols*2];
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

  // println("size : " + landTriangles.length);
 }


 PVector[] randomTriangleCenters(int size) {
  PVector[] lis = new PVector[size];
  for (int i = 0; i < lis.length; i++) {
    int randomTriangleIndex = int(random(0, landTriangles.length));
    PVector centerPoint = landTriangles[randomTriangleIndex].center;
    lis[i] = centerPoint;
   }

  return lis;
 }

 int[] findTrianglePathFromTriangleToTriangle(int startIndex, int endIndex) {
  IntList openSet = new IntList();
  IntList closedSet = new IntList();
  openSet.append(startIndex);
  int maxNumInterations = 100;
  int interationNum = 0;

  while(openSet.size() > 0 && interationNum < maxNumInterations) {

    int lowestIndex = startIndex;
    for(int i = 0; i < openSet.size(); i++) {
      // if(openSet.get(i)) {
      //
      //  }
     }
    interationNum++;
   }
  return null;
 }

 void highLightSurroundingTriangles(float x, float y) {
  int index = findTriangleIndex(x, y);
  if (index != -1) {
    int[] surroundingTrianglesIndexes =  findAdjecentTriangleIndexes(index);
    for (int i = 0; i < surroundingTrianglesIndexes.length; i++) {
      landTriangles[surroundingTrianglesIndexes[i]].highlight();
     }
   } else {
    println("ERROR");
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
 int[] findAdjecentTriangleIndexes(int triangleIndex) {
  IntList triangleIndexes = new IntList();

  int triType = landTriangles[triangleIndex].typeOfTriangle;
  int centerX = int((triangleIndex/2))%(numCols);
  int centerY = int(triangleIndex/(numCols*2));

  PVector[] adjecentTriIndexCoordinates = adjecentTris[triType];
  for (int i = 0; i < 3; i++) {

    int x = int(adjecentTriIndexCoordinates[i].x) + centerX;//add the middle index coordinates to the other coordinates to find the adjecent
    int y = int(adjecentTriIndexCoordinates[i].y) + centerY;
    int z = int(adjecentTriIndexCoordinates[i].z);
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

 int findTriangleIndex(float x, float y) {
  if (x < numCols*xWidth && x > 0 && y > 0 && y < numCols*yHeight) {
    //finds square that contains 2 triangles, 1 of them must countain the point
    int squareIndex = int(x/xWidth) + int((y/yHeight)) * numCols;

    int correctIndex = -1;
    for (int i = 0; i < 2; i++) {

      if (landTriangles[squareIndex*2 + i].pointInside(x, y) == true) {
        correctIndex = squareIndex*2 + i;
       }
     }
    if (correctIndex == -1) {
      println("POINT NOT INSIDE EITHER TRIAGNLE IN SQUARE");
     }
    return correctIndex;
   } else {
    println("POINT NOT INSIDE THE SCREEN");
    return -1;
   }
 }

 void changeTriangle(float x, float y) {
  int index = findTriangleIndex(x, y);
  if (index != -1) {
    landTriangles[index].type = "water";
   }
 }

 void display() {
  for (int i = 0; i < landTriangles.length; i++) {

    landTriangles[i].display(color(0));
   }
 }

 void highlightLandTriangleSelected(float x, float y) {
  int index = findTriangleIndex(x, y);
  if (index != -1) {
    landTriangles[index].highlight();
   } else {
    println("ERROR");
    //couldn't find triangle
   }
 }
}


class LandTriangle {
 color curC, oldC;
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


  center = new PVector(tempX/3., tempY/3.);
  typeOfTriangle = _typeOfTriangle;
 }

 void highlight() {
  hoveredOver = true;
  display(color(60, 100, 100));
 }

 void display(color c) {
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

 boolean pointInside(float x, float y) {
  return triPoint(vertexes[0].x, vertexes[0].y, vertexes[1].x, vertexes[1].y, vertexes[2].x, vertexes[2].y, x, y);
 }
}
