import meter.*;
import controlP5.*; //importing GUI library
import processing.serial.*;


// Custom colors
color green = color(190, 214, 48);
color turq = color(0, 173, 208);
color dblue = color(0, 83, 118);

// Fonts
//println(PFont.list()); Prints avliable fonts to console
PFont f; // Regular font
PFont fb; // Bold font

// Sandia logo
PImage snlLogo;

int nComponents = 10;     //number of wave components in sea state
float hVal, freqVal, sigHval, peakVal, peakFval, pVal;



Serial port1;
ControlP5 cp5; 
Chart waveSig; //wave Signal chart
Slider position; //slider for position mode
Slider h, freq; //sliders for function mode
Slider sigH, peakF, gama;  //sliders for sea state mode
Slider torque, other; // WEC sliders
Button jog, function, sea, off; // mode buttons

int mode = 1; // 1 = jog, 2 = function, 3 = sea, 4 = off




void setup() {

  fullScreen();
  port1 = new Serial(this, "COM4", 9600); // all communication with Mega
  delay(5000);
  // Fonts
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
    .setRange(0, 10) //slider range
    .setPosition(150, 250) //x and y coordinates of upper left corner of button
    .setSize(300, 20); //size (width, height)

  h = cp5.addSlider("Height (CM)")  //name slider
    .setRange(0, 10) //slider range
    .setPosition(150, 250) //x and y coordinates of upper left corner of button
    .setSize(300, 20)
    .hide(); //size (width, height)

  freq = cp5.addSlider("Frequency (Hz)")  //name of button
    .setRange(2, 4)
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

  gama = cp5.addSlider("Peakedness")  //name of button
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
    .setRange(-20, 20)
    .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
    .setStrokeWeight(4)
    .setColorCaptionLabel(color(40))
    .setColorBackground(turq)
    .setColorLabel(green)
    ;



  waveSig.addDataSet("incoming");
  waveSig.setData("incoming", new float[100]);

  port1.write('!');
  sendFloat(0);    //initialize arduino in jog mode
  ///////////////////////for testing:
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


  // Sandia Labs logo
  snlLogo = loadImage("SNL_Stacked_White.png");
  tint(255, 126);  // Apply transparency without changing color
  image(snlLogo, 5, height-snlLogo.height*0.25-5, snlLogo.width*0.25, snlLogo.height*0.25);

  //dividing line
  stroke(green);
  strokeWeight(1.5);
  line(width/3, 75, width/3, height-75);

  //updates chart for function mode  
  if (mode == 1) {    //jog
    if (position.getValue() != pVal) {    //only sends if value has changed
      pVal = position.getValue();
      port1.write('j');
      sendFloat(pVal);
    }
    //waveSig.push("incoming", (sin(frameCount*0.1)*pVal));
  } else if (mode == 2) {    //function
    if (hVal != h.getValue() || freqVal != freq.getValue()) { //only executes if a value has changed
      hVal = h.getValue();
      freqVal = freq.getValue();
      port1.write('a');
      sendFloat(hVal);
      port1.write('f');
      sendFloat(freqVal);
    }
    //waveSig.push("incoming", (sin(frameCount*freqVal)*hVal));
  } else if (mode == 3) {    //sea state
    if (sigHval != sigH.getValue() || peakFval != peakF.getValue()) { //only executes if a value has changed
      sigHval = sigH.getValue();
      peakFval = peakF.getValue();
      //Here we will call other java function

      //then send to arduino
    }
    waveSig.push("incoming", (sin(frameCount*peakFval)*sigHval));
  }
  readSerial();

  //delay(10);    //maybe delay to slow down serial
}

/////////////////// MAKES BUTTONS DO THINGS ////////////////////////////////////

void jog() {
  mode = 1;
  h.hide();
  freq.hide();
  sigH.hide();
  peakF.hide();
  gama.hide();
  position.show();
  //set mode on arduino:
  port1.write('!');
  sendFloat(0);
}

void fun() {
  mode = 2;
  position.hide();
  gama.hide();

  h.show();
  freq.show();
  //set mode on arduino:
  port1.write('!');
  sendFloat(1);
  //tell arduino to only look at one component
  port1.write('n');
  sendFloat(1);
}

void sea() {
  mode = 3;
  h.hide();
  freq.hide();
  h.hide();
  position.hide();
  sigH.show();
  peakF.show();
  gama.show();
  //set mode on arduino:
  port1.write('!');
  sendFloat(1);
  //tell arduino to look at all components
  port1.write('n');
  sendFloat(nComponents);
}

void off() {
  mode = 4;
  h.setValue(0);
  freq.setValue(0);
  sigH.setValue(0);
  peakF.setValue(0); 
  position.setValue(0);
  //set mode on arduino:
  port1.write('!');
  sendFloat(-1);
}
void sendFloat(float f)
{
  /* '!' indicates mode switch
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
   
   */
  f= Math.round(f*100.0)/100.0;    //limits to two decimal places
  String posStr = "<";    //starts the string
  posStr = posStr.concat(Float.toString(f));
  posStr = posStr.concat(">");    //end of string "keychar"
  port1.write(posStr);
}
void readSerial() {
  if (port1.available() > 0)
  {
    waveSig.push("incoming", readFloat());
    //println(readFloat());
  }
}
float readFloat() {
  while (port1.available() < 1) {
  }
  if (port1.read() == '<') {
    delay(5);    //short delay to allow the rest of the data through
    String str = port1.readStringUntil('>');
    if (str != null) {
      str = str.substring(0, str.length()-1);    //removes the >
      return float(str);
    } else {
      return 888.8;
    }
  } else {
    return 0.0;
  }
}
