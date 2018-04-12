/**
 * Processing Sound Library, Example 5....
 * HACKED! by Isaac Nealey
 * 
 * This sketch originally showed how to use the FFT class to analyze a stream  
 * of sound: "Change the variable 'bands' to get more or less 
 * spectral bands to work with. The 'smooth_factor' variable determines 
 * how much the signal will be smoothed on a scale form 0-1."
 *
 *
 * March 2018:
 * using for a sweet demo in vis 145! this iteration uses a guitar hero controller to
 * change sensitivity, color, and really anythingggg yo arduino = magic
 *
 *
 * Feb 2018: 
 * 1) changed code to take live input instead of a sample
 * 2) display in larger window (for projector)
 * 3) Eight (4 x (Y+ & Y-)) visualizers instead of one [might inscrease]
 * 4) visualizers change color 
 * 5) audio peaks as prgm input:
 *    -currently used to change waveform color and camera angle
 *    -heavily dependent on scale factor. 
 *        higher factor -> more frequent peaks
 * 6) imported my "camera glitch" position change method from
 *        VIS 145 project 1.
 *
 *            .........::::NOTE::::.........
 *      Default scale factor is 10-15x. In a quiet room, 
 *      it may appear that nothing exciting is happening on screen.
 *      Try making loud noises and increasing scale.
 *      Music is recommended for full effect but anywhere with 
 *      constant sound (coffeeshop, etc.) will work.
 *      OR: use input from an audio sample instead of "audioIn"
 *
 *  future implementation:
 *  - use analog input from arduino to control 'scale factor', color, and other params
 *  - use digital input "      "    for toggling 'constantLayering'
 *  - analog input/oscillation for alpha values
 */

import processing.sound.*;
import processing.serial.*;
import cc.arduino.*;

//init arduino variables
Arduino arduino;
final int THRESHOLD = 5;   //piezo threshold
final int BASE_SCALE = 10;
final int PICKUP = 0;  //pickup pin 
final int WAMMY = 1;   //wammy in
final int POT = 2;     //knob in
int[] buttonVals;//button array
int fretDown;    // which 'fret' is pushed
float wammyVal;    // wammy input
float knobVal;     // pot input
int pitchShift;  // shift buttons
int shiftCounter;// counter for checking sel/start
int velocity;    // pickup input


// Declare the processing sound variables 
FFT fft;
AudioDevice device;
AudioIn in;

// Declare a scaling factor
float scale = BASE_SCALE;

// Define how many FFT bands we want
int bands = 512;
int oneLess = bands - 1;
int thirdBands = bands/3;

// Declare a drawing variable for calculating rect width
float r_width;

// Create a smoothing vector
float[] sum = new float[bands];

// Create a smoothing factor
float smooth_factor = 0.1;

// Declare some phresh new colors
color color1, color2, color3;

// Move values for camera glitch
float xMove, yMove;

// Screen location helpers
int oneThirdH, twoThirdH, halfW;

// Flag for regular or gliched out visuals
// setting to true allows continuous drawing
//  (screen never clears)
boolean constantLayering = false;

// pretty colors!
color[] gSpec, rSpec, ySpec, bSpec, oSpec, wSpec;

// ooh pretty background
color bkg;

void setup() {
  //set size, background, default values
  //size(1280, 720, P3D);
  fullScreen(P3D);
  frameRate(24);
  background(0);
  // for 3d shape drawing
  translate(width/2, height/2, 0);

  color1 = color(255,255,255,104);
  color2 = color(255,255,255,104);
  color3 = color(255,255,255,104);
  oneThirdH = height/3;
  twoThirdH = height - (height/3);
  halfW = width/2;
  
  //set up color pallates:
  //green
  gSpec = new color[3];
  gSpec[0] = color(0, 255, 0, 165);
  gSpec[1] = color(0, 235, 60, 165);
  gSpec[2] = color(0, 255, 128, 165);
  //red
  rSpec = new color[3];
  rSpec[0] = color(255, 0, 0, 165);
  rSpec[1] = color(255, 0, 128, 165);
  rSpec[2] = color(255, 30, 90, 165);
  //yellow
  ySpec = new color[3];
  ySpec[0] = color(255, 255, 0, 165);
  ySpec[1] = color(255, 235, 128, 165);
  ySpec[2] = color(255, 225, 60, 165);
  //blue
  bSpec = new color[3];
  bSpec[0] = color(0, 0, 255, 165);
  bSpec[1] = color(60, 128, 255, 165);
  bSpec[2] = color(128, 60, 255, 165);
  //orange
  oSpec = new color[3];
  oSpec[0] = color(255, 128, 0, 165);
  oSpec[1] = color(255, 100, 0, 165);
  oSpec[2] = color(255, 115, 60, 165);
  //white
  wSpec = new color[3];
  wSpec[1] = color(255, 255, 255, 195);
  wSpec[0] = color(255, 255, 255, 60);
  wSpec[2] = color(255, 255, 255, 30);
  
  // set up our arduino stuff:
  //set the arduino to the proper one from the list.
  arduino = new Arduino(this, Arduino.list()[3], 57600);
  for(int i=2; i<9; i++) {    //config digital pins 2-8 for input
    arduino.pinMode(i, Arduino.INPUT);
  }
  buttonVals = new int[7];  //init button array
  shiftCounter = 0;  //init counter

  // create an input stream
  in = new AudioIn(this, 0);
  in.start();

  // If the Buffersize is larger than the FFT Size, the FFT will fail
  // so we set Buffersize equal to bands
  device = new AudioDevice(this, 44000, bands);

  // Calculate the width of the rects depending on how many bands we have
  r_width = width/float(bands);

  // Create and patch the FFT analyzer
  fft = new FFT(this, bands);
  fft.input(in);    //live input
}      

void draw() {
  //handle all the arduino stuff first
  //read digital pins
  for(int i=2; i<9; i++) { buttonVals[i - 2] = arduino.digitalRead(i); }
  //read analog pins
  velocity = arduino.analogRead(PICKUP);
  wammyVal = arduino.analogRead(WAMMY);
  knobVal = arduino.analogRead(POT);
  
  //decide which fret is down
  if(buttonVals[4] == 1) {  fretDown = 5;  }
  else if(buttonVals[3] == 1)  {  fretDown = 4;  }
  else if(buttonVals[2] == 1)  {  fretDown = 3;  }
  else if(buttonVals[1] == 1)  {  fretDown = 2;  }
  else if(buttonVals[0] == 1)  {  fretDown = 1;  }
  else  {  fretDown = 0;  }
  
  // switch colors according to fret 
  spectrumDeez(fretDown);
  
  //pitch shift buttons get checked every 3 frames 
  // -well i guess not pitch shift anymore...
  shiftCounter++;
  if(shiftCounter >= 3) {
    shiftCounter = 0;
    if(buttonVals[5] == 1)  {  constantLayering = !constantLayering;  }
    else if(buttonVals[6] == 1)  {  stroke(random(255), 104);  }
    else { noStroke(); }
  }
  
  // trigger shit with piezo
  if(velocity > THRESHOLD) {
    // ######### TRIGGER SOMETHING ###########
    bkg = color(255);
  }
  else { bkg = color(0); }
  
  // adjust visualization scale with potentiometer
  scale = BASE_SCALE * ((1 -(knobVal / 1024)) * 5);
  
  // move camera with wammy bar
  camera(width/2.0, ((wammyVal / 512) - 1) * height, (2 - (wammyVal / 512)) * ((height/2.0) / tan(PI*30.0 / 180.0)),
         width/2.0, height/2.0, 0, 0, 1, 0);

  //############ now onto drawing stuff: ###########
  
  //set background and stroke
  //if(!constantLayering) {  background(0);  }
  if(!constantLayering) {  background(bkg);  }
  
  fft.analyze();  //get fft for this frame
  // iterate through bands
  for (int i = 0; i < bands; i++) {
    // Smooth the FFT data by smoothing factor
    sum[i] += (fft.spectrum[i] - sum[i]) * smooth_factor;
    sum[oneLess-i] += (fft.spectrum[oneLess-i] - sum[oneLess-i]) * smooth_factor;
    
    // divide spectrum into three bands for coloring
    if(i >= 0 && i < thirdBands) { fill(color1); }
    else if(i >= thirdBands && i < 2*thirdBands) { fill(color2); }
    else { fill(color3); }
    
    // change colors and cam pos at peaks
    if(sum[i]*height*scale > height) {
      switch((int)(second() % 3)) {
        case 0:
          color1 = color(random(255), random(255), random(255), 165);
          break;
        case 1:
          color2 = color(random(255), random(255), random(255), 165);
          break;
        case 2:
          color3 = color(random(255), random(255), random(255), 165);
          break;
      }
      camMove();  //camera glitch
    }
    beginShape();
    vertex( 0, 0, r_width, -sum[i]*height*scale);
    vertex( width, height, r_width, sum[oneLess-i]*height*scale);
    vertex( 0, width, -sum[oneLess-i]*height*scale);
    vertex( i*r_width, twoThirdH, sum[oneLess-i]*height*scale);
    vertex( 0, height, -sum[oneLess-i]*height*scale);
    vertex( i*r_width-halfW, oneThirdH, sum[oneLess-i]*height*scale);
    vertex( i*r_width+halfW, oneThirdH, -sum[i]*height*scale); 
    vertex( i*r_width+halfW, oneThirdH, sum[i]*height*scale); 
    endShape();
  }  //...end for loop
}

// method for camera move glitch, based on the time its called
//  or randomness (by uncommenting)
void camMove() {
  xMove = millis() % 1280.0f;
  yMove = millis() % 720.0f;
  //xMove = random(200, 1080);
  //yMove = random(100, 620);
  //decide how to move camera
  switch(((int)millis() % 4)) {
    case 0:  //move x
      camera(xMove, 360.0, 360.0 / tan(PI*30.0 / 180.0), // eyeX, eyeY, eyeZ
        width/2.0, height/2.0, 0, 0, 1, 0);
      break;

    case 1:    //move y
      camera(640.0, yMove, 360.0 / tan(PI*30.0 / 180.0), // eyeX, eyeY, eyeZ
        width/2.0, height/2.0, 0, 0, 1, 0);
      break;

    case 2:  //move z
      camera(640.0, 360.0, yMove / tan(PI*30.0 / 180.0), // eyeX, eyeY, eyeZ
        width/2.0, height/2.0, 0, 0, 1, 0);
      break;
     
     case 3:  //default
       camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0),
         width/2.0, height/2.0, 0, 0, 1, 0);
      break;
    }  //end switch
}

void spectrumDeez(int input) {
    //maybe put this stuff in the if / else for buttonVals[]
  switch(input) {
    case 1:
      color1 = gSpec[0];
      color2 = gSpec[1];
      color3 = gSpec[2];
    break;
    
    case 2:
      color1 = rSpec[0];
      color2 = rSpec[1];
      color3 = rSpec[2];
    break;
    
    case 3:
      color1 = ySpec[0];
      color2 = ySpec[1];
      color3 = ySpec[2];
    break;
    
    case 4:
      color1 = bSpec[0];
      color2 = bSpec[1];
      color3 = bSpec[2];
    break;
    
    case 5:
      color1 = oSpec[0];
      color2 = oSpec[1];
      color3 = oSpec[2];
    break;
    
    case 0:
      color1 = wSpec[0];
      color2 = wSpec[1];
      color3 = wSpec[2];
    break;
  }
}