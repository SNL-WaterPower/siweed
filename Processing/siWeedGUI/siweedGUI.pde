import meter.*;
import controlP5.*; //importing GUI library
import processing.serial.*;
import java.lang.Math.*;
import java.util.LinkedList;
import java.util.Queue;

int queueSize = 1024;    //power of 2 closest to 30 seconds at 30 samples/second
miniWaveTankJonswap jonswap;
Table table;  //table for data logging
String startTime;
LinkedList fftList;
FFTbase myFFT;
float[] fftArr;

int previousMillis = 0;    //used to update fft 
int fftInterval = 100;    //in milliseconds

///test vars:
int sampleCount = 0;    //total number of samples gathered
int matchCount = 0;      //number of samples that have matched base set
float[] baseSet;
void setup() {
  //tests:///
  baseSet = new float[100];
  ////////
  fullScreen(P2D);
  frameRate(32);    //sets draw() to run 30 times a second.
  ///////initialize objects
  jonswap = new miniWaveTankJonswap();
  waveMaker = new UIData();
  wec = new UIData();
  fftList = new LinkedList();
  myFFT = new FFTbase();
  fftArr = new float[queueSize*2];
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
  port1.write('n');
  sendFloat(1, port1);    //initialize n at 1

  port2.write('!');
  sendFloat(-1, port2);    //off
  port2.write('n');
  sendFloat(1, port2);    //initialize n at 1
}

void draw() {
  // Background color
  background(dblue);
  //Title 
  textFont(fb, 32);
  fill(green);
  textLeading(15);
  textAlign(CENTER, TOP);
  text("CAPTURING the POWER of WAVES", width/6, 20);
  //Sandia Labs logo
  tint(255, 126);  // Apply transparency without changing color
  image(snlLogo, 5, height-snlLogo.height*0.25-5, snlLogo.width*0.25, snlLogo.height*0.25);
  //dividing line
  stroke(green);
  strokeWeight(1.5);
  line(width/3, 75, width/3, height-75);

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
    //update the jonswap values with new inputs
    jonswap.update(waveMaker.sigH, waveMaker.peakF, waveMaker.gamma);
    //then send to arduino
    //!!!!put this in a thread to not slow down processing(maybe)
    port1.write('n');
    sendFloat(jonswap.getNum(), port1);    //update n
    port1.write('a');              //send amplitude vector
    for (float f : jonswap.getAmp()) {
      //sendFloat(f, port1);
    }
    port1.write('p');              //send phase vector
    for (float f : jonswap.getPhase()) {
      //sendFloat(f, port1);
    }
    port1.write('f');              //send frequency vector
    for (float f : jonswap.getF()) {
      //sendFloat(f, port1);
    }
  }
  /////FFT section(move to fft tab eventually):
  if (millis() > previousMillis+fftInterval) { //fftList.size() == queueSize && 
    previousMillis = millis();
    //println("graphing FFT");
    float[] signalr = new float[queueSize];   //signal real
    float[] signali = new float[queueSize];    //signal imaginary
    for (int i = 0; i < fftList.size(); i++) {
      signalr[i] = (float)fftList.get(i);
    }
    fftArr = myFFT.fft(signalr, signali, true);
  }
  for (int i=0; i<queueSize*2; i++) {
    line((width*3/6)+.5*i, height/2, (width*3/6)+.5*i, height/2 - 20*fftArr[i]);
  }
  /////////testing section////
/*
  float val = 0;
  for (int i = 0; i < jonswap.getNum(); i++) {
    val += jonswap.getAmp()[i] * sin(2.0 * PI * (millis()/1000.0 - 2.0) * jonswap.getF()[i] + jonswap.getPhase()[i]);
    //val = sin(2.0 * PI * millis()/1000.0);
  }
  waveSig.push("incoming", val);
  if (waveMaker.mode == 3) {
    fftList.add(val);      //adds to the tail if in the right mode
    sampleCount++;
    if (fftList.size() > queueSize)
    {
      fftList.remove();          //removes from the head
    }
    if (sampleCount < 11) {    //skips first 10
    } else if (sampleCount < 111) {    //writes initial
      baseSet[sampleCount-11] = val;
    } else if (val - baseSet[matchCount] < 0.01) {
      matchCount++;
      if (matchCount > 50) {
        println("match: "+ matchCount + " sample# "+sampleCount);
      }
    } else if (matchCount > 0) {
      println("match failed " + sampleCount+"  "+matchCount);
      matchCount = 0;
    }
  }
  //println(fftList.size());
  */
  ///////////////////*/

  readMegaSerial();
  //thread("readMegaSerial");    //will run this funciton in parallel thread
  thread("readDueSerial");
  thread("logData");
}


/////Old but maybe useful:
/*
void serialEvent(Serial thisPort){
 if (thisPort == port1){
 readMegaSerial();
 }else if(thisPort == port2){
 readDueSerial();
 }
 }
 //Would work if you could guarantee that the last available character was '>'. Current version is the same but with a wait
 float altreadFloat(Serial port) {    //better, since a buffer is used, but then not all data is drawn. Either data needs to be stored or old method returned to
 if (port.readChar() == '<') {
 String str = port1.readStringUntil('>');
 str = str.substring(0, str.length()-1);    //removes the >
 return float(str);
 } else {
 return -1.0;
 }
 }
 */
