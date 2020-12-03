
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
  void update() {
  }
  //the enemies
  void checkCollision() {
  }

  boolean checkRectCollision(float x, float y, float w, float h) {
    return false;
  }
  boolean checkCircCollision(float x, float y, float r) {
    return false;
  }

  void displayHealth(float x, float y, float Length, float Height) {
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

  void checkAlive() {
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

  void displayDebugInfo() {
    stroke(0);
    strokeWeight(1);
    // float len = velocity.mag();
    float stetch = 20.;
    line(location.x, location.y, location.x + stetch*velocity.x, location.y + stetch*velocity.y);

    stroke(100);
    strokeWeight(20);
    point(actualTarget.x, actualTarget.y);
  }

  void update() {
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

  void beginTracking(PVector[] _destinations) {
    targetIndex = 0;
    destinations = _destinations;
    pathTarget = destinations[targetIndex];
    calcTarget();
    seek(actualTarget);
  }
  //dont fill, all child classes will have their own display function
  void display() {
  }

  void move() {
    velocity.add(acceleration);
    velocity.limit(maxSpeed);
    location.add(velocity);
    acceleration.mult(0);
  }

  void applyForce(PVector dir) {
    PVector modified = dir.copy().div(mass);
    acceleration.add(modified);
  }

  void seek(PVector target) {
    PVector dir = PVector.sub(target, location);
    dir.limit(maxSpeed);
    PVector goodDir = PVector.sub(dir, velocity);
    //tyring to make them turn slowly towards the user
    goodDir.limit(maxForce);
    applyForce(goodDir);
  }

  void changeTarget() {
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

  void calcTarget() {
    float x = pathTarget.x;
    float y = pathTarget.y;
    float margin = 1;
    x += random(-margin, margin);
    y += random(-margin, margin);
    actualTarget = new PVector(x, y);
  }

  boolean reached(PVector toGo) {

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
  color c;
  Ant(PVector _location) {
    super(_location);
  }
  void display() {
    noStroke();
    fill(c);
    ellipse(location.x, location.y, l, w);
  }

  void setColor() {
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

  boolean checkSegmentCollision(float iX, float iY, float iXLen, float iYLen) {
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
  void followTarget(PVector target, int index) {
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

  void update() {
    float speed = 10;
    float x = end.x + speed*randomGaussian();
    float y = end.y + speed*randomGaussian();
    PVector target = new PVector(x, y);
    followTarget(target, 0);
    display();
  }

  void display() {
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

  void receiveHit(float damage) {
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

  void anchor() {
    int last = 0;
    int first = segments.length-1;

    segments[last].followTarget(begining.copy(), 1);
    //segments[0].follow = begining.copy();
    for (int i = last+1; i <= first; i++) {
      segments[i].followTarget(segments[i-1].end, 1);
    }
  }
  //when a worm is hit
  void receiveHitWorm(float damage, float x, float y, float xLen, float yLen) {
    //at least 1 segment was hit
    if (checkWormCollision(x, y, xLen, yLen).length > 0) {
      currentHealth -= damage;
      checkAlive();
    }
  }
  //when a snake part is hit
  void receiveHitSegment(float damage, float x, float y, float xLen, float yLen) {
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
  int[] checkWormCollision(float iX, float iY, float iXLen, float iYLen) {
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

  boolean checkInsideStage() {
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

  void wander(PVector safePlace) {

    if (checkInsideStage() == true) {
      currentDirection.rotate(0.2*randomGaussian());
    } else {
      PVector toCenter = PVector.sub(segments[segments.length-1].end, safePlace);
      currentDirection = toCenter.copy().normalize().rotate(radians(180)).mult(speed);
    }
  }

  void move() {
    followTarget(PVector.add(segments[segments.length-1].end, currentDirection));
  }

  void followTarget(PVector target) {
    segments[segments.length-1].followTarget(target, 0);
    for (int i = segments.length-2; i >= 0; i--) {
      segments[i].followTarget(segments[i+1].start, 0);
    }
  }

  void display(boolean showEachSegment) {

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

  void update() {
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


  void update() {
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

  void subDivide(int wormIndex, int segmentIndex) {
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
      Segment[] segs = {parent.segments[int(map(segmentIndex, 0, 1, 1, 0))]};
      WormMob newParent = new WormMob(segs);
      parts.set(wormIndex, newParent);
    } else if (parent.segments.length == 1) {
      parts.remove(wormIndex);
    }
  }
}
