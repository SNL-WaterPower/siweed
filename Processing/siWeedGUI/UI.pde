ControlP5 cp5;
Chart waveChart, wecChart; //wave Signal chart
Slider position; //slider for position mode
Slider h, freq; //sliders for function mode
Slider sigH, peakF, gamma;  //sliders for sea state mode
Slider pGain, dGain, torqueSlider, sigHWEC, peakFWEC, gammaWEC; // WEC sliders
Button jog, function, sea, off, offWEC, torque, feedback, seaWEC; // mode buttons
Button wecQs, waveQs, wecChartQs, waveChartQs, FFTQs, meterQs; // popup buttons
Button wavePosData, waveElData, wecPosData, wecVelData, wecTorqData, wecPowData;
Button quad1, quad2, quad3, quad4; // power bar
Button consoleButton; //Idealy this would be a toggle, but was getting errors on the ".isVisible()"
Textarea wecText, waveText, myTextarea, wecChartText, waveChartText, FFTText, meterText;
//These varibles are defined in initializeUI() so width and height variables return non zero values
int zeroLocationLeft, zeroLocationRight, zeroLocationY, chartLocationY, columnWidth, chartSizeY, chartStroke, buttonHeight, bannerHeight, modeButtonsY, chartButtonsY, powerMeterButtonsY, buttonWidth, spaceBetweenButtons;    

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
color clear = color(grey, 100);


// Fonts
PFont f; // Regular font
PFont fb; // Bold font
PFont buttonFont, bigButtonFont, sliderFont, headerTextBoxFont, headerTextBoxFontBold, textBoxFont, smallTextBoxFont; 


//Pics
PImage snlLogo, wavePic, LHSPic, pic1, pic2;
void initializeUI() {
  //These variables need to be defined here so that the height and width variables do not return 0
  //Every variable is scaled by the size of the window, the GUI will look similar no matter the screen dimensions
  zeroLocationLeft = 780*width/1920;    //origin of the left column
  zeroLocationRight = 1350*width/1920;   //origin of the right column
  zeroLocationY = 35*height/1100;
  chartLocationY = 475*height/1100;
  columnWidth = 504*width/1920;      //if you imagine the right half of the GUI as 2 columns, this is the width of each column
  chartSizeY = 185*height/1100;
  chartStroke = 2*height/1100;
  if (chartStroke < 1) {
    chartStroke = 1;
  }    //make sure the stroke is at least 1
  buttonHeight = 35*height/1100;      //used for buttons and some title boxes
  bannerHeight = 45*height/1100;     //used for the top two title boxes
  modeButtonsY = 155*height/1100;     //y coordinate of the mode select buttons
  chartButtonsY = chartLocationY+chartSizeY;
  powerMeterButtonsY = 1010*height/1100;
  buttonWidth = columnWidth/4;    //most of the GUI has 4 buttons per column
  spaceBetweenButtons = 2*width/1920;    
  // starting ControlP5 stuff
  cp5 = new ControlP5(this);

  //Fonts
  f = createFont("Arial", 16*width/1920, true);
  fb = createFont("Arial Bold Italic", 32*width/1920, true);
  buttonFont = createFont("Arial Bold Italic", 12*width/1920, true);
  bigButtonFont = createFont("Arial Bold Italic", 16*width/1920, true);
  sliderFont = createFont("Arial Bold Italic", 12*width/1920, true);
  headerTextBoxFont = createFont("Arial", 35*width/1920, true);
  headerTextBoxFontBold = createFont("Arial Bold", 35*width/1920, true);
  textBoxFont = createFont("Arial Bold Italic", 22*width/1920, true);
  smallTextBoxFont = createFont("Arial Bold Italic", 18*width/1920, true);

  // Buttons //
  consoleButton = cp5.addButton("consoleButton")
    .setPosition(1800*width/1920, 1065*height/1100)
    .setSize(100*width/1920, 25*height/1100)
    .setLabel("Console")
    .setColorBackground(grey)
    .setFont(buttonFont); 

  // wave maker buttons //
  jog = cp5.addButton("jog")
    .setPosition(zeroLocationLeft, modeButtonsY)
    .setSize(buttonWidth - spaceBetweenButtons, buttonHeight)
    .setLabel("Jog Mode")
    .setFont(buttonFont )
    .setColorBackground(buttonblue);

  function = cp5.addButton("fun")
    .setPosition(zeroLocationLeft + buttonWidth, modeButtonsY)
    .setSize(buttonWidth - spaceBetweenButtons, buttonHeight)
    .setLabel("Function Mode")
    .setFont(buttonFont)
    .setColorBackground(buttonblue); 

  sea = cp5.addButton("sea")
    .setPosition(zeroLocationLeft + buttonWidth*2, modeButtonsY)
    .setSize(buttonWidth - spaceBetweenButtons, buttonHeight)
    .setLabel("Sea State")
    .setFont(buttonFont)
    .setColorBackground(buttonblue); 

  off = cp5.addButton("off")
    .setPosition(zeroLocationLeft + buttonWidth*3, modeButtonsY)
    .setSize(buttonWidth, buttonHeight)
    .setLabel("OFF")
    .setFont(buttonFont)
    .setColorBackground(buttonblue); 

  //WEC controls buttons //
  torque = cp5.addButton("torque")
    .setPosition(zeroLocationRight, modeButtonsY)
    .setSize(buttonWidth - spaceBetweenButtons, buttonHeight)
    .setLabel("Torque")
    .setFont(buttonFont)
    .setColorBackground(buttonblue);

  feedback = cp5.addButton("feedback")
    .setPosition(zeroLocationRight + buttonWidth, modeButtonsY)
    .setSize(buttonWidth - spaceBetweenButtons, buttonHeight)
    .setLabel("Feedback")
    .setFont(buttonFont)
    .setColorBackground(buttonblue); 

  seaWEC = cp5.addButton("seaWEC")
    .setPosition(zeroLocationRight + buttonWidth*2, modeButtonsY)
    .setSize(buttonWidth - spaceBetweenButtons, buttonHeight)
    .setLabel("SID")      //!!!Need to change this name to something more intuitive
    .setFont(buttonFont)
    .setColorBackground(buttonblue);    

  offWEC = cp5.addButton("offWEC")
    .setPosition(zeroLocationRight + buttonWidth*3, modeButtonsY)
    .setSize(buttonWidth, buttonHeight)
    .setLabel("Off")
    .setFont(buttonFont)
    .setColorBackground(buttonblue);

  // Wavemaker info buttons //     
  wavePosData = cp5.addButton("wavePosData")
    .setPosition(zeroLocationLeft, chartButtonsY)
    .setColorBackground(grey)
    .setSize(buttonWidth*2 - spaceBetweenButtons, buttonHeight)
    .setLabel("Wave Maker Position")
    .setFont(buttonFont); 

  waveElData = cp5.addButton("waveElData")
    .setPosition(zeroLocationLeft + buttonWidth*2, chartButtonsY)
    .setColorBackground(grey)
    .setSize(buttonWidth*2, buttonHeight)
    .setLabel("Wave Elevation")
    .setFont(buttonFont); 

  //WEC info buttons //
  wecPosData = cp5.addButton("wecPosData")
    .setPosition(zeroLocationRight, chartButtonsY)
    .setColorBackground(grey)
    .setSize(buttonWidth - spaceBetweenButtons, buttonHeight)
    .setLabel("Position")
    .setFont(buttonFont); 

  wecVelData = cp5.addButton("wecVelData")
    .setPosition(zeroLocationRight + buttonWidth, chartButtonsY)
    .setColorBackground(grey)
    .setSize(buttonWidth - spaceBetweenButtons, buttonHeight)
    .setLabel("Velocity")
    .setFont(buttonFont);

  wecTorqData = cp5.addButton("wecTorqData")
    .setPosition(zeroLocationRight + buttonWidth*2, chartButtonsY)
    .setColorBackground(grey)
    .setSize(buttonWidth - spaceBetweenButtons, buttonHeight)
    .setLabel("Torque")
    .setFont(buttonFont);

  wecPowData = cp5.addButton("wecPowData")
    .setPosition(zeroLocationRight + buttonWidth*3, chartButtonsY)
    .setColorBackground(grey)
    .setSize(buttonWidth, buttonHeight)
    .setLabel("Power")
    .setFont(buttonFont);

  //Power meter buttons //
  quad1 = cp5.addButton("quad1")
    .setPosition(zeroLocationRight, powerMeterButtonsY)
    .setColorBackground(grey)
    .setSize(buttonWidth - spaceBetweenButtons, buttonHeight)
    .setLabel("25%");  

  quad2 = cp5.addButton("quad2")
    .setPosition(zeroLocationRight + buttonWidth, powerMeterButtonsY)
    .setColorBackground(grey)
    .setSize(buttonWidth - spaceBetweenButtons, buttonHeight)
    .setLabel("50%"); 

  quad3 = cp5.addButton("quad3")
    .setPosition(zeroLocationRight + buttonWidth*2, powerMeterButtonsY)
    .setColorBackground(grey)
    .setSize(buttonWidth - spaceBetweenButtons, buttonHeight)
    .setLabel("75%"); 

  quad4 = cp5.addButton("quad4")
    .setPosition(zeroLocationRight + buttonWidth*3, powerMeterButtonsY)
    .setColorBackground(grey)
    .setSize(buttonWidth, buttonHeight)
    .setLabel("100%");

  //pop up buttons:
  waveQs = cp5.addButton("waveQs")
    .setPosition(zeroLocationLeft + columnWidth - bannerHeight, 90*height/1100)
    .setSize(bannerHeight, bannerHeight)
    .setColorBackground(turq)
    .setFont(bigButtonFont)
    .setLabel("?");
  wecQs = cp5.addButton("wecQs")
    .setPosition(zeroLocationRight + columnWidth - bannerHeight, 90*height/1100)
    .setSize(bannerHeight, bannerHeight)
    .setColorBackground(green)
    .setFont(bigButtonFont)
    .setLabel("?");
  waveChartQs = cp5.addButton("waveChartQs")
    .setPosition(zeroLocationLeft + columnWidth - buttonHeight, chartLocationY-buttonHeight)
    .setSize(buttonHeight, buttonHeight)
    .setColorBackground(buttonblue)
    .setFont(bigButtonFont)
    .setLabel("?");
  wecChartQs = cp5.addButton("wecChartQs")
    .setPosition(zeroLocationRight + columnWidth - buttonHeight, chartLocationY-buttonHeight)
    .setSize(buttonHeight, buttonHeight)
    .setColorBackground(buttonblue)
    .setFont(buttonFont)
    .setLabel("?");
  FFTQs = cp5.addButton("FFTQs")
    .setPosition(zeroLocationLeft + columnWidth - buttonHeight, 725*height/1100)
    .setSize(buttonHeight, buttonHeight)
    .setColorBackground(buttonblue)
    .setFont(bigButtonFont)
    .setLabel("?");
  meterQs = cp5.addButton("meterQs")
    .setPosition(zeroLocationRight + columnWidth - buttonHeight, 725*height/1100)
    .setSize(buttonHeight, buttonHeight)
    .setColorBackground(buttonblue)
    .setFont(bigButtonFont)
    .setLabel("?");

  // Sliders // 
  int sliderX, sliderY;
  sliderX = zeroLocationLeft;
  sliderY = 200*height/1100;
  int sliderSizeX = 380*width/1920;
  int sliderSizeY = 35*height/1100;
  int sliderOffset = 48*height/1100;

  // Motor Jog Mode Sliders
  position = cp5.addSlider("Position (MM)")  //name slider
    .setRange(-25, 25) //slider range
    .setPosition(sliderX, sliderY) 
    .setFont(sliderFont)
    .setSize(sliderSizeX, sliderSizeY)
    .setColorForeground(color(turq))
    .setColorBackground(color(buttonblue))
    .hide()
    .setColorCaptionLabel(color(buttonblue));

  // Motor Function Mode Sliders
  h = cp5.addSlider("Amplitude (MM)") 
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
  sigH = cp5.addSlider("Significant Amplitude (MM)")  
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
    .hide()
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
  sigH.setValue(5.0);
  peakF.setValue(2.0);
  gamma.setValue(3.5);

  sigHWEC.setValue(2.5);
  peakFWEC.setValue(0.3);
  gammaWEC.setValue(0.3);

  // Charts //
  waveChart =  cp5.addChart("Wave Information chart")//
    .setPosition(zeroLocationLeft, chartLocationY)
    .setSize(columnWidth, chartSizeY)
    .setFont(sliderFont)
    .setRange(-10, 10)
    .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
    .setColorCaptionLabel(color(40))  
    .setColorBackground(white)
    .setLabel("");

  waveChart.addDataSet("debug");                          //all other data sets are created with button functions
  waveChart.setData("debug", new float[360]);
  waveChart.setStrokeWeight(chartStroke);      //This needs to be set after a data set is added in order to work
  //println(waveChart.getStrokeWeight());
  wecChart =  cp5.addChart("WEC Information chart")
    .setPosition(zeroLocationRight, chartLocationY)
    .setSize(columnWidth, chartSizeY)
    .setFont(sliderFont)
    .setRange(-10, 10)
    .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
    .setColorCaptionLabel(color(40))
    .setColorBackground(white)
    .setLabel("");

  snlLogo = loadImage("SNL_Stacked_White.png");
  wavePic = loadImage("ocean.jpg");
  LHSPic = loadImage("LHS.png");
  pic1 = loadImage("1.png");
  pic2 = loadImage("2.png");

  //console, this needs to be in the setup to ensure
  //that it catches any errors when program starts
  consoleOutput=cp5.addTextarea("consoleOutput")
    .setPosition(1650*width/1920, 800*height/1100) 
    .setSize(330*width/1920, 150*height/1100)
    .setLineHeight(14*height/1100)
    .setColorValue(green) //color of font
    .scroll(1) //enable scrolling up and down
    .hide(); //hidden on startup   
  if (!debug && guiConsole)      //only does in GUI console if not debugging
  {
    console = cp5.addConsole(consoleOutput);
  }
  myTextarea = cp5.addTextarea("txtMission")
    .setPosition(zeroLocationLeft, zeroLocationY)
    .setText("MISSION")
    .setSize(300*width/1920, 55*height/1100)
    .setFont(headerTextBoxFont)
    .setLineHeight(7*height/1100)
    .setColor(buttonblue);
  myTextarea = cp5.addTextarea("txtControl")
    .setPosition(zeroLocationLeft+150*width/1920, zeroLocationY)
    .setText("CONTROL")
    .setSize(300*width/1920, 55*height/1100)
    .setFont(headerTextBoxFontBold)
    .setLineHeight(7*height/1100)
    .setColor(turq);
  myTextarea = cp5.addTextarea("txtSystem")
    .setPosition(zeroLocationLeft, 385*height/1100)
    .setText("SYSTEM")
    .setSize(350*width/1920, 75*height/1100)
    .setFont(headerTextBoxFont)
    .setLineHeight(7*height/1100)
    .setColor(color(buttonblue));
  myTextarea = cp5.addTextarea("txtStatus")
    .setPosition(zeroLocationLeft+145*width/1920, 385*height/1100)
    .setText("STATUS")
    .setSize(350*width/1920, 75*height/1100)
    .setFont(headerTextBoxFontBold)
    .setLineHeight(7*height/1100)
    .setColor(white);

  myTextarea = cp5.addTextarea("txtWaveInformation")
    .setPosition(zeroLocationLeft+160*width/1920, 445*height/1100)
    .setText("WAVE INFORMATION" )
    .setSize(300*width/1920, 40*height/1100)
    .setFont(smallTextBoxFont)
    .setLineHeight(10*height/1100)
    .setColor(color(white)); 

  myTextarea = cp5.addTextarea("txtWECInformation")
    .setPosition(zeroLocationRight + 160*width/1920, 445*height/1100)
    .setText("WEC INFORMATION")
    .setSize(300*width/1920, 40*height/1100)
    .setFont(smallTextBoxFont)
    .setLineHeight(10*height/1100)
    .setColor(color(white));

  myTextarea = cp5.addTextarea("txtWaveDimensions")
    .setPosition(zeroLocationLeft+100*width/1920, 100*height/1100)
    .setText("CHANGE WAVE DIMENSIONS" )
    .setSize(350*width/1920, 40*height/1100)
    .setFont(textBoxFont)
    .setLineHeight(10*height/1100)
    .setColor(color(white)); 

  myTextarea = cp5.addTextarea("txtWECControls")
    .setPosition(zeroLocationRight + 100*width/1920, 100*height/1100)
    .setText("CHANGE WEC CONTROLS")
    .setSize(300*width/1920, 40*height/1100)
    .setFont(textBoxFont)
    .setLineHeight(10*height/1100)
    .setColor(color(white)); 

  myTextarea = cp5.addTextarea("txtPowerMeter")
    .setPosition(zeroLocationRight+170*width/1920, 730*height/1100)
    .setText("POWER METER")
    .setSize(300*width/1920, 40*height/1100)
    .setFont(smallTextBoxFont)
    .setLineHeight(10*height/1100)
    .setColor(color(white));

  myTextarea = cp5.addTextarea("FFTTitle")
    .setPosition(zeroLocationLeft + 170*width/1920, 730*height/1100)
    .setText("Frequency Analysis")
    .setSize(300*width/1920, 40*height/1100)
    .setFont(smallTextBoxFont)
    .setLineHeight(10*height/1100)
    .setColor(color(white));


  //Pop up text areas:
  waveText = cp5.addTextarea("Wave Information")
    .setPosition(zeroLocationLeft, 150*height/1100)
    .setSize(columnWidth, 200*height/1080)
    .setFont(createFont("arial", 16*width/1920))
    .setLineHeight(18*height/1100)
    .setColor(black)
    .setColorBackground(white)
    .setText(loadStrings("popUpText.txt")[1])      //loads the first line of text in this text file in the data folder
    .hide();

  wecText = cp5.addTextarea("WEC Information")
    .setPosition(zeroLocationRight, 150*height/1100)
    .setSize(columnWidth, 200*height/1080)
    .setFont(createFont("arial", 16*width/1920))
    .setLineHeight(18*height/1100)
    .setColor(black)
    .setColorBackground(white)
    .setText(loadStrings("popUpText.txt")[3])    //loads the first line of text in this text file in the data folder
    .hide();

  waveChartText = cp5.addTextarea("Wave Chart Information")
    .setPosition(zeroLocationLeft, chartLocationY)
    .setSize(columnWidth, chartSizeY+buttonHeight)
    .setFont(createFont("arial", 16*width/1920))
    .setLineHeight(18*height/1100)
    .setColor(black)
    .setColorBackground(white)
    .setText(loadStrings("popUpText.txt")[5])      //loads the first line of text in this text file in the data folder
    .hide();

  wecChartText = cp5.addTextarea("WEC Chart Information")
    .setPosition(zeroLocationRight, chartLocationY)
    .setSize(columnWidth, chartSizeY+buttonHeight)
    .setFont(createFont("arial", 16*width/1920))
    .setLineHeight(18*height/1100)
    .setColor(black)
    .setColorBackground(white)
    .setText(loadStrings("popUpText.txt")[7])    //loads the first line of text in this text file in the data folder
    .hide();

  FFTText = cp5.addTextarea("FFT Information")
    .setPosition(zeroLocationLeft, 760*height/1100)
    .setSize(columnWidth, 250*height/1100+buttonHeight)
    .setFont(createFont("arial", 16*width/1920))
    .setLineHeight(18*height/1100)
    .setColor(black)
    .setColorBackground(white)
    .setText(loadStrings("popUpText.txt")[9])      //loads the first line of text in this text file in the data folder
    .hide();

  meterText = cp5.addTextarea("Meter Information")
    .setPosition(zeroLocationRight, 760*height/1100)
    .setSize(columnWidth, 250*height/1100+buttonHeight)
    .setFont(createFont("arial", 16*width/1920))
    .setLineHeight(18*height/1100)
    .setColor(black)
    .setColorBackground(white)
    .setText(loadStrings("popUpText.txt")[11])    //loads the first line of text in this text file in the data folder
    .hide();

  if (basicMode) {      //These settings if in basic mode. Removes some functionality
    //Reset size and position of buttons we do want:
    function.setPosition(zeroLocationLeft, modeButtonsY)
      .setSize(buttonWidth*2 - spaceBetweenButtons, buttonHeight);

    off.setPosition(zeroLocationLeft + buttonWidth*2, modeButtonsY)
      .setSize(buttonWidth*2, buttonHeight);
    //WEC control buttons: //
    feedback.setPosition(zeroLocationRight, modeButtonsY)
      .setSize(buttonWidth*2 - spaceBetweenButtons, buttonHeight);   

    offWEC.setPosition(zeroLocationRight + buttonWidth*2, modeButtonsY)
      .setSize(buttonWidth*2, buttonHeight);
    //move dGain slider up
    dGain.setPosition(sliderX, sliderY)
      .setLabel("Damping");

    //hide buttons we don't want:
    jog.hide();
    sea.hide(); 
    torque.hide();
    seaWEC.hide();
  }
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
    sendSerial('!', waveMaker.mode, port1);
  }
  sendNewDataWM = true;    //this parameter being adjusted will cause the main loop to send the initial data
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
    sendSerial('!', waveMaker.mode, port1);
  }
  sendNewDataWM = true;    //this parameter being adjusted will cause the main loop to send the initial data
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
  //draw();    //this sends values before changing mode, which increases stability
  if (WMConnected) {
    sendSerial('!', waveMaker.mode, port1);
  }
  sendNewDataWM = true;    //this parameter being adjusted will cause the main loop to send the initial data
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
    sendSerial('!', waveMaker.mode, port1);
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
    sendSerial('!', wec.mode, port2);
  }
  sendNewDataWEC = true;    //this parameter being adjusted will cause the main loop to send the initial data
}   

void feedback() {
  torque.setColorBackground(buttonblue);
  feedback.setColorBackground(green);
  seaWEC.setColorBackground(buttonblue);
  offWEC.setColorBackground(buttonblue);
  wec.mode = 2; 
  torqueSlider.hide();
  if (!basicMode) {    //don't show the pgain slider in basic mode
    pGain.show();
  } else {
    pGain.hide();
  }
  dGain.show();
  sigHWEC.hide();
  peakFWEC.hide();
  gammaWEC.hide();
  if (WECConnected) {
    sendSerial('!', wec.mode, port2);
  }
  sendNewDataWEC = true;     //this parameter being adjusted will cause the main loop to send the initial data
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
  //draw();    //this sends values before changing mode, which increases stability
  if (WECConnected) {
    sendSerial('!', wec.mode, port2);
  }
  sendNewDataWEC = true;     //this parameter being adjusted will cause the main loop to send the initial data
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
    sendSerial('!', wec.mode, port2);
  }
}

boolean wavePosClicked = false; 
void wavePosData() {
  if (wavePosClicked == false) {
    wavePosClicked = true;
    wavePosData.setColorBackground(buttonblue);
    waveChart.addDataSet("waveMakerPosition");
    waveChart.setColors("waveMakerPosition", buttonblue);
    waveChart.setData("waveMakerPosition", new float[360]);
    waveChart.setStrokeWeight(chartStroke);      //This needs to be set after a data set is added in order to work
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
    waveChart.setStrokeWeight(chartStroke);      //This needs to be set after a data set is added in order to work
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
    wecPosData.setColorBackground(buttonblue);
    wecChart.addDataSet("wecPosition");
    wecChart.setColors("wecPosition", buttonblue);
    wecChart.setData("wecPosition", new float[360]);
    wecChart.setStrokeWeight(chartStroke);      //This needs to be set after a data set is added in order to work
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
    wecChart.setStrokeWeight(chartStroke);      //This needs to be set after a data set is added in order to work
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
    wecChart.setStrokeWeight(chartStroke);      //This needs to be set after a data set is added in order to work
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
    wecChart.setStrokeWeight(chartStroke);      //This needs to be set after a data set is added in order to work
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
void waveChartQs() {
  if (waveChartText.isVisible()) {
    waveChartText.hide();
  } else {
    waveChartText.show();
  }
}
void wecChartQs() {
  if (wecChartText.isVisible()) {
    wecChartText.hide();
  } else {
    wecChartText.show();
  }
}
void FFTQs() {
  if (FFTText.isVisible()) {
    FFTText.hide();
  } else {
    FFTText.show();
  }
}

void meterQs() {
  if (meterText.isVisible()) {
    meterText.hide();
  } else {
    meterText.show();
  }
}

void drawFFT() {
  if (millis() > previousMillis+fftInterval) {
    previousMillis = millis();
    updateFFT();
  }
  //////////////////FFT vars: These need to be in the function in order for width and height scaling to work
  float originx = zeroLocationLeft+25*width/1920;    //x and y coordinates of the FFT graph
  float originy = 1025*height/1100;
  float xScale = 1.6*width/1920;    //how spaced the graph is horizontally
  float yScale = 50000*height/1100;    //how tall the data is. axis has to be set separately
  int FFTHeight = 225*height/1100;    //height of y axis coordinates. Does not scale data
  int yAxisCount = 5;    //how many numbers on the y axis
  float FFTXOffset = 10*width/1920, FFTYOffset = 20*height/1100;
  int nyquist = (int)frameRate/2;    //sampling frequency/2 NOTE: framerate is not a constant variable
  //////////
  textSize(14*height/1100);
  strokeWeight(3*width/1920);
  for (int i=0; i<=queueSize/2; i++) {      //cut in half
    if (waveMaker.mode == 2 || waveMaker.mode == 3) {    //if in a mode where the FFT is meaningful, and data is added
      fill(green);
      stroke(green);
    } else {
      fill(grey);
      stroke(grey);
    }
    float x = originx+xScale*i;
    float y = originy;
    float maxY = originy - FFTHeight;    //value that saturates the data
    float yCord = y - yScale*fftArr[i];    //how high to draw the line
    if (yCord < maxY) {    //saturate, so y doesn't get drawn off the graph(remember y coordinates are flipped)
      yCord = maxY;
    }
    line(x+FFTXOffset, y-FFTYOffset, x+FFTXOffset, yCord-FFTYOffset);
    fill(white);    //text color
    if (i%32 == 0) {        //should make 32 into a variable, but frameRate is not an int.
      text((int)(i*(1/((float)queueSize/32))), x+FFTXOffset, y);    //x-axis: frequency spacing is 1/T, where t is length of sample in seconds
    }
    if (i%1 == 0 && i<=yAxisCount && i != 0) {    //mod controls spacing, draws only if less than max count and not zero(to not draw 2 zeros)
      text(i, originx, y - FFTHeight/yAxisCount*i);    //y-axis
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
  rect(zeroLocationLeft, 90*height/1100, columnWidth, bannerHeight); // Change wave dimensions
  fill(green);
  rect(zeroLocationRight, 90*height/1100, columnWidth, bannerHeight); // Change WEC controls
  fill(buttonblue);
  rect(zeroLocationLeft, chartLocationY-buttonHeight, columnWidth, buttonHeight); // Wave Information
  rect(zeroLocationRight, chartLocationY-buttonHeight, columnWidth, buttonHeight); // Wec Information
  rect(zeroLocationRight, 725*height/1100, columnWidth, buttonHeight); // Power Meter title
  rect(zeroLocationLeft, 725*height/1100, columnWidth, buttonHeight); // FFT title
  rect(zeroLocationRight, 760*height/1100, columnWidth, 250*height/1100);  //meter background
  rect(zeroLocationLeft, 760*height/1100, columnWidth, 250*height/1100+buttonHeight);  //FFT background

  //draw white rectangles behind the buttons to make it look like there are lines separating them:
  fill(white);
  rect(zeroLocationLeft, chartButtonsY, buttonWidth*4, buttonHeight);
  rect(zeroLocationRight, chartButtonsY, buttonWidth*4, buttonHeight);
  rect(zeroLocationRight, powerMeterButtonsY, buttonWidth*4, buttonHeight);
  //draw lines to separate FFT and Meter titles from data
  stroke(white);
  strokeWeight(2);
  line(zeroLocationLeft, 727*height/1100+buttonHeight, zeroLocationLeft + columnWidth, 727*height/1100+buttonHeight);
  line(zeroLocationRight, 727*height/1100+buttonHeight, zeroLocationRight + columnWidth, 727*height/1100+buttonHeight);
  image(LHSPic, 0, 0, width/2.7, height); //lhs pic
  image(pic1, zeroLocationLeft + 20*width/1920, 90*height/1100, bannerHeight, bannerHeight);
  image(pic2, zeroLocationRight + 20*width/1920, 90*height/1100, bannerHeight, bannerHeight);
  //controls power indicators
  if (myMeter.getAverageVal() >= 0.5) {
    quad1.setColorBackground(green).setColorActive(green);
  } else {
    quad1.setColorBackground(grey).setColorActive(grey);    //if under threshold, then grey
  }
  if (myMeter.getAverageVal() >= 1) {
    quad2.setColorBackground(green).setColorActive(green);
  } else {
    quad2.setColorBackground(grey).setColorActive(grey);    //if under threshold, then grey
  }
  if (myMeter.getAverageVal() >= 1.5) {
    quad3.setColorBackground(green).setColorActive(green);
  } else {
    quad3.setColorBackground(grey).setColorActive(grey);    //if under threshold, then grey
  }
  if (myMeter.getAverageVal() >= 1.8) {
    quad4.setColorBackground(green).setColorActive(green);
  } else {
    quad4.setColorBackground(grey).setColorActive(grey);    //if under threshold, then grey
  }
}
