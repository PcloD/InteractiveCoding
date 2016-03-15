
PShape shp;
PShader shr;

float noiseIntensity = 0.42f;
float noiseScale = 0.91f;
float noiseSpeed = 0.2f;
float shininess = 20.0f;

float interpolation = 0.0f;
int shapeMode = 2;

Ticker ticker;

boolean mutation = false;

void setup() {
  size(640, 640, P3D);
  
  shp = loadShape("sphere.obj"); // http://graphics.stanford.edu/hackliszt/meshes/sphere.obj
  shr = loadShader("sample.frag", "sample.vert");
  
  ticker = new Ticker();
}

void draw() {
  background(0);
  
  interpolation = ticker.getT();
  
  shr.set("uTime", frameCount * 0.1f);
  shr.set("uNoiseIntensity", noiseIntensity);
  shr.set("uNoiseScale", noiseScale);
  shr.set("uNoiseSpeed", noiseSpeed);
  shr.set("uShininess", shininess);
  shr.set("uInterpolation", interpolation);
  shr.set("uShapeMode", shapeMode);
  
  shader(shr);
  
  float dirY = (mouseY / float(height) - 0.5) * 2;
  float dirX = (mouseX / float(width) - 0.5) * 2;
  directionalLight(204, 204, 204, -dirX, -dirY, -1);
  
  translate(width / 2f, height / 2f);
  rotateX(frameCount * 0.01f);
  rotateY(frameCount * 0.015f);

  scale(120f, 120f, 120f);
  
  shape(shp);
  
  ticker.update(0.03f);
}

void keyPressed() {
  mutate();
}

void mouseClicked() {
  mutate();
}

void mutate() {
  mutation = !mutation;
  if(mutation) {
      ticker.start(3f, 0f, 1f);
      shapeMode++;
  } else {
      ticker.start(3f, 1f, 0f);
  }
}