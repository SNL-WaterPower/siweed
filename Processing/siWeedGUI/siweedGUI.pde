import meter.*;
import controlP5.*;  //importing GUI library
import processing.serial.*;
import java.lang.Math.*;
import java.util.LinkedList;
import java.util.Queue;



//ControlP5 cp5; delcared in UI

Textarea myTextarea;

Println console; //Needed for GUI console to work
Textarea consoleOutput; //Needed for GUI console to work

boolean debug = false;    //for debug print statements

int queueSize = 512;    //power of 2 closest to 30(15) seconds at 32 samples/second    !!Needs to match arduino
LinkedList fftList;
fft myFFT;
float[] fftArr;

int previousMillis = 0;    //used to update fft 
int fftInterval = 100;    //in milliseconds
int test = 0;


// meter set up  

Meter myMeter;
String fundingState = "Sandia National Laboratories is a multi-mission laboratory managed \n and operated by National Technology and Engineering Solutions of Sandia, LLC., a wholly owned \n subsidiary of Honeywell International, Inc., for the U.S. Department of Energy's \n National Nuclear Security Administration under contract DE-NA0003525.";
//String welcome = "Can you save the town from its power outage? \nChange the demension and type \n of wave to see how the power changes! \n Change the wave energy converter's controls \n to harvest more power. \n How quickly can you light up all four quadrants?";

void setup() {
  ////////
  frameRate(32);    //sets draw() to run x times a second.
  ///////initialize objects
  
  size(1920, 1100, P2D); //need this for the touch screen
  surface.setTitle("SIWEED");
  waveMaker = new UIData();
  wec = new UIData();
  fftList = new LinkedList();
  myFFT = new fft();
  fftArr = new float[queueSize*2];
  //fftComplexArr = new Complex[queueSize];
  waveMaker.mode = 1;    // 1 = jog, 2 = function, 3 = sea, 4 = off
  wec.mode = 4;  //1 = torque, 2= feedback, 3 = "sea", 4 = off
  initializeDataLogging();
  initializeUI();
  myMeter = new Meter(0.0, 5.0); //min and max

/*
  //initialize the modes on the arduinos:
  port1.write('!');
  sendFloat(0, port1);    //jog mode
  port1.write('j');
  sendFloat(0, port1);    //at position 0
  
  port2.write('!');
  sendFloat(-1, port2);    //off
  
  unitTests();
  */
  
}

/*
public void settings() {

  fullScreen(2);
}*/
boolean initialized = false;
int timestamp = 0;   //for debuging

void draw() {
boolean initialized = false;
int timestamp = 0;   //for debuging
  if (!initialized) {  //Because these take too long, they need to be run in draw(setup cannot take more that 5 seconds.)
    initializeSerial();    //has a 2+ second delay
    unitTests();
    if (debug) {
      print("1 ");
      println(millis() - timestamp);
      timestamp = millis();
    }
    initialized = true;
  }

  displayUpdate(); 
  //The reason for this is because the slider texts. 
  //Without constantly updating the background and boxes, the text from the sliers will just remain there.

  
  // Background color
  background(dblue);
  //Title 
  textFont(fb, 40);
  fill(green);
  textLeading(15);
  textAlign(CENTER, TOP);
  
  image(wavePic, 0, 0, width, height); //background
  fill(buttonblue);
  stroke(buttonblue);
  strokeWeight(0);
  image(snlLogo, width-snlLogo.width*0.25-5, height-snlLogo.height*0.25-5, snlLogo.width*0.25, snlLogo.height*0.25); //Logo
  rect(0, 0, width/3.5, height); // LHS banner 
  fill(255,255,255);
  stroke(255,255,255);
  rect(width/3.5, 0, width, height/2.5); //mission control banner
  fill(turq);
  stroke(turq);
  rect(width/3.5, height/2.5, width, height); //mission control banner
  fill(green);
  text("SIWEED", (width/3.5)/2, 30);
  fill(255,255,255);
  textSize(12);
  textLeading(14);
  text(fundingState, (width/3.5)/2, 1125);
 
  //Mission Control
//  fill(turq, 150);
//  stroke(buttonblue, 150);
//  strokeWeight(3);
//  rect(25, 150, 705, 930, 7); // background
//  fill(green);
//  stroke(buttonblue);
//  rect(15, 130, 225, 75, 7); //Mission Control Title Box 
  //Mission Control Text
  textFont(fb, 25);
  fill(buttonblue);
  textLeading(15);
  textAlign(LEFT, TOP);
  text("Mission Control", (width/3.5 + 50), 30);
  
  // System Status
/*  fill(turq, 150);
  stroke(buttonblue, 150);
  rect(780, 150, 1115, 930, 7); // background
  fill(green);
  stroke(buttonblue);
  rect(770, 130, 225, 75, 7); //system title
  fill(buttonblue);
  rect(1387, 185, 480, 400, 7); //power box
  rect(805, 225, 550, 225, 7); // explainer box
  rect(805, 475, 550, 575, 7); //graph background
  rect(1387, 610, 480, 440, 7); //FFT background 
  fill(255,255,255);
  textFont(fb, 20);
  text(welcome, 810, 250);
  //System Status Text */
  textFont(fb, 25);
  fill(buttonblue);
  textLeading(15);
  textAlign(LEFT, TOP);
  stroke(buttonblue);
  text("System Status", (width/3.5 + 50), (height/2.5 + 30));
  stroke(green); 
    
  textFont(fb, 20);
  fill(buttonblue);
  textLeading(15);
  textAlign(LEFT, TOP);
  text("Change Wave Dimensions", (width/3.5 + 50), 90);
  
  textFont(fb, 20); 
  fill(buttonblue);
  textLeading(15);
  textAlign(LEFT, TOP);
  text("Change WEC Controls", (width/3.5 + 700), 90);
  
  if (debug) {
    print("2 ");
    println(millis() - timestamp);
    timestamp = millis();
  }



  if (debug) {
    print("3 ");
    println(millis() - timestamp);
    timestamp = millis();
  }

  if (debug) {
    print("4 ");
    println(millis() - timestamp);
    timestamp = millis();
  }

  if (debug) {
    print("4 ");
    println(millis() - timestamp);
    timestamp = millis();
  }

  if (debug) {
    print("5 ");
    println(millis() - timestamp);
    timestamp = millis();
  }

  if (debug) {
    print("6 ");
    println(millis() - timestamp);
    timestamp = millis();
  }


  if (debug) {
    print("7 ");
    println(millis() - timestamp);
    timestamp = millis();
  }

  //Meter control:
  pow = 1.25; //might be able to delete 
  myMeter.update(pow);

  if (pow >= 1.25 && pow < 3) {
    quad1.setColorBackground(green);
  }
  if (pow >= 3 && pow < 4.25) {
    quad1.setColorBackground(green);
    quad2.setColorBackground(green);
  }
  if (pow >= 4.25 && pow < 5) {
    quad1.setColorBackground(green);
    quad2.setColorBackground(green);
    quad3.setColorBackground(green);
  }
  if (pow >= 5) {
    quad1.setColorBackground(green);
    quad2.setColorBackground(green);
    quad3.setColorBackground(green);
    quad4.setColorBackground(green);
  }

  if (debug) {
    print("9 ");
    println(millis() - timestamp);
    timestamp = millis();
  }

  //controls button pop up behavior
  if (mousePressed && waveText.isVisible()) {
    waveText.hide();
  }
  //controls button pop up behavior
  if (mousePressed && wecText.isVisible()) {
    wecText.hide();
  }

  if (!megaConnected) {
    //do nothing
  } else if (waveMaker.mode == 1 && position.getValue() != waveMaker.mag) {  //only sends if value has changed  
    //Jog:
    waveMaker.mag = position.getValue();
    port1.write('j');
    sendFloat(waveMaker.mag, port1);
    //function:
  } else if (waveMaker.mode == 2 && !mousePressed && (waveMaker.amp != h.getValue() || waveMaker.freq != freq.getValue())) {    //only executes if a value has changed and the mouse is lifted(smooths transition)
    waveMaker.amp = h.getValue();
    waveMaker.freq = freq.getValue();
    port1.write('a');
    sendFloat(waveMaker.amp, port1);
    port1.write('f');
    sendFloat(waveMaker.freq, port1);
    //Sea State:
  } else if (waveMaker.mode == 3 && !mousePressed && (waveMaker.sigH != sigH.getValue() || waveMaker.peakF != peakF.getValue() || waveMaker.gamma != gamma.getValue())) {    //only executes if a value has changed and the mouse is lifted(smooths transition)
    waveMaker.sigH = sigH.getValue();
    waveMaker.peakF = peakF.getValue();
    waveMaker.gamma = gamma.getValue();
    port1.write('s');
    sendFloat(waveMaker.sigH, port1);
    port1.write('p');
    sendFloat(waveMaker.peakF, port1);
    port1.write('g');
    sendFloat(waveMaker.gamma, port1);    //gamma always needs to be the last sent
  }

  if (debug) {
    print("10 ");
    println(millis() - timestamp);
    timestamp = millis();
  }

  if (!dueConnected) {
    //do nothing
  } else if (wec.mode == 1 && torque.getValue() != wec.mag) {  //only sends if value has changed  
    //Jog:
    wec.mag = torque.getValue();
    port2.write('t');
    sendFloat(wec.mag, port2);
    //feedback:
  } else if (wec.mode == 2 && !mousePressed && (wec.amp != pGain.getValue() || wec.freq != dGain.getValue())) {    //only executes if a value has changed and the mouse is lifted(smooths transition) //for wec, amp is kp and freq is kd;
    wec.amp = pGain.getValue();
    wec.freq = dGain.getValue();
    port1.write('k');
    sendFloat(wec.amp, port2);
    port1.write('d');
    sendFloat(wec.freq, port2);
    //Sea State:
  } else if (wec.mode == 3 && !mousePressed && (wec.sigH != sigHWEC.getValue() || wec.peakF != peakFWEC.getValue() || wec.gamma != gammaWEC.getValue())) {    //only executes if a value has changed and the mouse is lifted(smooths transition)
    wec.sigH = sigHWEC.getValue();
    wec.peakF = peakFWEC.getValue();
    wec.gamma = gammaWEC.getValue();
    port1.write('s');
    sendFloat(wec.sigH, port2);
    port1.write('p');
    sendFloat(wec.peakF, port2);
    port1.write('g');
    sendFloat(wec.gamma, port2);    //gamma always needs to be the last sent
  }

  if (debug) {
    print("11 ");
    println(millis() - timestamp);
    timestamp = millis();
  }

  /////FFT section(move to fft tab eventually):  //!!needs to be activated and deactivated(maybe)
  if (millis() > previousMillis+fftInterval) {
    previousMillis = millis();
    updateFFT();
  }
  drawFFT();
  if (initialized) {
    thread("readMegaSerial");    //will run this funciton in parallel thread
    thread("readDueSerial");
    thread("logData");
  }
  if (debug) {
    print("12 ");
    println(millis() - timestamp);
    timestamp = millis();
  }
  
}//draw closing 

void updateFFT() {
  Complex[] fftIn = new Complex[queueSize];
  for (int i = 0; i < queueSize; i++) {    //fill with zeros
    fftIn[i] = new Complex(0, 0);
  }
  for (int i = 0; i < fftList.size(); i++) {
    fftIn[i] = new Complex((float)fftList.get(i), 0);
  }
  //fftIn[0] = new Complex(1,0);
  //fftIn[1] = new Complex(0,0);
  //fftIn[2] = new Complex(-1,0);
  //fftIn[3] = new Complex(0,0);
  Complex[] fftOut = myFFT.fft(fftIn);
  for (int i = 0; i < queueSize; i++) {
    fftArr[i] = (float)Math.sqrt( fftOut[i].re()*fftOut[i].re() + fftOut[i].im()*fftOut[i].im() )/queueSize;      //magnitude
    //println(fftOut[i].re()+" + "+fftOut[i].im()+"i");
  }
  //println("in: "+fftIn[16]);
  //println("out: "+fftArr[16]);
}
