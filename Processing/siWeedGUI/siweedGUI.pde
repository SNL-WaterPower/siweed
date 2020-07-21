import meter.*;
import controlP5.*; //importing GUI library
import processing.serial.*;
import java.lang.Math.*;
import java.util.LinkedList;
import java.util.Queue;

int queueSize = 512;    //power of 2 closest to 30(15) seconds at 32 samples/second    !!Needs to match arduino
LinkedList fftList;
fft myFFT;
float[] fftArr;

int previousMillis = 0;    //used to update fft 
int fftInterval = 100;    //in milliseconds

///test vars:
/*
float TSVal;
 */
 
// meter set up  
Meter m;
void setup() {
  ////////
  frameRate(32);    //sets draw() to run x times a second.
  ///////initialize objects
 // size(1920,1200);
  waveMaker = new UIData();
  wec = new UIData();
  fftList = new LinkedList();
  myFFT = new fft();
  fftArr = new float[queueSize*2];
  //fftComplexArr = new Complex[queueSize];
  waveMaker.mode = 1;    // 1 = jog, 2 = function, 3 = sea, 4 = off
  wec.mode = 3;  //1 = torque, 2 = "sea", 3 = off
  initializeDataLogging();
  initializeSerial();    //has a 2 second delay
  initializeUI();

  //initialize the modes on the arduinos:
  port1.write('!');
  sendFloat(0, port1);    //jog mode
  port1.write('j');
  sendFloat(0, port1);    //at position 0
  
  port2.write('!');
  sendFloat(-1, port2);    //off
  
  //adding meter 
  m = new Meter(this, 1120, 850);
  m.setTitle("Power");
  m.setFrameColor(color(turq));
  m.setMinInputSignal(0);
  m.setMaxInputSignal(500);
  //// Use the default values for testing, 0 - 255.
  //minIn = m.getMinInputSignal();
  //maxIn = m.getMaxInputSignal();
  
}

public void settings() {
  fullScreen(2);
}

void draw() {
  // Background color
  background(dblue);
  //Title 
  textFont(fb, 32);
  fill(green);
  textLeading(15);
  textAlign(CENTER, TOP);
  text("CAPTURING the POWER of WAVES", width/2, 50);
  
  rect(25, 100, 800, 550, 7);
  rect(25, 680, 800, 550, 7);
  
  textFont(fb, 20);
  fill(buttonblue);
  textLeading(15);
  textAlign(CENTER, TOP);
  text("Change Wave Dimensions", 175, 120);
  
  textFont(fb, 20);
  fill(buttonblue);
  textLeading(15);
  textAlign(CENTER, TOP);
  text("Change WEC Controls", 175, 700);

  tint(255, 126);  // Apply transparency without changing color
  image(wavePic, 5, 5, width, 100);
  image(snlLogo, 5, height-snlLogo.height*0.25-5, snlLogo.width*0.25, snlLogo.height*0.25);

  //dividing line
  stroke(green);
  strokeWeight(2);
  strokeCap(ROUND);
  line(width/3, 150, width/3, height-150); //height = 1440
  
  
  
  

  
  
  //meter
  // Input for testing.
  // Update the sensor value to the meter.
  m.updateMeter((int)(100*pow));
  // Use a delay to see the changes.
  
  //controls button pop up behavior
  if (mousePressed && waveText.isVisible()){
    waveText.hide();
  }
  //controls button pop up behavior
  if (mousePressed && wecText.isVisible()){
    wecText.hide();
  }
  //Jog:
  if (waveMaker.mode == 1 && position.getValue() != waveMaker.mag) {  //only sends if value has changed  
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
  
  /////FFT section(move to fft tab eventually):  //!!needs to be activated and deactivated(maybe)
  if (millis() > previousMillis+fftInterval) {
    previousMillis = millis();
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
      fftArr[i] = 2.0*(float)Math.sqrt( fftOut[i].re()*fftOut[i].re() + fftOut[i].im()*fftOut[i].im() )/queueSize;      //magnitude
      //println(fftOut[i].re()+" + "+fftOut[i].im()+"i");
    }
    //println("in: "+fftIn[16]);
    //println("out: "+fftArr[16]);
  }
  drawFFT();
  thread("readMegaSerial");    //will run this funciton in parallel thread
  thread("readDueSerial");
  thread("logData");
}
