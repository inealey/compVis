import processing.video.*;
import gab.opencv.*;

OpenCV opencv;
Capture cam;
PImage src, canny, scharr, sobel;
boolean frameCap;
boolean live;

void setup() {
  frameCap = false;
  live = true;
  
  String[] cameras = Capture.list();
  
  if(live) {
    cam = new Capture(this, cameras[0]);
    cam.start();
  }
  else {
    //src = loadImage("helix_scan.png");
    src = loadImage("Mandeville_Center_UCSD.jpg");
  }
  size(1080, 720);
  
  /*
  opencv = new OpenCV(this, src);
  opencv.findCannyEdges(20,75);
  canny = opencv.getSnapshot();
  
  opencv.loadImage(src);
  opencv.findScharrEdges(OpenCV.HORIZONTAL);
  scharr = opencv.getSnapshot();
  
  opencv.loadImage(src);
  opencv.findSobelEdges(1,0);
  sobel = opencv.getSnapshot();
  */
}


void draw() {
  if(live) {
     cam.read();
     opencv.loadImage(cam);
     opencv.findSobelEdges(1,0);
     sobel = opencv.getSnapshot();
     println("gettin in!");
  }
  else {
    opencv.loadImage(src);
    opencv.findSobelEdges(1,0);
    sobel = opencv.getSnapshot();
  }
  
  pushMatrix();
  //scale(0.5);
  scale(1);
  //image(canny, 0, 0);
  //image(scharr, 0, 0);
  //image(sobel, 0, 0);
  //image(canny, 0, 0, 1280, 720);
  //image(scharr, 0, 0, 1280, 720);
  image(sobel, 0, 0, 1280, 720);
  popMatrix();
  /*
  text("Source", 10, 25); 
  text("Canny", src.width/2 + 10, 25); 
  text("Scharr", 10, src.height/2 + 25); 
  text("Sobel", src.width/2 + 10, src.height/2 + 25);
  */
  if(frameCap) {
    save("mandy_sobel.png");
    frameCap = false;
  }
}