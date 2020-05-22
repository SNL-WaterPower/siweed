import meter.*;
import controlP5.*; //importing GUI library
import processing.serial.*;
import java.lang.Math.*;
import java.util.LinkedList;
import java.util.Queue;

int queueSize = 1024;    //power of 2 closest to 30 seconds

// Custom colors
color green = color(190, 214, 48);
color turq = color(0, 173, 208);
color dblue = color(0, 83, 118);

// Fonts
PFont f; // Regular font
PFont fb; // Bold font

// Sandia logo
PImage snlLogo;
miniWaveTankJonswap jonswap;

Serial port1;    //arduino mega
Serial port2;    //arduino Due
ControlP5 cp5; 
Chart waveSig; //wave Signal chart
Slider position; //slider for position mode
Slider h, freq; //sliders for function mode
Slider sigH, peakF, gamma;  //sliders for sea state mode
Slider torque, other; // WEC sliders
Button jog, function, sea, off; // mode buttons

Table table;  //table for data logging
String startTime;
//Variables to be logged:
//int nComponents = 10;     //number of wave components in sea state
public class UIData {        //an object for the WEC and Wavemaker portions of the UI to use
  public int mode;
  public float mag, amp, freq, sigH, peakF, gamma;
}
//data not held in the class(not in the UI):
float probe1, probe2, waveMakerPos, debugData, wecPos, tau, pow;
UIData waveMaker;
UIData wec;
Queue fftQueue;
FFTbase fft;
void setup() {
  fullScreen(P2D);
  frameRate(30);    //sets draw() to run 30 times a second. It would run around 40 without this restriciton
  ///////initialize jonswap
  jonswap = new miniWaveTankJonswap();
  /////////initilize UIData objects
  waveMaker = new UIData();
  wec = new UIData();
  fftQueue = new LinkedList();
  fft = new FFTbase();
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
    port1.write('n');
    sendFloat(jonswap.getNum(), port1);    //update n
    port1.write('a');              //send amplitude vector
    for (float f : jonswap.getAmp()) {
      sendFloat(f, port1);
    }
    port1.write('p');              //send phase vector
    for (float f : jonswap.getPhase()) {
      sendFloat(f, port1);
    }
    port1.write('f');              //send frequency vector
    for (float f : jonswap.getF()) {
      sendFloat(f, port1);
    }
    /////FFT section:
    if(fftQueue.size() == ) {
      
    }else{
    }
  }
  /*/////////testing section////
   
   float val = 0;
   for (int i = 0; i < jonswap.getNum(); i++) {
   val += jonswap.getAmp()[i] * sin(2.0 * PI * (millis()/1000.0 - 2.0) * jonswap.getF()[i] + jonswap.getPhase()[i]);
   }
   waveSig.push("incoming", val);
   ///////////////////*/

  readMegaSerial();
  //thread("readMegaSerial");    //will run this funciton in parallel thread
  thread("readDueSerial");
  thread("logData");
}

//Funciton to test CSV functionality     //should be called by thread("functionName") in draw, like readSerail() is now
void logData() {     //will be called at the framerate
  TableRow newRow = table.addRow();
  newRow.setFloat("timeStamp", millis());
  newRow.setInt("UIWaveMakerMode", waveMaker.mode);
  newRow.setFloat("UIWaveMakerPos", waveMaker.mag);
  newRow.setFloat("UIWaveMakerHeight", waveMaker.amp);
  newRow.setFloat("UIWaveMakerFrequency", waveMaker.freq);
  newRow.setFloat("UIWaveMakerSigH", waveMaker.sigH);
  newRow.setFloat("UIWaveMakerPeakF", waveMaker.peakF);
  newRow.setFloat("UIWaveMakergamma", waveMaker.gamma);
  newRow.setFloat("UIWecMode", wec.mode);
  newRow.setFloat("UIWecTorque", wec.mag);
  newRow.setFloat("UIWeckP", torque.getValue());
  newRow.setFloat("UIWeckD", other.getValue()); 
  newRow.setFloat("UIWecHeight", wec.amp);
  newRow.setFloat("UIWecFrequency", wec.freq);
  newRow.setFloat("UIWecSigH", wec.sigH);
  newRow.setFloat("UIWecPeakF", wec.peakF);
  newRow.setFloat("UIWecgamma", wec.gamma);
  newRow.setFloat("probe1", probe1);
  newRow.setFloat("probe2", probe2);
  newRow.setFloat("waveMakerPos", waveMakerPos);
  newRow.setFloat("waveMakerDebugData", debugData);
  newRow.setFloat("wecPos", wecPos);
  newRow.setFloat("wecTau", tau);
  newRow.setFloat("wecPower", pow);
  saveTable(table, "data/"+startTime+".csv");
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
