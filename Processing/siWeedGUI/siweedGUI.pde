import controlP5.*;  //importing GUI library
import processing.serial.*;
import java.lang.Math.*;
import java.util.LinkedList;

////////////////////Scaling section:
//input scaling:
float WMJogScale = 1000;
float WMAmpScale = 1000;
float WMSigHScale = 1000;    //These should be a multiple of 10, so units can stay accurate
float WCJogScale = 1000;
float WCPScale = 80;
float WCDScale = 600;
float WCSigHScale = 1000; 
//chart scaling:    //these factors are used in serial upon receipt of variables.
float waveElevationScale = 1000;
float WMPosScale = 400;
float WCPosScale = 500;
float WCTauScale = 1000;
float WCPowScale = 5000;
float WCVelScale = 20;
////////////////////////////
boolean debug = false;    //for debug print statements. Also disables GUI console, and puts it in processing
boolean guiConsole = false; 
boolean dataLogging = false;    //if this is true, a .csv with most variables will be written, but it has a memory leak and cannot run at high performance for more than a few minutes

Println console; //Needed for GUI console to work
Textarea consoleOutput; //Needed for GUI console to work

int queueSize = 512;    //power of 2 closest to 30(15) seconds at 32 samples/second    !!Needs to match arduino
LinkedList fftList;
fft myFFT;
float[] fftArr;
int previousMillis = 0;    //used to update fft 
int fftInterval = 100;    //in milliseconds

// meter set up  

Meter myMeter;
String fundingState = "Sandia National Laboratories is a multi-mission laboratory managed \n and operated by National Technology and Engineering Solutions of Sandia, LLC., a wholly owned \n subsidiary of Honeywell International, Inc., for the U.S. Department of Energy's \n National Nuclear Security Administration under contract DE-NA0003525.";
//String welcome = "Can you save the town from its power outage? \nChange the demension and type \n of wave to see how the power changes! \n Change the wave energy converter's controls \n to harvest more power. \n How quickly can you light up all four quadrants?";

void setup() {
  ////////
  frameRate(32);    //sets draw() to run x times a second.
  ///////initialize objects
  size(1920, 1100, P2D); //need this for the touch screen
  //size(displayWidth, displayHeight, P2D); //need this for the touch screen
  //fullScreen();
  //surface.setResizable(true);
  surface.setTitle("SIWEED");
  waveMaker = new UIData();
  wec = new UIData();
  fftList = new LinkedList();
  myFFT = new fft();
  fftArr = new float[queueSize*2];
  waveMaker.mode = 1;    // 1 = jog, 2 = function, 3 = sea, 4 = off
  wec.mode = 1;  //1 = jog, 2= feedback, 3 = "sea", 4 = off
  if (dataLogging) {
    initializeDataLogging();
  }
  initializeUI();
  myMeter = new Meter(-2.0, 2.0);    //min and max
}

/*
public void settings() {
 fullScreen();
 }
 */

boolean initialized = false;
void draw() {
  int timestamp = 0;   //for debuging
  if (!initialized) {  //Because these take too long, they need to be run in draw(setup cannot take more that 5 seconds.)
    initializeSerial();    //has a 2+ second delay
    unitTests();
    initialized = true;
  }
  displayUpdate(); 
  drawFFT();
  //Meter control:
  myMeter.update(pow*WCPowScale);

  if (!WMConnected) {
    //do nothing
  } else if (waveMaker.mode == 1 && position.getValue() != waveMaker.mag*WMJogScale) {  //only sends if value has changed  
    //Jog:
    waveMaker.mag = position.getValue()/WMJogScale;
    port1.write('j');
    sendFloat(waveMaker.mag, port1);
    //function:
  } else if (waveMaker.mode == 2 && !mousePressed && (waveMaker.amp*WMAmpScale != h.getValue() || waveMaker.freq != freq.getValue())) {    //only executes if a value has changed and the mouse is lifted(smooths transition)
    waveMaker.amp = h.getValue()/WMAmpScale;
    waveMaker.freq = freq.getValue();
    port1.write('a');
    sendFloat(waveMaker.amp, port1);
    port1.write('f');
    sendFloat(waveMaker.freq, port1);
    //Sea State:
  } else if (waveMaker.mode == 3 && !mousePressed && (waveMaker.sigH*WMSigHScale != sigH.getValue() || waveMaker.peakF != peakF.getValue() || waveMaker.gamma != gamma.getValue())) {    //only executes if a value has changed and the mouse is lifted(smooths transition)
    waveMaker.sigH = sigH.getValue()/WMSigHScale;
    waveMaker.peakF = peakF.getValue();
    waveMaker.gamma = gamma.getValue();
    port1.write('s');
    sendFloat(waveMaker.sigH, port1);
    port1.write('p');
    sendFloat(waveMaker.peakF, port1);
    port1.write('g');
    sendFloat(waveMaker.gamma, port1);    //gamma always needs to be the last sent
    if (debug) {
      println("sending jonswap values");
    }
  }

  if (!WECConnected) {
    //do nothing
  } else if (wec.mode == 1 && torqueSlider.getValue() != wec.mag*WCJogScale) {  //only sends if value has changed  
    //Jog:
    wec.mag = torqueSlider.getValue()/WCJogScale;
    port2.write('t');
    sendFloat(wec.mag, port2);
    //feedback:
  } else if (wec.mode == 2 && !mousePressed && (wec.amp*WCPScale != pGain.getValue() || wec.freq*WCDScale != dGain.getValue())) {    //only executes if a value has changed and the mouse is lifted(smooths transition) //for wec, amp is kp and freq is kd;
    wec.amp = pGain.getValue()/WCPScale;
    wec.freq = dGain.getValue()/WCDScale;
    port2.write('k');
    sendFloat(wec.amp, port2);
    port2.write('d');
    sendFloat(wec.freq, port2);
    //Sea State:
  } else if (wec.mode == 3 && !mousePressed && (wec.sigH*WCSigHScale != sigHWEC.getValue() || wec.peakF != peakFWEC.getValue() || wec.gamma != gammaWEC.getValue())) {    //only executes if a value has changed and the mouse is lifted(smooths transition)
    wec.sigH = sigHWEC.getValue()/WCSigHScale;
    wec.peakF = peakFWEC.getValue();
    wec.gamma = gammaWEC.getValue();
    port2.write('s');
    sendFloat(wec.sigH, port2);
    port2.write('p');
    sendFloat(wec.peakF, port2);
    port2.write('g');
    sendFloat(wec.gamma, port2);    //gamma always needs to be the last sent
  }

  /////FFT section(move to fft tab eventually):  //!!needs to be activated and deactivated based on mode(maybe)
  if (millis() > previousMillis+fftInterval) {
    previousMillis = millis();
    updateFFT();
  }
  if (initialized) {
    if (dataLogging) {
      logData();
    }
    readWMSerial();
    readWECSerial();
  }
}


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
  }
}
