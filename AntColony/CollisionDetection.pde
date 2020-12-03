

// CIRCLE/RECTANGLE FOR CENTER RECT
boolean circleRect(float cx, float cy, float radius, float rx, float ry, float rw, float rh) {

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
boolean rectRectCollision(float x1, float y1, float w1, float h1, float x2, float y2, float w2, float h2) {

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
boolean triPoint(float x1, float y1, float x2, float y2, float x3, float y3, float px, float py) {

  
  float percentMarginOfError = .001;
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
