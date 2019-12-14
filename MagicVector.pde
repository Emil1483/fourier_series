class MagicVector {
  PVector c;
  float speed;
  MagicVector child;
  
  MagicVector(PVector c, float speed) {
    this.c = c;
    this.speed = speed;
  }
  
  String toString() {
    return "c: " + c + ", speed: " + speed;
  }
  
  PVector getBottomPos(PVector pos, int index) {
    PVector end = new PVector(pos.x + c.x, pos.y + c.y);
    if (child != null && index <= showChildren) return child.getBottomPos(end, index + 1);
    else return end;
  }
  
  void addChild(MagicVector child) {
    if (this.child == null) {
      this.child = child;
    } else {
      this.child.addChild(child);
    }
  }
  
  void update() {
    c.rotate(speed * TWO_PI * timeStep);
    if (child != null) child.update();
  }
  
  void show(PVector pos, int index) {
    if (index > showChildren + 1) return;
    PVector end = new PVector(pos.x + c.x, pos.y + c.y);
    if (child != null) child.show(end, index + 1);
    if (speed == 0) return;
    
    PVector showPos = pos.copy();
    PVector showC = c.copy();
    showPos.mult(lenMult);
    showC.mult(lenMult);
    
    stroke(255);
    strokeWeight(1);
    arrow(showPos, showC);
    
    noFill();
    stroke(255, 90);
    circle(showPos.x, showPos.y, showC.mag() * 2);
  }
  
  void arrow(PVector p1, PVector p2) {
    PVector end = new PVector(p1.x, p1.y);
    end.add(p2);
    line(p1.x, p1.y, end.x, end.y);
    
    float angle = p2.heading();
    float angleDiff = PI/7 + PI;
    float endLineLength = p2.mag() / 8;
    PVector endLine1 = PVector.fromAngle(angle + angleDiff);
    PVector endLine2 = PVector.fromAngle(angle - angleDiff);
    endLine1.mult(endLineLength);
    endLine2.mult(endLineLength);
    endLine1.add(end);
    endLine2.add(end);
    
    line(end.x, end.y, endLine1.x, endLine1.y);
    line(end.x, end.y, endLine2.x, endLine2.y);
  }
}
