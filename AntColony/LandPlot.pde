

class LandPlot {
//LandSquare[] plots;
LandTriangle[] landTriangles;
Node[] nodes;

int numRows;
int numCols;

float xWidth;
float yHeight;

int[] currentPath; // DO NOT USE THIS IN FUTURE THIS IS BAD

ArrayList<Insect> insects = new ArrayList<Insect>();


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
                                temp = new PVector[3];       //j =  0      1                                         0    1
                                for (int i = 0; i < temp.length; i++) { //0, 2, 1, 3                                     //1,3, 2,4

                                        temp[i] = squareTriangles[index][i+3*j].copy();
                                }
                                int typeOfTriangle = index*2 + j;
                                float increment = 0.1;
                                float noiseX = float(col) * increment;
                                float noiseY = float(row) * increment;

                                LandTriangle tempTriangle = new LandTriangle(temp, topLeft, xWidth, yHeight, typeOfTriangle);
                                if(noise(noiseX, noiseY) <= .3){
                                  tempTriangle.type = "stone";
                                }
                                landTriangles[row*numCols*2 + col*2 + j] = tempTriangle;
                                // println(row*numSquareCols*2 + col*2 + j);

                        }

                        // println(index);
                }
                parity = (parity+1)%2;
        }

        for(int i = 0; i < nodes.length; i++) {
                nodes[i] = new Node(i, landTriangles[i].center, findAdjecentTriangleIndexes(i));
        }

        // println("size : " + landTriangles.length);
}

float heuristic(int start, int end){
        PVector temp = PVector.sub(nodes[start].location, nodes[end].location);
        return temp.mag();
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

void resetNodeVals(){
        for(int i = 0; i < nodes.length; i++) {
                nodes[i].init();
        }
}

PVector[] returnPathLocations(int[] indexes){
  PVector[] temp = new PVector[indexes.length];
  for(int i = 0; i < temp.length; i++){
    temp[i] = landTriangles[indexes[i]].center;
  }
  return temp;
}

void createPath(int start, int end){
        changePath(findTrianglePathFromTriangleToTriangle(start, end));
}

int[] findTrianglePathFromTriangleToTriangle(int startIndex, int endIndex) {
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
                if(closestIndex == endIndex) {
                        //found the endpoint
                        break;//should probably calc the final route to return at the end of the function
                }
                openSet = removeFromIntList(openSet, closestIndex);
                closedSet.append(closestIndex);
                String filter = "stone"; // will see this type of triangle as a obstacle that it cannot go through
                int[] tempNeighbors = nodes[closestIndex].neighbors;
                for(int i = 0; i < tempNeighbors.length; i++) {
                        int currentNeighborIndex = tempNeighbors[i];
                        if(landTriangles[currentNeighborIndex].type.equals(filter) == false ) {
                                if(closedSet.hasValue(currentNeighborIndex) == false) {//not in closed set
                                        // println("found neighbor not in closed list");
                                        Node neighbor = nodes[currentNeighborIndex];
                                        float tempG = neighbor.g + 1;
                                        if(openSet.hasValue(currentNeighborIndex) == true) {
                                                if(tempG < neighbor.g) {
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
                }
                interationNum++;
                // println("open set : " + openSet.size());
                // println("closed set : " + closedSet.size());
        }
        if(interationNum >= maxNumInterations) {
                // println("HIT MAX");
        }
currentPath = traceBack(endIndex);
        return currentPath;
}

void addTrackingAnt(PVector position){
  PVector targets[] = returnPathLocations(currentPath);
 Ant temp = new Worker(position);
 temp.beginTracking(targets);
 insects.add(temp);
}

int[] traceBack(int endIndex){
        IntList steps = new IntList();
        int curIndex = endIndex;
        int interationNum = 0;
        int maxIterationNum = 100;
        while(nodes[curIndex].before != -1 && interationNum < maxIterationNum) {//keep going backward until you hit a node that doesnt have a previous node
                steps.append(curIndex);
                curIndex = nodes[curIndex].before;
                interationNum++;
        }
        steps.append(curIndex);
        steps.reverse();
        return steps.array();
}

void highLightSurroundingTriangles(float x, float y, color outline) {
        int index = findTriangleIndex(x, y);
        if (index != -1) {
                highlightSurroundingTrianglesIndex(index, outline);
        } else {
                // println("ERROR");
                //couldn't find triangle
        }
}

void highlightSurroundingTrianglesIndex(int index, color outline){
        int[] surroundingTrianglesIndexes =  findAdjecentTriangleIndexes(index);
        for (int i = 0; i < surroundingTrianglesIndexes.length; i++) {
                landTriangles[surroundingTrianglesIndexes[i]].highlight(outline);
        }
}


PVector[][] adjecentTris = {
        //SW CORNER
        {new PVector(-1, 0, 1),
         new PVector(0, 1, 0),
         new PVector(0, 0, 1)},
        //1 NE CORNER
        {new PVector(0, -1, 1),
         new PVector(1, 0, 0),
         new PVector(0, 0, 0)},
        //2 NW CORNER
        {new PVector(-1, 0, 1),
         new PVector(0, -1, 0),
         new PVector(0, 0, 1)},
        //3 SE CORNER
        {new PVector(0, 1, 1),
         new PVector(1, 0, 0),
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

                int x = int(adjecentTriIndexCoordinates[i].x) + centerX;  //add the middle index coordinates to the other coordinates to find the adjecent
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
                        // println("POINT NOT INSIDE EITHER TRIAGNLE IN SQUARE");
                }
                return correctIndex;
        } else {
                // println("POINT NOT INSIDE THE SCREEN");
                return -1;
        }
}

void changePath(int[] indexes){
        for(int i = 0; i < indexes.length; i++) {
                changeTriangle(indexes[i]);
        }
}

void changeTriangle(int index) {
        if (index != -1) {
                landTriangles[index].type = "water";
        }
}

void display() {
        for (int i = 0; i < landTriangles.length; i++) {

                landTriangles[i].display(color(0));
        }
        for(int i = insects.size()-1; i >= 0 ; i--){

          insects.get(i).update();
          if(insects.get(i).targetIndex == -1){//reached the end of its path
            insects.remove(i);
          }
        }
}

void highlightLandTriangleIndex(int index, color outline){
        if (index != -1) {
                landTriangles[index].highlight(outline);
        } else {
                // println("ERROR");
                //couldn't find triangle
        }
}

void highlightLandTrianglePosition(float x, float y, color outline) {
        int index = findTriangleIndex(x, y);
        highlightLandTriangleIndex(index, outline);
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

void highlight(color outline) {
        hoveredOver = true;
        display(outline);
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

class Node {
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

void init(){
        f = 0;
        g = 0;
        h = 0;
        before = -1;
}

}
