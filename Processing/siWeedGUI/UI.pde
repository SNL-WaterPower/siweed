ControlP5 cp5; 
Chart waveSig; //wave Signal chart
Slider position; //slider for position mode
Slider h, freq; //sliders for function mode
Slider sigH, peakF, gamma;  //sliders for sea state mode
Slider pGain, dGain, torqueSlider, sigHWEC, peakFWEC, gammaWEC; // WEC sliders
Button jog, function, sea, off, torque, feedback, seaWEC, offWec; // mode buttons
Button wecQs, waveQs;
Textarea wecText, waveText;
  // Custom colors
color green = color(190, 214, 48);
color turq = color(0, 173, 208);
color dblue = color(0, 83, 118);
color buttonblue = color(0, 45, 90);
color hoverblue = color(0, 116, 217);


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
  
  waveQs = cp5.addButton("waveQs")
    .setPosition(275, 120)
    .setSize(15, 15)
    .setLabel("?");
  
  wecQs = cp5.addButton("wecQs")
    .setPosition(255, 620)
    .setSize(15, 15)
    .setLabel("?");
    
  // wave maker buttons
  jog = cp5.addButton("jog")
    .setPosition(100, 200)
    .setSize(150, 100)
    .setLabel("Jog Mode");

  function = cp5.addButton("fun")
    .setPosition(250, 200)
    .setSize(150, 100)
    .setLabel("Function Mode"); 

  sea = cp5.addButton("sea")
    .setPosition(400, 200)
    .setSize(150, 100)
    .setLabel("Sea State"); 

  off = cp5.addButton("off")
    .setPosition(550, 200)
    .setSize(150, 100)
    .setLabel("OFF"); 

  ///  Slider pGain, dGain, positionTorque, torque; // WEC sliders
  ///Button jog, function, sea, off, torque, feedback, jogWEC, offWec; 

  torque = cp5.addButton("torque")
    .setPosition(100, 700)
    .setSize(150, 100)
    .setLabel("Torque");   

  feedback = cp5.addButton("feedback")
    .setPosition(250, 700)
    .setSize(150, 100)
    .setLabel("Feedback"); 
  //spring, jogWEC, offWec 

  seaWEC = cp5.addButton("seaWEC")
    .setPosition(400, 700)
    .setSize(150, 100)
    .setLabel("Sea State");    

  offWec = cp5.addButton("offWec")
    .setPosition(550, 700)
    .setSize(150, 100)
    .setLabel("Off"); 


  // Sliders // 
  //distance between slider and buttons is 150, distance between each slider is 75
  
  // Motor Jog Mode Sliders
  position = cp5.addSlider("Position (CM)")  //name slider
    .setRange(-10, 10) //slider range
    .setPosition(150, 350) //x and y coordinates of upper left corner of button
    .setSize(300, 50); //size (width, height)
    
  // Motor Function Mode Sliders
  h = cp5.addSlider("Height (CM)")  //name slider
    .setRange(0, 10) //slider range
    .setPosition(150, 350) //x and y coordinates of upper left corner of button
    .setSize(300, 50)
    .hide(); //size (width, height)

  freq = cp5.addSlider("Frequency (Hz)")  //name of button
    .setRange(0, 4)
    .setPosition(150, 425) //x and y coordinates of upper left corner of button
    .setSize(300, 50)
    .hide(); //size (width, height)


  // Motor Sea State Mode Sliders
  sigH = cp5.addSlider("Significant Height (CM)")  //name slider
    .setRange(0, 10) //slider range
    .setPosition(150, 350) //x and y coordinates of upper left corner of button
    .setSize(300, 50)
    .hide(); //size (width, height)

  peakF = cp5.addSlider("Peak Frequency (Hz)")  //name of button
    .setRange(0, 4)
    .setPosition(150, 425) //x and y coordinates of upper left corner of button
    .setSize(300, 50)
    .hide(); //size (width, height)

  gamma = cp5.addSlider("Peakedness")  //name of button
    .setRange(0, 7)
    .setPosition(150, 500) //x and y coordinates of upper left corner of button
    .setSize(300, 50)
    .hide(); //size (width, height)

  // WEC Torque Sliders
  torqueSlider = cp5.addSlider("Torque")  //name of button
    .setRange(0, 0.5)
    .setPosition(150, 850) //x and y coordinates of upper left corner of button
    .setSize(300, 50); //size (width, height)

  // WEC Feedback Sliders   
  pGain = cp5.addSlider("P Gain")  //name of button
    .setRange(0, 0.5)
    .setPosition(150, 850) //x and y coordinates of upper left corner of button
    .setSize(300, 50) //size (width, height)
    .hide();

  dGain = cp5.addSlider("D Gain")  //name of button
    .setRange(0, 0.5)
    .setPosition(150, 925) //x and y coordinates of upper left corner of button
    .setSize(300, 50) //size (width, height)
    .hide();

  //WEC Seastate Sliders 

  sigHWEC = cp5.addSlider("WEC Significant Height (CM)")  //name of button
    .setRange(0, 0.5)
    .setPosition(150, 850) //x and y coordinates of upper left corner of button
    .setSize(300, 50) //size (width, height)
    .hide();

  peakFWEC = cp5.addSlider("WEC Peak Frequency (Hz)")  //name of button
    .setRange(0, 0.5)
    .setPosition(150, 925) //x and y coordinates of upper left corner of button
    .setSize(300, 50) //size (width, height)
    .hide();

  gammaWEC = cp5.addSlider("WEC Peakedness)")  //name of button
    .setRange(0, 0.5)
    .setPosition(150, 1000) //x and y coordinates of upper left corner of button
    .setSize(300, 50) //size (width, height)
    .hide();
 

  waveText = cp5.addTextarea("Wave Infromation")
    .setPosition(275, 150)
    .setSize(550, 400)
    .setFont(createFont("arial", 12))
    .setLineHeight(14)
    .setColor(turq)
    .setColorBackground(buttonblue)
    .setColorForeground(color(255, 100))
    .hide()
    ;

    
  wecText = cp5.addTextarea("WEC Infromation")
    .setPosition(260, 650)
    .setSize(550, 400)
    .setFont(createFont("arial", 12))
    .setLineHeight(14)
    .setColor(turq)
    .setColorBackground(buttonblue)
    .setColorForeground(color(255, 100))
    .hide()
    ;

  // Charts //
  waveSig =  cp5.addChart("Sin Wave")
    .setPosition(933.375, 150 )
    .setSize(800, 450)
    .setRange(-10, 10)
    .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
    .setStrokeWeight(4)
    .setColorCaptionLabel(color(40))
    .setColorBackground(turq)
    .setColorLabel(green)
    ;

  waveSig.addDataSet("incoming");
  waveSig.setData("incoming", new float[360]);    //use to set the domain of the plot. This value is = desired domain(secnods) * 30

  h.setValue(5);
  freq.setValue(1.0);
  sigH.setValue(2.5);
  peakF.setValue(3.0);
  gamma.setValue(7.0);

  snlLogo = loadImage("SNL_Stacked_White.png");
}
//button functions:
/////////////////// MAKES BUTTONS DO THINGS ////////////////////////////////////

// Motor Buttons 

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
  sendFloat(2, port1);
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

// WEC Buttons 

void torque() {
  wec.mode = 1; 
  torqueSlider.show();
  pGain.hide();
  dGain.hide();
  sigHWEC.hide();
  peakFWEC.hide();
  gammaWEC.hide();
  port2.write('!');
  sendFloat(0, port2);
}   

void feedback() {
  wec.mode = 2; 
  torqueSlider.hide();
  pGain.show();
  dGain.show();
  sigHWEC.hide();
  peakFWEC.hide();
  gammaWEC.hide();
  port2.write('!');
  sendFloat(1, port2);
}

// Slider pGain, dGain, torqueSlider, sigHWEC, peakFWEC, gammaWEC; 
//torque, feedback, seaWEC, offWec 


void seaWEC() {
  wec.mode = 3; 
  torqueSlider.hide();
  pGain.hide();
  dGain.hide();
  sigHWEC.show();
  peakFWEC.show();
  gammaWEC.show();
  port2.write('!');
  sendFloat(2, port2);
}

void offWEC() {
  wec.mode = 4; 
  torqueSlider.setValue(0);
  pGain.setValue(0);
  dGain.setValue(0);
  sigHWEC.setValue(0);
  peakFWEC.setValue(0);
  gammaWEC.setValue(0);
  port2.write('!');
  sendFloat(-1, port2);
}

void waveQs() {
  if (waveText.isVisible()){
    waveText.hide();
  }
  else{
    waveText.show();
  }
}

void wecQs() {
  if (wecText.isVisible()){
    wecText.hide();
  }
  else{
    wecText.show();
  }
}
