ControlP5 cp5; 
Chart waveSig; //wave Signal chart
Slider position; //slider for position mode
Slider h, freq; //sliders for function mode
Slider sigH, peakF, gamma;  //sliders for sea state mode
Slider torque, other; // WEC sliders
Button jog, function, sea, off; // mode buttons
// Custom colors
color green = color(190, 214, 48);
color turq = color(0, 173, 208);
color dblue = color(0, 83, 118);

// Fonts
PFont f; // Regular font
PFont fb; // Bold font
// Sandia logo
PImage snlLogo;
void initializeUI() {
  // starting ControlP5 stuff
  cp5 = new ControlP5(this);
  //Fonts
  f = createFont("Arial", 16, true);
  fb = createFont("Arial Bold Italic", 32, true);
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
    .setRange(0, 4)
    .setPosition(150, 300) //x and y coordinates of upper left corner of button
    .setSize(300, 20)
    .hide(); //size (width, height)

  gamma = cp5.addSlider("Peakedness")  //name of button
    .setRange(0, 7)
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
    .setRange(-10, 10)
    .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
    .setStrokeWeight(4)
    .setColorCaptionLabel(color(40))
    .setColorBackground(turq)
    .setColorLabel(green)
    ;

  waveSig.addDataSet("incoming");
  waveSig.setData("incoming", new float[360]);    //use to set the domain of the plot. This value is = desired domain(secnods) * 30

  sigH.setValue(2.5);
  peakF.setValue(3.0);
  gamma.setValue(7.0);
  
  snlLogo = loadImage("SNL_Stacked_White.png");
}
//button functions:
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
  sendFloat(jonswap.getNum(), port1);
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
