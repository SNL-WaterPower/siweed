 import controlP5.*;  //importing GUI library
import processing.serial.*;
import java.lang.Math.*;
import java.util.LinkedList;

//MODIFIERS: Change these booleans to adjust runtime functionality:
static final boolean debug = false;    //for debug print statements. Also disables GUI console, and puts it in processing
static final boolean guiConsole = true; 
static final boolean dataLogging = false;    //if this is true, a .csv with most variables will be written in the data folder with the sketch
static final boolean basicMode = false;      //disables some control modes, to make the GUI simpler to use
////////////////////Scaling section:
//input scaling:
static final float WMJogScale = 1000;
static final float WMAmpScale = 1000;
static final float WMSigHScale = 1000;    //These should be a multiple of 10, so units can stay accurate
static final float WCJogScale = 1000;
static final float WCPScale = 40;
static final float WCDScale = 200;
static final float WCSigHScale = 1000; 
//chart scaling:    //these factors are used in serial upon receipt of variables.
static final float waveElevationScale = 500;
static final float WMPosScale = 250;
static final float WCPosScale = 500;
static final float WCTauScale = 1000;
static final float WCPowScale = 15000;
static final float WCVelScale = 60;
////////////////////////////

Println console; //Needed for GUI console to work
Textarea consoleOutput; //Needed for GUI console to work

int queueSize = 512;    //power of 2 closest to 15 seconds at 32 samples/second    !!Needs to match sampling rate of arduino
LinkedList<Float> fftList;     //used to store the data coming into the FFT
fft myFFT;
float[] fftArr;        //used to store the output from the fft
//int originalx, originaly;    //used to track when the window is resized
int previousMillis = 0;    //used to update fft 
int fftInterval = 100;    //in milliseconds. This is the time between FFT calculations, so it can run at a slower rate
boolean sendNewDataWM = false, sendNewDataWEC = false;    //when a mode button is switched, this flag is set true to indicate that slider values need to be sent

// meter set up  

Meter myMeter;
String fundingState = "Sandia National Laboratories is a multi-mission laboratory managed \n and operated by National Technology and Engineering Solutions of Sandia, LLC., a wholly owned \n subsidiary of Honeywell International, Inc., for the U.S. Department of Energy's \n National Nuclear Security Administration under contract DE-NA0003525.";
//String welcome = "Can you save the town from its power outage? \nChange the demension and type \n of wave to see how the power changes! \n Change the wave energy converter's controls \n to harvest more power. \n How quickly can you light up all four quadrants?";

void setup() {
  ////////
  frameRate(32);    //sets draw() to run x times a second.
  ///////initialize objects
  //size(1920, 1100, P2D); //need this for the touch screen
  fullScreen(P2D);
  //surface.setResizable(true);    //throws an error
  surface.setTitle("SIWEED");
  waveMaker = new UIData();
  wec = new UIData();
  fftList = new LinkedList<Float>();     //stores the input to the FFT
  myFFT = new fft();
  fftArr = new float[queueSize*2];    //used to store the output from the FFT
  waveMaker.mode = 1;    // 1 = jog, 2 = function, 3 = sea, 4 = off
  wec.mode = 1;  //1 = jog, 2= feedback, 3 = "sea", 4 = off
  if (dataLogging) {
    initializeDataLogging();
  }
  initializeUI();
  myMeter = new Meter(-2.0, 2.0);    //min and max
}
boolean initialized = false;
void draw() {
  if (debug) {
    //print("framerate: ");
    //println(frameRate);
  }
  int timestamp = 0;   //for debuging
  if (!initialized) {  //Because these take too long, they need to be run in draw(setup cannot take more that 5 seconds.)
    initializeSerial();    //has a 2+ second delay
    unitTests();
    //press buttons to initialize GUI and Arduino modes:
    //set chart buttons true at startup by virtually pressing the button:
    wavePosData();
    wecPosData();
    if (!basicMode) {    //if in normal mode, virtually press these buttons
      jog();
      torque();
    } else {    //if in basic mode, start with theses buttons pressed:
      off();
      feedback();
    }
    initialized = true;
  } else {      //if initialized
    if (dataLogging) {
      logData();
    }
    readWMSerial();
    readWECSerial();
    verifyChecksum();
  }
  displayUpdate(); 
  drawFFT();
  //Meter control:
  myMeter.update(pow*WCPowScale);
  //slider input:
  if (!WMConnected) {
    //do nothing
  } else if (waveMaker.mode == 1 && (position.getValue() != waveMaker.mag*WMJogScale || sendNewDataWM)) {  //send data if mode is right and value has changed or button has been pressed
    //Jog:
    if (frameCount % 2 == 0) {      //limits how often data is sent
      waveMaker.mag = position.getValue()/WMJogScale;
      sendSerial('j', waveMaker.mag, port1, 1);
      sendNewDataWM = false;
    }
    //function:
  } else if (waveMaker.mode == 2 && ( (!mousePressed && (waveMaker.amp*WMAmpScale != h.getValue() || waveMaker.freq != freq.getValue()) ) || sendNewDataWM) ) {    //only executes if mode is right and ( (value has changed and mouse is lifted) or mode button has been pressed)
    waveMaker.amp = h.getValue()/WMAmpScale;
    waveMaker.freq = freq.getValue();
    sendSerial('a', waveMaker.amp, port1);
    sendSerial('f', waveMaker.freq, port1, 2);
    sendNewDataWM = false;
    //Sea State:
  } else if (waveMaker.mode == 3 && ( (!mousePressed && (waveMaker.sigH*WMSigHScale != sigH.getValue() || waveMaker.peakF != peakF.getValue() || waveMaker.gamma != gamma.getValue()) ) || sendNewDataWM) ) {    //only executes if mode is right and ( (value has changed and mouse is lifted) or mode button has been pressed)
    waveMaker.sigH = sigH.getValue()/WMSigHScale;
    waveMaker.peakF = peakF.getValue();
    waveMaker.gamma = gamma.getValue();
    sendSerial('s', waveMaker.sigH, port1);
    sendSerial('p', waveMaker.peakF, port1);
    sendSerial('g', waveMaker.gamma, port1, 3);    //gamma always needs to be the last sent
    sendNewDataWM = false;
    if (debug) {
      println("sending jonswap values");
    }
  }

  if (!WECConnected) {
    //do nothing
  } else if (wec.mode == 1 && (torqueSlider.getValue() != wec.mag*WCJogScale || sendNewDataWEC)) {  //send data if mode is right and value has changed or button has been pressed
    //Jog:
    if (frameCount % 2 == 0) {      //limits how often data is sent
      wec.mag = torqueSlider.getValue()/WCJogScale;
      //wec.mag = sin(0.1*2*PI*millis()/1000)*torqueSlider.getValue()/WCJogScale;
      sendSerial('t', wec.mag, port2, 1);
      sendNewDataWEC = false;
    }
    //feedback:
  } else if (wec.mode == 2 && ( (!mousePressed && (wec.amp*WCPScale != pGain.getValue() || wec.freq*WCDScale != dGain.getValue()) )|| sendNewDataWEC) ) {    //only executes if mode is right and ( (value has changed and mouse is lifted) or mode button has been pressed) //for wec, amp is kp and freq is kd;
    wec.amp = pGain.getValue()/WCPScale;
    wec.freq = dGain.getValue()/WCDScale;
    sendSerial('k', wec.amp, port2);
    sendSerial('d', wec.freq, port2, 2);
    sendNewDataWEC = false;
    //Sea State:
  } else if (wec.mode == 3 && ( (!mousePressed && (wec.sigH*WCSigHScale != sigHWEC.getValue() || wec.peakF != peakFWEC.getValue() || wec.gamma != gammaWEC.getValue()) )|| sendNewDataWEC) ) {    //only executes if mode is right and ( (value has changed and mouse is lifted) or mode button has been pressed)
    wec.sigH = sigHWEC.getValue()/WCSigHScale;
    wec.peakF = peakFWEC.getValue();
    wec.gamma = gammaWEC.getValue();
    sendSerial('s', wec.sigH, port2);
    sendSerial('p', wec.peakF, port2);
    sendSerial('g', wec.gamma, port2, 3);    //gamma always needs to be the last sent
    sendNewDataWEC = false;
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
