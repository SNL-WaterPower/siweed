import meter.*;
import controlP5.*; //importing GUI library
import processing.serial.*;
import java.lang.Math.*;

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
int nComponents = 10;     //number of wave components in sea state
public class UIData {        //an object for the WEC and Wavemaker portions of the UI to use
  public int mode;
  public float mag, amp, freq, sigH, peakF, gamma;
}
//data not held in the class(not in the UI):
float probe1, probe2, waveMakerPos, debugData, wecPos, tau, pow;
UIData waveMaker;
UIData wec;

void setup() {
  fullScreen(P2D);
  frameRate(30);    //sets draw() to run 30 times a second. It would run around 40 without this restriciton
  ///////initialize jonswap
  jonswap = new miniWaveTankJonswap();
  /////////initilize UIData objects
  waveMaker = new UIData();
  wec = new UIData();
  waveMaker.mode = 1;    // 1 = jog, 2 = function, 3 = sea, 4 = off
  wec.mode = 3;  //1 = torque, 2 = "sea", 3 = off
  startTime = month() + "-" + day() + "-" + year() + "_" + hour() + "-" + minute() + "-" + second();
  //Table initialization:
  table = new Table();
  table.addColumn("timeStamp");
  table.addColumn("UIWaveMakerMode");
  table.addColumn("UIWaveMakerPos");
  table.addColumn("UIWaveMakerHeight");
  table.addColumn("UIWaveMakerFrequency");
  table.addColumn("UIWaveMakerSigH");
  table.addColumn("UIWaveMakerPeakF");
  table.addColumn("UIWaveMakergamma");
  table.addColumn("UIWecMode");
  table.addColumn("UIWecTorque");
  table.addColumn("UIWeckP");
  table.addColumn("UIWeckD");
  table.addColumn("UIWecHeight");
  table.addColumn("UIWecFrequency");
  table.addColumn("UIWecSigH");
  table.addColumn("UIWecPeakF");
  table.addColumn("UIWecgamma");
  table.addColumn("probe1");
  table.addColumn("probe2");
  table.addColumn("waveMakerPos");
  table.addColumn("waveMakerDebugData");
  table.addColumn("wecPos");
  table.addColumn("wecTau");
  table.addColumn("wecPower");
  ///////////initialize Serial
  port1 = new Serial(this, "COM4", 250000); // all communication with Megas
  port2 = new Serial(this, "COM5", 250000); // all communication with Due
  delay(2000);
  //Fonts
  f = createFont("Arial", 16, true);
  fb = createFont("Arial Bold Italic", 32, true);
  // starting ControlP5 stuff
  cp5 = new ControlP5(this);

  // Buttons //
  jog = cp5.addButton("jog")
    .setPosition(100, 100)
    .setSize(100, 50)
    .setLabel("Jog Mode");

  function = cp5.addButton("fun")
    .setPosition(200, 100)
    .setSize(100, 50)
    .setLabel("Function Mode"); 

  sea = cp5.addButton("sea")
    .setPosition(300, 100)
    .setSize(100, 50)
    .setLabel("Sea State"); 

  off = cp5.addButton("off")
    .setPosition(400, 100)
    .setSize(100, 50)
    .setLabel("OFF"); 

  // Sliders // 
  position = cp5.addSlider("Position (CM)")  //name slider
    .setRange(-10, 10) //slider range
    .setPosition(150, 250) //x and y coordinates of upper left corner of button
    .setSize(300, 20); //size (width, height)

  h = cp5.addSlider("Height (CM)")  //name slider
    .setRange(0, 10) //slider range
    .setPosition(150, 250) //x and y coordinates of upper left corner of button
    .setSize(300, 20)
    .hide(); //size (width, height)

  freq = cp5.addSlider("Frequency (Hz)")  //name of button
    .setRange(0, 4)
    .setPosition(150, 300) //x and y coordinates of upper left corner of button
    .setSize(300, 20)
    .hide(); //size (width, height)

  sigH = cp5.addSlider("Significant Height (CM)")  //name slider
    .setRange(0, 10) //slider range
    .setPosition(150, 250) //x and y coordinates of upper left corner of button
    .setSize(300, 20)
    .hide(); //size (width, height)

  peakF = cp5.addSlider("Peak Frequency (Hz)")  //name of button
    .setRange(2, 4)
    .setPosition(150, 300) //x and y coordinates of upper left corner of button
    .setSize(300, 20)
    .hide(); //size (width, height)

  gamma = cp5.addSlider("Peakedness")  //name of button
    .setRange(1, 7)
    .setPosition(150, 350) //x and y coordinates of upper left corner of button
    .setSize(300, 20)
    .hide(); //size (width, height)

  torque = cp5.addSlider("Torque")  //name of button
    .setRange(0, 0.5)
    .setPosition(150, 650) //x and y coordinates of upper left corner of button
    .setSize(300, 20); //size (width, height)

  other = cp5.addSlider("otherthing")  //name of button
    .setRange(0, 0.5)
    .setPosition(150, 700) //x and y coordinates of upper left corner of button
    .setSize(300, 20); //size (width, height)

  // Charts //
  waveSig =  cp5.addChart("Sin Wave")
    .setPosition(933.375, 100  )
    .setSize(800, 300)
    .setRange(-5, 5)
    .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
    .setStrokeWeight(4)
    .setColorCaptionLabel(color(40))
    .setColorBackground(turq)
    .setColorLabel(green)
    ;

  waveSig.addDataSet("incoming");
  waveSig.setData("incoming", new float[3600]);    //use to set the domain of the plot
  
  sigH.setValue(2.5);
  peakF.setValue(3.0);
  gamma.setValue(7.0);
  

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

  snlLogo = loadImage("SNL_Stacked_White.png");
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
  }
  /////////testing section////
  
  float val = 0;
  for (int i = 0; i < jonswap.getNum(); i++) {
    val += jonswap.getAmp()[i] * sin(2.0 * PI * (millis()/1000.0 - 2.0) * jonswap.getF()[i] + jonswap.getPhase()[i]);
  }
  waveSig.push("incoming", val);
  ///////////////////
  
  thread("readMegaSerial");    //will run this funciton in parallel thread
  thread("readDueSerial");
  thread("logData");
}

/////////////////// MAKES BUTTONS DO THINGS ////////////////////////////////////

void jog() {
  waveMaker.mode = 1;
  h.hide();
  freq.hide();
  sigH.hide();
  peakF.hide();
  gamma.hide();
  position.show();
  //set mode on arduino:
  port1.write('!');
  sendFloat(0, port1);
}

void fun() {
  waveMaker.mode = 2;
  position.hide();
  gamma.hide();
  sigH.hide();
  peakF.hide();
  gamma.hide();

  h.show();
  freq.show();
  //set mode on arduino:
  port1.write('!');
  sendFloat(1, port1);
  //tell arduino to only look at one component
  port1.write('n');
  sendFloat(1, port1);
}

void sea() {
  waveMaker.mode = 3;
  h.hide();
  freq.hide();
  h.hide();
  position.hide();
  sigH.show();
  peakF.show();
  gamma.show();
  //set mode on arduino:
  port1.write('!');
  sendFloat(1, port1);
  //tell arduino to look at all components
  port1.write('n');
  sendFloat(nComponents, port1);
}

void off() {
  waveMaker.mode = 4;
  h.setValue(0);
  freq.setValue(0);
  sigH.setValue(0);
  peakF.setValue(0); 
  gamma.setValue(0);
  position.setValue(0);
  //set mode on arduino:
  port1.write('!');
  sendFloat(-1, port1);
}
void sendFloat(float f, Serial port)
{
  /* 
   For mega:
   '!' indicates mode switch
   j indicates jog position
   
   n indicates length of vectors/number of functions in sea state(starting at 1)
   a indicates incoming amp vector
   p indicates incoming phase vector
   f indicates incoming frequency vector
   
   ex:  !<1>n<2>a<1.35><2.36>p<1.35><2.36>f<1.35><2.36>    
   
   with this function sending data will look something like this:
   if(values have changed)    //or run certain lines on a button press
   port1.write('!');    set mode(only needs to be done when switching)
   sendFloat(1);
   
   port1.write('n');    set number of components(only needs to be done once)
   sendFloat(30);        
   
   port1.write('a');
   sendFloat(2.3);
   sendFloat(1.2);
   .
   .
   .
   .
   //needs to send n number of floats
   
   For Due:
   '!' indicates mode switch, next int is mode
   t indicates torque command
   k indicates kp -p was taken
   d indicates kd
   n indicates length of vectors/number of functions in sea state(starting at 1)
   a indicates incoming amp vector
   p indicates incoming phase vector
   f indicates incoming frequency vector
   */
  f= Math.round(f*100.0)/100.0;    //limits to two decimal places
  String posStr = "<";    //starts the string
  posStr = posStr.concat(Float.toString(f));
  posStr = posStr.concat(">");    //end of string "keychar"
  port.write(posStr);
}
void readMegaSerial() {
  /*
  mega:
   1:probe 1
   2:probe 2
   p:position
   d:other data for debugging
   */
  while (port1.available() > 0) {    //recieves until buffer is empty. Since it runs 30 times a second, the arduino will send many samples per execution.
    switch(port1.readChar()) {
    case '1':
      probe1 = readFloat(port1);
      break;
    case '2':
      probe2 = readFloat(port1);
      break;
    case 'p':
      waveMakerPos = readFloat(port1);
      break;
    case 'd':
      debugData = readFloat(port1);
      //waveSig.push("incoming", debugData);
      break;
    }
  }
}
void readDueSerial() {
  /*
  Due:
   e: encoder position
   t: tau commanded to motor
   p: power
   */
  while (port2.available() > 0)
  {
    switch(port2.readChar()) {
    case 'e':
      wecPos = readFloat(port2);
      //waveSig.push("incoming", probeData);
      break;
    case 't':
      tau = readFloat(port2);
      //waveSig.push("incoming", data);
      break;
    case 'p':
      pow = readFloat(port2);
      break;
    }
  }
}
float readFloat(Serial port) {
  waitForSerial(port);
  if (port.readChar() == '<') {
    String str = "";    //port.readStringUntil('>');
    do {
      waitForSerial(port);
      str += port.readChar();
    } while (str.charAt(str.length()-1) != '>');
    str = str.substring(0, str.length()-1);    //removes the >
    return float(str);
  } else {
    return -1.0;
  }
}
void waitForSerial(Serial port) {
  while (port.available() < 1) {    //wait for port to not be empty
    delay(1);    //give serial some time to come through
  }
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
