ControlP5 cp5;
Chart waveChart, wecChart; //wave Signal chart
Slider position; //slider for position mode
Slider h, freq; //sliders for function mode
Slider sigH, peakF, gamma;  //sliders for sea state mode
Slider pGain, dGain, torqueSlider, sigHWEC, peakFWEC, gammaWEC; // WEC sliders
Button jog, function, sea, off, offWEC, torque, feedback, seaWEC; // mode buttons
Button wecQs, waveQs; // popup buttons
Button wavePosData, waveElData, wecPosData, wecVelData, wecTorqData, wecPowData;
Button quad1, quad2, quad3, quad4; // power bar
Button consoleButton; //Idealy this would be a toggle, but was getting errors on the ".isVisible()"
Textarea wecText, waveText, myTextarea;
int zeroLocationX = 780;
float zeroLocationY = 35;
float offsetX = 50;
float offsetY = 50;
int chartLocationX = zeroLocationX;
int chartLocationY = 475;
int zeroLocationRight = 1350;
int chartSizeX = 505;
int chartSizeY = 175;

// Custom colors
color green = color(176, 191, 70);
color turq = color(20, 186, 215);
color dblue = color(0, 83, 118);
color buttonblue = color(0, 102, 137);
color hoverblue = color(0, 116, 217);
color grey = color(180, 190, 191);
color black = color(0, 0, 0);
color white = color(255, 255, 255);
color red = color(255, 0, 0);


// Fonts
PFont f; // Regular font
PFont fb; // Bold font
PFont buttonFont, sliderFont, titleTextBoxFont, headerTextBoxFont, textBoxFont, smallTextBoxFont; 


// Sandia logo
PImage snlLogo;
PImage wavePic;
PImage LHSPic;
void initializeUI() {

  // starting ControlP5 stuff
  cp5 = new ControlP5(this);

  //Fonts
  f = createFont("Arial", 16, true);
  fb = createFont("Arial Bold Italic", 32, true);
  titleTextBoxFont = buttonFont = createFont("Arial Bold Italic", 40, true);
  buttonFont = createFont("Arial Bold Italic", 12, true);
  sliderFont = createFont("Arial Bold Italic", 12, true);
  headerTextBoxFont = createFont("Arial Bold", 35, false);
  textBoxFont = createFont("Arial Bold Italic", 22, true);
  smallTextBoxFont = createFont("Arial Bold Italic", 18, true);

  // Buttons //
  consoleButton = cp5.addButton("consoleButton")
    .setPosition(1800, 1040)
    .setSize(100, 50)
    .setLabel("Console")
    .setColorBackground(grey)
    .setFont(buttonFont); 

  int buttonX, buttonY;
  buttonX = int(zeroLocationX); 
  buttonY = 155;
  int buttonSizeX = 125;
  int buttonSizeY = 35;
  int spaceBetweenButtons = 127;

  // wave maker buttons //
  jog = cp5.addButton("jog")
    .setPosition(buttonX, buttonY)
    .setSize(buttonSizeX, buttonSizeY)
    .setLabel("Jog Mode")
    .setFont(buttonFont )
    .setColorBackground(turq);    //starts on

  function = cp5.addButton("fun")
    .setPosition(buttonX + spaceBetweenButtons, buttonY)
    .setSize(buttonSizeX, buttonSizeY)
    .setLabel("Function Mode")
    .setFont(buttonFont)
    .setColorBackground(buttonblue); 

  sea = cp5.addButton("sea")
    .setPosition(buttonX + spaceBetweenButtons*2, buttonY)
    .setSize(buttonSizeX, buttonSizeY)
    .setLabel("Sea State")
    .setFont(buttonFont)
    .setColorBackground(buttonblue); 

  off = cp5.addButton("off")
    .setPosition(buttonX + spaceBetweenButtons*3, buttonY)
    .setSize(buttonSizeX, buttonSizeY)
    .setLabel("OFF")
    .setFont(buttonFont)
    .setColorBackground(buttonblue); 

  buttonY = 1015;
  //Power meter buttons //
  quad1 = cp5.addButton("quad1")
    .setPosition(buttonX, buttonY)
    .setColorBackground(grey)
    .setSize(buttonSizeX, buttonSizeY)
    .setLabel("25%");  

  quad2 = cp5.addButton("quad2")
    .setPosition(buttonX + spaceBetweenButtons, buttonY)
    .setColorBackground(grey)
    .setSize(buttonSizeX, buttonSizeY)
    .setLabel("50%"); 

  quad3 = cp5.addButton("quad3")
    .setPosition(buttonX + spaceBetweenButtons*2, buttonY)
    .setColorBackground(grey)
    .setSize(buttonSizeX, buttonSizeY)
    .setLabel("75%"); 

  quad4 = cp5.addButton("quad4")
    .setPosition(buttonX + spaceBetweenButtons*3, buttonY)
    .setColorBackground(grey)
    .setSize(buttonSizeX, buttonSizeY)
    .setLabel("100%");


  buttonX = buttonX+570;  
  buttonY = 155;

  //WEC controls buttons //
  torque = cp5.addButton("torque")
    .setPosition(buttonX, buttonY)
    .setSize(buttonSizeX, buttonSizeY)
    .setLabel("Torque")
    .setFont(buttonFont)
    .setColorBackground(green);       //starts on

  feedback = cp5.addButton("feedback")
    .setPosition(buttonX + spaceBetweenButtons, buttonY)
    .setSize(buttonSizeX, buttonSizeY)
    .setLabel("Feedback")
    .setFont(buttonFont)
    .setColorBackground(buttonblue); 


  seaWEC = cp5.addButton("seaWEC")
    .setPosition(buttonX + spaceBetweenButtons*2, buttonY)
    .setSize(buttonSizeX, buttonSizeY)
    .setLabel("SID")      //!!!Need to change this name to something more intuitive
    .setFont(buttonFont)
    .setColorBackground(buttonblue);    

  offWEC = cp5.addButton("offWEC")
    .setPosition(buttonX + spaceBetweenButtons*3, buttonY)
    .setSize(buttonSizeX, buttonSizeY)
    .setLabel("Off")
    .setFont(buttonFont)
    .setColorBackground(buttonblue);

  // Data buttons //     
  int dataButtonX, dataButtonY;

  dataButtonX =buttonSizeX+127;
  dataButtonY = buttonSizeY;


  wavePosData = cp5.addButton("wavePosData")
    .setPosition(chartLocationX, chartLocationY+chartSizeY)
    .setColorBackground(grey)
    .setSize(dataButtonX, buttonSizeY)
    .setLabel("Wave Maker Position")
    .setFont(buttonFont); 

  waveElData = cp5.addButton("waveElData")
    .setPosition(chartLocationX + dataButtonX+1, chartLocationY+chartSizeY)
    .setColorBackground(grey)
    .setSize(dataButtonX, buttonSizeY)
    .setLabel("Wave Elevation")
    .setFont(buttonFont); 


  //WEC info buttons //
  wecPosData = cp5.addButton("wecPosData")
    .setPosition(buttonX, chartLocationY+chartSizeY)
    .setColorBackground(grey)
    .setSize(buttonSizeX, buttonSizeY)
    .setLabel("Position")
    .setFont(buttonFont); 


  wecVelData = cp5.addButton("wecVelData")
    .setPosition(buttonX + spaceBetweenButtons, chartLocationY+chartSizeY)


    .setColorBackground(grey)
    .setSize(buttonSizeX, buttonSizeY)
    .setLabel("Velocity")
    .setFont(buttonFont);

  wecTorqData = cp5.addButton("wecTorqData")
    .setPosition(buttonX + spaceBetweenButtons*2, chartLocationY+chartSizeY)

    .setColorBackground(grey)
    .setSize(buttonSizeX, buttonSizeY)
    .setLabel("Torque")
    .setFont(buttonFont);


  wecPowData = cp5.addButton("wecPowData")
    .setPosition(buttonX + spaceBetweenButtons*3, chartLocationY+chartSizeY)

    .setColorBackground(grey)
    .setSize(buttonSizeX, buttonSizeY)
    .setLabel("Power")
    .setFont(buttonFont);


  // Sliders // 

  int sliderX, sliderY;
  sliderX = int(zeroLocationX);
  sliderY = 200 ;
  int sliderSizeX = 380 ;
  int  sliderSizeY = 35;
  int sliderOffset = 48;

  // Motor Jog Mode Sliders
  position = cp5.addSlider("Position (MM)")  //name slider
    .setRange(-25, 25) //slider range
    .setPosition(sliderX, sliderY) 
    .setFont(sliderFont)
    .setSize(sliderSizeX, sliderSizeY)
    .setColorForeground(color(turq))
    .setColorBackground(color(buttonblue))
    .setColorCaptionLabel(color(buttonblue));

  // Motor Function Mode Sliders
  h = cp5.addSlider("Height (MM)") 
    .setRange(0, 20) //slider range
    .setPosition(sliderX, sliderY) 
    .setSize(sliderSizeX, sliderSizeY)
    .setFont(sliderFont)
    .setColorCaptionLabel(color(buttonblue))
    .hide()
    .setColorForeground(color(turq))
    .setColorBackground(color(buttonblue));

  freq = cp5.addSlider("Frequency (Hz)") 
    .setRange(0, 2.5)
    .setPosition(sliderX, sliderY + sliderOffset)
    .setSize(sliderSizeX, sliderSizeY)
    .setFont(sliderFont)
    .hide()
    .setColorForeground(color(turq))
    .setColorBackground(color(buttonblue))
    .setColorCaptionLabel(color(buttonblue));


  // Motor Sea State Mode Sliders
  sigH = cp5.addSlider("Significant Height (MM)")  
    .setRange(0, 10) //slider range
    .setPosition(sliderX, sliderY) 
    .setSize(sliderSizeX, sliderSizeY)
    .setFont(sliderFont)
    .hide().setColorForeground(color(turq))
    .setColorBackground(color(buttonblue))
    .setColorCaptionLabel(color(buttonblue));

  peakF = cp5.addSlider("Peak Frequency (Hz)")  
    .setRange(0, 4)
    .setPosition(sliderX, sliderY + sliderOffset) 
    .setSize(sliderSizeX, sliderSizeY)
    .setFont(sliderFont)
    .hide()
    .setColorForeground(color(turq))
    .setColorBackground(color(buttonblue))
    .setColorCaptionLabel(color(buttonblue)); 

  gamma = cp5.addSlider("Peakedness")  
    .setRange(0, 7)
    .setPosition(sliderX, sliderY + sliderOffset*2) 
    .setSize(sliderSizeX, sliderSizeY)
    .setFont(sliderFont)
    .hide()
    .setColorForeground(color(turq))
    .setColorBackground(color(buttonblue))
    .setColorCaptionLabel(color(buttonblue)); 

  // WEC Torque Sliders
  sliderX = zeroLocationRight;
  torqueSlider = cp5.addSlider("Torque")  
    //.setRange(-0.006, 0.006)      //max amps * torque constant. I think this will max amperage at max slider value
    .setRange(-6, 6)
    .setFont(sliderFont)
    .setPosition(sliderX, sliderY) 
    .setSize(sliderSizeX, sliderSizeY)
    .setColorForeground(color(green))
    .setColorBackground(color(buttonblue))
    .setColorCaptionLabel(color(buttonblue)); 

  // WEC Feedback Sliders   
  pGain = cp5.addSlider("P Gain")  
    //.setRange(-0.0006, 0.0006)    //user needs to be able to command negative //0.1(wave height in meters) * max torque(above)
    .setRange(-10, 10)    //scaled in main tab
    .setFont(sliderFont)
    .setPosition(sliderX, sliderY) 
    .setSize(sliderSizeX, sliderSizeY) 
    .hide()
    .setColorForeground(color(green))
    .setColorBackground(color(buttonblue))
    .setColorCaptionLabel(color(buttonblue));

  dGain = cp5.addSlider("D Gain")  //name of button
    //.setRange(0, 0.0005)    //user needs to only command positive
    .setRange(0, 10)    //scaled in main tab
    .setFont(sliderFont)
    .setPosition(sliderX, sliderY + sliderOffset) 
    .setSize(sliderSizeX, sliderSizeY) 
    .hide()
    .setColorForeground(color(green))
    .setColorBackground(color(buttonblue))
    .setColorCaptionLabel(color(buttonblue));

  //WEC Seastate Sliders 


  sigHWEC = cp5.addSlider("WEC Significant Tau")  //name of button
    .setRange(0, 5)
    .setFont(sliderFont)
    .setPosition(sliderX, sliderY) 
    .setSize(sliderSizeX, sliderSizeY)
    .hide()
    .setColorForeground(color(green))
    .setColorBackground(color(buttonblue))
    .setColorCaptionLabel(color(buttonblue));

  peakFWEC = cp5.addSlider("WEC Peak Frequency (Hz)") 
    .setRange(0, 0.5)
    .setFont(sliderFont)
    .setPosition(sliderX, sliderY + sliderOffset) 
    .setSize(sliderSizeX, sliderSizeY)
    .hide()
    .setColorForeground(color(green))
    .setColorBackground(color(buttonblue))
    .setColorCaptionLabel(color(buttonblue));

  gammaWEC = cp5.addSlider("WEC Peakedness")  
    .setRange(0, 0.5)
    .setFont(sliderFont)
    .setPosition(sliderX, sliderY + sliderOffset*2)
    .setSize(sliderSizeX, sliderSizeY) 
    .hide()
    .setColorForeground(color(green))
    .setColorBackground(color(buttonblue))
    .setColorCaptionLabel(color(buttonblue));

  //slider default values:    //only non zeros need to be set
  h.setValue(5);
  freq.setValue(1.0);
  sigH.setValue(2.5);
  peakF.setValue(3.0);
  gamma.setValue(7.0);

  sigHWEC.setValue(2.5);
  peakFWEC.setValue(0.3);
  gammaWEC.setValue(0.3);

  waveText = cp5.addTextarea("Wave Infromation") //is this used?
    .setPosition(buttonX, 150)
    .setSize(550, 400)
    .setFont(createFont("arial", 16))
    .setLineHeight(14)
    .setColor(turq)
    .setColorBackground(buttonblue)
    .setColorForeground(color(255, 100))
    .setText("At vero eos et: accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas. Molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat.")
    .hide()
    ;


  wecText = cp5.addTextarea("WEC Infromation")//is this used?
    .setPosition(260, 750)
    .setSize(550, 400)
    .setFont(createFont("arial", 16))
    .setLineHeight(14)
    .setColor(turq)
    .setColorBackground(buttonblue)
    .setColorForeground(color(255, 100))
    .setText("At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat.")
    .hide()
    ;


  // Charts //


  waveChart =  cp5.addChart("Wave Information chart")//
    .setPosition(chartLocationX, chartLocationY)
    .setSize(chartSizeX, chartSizeY)
    .setFont(sliderFont)
    .setRange(-10, 10)
    .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
    .setStrokeWeight(10)
    .setColorCaptionLabel(color(40))

    .setColorBackground(white)
    .setLabel("");


  waveChart.addDataSet("debug");
  waveChart.setData("debug", new float[360]);

  wecChart =  cp5.addChart("WEC Information chart")
    .setPosition(zeroLocationRight, chartLocationY)
    .setSize(chartSizeX, chartSizeY)

    .setFont(sliderFont)
    .setRange(-10, 10)
    .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
    .setStrokeWeight(10)
    .setColorCaptionLabel(color(40))
    .setColorBackground(white)
    .setLabel("");


  snlLogo = loadImage("SNL_Stacked_White.png");
  wavePic = loadImage("ocean.jpg");
  LHSPic = loadImage("LHS.png");


  //console, this needs to be in the setup to ensure
  //that it catches any errors when program starts
  consoleOutput=cp5.addTextarea("consoleOutput")
    .setPosition(1650, 800) 
    .setSize(330, 100)
    .setLineHeight(14)
    .setColorValue(green) //color of font
    .scroll(1) //enable scrolling up and down
    .hide(); //hidden on startup   
  if (!debug && guiConsole)      //only does in GUI console if not debugging
  {
    console = cp5.addConsole(consoleOutput);
  }

  myTextarea = cp5.addTextarea("txtSystemStatus")

    .setPosition(zeroLocationX, 385)
    .setText("SYSTEM STATUS")
    .setSize(350, 75)

    .setFont(headerTextBoxFont)
    .setLineHeight(7)
    .setColor(color(buttonblue));



  myTextarea = cp5.addTextarea("txtWaveDimensions")
    .setPosition(zeroLocationX+100, 100)
    .setText("CHANGE WAVE DIMENSIONS" )
    .setSize(350, 40)
    .setFont(textBoxFont)
    .setLineHeight(10)
    .setColor(color(white)); 

  myTextarea = cp5.addTextarea("txtWaveInformation")
    .setPosition(zeroLocationX+160, 448)
    .setText("WAVE INFORMATION" )
    .setSize(350, 40)
    .setFont(smallTextBoxFont)
    .setLineHeight(10)
    .setColor(color(white)); 



  myTextarea = cp5.addTextarea("txtWECControls")
    .setPosition(zeroLocationRight + 100, 100)
    .setText("CHANGE WEC CONTROLS")
    .setSize(300, 40)
    .setFont(textBoxFont)
    .setLineHeight(10)
    .setColor(color(white)); 

  myTextarea = cp5.addTextarea("txtPowerMeter")
    .setPosition(zeroLocationX+180, 720)
    .setText("POWER METER")
    .setSize(300, 40)
    .setFont(smallTextBoxFont)
    .setLineHeight(10)
    .setColor(color(white));

  myTextarea = cp5.addTextarea("FFTTitle")
    .setPosition(zeroLocationRight + 170, 720)
    .setText("Frequency Analysis")
    .setSize(300, 40)
    .setFont(smallTextBoxFont)
    .setLineHeight(10)
    .setColor(color(white));

  myTextarea = cp5.addTextarea("txtFFT")
    .setPosition(zeroLocationRight + 160, 448)
    .setText("WEC INFORMATION")
    .setSize(300, 40)
    .setFont(smallTextBoxFont)
    .setLineHeight(10)
    .setColor(color(white));

  myTextarea = cp5.addTextarea("txtMissionControl")
    .setPosition(zeroLocationX, zeroLocationY)
    .setText("Mission Control")
    .setSize(300, 55)
    .setFont(headerTextBoxFont)
    .setLineHeight(7)
    .setColor(color(buttonblue));

  //set chart buttons true at startup by virtually pressing the button:
  wavePosData();
  wecPosData();
}
//button functions:
/////////////////// MAKES BUTTONS DO THINGS ////////////////////////////////////

// Console Button
void consoleButton() {
  if (consoleOutput.isVisible()) {
    consoleOutput.hide();
    consoleButton.setColorBackground(grey);
  } else {
    consoleOutput.show();
    consoleButton.setColorBackground(hoverblue);
  }
}

// Motor Buttons 

void jog() {
  jog.setColorBackground(turq);
  function.setColorBackground(buttonblue);
  sea.setColorBackground(buttonblue);
  off.setColorBackground(buttonblue);
  waveMaker.mode = 1;
  h.hide();
  freq.hide();
  sigH.hide();
  peakF.hide();
  gamma.hide();
  position.show();

  //set mode on arduino:
  if (WMConnected) {
    port1.write('!');
    sendFloat(0, port1);
  }
  waveMaker.mag += 1;    //this parameter being adjusted will cause the main loop to send the initial data
}

void fun() {
  jog.setColorBackground(buttonblue);
  function.setColorBackground(turq);
  sea.setColorBackground(buttonblue);
  off.setColorBackground(buttonblue);
  waveMaker.mode = 2;
  position.hide();
  gamma.hide();
  sigH.hide();
  peakF.hide();
  gamma.hide();

  h.show();
  freq.show();
  //set mode on arduino:
  if (WMConnected) {
    port1.write('!');
    sendFloat(1, port1);
  }
  waveMaker.amp += 1;    //this parameter being adjusted will cause the main loop to send the initial data
}

void sea() {
  jog.setColorBackground(buttonblue);
  function.setColorBackground(buttonblue);
  sea.setColorBackground(turq);
  off.setColorBackground(buttonblue);
  waveMaker.mode = 3;
  h.hide();
  freq.hide();
  h.hide();
  position.hide();
  sigH.show();
  peakF.show();
  gamma.show();
  //set mode on arduino:
  if (WMConnected) {
    port1.write('!');
    sendFloat(2, port1);
  }
  waveMaker.sigH += 1;    //this parameter being adjusted will cause the main loop to send the initial data
}

void off() {
  jog.setColorBackground(buttonblue);
  function.setColorBackground(buttonblue);
  sea.setColorBackground(buttonblue);
  off.setColorBackground(turq);
  waveMaker.mode = 4;
  h.hide();
  freq.hide();
  h.hide();
  position.hide();
  sigH.hide();
  peakF.hide();
  gamma.hide();
  //set mode on arduino:
  if (WMConnected) {
    port1.write('!');
    sendFloat(-1, port1);
  }
}

// WEC Buttons 

void torque() {
  torque.setColorBackground(green);
  feedback.setColorBackground(buttonblue);
  seaWEC.setColorBackground(buttonblue);
  offWEC.setColorBackground(buttonblue);
  wec.mode = 1; 
  torqueSlider.show();
  pGain.hide();
  dGain.hide();
  sigHWEC.hide();
  peakFWEC.hide();
  gammaWEC.hide();
  if (WECConnected) {
    port2.write('!');
    sendFloat(0, port2);
  }
  wec.mag += 1;    //this parameter being adjusted will cause the main loop to send the initial data
}   

void feedback() {
  torque.setColorBackground(buttonblue);
  feedback.setColorBackground(green);
  seaWEC.setColorBackground(buttonblue);
  offWEC.setColorBackground(buttonblue);
  wec.mode = 2; 
  torqueSlider.hide();
  pGain.show();
  dGain.show();
  sigHWEC.hide();
  peakFWEC.hide();
  gammaWEC.hide();
  if (WECConnected) {
    port2.write('!');
    sendFloat(1, port2);
  }
  wec.amp += 1;    //this parameter being adjusted will cause the main loop to send the initial data
}

// Slider pGain, dGain, torqueSlider, sigHWEC, peakFWEC, gammaWEC; 
//torque, feedback, seaWEC, offWEC 


void seaWEC() {
  torque.setColorBackground(buttonblue);
  feedback.setColorBackground(buttonblue);
  seaWEC.setColorBackground(green);
  offWEC.setColorBackground(buttonblue);
  wec.mode = 3; 
  torqueSlider.hide();
  pGain.hide();
  dGain.hide();
  sigHWEC.show();
  peakFWEC.show();
  gammaWEC.show();
  if (WECConnected) {
    port2.write('!');
    sendFloat(2, port2);
  }

  wec.sigH += 1;    //this parameter being adjusted will cause the main loop to send the initial data
}

void offWEC() {
  torque.setColorBackground(buttonblue);
  feedback.setColorBackground(buttonblue);
  seaWEC.setColorBackground(buttonblue);
  offWEC.setColorBackground(green);
  wec.mode = 4; 
  torqueSlider.hide();    //hides all sliders
  pGain.hide();
  dGain.hide();
  sigHWEC.hide();
  peakFWEC.hide();
  gammaWEC.hide();
  if (WECConnected) {
    port2.write('!');
    sendFloat(-1, port2);
  }
}

boolean wavePosClicked = false; 
void wavePosData() {
  if (wavePosClicked == false) {
    wavePosClicked = true;
    wavePosData.setColorBackground(hoverblue);
    waveChart.addDataSet("waveMakerPosition");
    waveChart.setData("waveMakerPosition", new float[360]);
  } else {
    wavePosClicked = false;  
    wavePosData.setColorBackground(grey);
    waveChart.removeDataSet("waveMakerPosition");
  }
}

boolean waveElClicked = false; 
void waveElData() {
  if (waveElClicked == false) {
    waveElClicked = true;
    waveElData.setColorBackground(green);
    waveChart.addDataSet("waveElevation");
    waveChart.setColors("waveElevation", green);
    waveChart.setData("waveElevation", new float[360]);
  } else {
    waveElClicked = false;  
    waveElData.setColorBackground(grey);
    waveChart.removeDataSet("waveElevation");
  }
}


boolean wecPosClicked = false;
void wecPosData() {
  if (wecPosClicked == false) {
    wecPosClicked = true;
    wecPosData.setColorBackground(hoverblue);
    wecChart.addDataSet("wecPosition");
    wecChart.setColors("wecPosition", hoverblue);
    wecChart.setData("wecPosition", new float[360]);
  } else {
    wecPosClicked = false;  
    wecPosData.setColorBackground(grey);
    wecChart.removeDataSet("wecPosition");
  }
}

boolean wecVelClicked = false;
void wecVelData() {
  if (wecVelClicked == false) {
    wecVelClicked = true;
    wecVelData.setColorBackground(green);
    wecChart.addDataSet("wecVelocity");
    wecChart.setColors("wecVelocity", green);
    wecChart.setData("wecVelocity", new float[360]);
  } else {
    wecVelClicked = false;  
    wecVelData.setColorBackground(grey);
    wecChart.removeDataSet("wecVelocity");
  }
}

boolean wecTorqClicked = false; 
void wecTorqData() {
  if (wecTorqClicked == false) {
    wecTorqClicked = true;
    wecTorqData.setColorBackground(color(0, 0, 0));
    wecChart.addDataSet("wecTorque");
    wecChart.setColors("wecTorque", color(0, 0, 0));
    wecChart.setData("wecTorque", new float[360]);
  } else {
    wecTorqClicked = false;  
    wecTorqData.setColorBackground(grey);
    wecChart.removeDataSet("wecTorque");
  }
}

boolean wecPowClicked = false;
void wecPowData() {
  if (wecPowClicked == false) {
    wecPowClicked = true;
    wecPowData.setColorBackground(color(209, 18, 4));
    wecChart.addDataSet("wecPower");
    wecChart.setColors("wecPower", color(209, 18, 4));
    wecChart.setData("wecPower", new float[360]);
  } else {
    wecPowClicked = false;  
    wecPowData.setColorBackground(grey);
    wecChart.removeDataSet("wecPower");
  }
}

void waveQs() {
  if (waveText.isVisible()) {
    waveText.hide();
  } else {
    waveText.show();
  }
}

void wecQs() {
  if (wecText.isVisible()) {
    wecText.hide();
  } else {
    wecText.show();
  }
}
//////////////////FFT vars:
float originx = 1400;    //x and y coordinates of the FFT graph
float originy = 1000;
float xScale = 1.5;    //how spaced the graph is horizontally
float yScale = 50000;    //how tall the data is. axis has to be set separately
float FFTHeight = 200;    //height of y axis coordinates. Does not scale data
int yAxisCount = 5;    //how many numbers on the y axis
float FFTXOffset = 10, FFTYOffset = 10;
void drawFFT() {
  int nyquist = (int)frameRate/2;    //sampling frequency/2 NOTE: framerate is not a constant variable
  textSize(12);
  fill(green);
  stroke(green);
  for (int i=0; i<=queueSize/2; i++) {      //cut in half
    float x = originx+xScale*i;
    float y = originy;
    float maxY = originy - FFTHeight;    //value that saturates the data
    float yCord = y - yScale*fftArr[i];    //how high to draw the line
    if (yCord < maxY) {    //saturate, so y doesn't get drawn off the graph(remember coordinates are flipped)
      yCord = maxY;
    }
    line(x+FFTXOffset, y-FFTYOffset, x+FFTXOffset, yCord-FFTYOffset);
    if (i%32 == 0) {        //should make 32 into a variable, but frameRate is not an int.
      text((int)(i*(1/((float)queueSize/32))), x+FFTXOffset, y);    //x-axis: frequency spacing is 1/T, where t is length of sample in seconds
    }
    if (i%1 == 0 && i<=yAxisCount && i != 0) {    //mod controls spacing, draws only if less than max count and not zero(to not draw 2 zeros)
      text(i, originx, y - FFTHeight/yAxisCount*i);    //y-axis    //units need to be fixed
    }
  }
}
void displayUpdate() {

  // Background color
  background(dblue);
  fill(buttonblue);
  stroke(buttonblue);
  strokeWeight(0);
  image(snlLogo, width-snlLogo.width*0.25-5, height-snlLogo.height*0.25-5, snlLogo.width*0.25, snlLogo.height*0.25); //Logo

  rect(0, 0, width/2.7, height); // LHS banner 
  fill(white);
  rect(width/2.7, 0, width, height*.333); //mission control banner
  fill(turq);
  //stroke(turq);
  rect(width/2.7, height*.333, width, height); //mission control banner

  fill(255, 255, 255);
  textSize(12);
  textLeading(14);
  //boxes behind the titles
  fill(turq);
  rect(zeroLocationX, 90, 505, 45); // Change wave dimensions
  fill(green);
  rect(zeroLocationRight, 90, 505, 45); // Change WEC controls
  fill(buttonblue);
  rect(zeroLocationX, 445, 505, 45); // Wave Information
  rect(zeroLocationRight, 445, 505, 45); // Wec Information
  rect(zeroLocationX, 715, 505, 45); // Power Meter
  rect(zeroLocationRight, 715, 505, 45); // FFT
  rect(zeroLocationX, 770, 505, 240,7);  //meter background
  rect(zeroLocationRight, 770, 505, 240,7);  //FFT background
  image(LHSPic, 0, 0, width/2.7, height); //lhs pic
  
  //controls button pop up behavior for info boxes
  if (mousePressed && waveText.isVisible()) {
    waveText.hide();
  }
  if (mousePressed && wecText.isVisible()) { 
    wecText.hide();
  }
  //controls power indicators
  if (pow >= 1.25) {
    quad1.setColorBackground(green).setColorActive(green);
  } else {
    quad1.setColorBackground(grey).setColorActive(grey);    //if under threshold, then grey
  }
  if (pow >= 3) {
    quad2.setColorBackground(green).setColorActive(green);
  } else {
    quad2.setColorBackground(grey).setColorActive(grey);    //if under threshold, then grey
  }
  if (pow >= 4.25) {
    quad3.setColorBackground(green).setColorActive(green);
  } else {
    quad3.setColorBackground(grey).setColorActive(grey);    //if under threshold, then grey
  }
  if (pow >= 5) {
    quad4.setColorBackground(green).setColorActive(green);
  } else {
    quad4.setColorBackground(grey).setColorActive(grey);    //if under threshold, then grey
  }
}
