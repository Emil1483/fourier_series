MagicVector magicVector;

float timeStep = 0.0025;
ArrayList<PVector> path;
ArrayList<PVector> result;
float lenMult;
int feathering = 100;
int showChildren = 1;
int children = 400; //Must be even

void setup() {
  fullScreen(P2D);
  
  path = new ArrayList<PVector>();
  JSONObject json = loadJSONObject("data/tobias.json");
  int index = 0;
  while (!json.isNull(index + "")) {
    JSONObject posJson = json.getJSONObject(index + "");
    path.add(new PVector(posJson.getFloat("x"), posJson.getFloat("y")));
    index ++;
  }
  
  lenMult = 1180.0;
  
  magicVector = new MagicVector(new PVector(0, 0), 0);
  for (int i = 0; i < children / 2; i += 1) {
    magicVector.addChild(new MagicVector(c_n(i), i));
    if (i == 0) continue;
    magicVector.addChild(new MagicVector(c_n(-i), -i));
  }
  
  result = new ArrayList<PVector>();
}

PVector c_n(int n) {
  PVector result = new PVector(0, 0);
  float dt = 0.0002;
  for (float t = 0; t < 1; t += dt) {
    PVector add = PVector.fromAngle(-TWO_PI * n * t);
    PVector f_t = f_t(t);
    add.rotate(f_t.heading());
    add.mult(f_t.mag());
    add.mult(dt);
    result.add(add);
  }
  return result;
}

PVector f_t(float t) {
  int index = floor(t * path.size());
  PVector result = path.get(index).copy();
  result.mult(lenMult);
  return result;
}

void draw() {
  background(0);
  
  fill(255);
  textSize(70);
  text(showChildren, 30, height - 30);
  
  int maxResultSize = round(1.0 / timeStep);
  
  magicVector.update();
  result.add(magicVector.getBottomPos(new PVector(0, 0), 0));
  if(result.size() > maxResultSize) {
    result.remove(0);
  }
  
  for (int i = 0; i < result.size() - 1; i++) {
    PVector p1 = result.get(i);
    PVector p2 = result.get(i + 1);
    
    int dist = result.size() - i;
    int lenBeforeFeathering = maxResultSize - feathering;
    float mult = map(dist, lenBeforeFeathering, lenBeforeFeathering + feathering, 1, 0);
    
    stroke(map(mult, 0, 1, 122, 255));
    strokeWeight(map(min(mult, 1), 0, 1, 0.5, 3));
    line(p1.x, p1.y, p2.x, p2.y);
  }
  magicVector.show(new PVector(0, 0), 0);
}

void keyPressed() {
  try {
    showChildren += int(key + "");
  } finally {
    if (key == ' ') showChildren += 20;
  }
  if (showChildren > children) showChildren = children;
}
