PImage img;
String url;

void setup() {
  //size(640,480);
  size(1280, 720, P2D);
  url = "http://127.0.0.1:5000/video_feed";
  //url = "http://127.0.0.1:5000";
  img = loadImage(url, "jpg");
  delay(200);
}

void draw() {
  //img = loadImage(url, "jpg");
  //delay(200);
  //background(0);
  image(img, 0, 0);
}