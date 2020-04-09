int w = 800;
int h = 800;
int pW = 1;
int pH = 1;
int deepIterations = 360;

int[] colors = new int[w*h];

double zoomX = 0;
double zoomY = 0;
double zoomW = 4;
double zoomH = 4;

float offsetX = 0;
float offsetY = 0;

boolean rendered = false;

void setup() {
  size(800, 800);
  surface.setLocation(1000, 100);
  colorMode(HSB, 255, 255, 255);  
}

void recalculate() {
  for (int x = 0; x < w; x++) {
    for (int y = 0; y < h; y++) {
      int i=0;
      double cx=mapD(x, 0, w, zoomX - zoomW/2, zoomX + zoomW/2);
      double cy=mapD(y, 0, h, zoomY - zoomH/2, zoomY + zoomH/2);
      double zx=0;
      double zy=0;                        

      do
      {
        double xt=zx*zy;
        zx=zx*zx-zy*zy+cx;
        zy=2*xt+cy;
        i++;
      }
      while (i<deepIterations&&(zx*zx+zy*zy)<4);

      int index = x + h * y;
      colors[index] = i;
    }
  }
}

void draw() {
  update();
  background(0);
  
  loadPixels();
  for (int i = 0; i < w; i++) {
    for (int j = 0; j < h; j++) {
      for (int x = 0; x < pW; x++) {
        for (int y = 0; y < pH; y++) {
          int pixelsIndex = (i*pW+x) + (h*pH) * (j*pH+y);
          int colorsIndex = (i+int(offsetX)) + h * (j+int(offsetY));
          if (0 <= colorsIndex && colorsIndex < colors.length && colors[colorsIndex] != 255) {
            float colorCode = map(colors[colorsIndex] % 12, 0, 12, 0, 255);
            pixels[pixelsIndex] = color(colorCode, 255 * 0.9, 255*0.9);
          } else {
            pixels[pixelsIndex] = color(0);
          }
        }
      }
    }
  }
  updatePixels();
  
  text(frameRate, 20, 20);
}

void keyTyped() {
  if (key == 'q') {
    zoomW /= 2;
    zoomH /= 2;
  } 
  if (key == 'e') {
    zoomW *= 2;
    zoomH *= 2;
  }
}

void update() {
  if (keyPressed) {
    rendered = false;
    double speedX = zoomW/80;
    double speedY = zoomH/80;
    if (key == 'a') {
      zoomX -= speedX;
      offsetX -= speedX/zoomW*w;
    }
    if (key == 'd') {
      zoomX += speedX;
      offsetX += speedX/zoomW*w;
    }
    if (key == 's') {
      zoomY += speedY;
      offsetY += speedY/zoomH*h;
    }
    if (key == 'w') {
      zoomY -= speedY;
      offsetY -= speedY/zoomH*h;
    }
  } else if (!rendered) {
    offsetX = 0;
    offsetY = 0;
    recalculate();
    rendered = true;
  }
}

void mouseClicked() {
    rendered = false;
  double mouseRX = mapD(mouseX, 0, w, zoomX - zoomW/2, zoomX + zoomW/2);
  double mouseRY = mapD(mouseY, 0, h, zoomY - zoomH/2, zoomY + zoomH/2);
  zoomX = mouseRX;
  zoomY = mouseRY;
  zoomW /= 2;
  zoomH /= 2;
}

double mapD(double value, double start1, double stop1, double start2, double stop2) {
  return (value - start1) / (stop1 - start1) * (stop2 - start2) + start2;
}
