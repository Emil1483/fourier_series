MagicVector magicVector;

float timeStep = 0.0005;
ArrayList<PVector> path;
ArrayList<PVector> result;
float firstLenMult = 1279;
float lenMult = firstLenMult;
int feathering = 250;
int showChildren = 1;
int children = 4000; //Must be even
PVector offset;
boolean follow = false;

color canvas = color(0);//color(16, 24, 32);
color lines = color(254, 231, 21);

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

  PVector avgPos = new PVector();
  float dt = 1.0 / path.size();
  for (PVector pos : path) {
    PVector p = pos.copy();
    p.mult(dt);
    avgPos.add(p);
  }
  offset = new PVector(width/2 - avgPos.x * lenMult, height/2 - avgPos.y * lenMult);

  magicVector = new MagicVector(new PVector(0, 0), 0);
  for (int i = 0; i < children / 2 + 5; i += 1) {
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
  return result;
}

void draw() {
  background(canvas);

  fill(lines);
  textSize(70);
  text(showChildren, 30, height - 30);

  int maxResultSize = round(1.0 / timeStep);

  magicVector.update();
  PVector bottom = magicVector.getBottomPos(new PVector(0, 0), 0);
  result.add(bottom);
  while (result.size() > maxResultSize) {
    result.remove(0);
  }

  if (!follow) translate(offset.x, offset.y);
  if (follow) translate(width / 2 - bottom.x, height / 2 - bottom.y);

  magicVector.show(new PVector(0, 0), 0);

  for (int i = 0; i < result.size() - 1; i++) {
    PVector p1 = result.get(i);
    PVector p2 = result.get(i + 1);

    int dist = result.size() - i;
    int lenBeforeFeathering = maxResultSize - feathering;
    float mult = map(dist, lenBeforeFeathering, lenBeforeFeathering + feathering, 1, 0);

    stroke(lines, map(mult, 0, 1, 90, 255));
    strokeWeight(map(min(mult, 1), 0, 1, 0.3, 2));
    line(p1.x, p1.y, p2.x, p2.y);
  }
}

void multResult(float m) {
  for (PVector pos : result) {
    pos.mult(m);
  }
}

void keyPressed() {
  if (key == 'c') {
    result.clear();
    return;
  }
  if (key == 'f') {
    follow = !follow;
    if (!follow) {
      multResult(firstLenMult / lenMult);
      lenMult = firstLenMult;
    }
    return;
  }
  if (key == '+') {
    if (!follow) return;
    if (lenMult * 1.5 >= 50856) return;
    lenMult *= 1.5;
    multResult(1.5);
    return;
  }
  if (key == '-') {
    if (!follow) return;
    multResult(1.0/1.5);
    lenMult /= 1.5;
    return;
  }
  if (key == '?') {
    timeStep *= 2;
    return;
  }
  if (key == '_') {
    timeStep /= 2;
    if (timeStep < 0.00002) timeStep =  0.00002;
    return;
  }
  try {
    showChildren += int(key + "");
  } 
  finally {
    if (key == 'n') showChildren += 20;
    else if (key == 'm') showChildren += 100;
    else if (key == 'b') showChildren -= 20;
    else if (key == 'v') showChildren -= 100;
  }
  if (showChildren > children) showChildren = children;
  if (showChildren < 1) showChildren = 1;
}
