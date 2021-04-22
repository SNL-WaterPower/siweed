ControlP5 cp5; 
Textarea myTextarea;
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
Textarea wecText, waveText;

// Custom colors
color green = color(190, 214, 48);
color turq = color(0, 173, 208);
color dblue = color(0, 83, 118);
color buttonblue = color(0, 45, 90);
color hoverblue = color(0, 116, 217);
color grey = color(180, 190, 191);
color black = color(0, 0, 0);
color white = color(255, 255, 255);
color red = color(255, 0, 0);


// Fonts
PFont f; // Regular font
PFont fb; // Bold font
PFont buttonFont, sliderFont, titleTextBoxFont, headerTextBoxFont, textBoxFont; 


// Sandia logo
PImage snlLogo;
PImage wavePic;
void initializeUI() {

  // starting ControlP5 stuff
  cp5 = new ControlP5(this);
  //Fonts
  f = createFont("Arial", 16, true);
  fb = createFont("Arial Bold Italic", 32, true);
  titleTextBoxFont = buttonFont = createFont("Arial Bold Italic", 40, true);
  buttonFont = createFont("Arial Bold Italic", 12, true);
  sliderFont = createFont("Arial Bold Italic", 12, true);
  headerTextBoxFont = createFont("Arial Bold", 25, false);
  textBoxFont = createFont("Arial Bold Italic", 20, true);

  // Buttons //
  //1387

  /* Code to make this toggle, but getting errors on ".isVisible()
   consoleButton = cp5.addToggle("consoleButton")
   .setCaptionLabel("AllconsoleButton")
   //.setValue(0)
   .setPosition(1390, 610)
   .setSize(50, 20)
   .setColorBackground(grey)
   .setState(false);
   */
  consoleButton = cp5.addButton("consoleButton")
    .setPosition(1390, 610)
    .setSize(100, 50)
    .setLabel("Console")
    .setColorBackground(grey)
    .setFont(buttonFont); 

  int powerX, powerY;
  powerX = 1425;
  powerY = 500;

  quad1 = cp5.addButton("quad1")
    .setPosition(powerX, powerY)
    .setColorBackground(grey)
    .setSize(100, 50)
    .setLabel("25%");  

  quad2 = cp5.addButton("quad2")
    .setPosition(powerX + 100, powerY)
    .setColorBackground(grey)
    .setSize(100, 50)
    .setLabel("50%"); 

  quad3 = cp5.addButton("quad3")
    .setPosition(powerX + 200, powerY)
    .setColorBackground(grey)
    .setSize(100, 50)
    .setLabel("75%"); 

  quad4 = cp5.addButton("quad4")
    .setPosition(powerX + 300, powerY)
    .setColorBackground(grey)
    .setSize(100, 50)
    .setLabel("100%");


  int qX, qY;
  qX = 295;
  qY = 215;
  waveQs = cp5.addButton("waveQs")
    .setPosition(qX, qY)
    .setSize(15, 15)
    .setLabel("?");

  wecQs = cp5.addButton("wecQs")
    .setPosition(qX - 35, qY + 400)
    .setSize(15, 15)
    .setLabel("?");

  // wave maker buttons
  int buttonX, buttonY;
  buttonX = 45;
  buttonY = 260;
  jog = cp5.addButton("jog")
    .setPosition(buttonX, buttonY)
    .setSize(150, 65)
    .setLabel("Jog Mode")
    .setFont(buttonFont );

  function = cp5.addButton("fun")
    .setPosition(buttonX + 170, buttonY)
    .setSize(150, 65)
    .setLabel("Function Mode")
    .setFont(buttonFont); 

  sea = cp5.addButton("sea")
    .setPosition(buttonX + 340, buttonY)
    .setSize(150, 65)
    .setLabel("Sea State")
    .setFont(buttonFont); 

  off = cp5.addButton("off")
    .setPosition(buttonX + 510, buttonY)
    .setSize(150, 65)
    .setLabel("OFF")
    .setFont(buttonFont); 


  buttonY = 660;

  torque = cp5.addButton("torque")
    .setPosition(buttonX, buttonY)
    .setSize(150, 65)
    .setLabel("Torque")
    .setFont(buttonFont);   

  feedback = cp5.addButton("feedback")
    .setPosition(buttonX + 170, buttonY)
    .setSize(150, 65)
    .setLabel("Feedback")
    .setFont(buttonFont); 
  //spring, jogWEC, offWEC 

  seaWEC = cp5.addButton("seaWEC")
    .setPosition(buttonX + 340, buttonY)
    .setSize(150, 65)
    .setLabel("Sea State")
    .setFont(buttonFont);    

  offWEC = cp5.addButton("offWEC")
    .setPosition(buttonX + 510, buttonY)
    .setSize(150, 65)
    .setLabel("Off")
    .setFont(buttonFont); 

  //Button wavePosData, waveElData, wecPosData, wecVelData, wecTorqData, wecPowData;
  int dataButtonX, dataButtonY;
  dataButtonX = 970;
  dataButtonY = 735;

  wavePosData = cp5.addButton("wavePosData")
    .setPosition(dataButtonX, dataButtonY)
    .setColorBackground(grey)
    .setSize(100, 50)
    .setLabel("Wave Maker\nPosition")
    .setFont(buttonFont); 

  waveElData = cp5.addButton("waveElData")
    .setPosition(dataButtonX + 125, dataButtonY)
    .setColorBackground(grey)
    .setSize(100, 50)
    .setLabel("Wave\nElevation")
    .setFont(buttonFont); 

  dataButtonY = 990;

  wecPosData = cp5.addButton("wecPosData")
    .setPosition(dataButtonX - 125, dataButtonY)
    .setColorBackground(grey)
    .setSize(100, 50)
    .setLabel("Wec Position")
    .setFont(buttonFont); 

  wecVelData = cp5.addButton("wecVelData")
    .setPosition(dataButtonX, dataButtonY)
    .setColorBackground(grey)
    .setSize(100, 50)
    .setLabel("WEC Velocity")
    .setFont(buttonFont);

  wecTorqData = cp5.addButton("wecTorqData")
    .setPosition(dataButtonX + 125, dataButtonY)
    .setColorBackground(grey)
    .setSize(100, 50)
    .setLabel("WEC Torque")
    .setFont(buttonFont);

  wecPowData = cp5.addButton("wecPowData")
    .setPosition(dataButtonX + 250, dataButtonY)
    .setColorBackground(grey)
    .setSize(100, 50)
    .setLabel("WEC Power")
    .setFont(buttonFont);

  // Sliders // 
  //distance between slider and buttons is 150, distance between each slider is 100

  int sliderX, sliderY;
  sliderX = 150;
  sliderY = 240 + 65 + 50; // button Y lcation (240) + size of button + 50 

  // Motor Jog Mode Sliders
  position = cp5.addSlider("Position (MM)")  //name slider
    .setRange(-25, 25) //slider range
    .setPosition(sliderX, sliderY) //x and y coordinates of upper left corner of button
    .setFont(sliderFont)
    .setSize(450, 50); //size (width, height)

  // Motor Function Mode Sliders
  h = cp5.addSlider("Height (MM)")  //name slider
    .setRange(0, 20) //slider range
    .setPosition(sliderX, sliderY) //x and y coordinates of upper left corner of button
    .setSize(450, 50)
    .setFont(sliderFont)
    .hide(); //size (width, height)

  freq = cp5.addSlider("Frequency (Hz)")  //name of button
    .setRange(0, 2.5)
    .setPosition(sliderX, sliderY + 100) //x and y coordinates of upper left corner of button
    .setSize(450, 50)
    .setFont(sliderFont)
    .hide(); //size (width, height)


  // Motor Sea State Mode Sliders
  sigH = cp5.addSlider("Significant Height (MM)")  //name slider
    .setRange(0, 10) //slider range
    .setPosition(sliderX, sliderY) //x and y coordinates of upper left corner of button
    .setSize(450, 50)
    .setFont(sliderFont)
    .hide(); //size (width, height)

  peakF = cp5.addSlider("Peak Frequency (Hz)")  //name of button
    .setRange(0, 4)
    .setPosition(sliderX, sliderY + 100) //x and y coordinates of upper left corner of button
    .setSize(450, 50)
    .setFont(sliderFont)
    .hide(); //size (width, height)

  gamma = cp5.addSlider("Peakedness")  //name of button
    .setRange(0, 7)
    .setPosition(sliderX, sliderY + 200) //x and y coordinates of upper left corner of button
    .setSize(450, 50)
    .setFont(sliderFont)
    .hide(); //size (width, height)

  sliderY = buttonY + 65 + 50 ; //button y coordinate + button size + 50 (offset)

  // WEC Torque Sliders
  torqueSlider = cp5.addSlider("Torque")  //name of button
    //.setRange(-0.006, 0.006)      //max amps * torque constant. I think this will max amperage at max slider value
    .setRange(-6, 6)
    .setFont(sliderFont)
    .setPosition(sliderX, sliderY) //x and y coordinates of upper left corner of button
    .setSize(450, 50); //size (width, height)

  // WEC Feedback Sliders   
  pGain = cp5.addSlider("P Gain")  //name of button
    //.setRange(-0.0006, 0.0006)    //user needs to be able to command negative //0.1(wave height in meters) * max torque(above)
    .setRange(-10, 10)    //scaled in main tab
    .setFont(sliderFont)
    .setPosition(sliderX, sliderY) //x and y coordinates of upper left corner of button
    .setSize(450, 50) //size (width, height)
    .hide();

  dGain = cp5.addSlider("D Gain")  //name of button
    //.setRange(0, 0.0005)    //user needs to only command positive
    .setRange(0, 10)    //scaled in main tab
    .setFont(sliderFont)
    .setPosition(sliderX, sliderY + 100) //x and y coordinates of upper left corner of button
    .setSize(450, 50) //size (width, height)
    .hide();

  //WEC Seastate Sliders 

  sigHWEC = cp5.addSlider("WEC Significant Tau")  //name of button
    .setRange(0, 5)
    .setFont(sliderFont)
    .setPosition(sliderX, sliderY) //x and y coordinates of upper left corner of button
    .setSize(450, 50) //size (width, height)
    .hide();

  peakFWEC = cp5.addSlider("WEC Peak Frequency (Hz)")  //name of button
    .setRange(0, 0.5)
    .setFont(sliderFont)
    .setPosition(sliderX, sliderY + 100) //x and y coordinates of upper left corner of button
    .setSize(450, 50) //size (width, height)
    .hide();

  gammaWEC = cp5.addSlider("WEC Peakedness)")  //name of button
    .setRange(0, 0.5)
    .setFont(sliderFont)
    .setPosition(sliderX, sliderY + 200) //x and y coordinates of upper left corner of button
    .setSize(450, 50) //size (width, height)
    .hide();

  //slider default values:    //only non zeros need to be set
  h.setValue(5);
  freq.setValue(1.0);
  sigH.setValue(2.5);
  peakF.setValue(3.0);
  gamma.setValue(7.0);

  sigHWEC.setValue(2.5);
  peakFWEC.setValue(0.3);
  gammaWEC.setValue(0.3);

  waveText = cp5.addTextarea("Wave Infromation")
    .setPosition(275, 150)
    .setSize(550, 400)
    .setFont(createFont("arial", 16))
    .setLineHeight(14)
    .setColor(turq)
    .setColorBackground(buttonblue)
    .setColorForeground(color(255, 100))
    .setText("At vero eos et: accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas. Molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat.")
    .hide()
    ;


  wecText = cp5.addTextarea("WEC Infromation")
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
  waveChart =  cp5.addChart("Wave Information")
    .setFont(sliderFont)
    .setPosition(830, 540)
    .setSize(500, 175)
    .setRange(-10, 10)
    .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
    .setStrokeWeight(10)
    .setColorCaptionLabel(color(40))
    .setColorBackground(turq)
    .setColorLabel(green)
    ;
  waveChart.addDataSet("debug");
  waveChart.setData("debug", new float[360]);

  wecChart =  cp5.addChart("WEC Information")
    .setFont(sliderFont)
    .setPosition(830, 795)
    .setSize(500, 175)
    .setRange(-10, 10)
    .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
    .setStrokeWeight(10)
    .setColorCaptionLabel(color(40))
    .setColorBackground(turq)
    .setColorLabel(green)
    ;


  snlLogo = loadImage("SNL_Stacked_White.png");
  wavePic = loadImage("ocean.jpg");


  //console, this needs to be in the setup to ensure
  //that it catches any errors when program starts
  consoleOutput=cp5.addTextarea("consoleOutput")
    .setPosition(1460, 710) 
    .setSize(330, 300)
    .setLineHeight(14)
    .setColorValue(green) //color of font
    // .setColorBackground(color(100,100))
    // .setColorForeground(color(255,100))
    .scroll(1) //enable scrolling up and down
    .hide(); //hidden on startup   
  if (!debug && guiConsole)      //only does in GUI console if not debugging
  {
    console = cp5.addConsole(consoleOutput);
  }


  myTextarea = cp5.addTextarea("txtBanner")
    .setPosition(width/6, height/45)
    .setText("Sandia Interactive Wave Energy Educational Display (SIWEED)")
    .setSize(1200, 90)
    .setFont(titleTextBoxFont)
    .setLineHeight(14)
    .setColor(color(green)) ;
  //.setColorBackground(color(255,100));
  //.setColorForeground(color(255,100));

  myTextarea = cp5.addTextarea("txtWelcome")
    .setText(welcome)
    .setPosition(810, 250)
    .setSize(500, 300)
    .setFont(textBoxFont)
    .setLineHeight(29)
    .setColor(color(white)); // need to find the correct color for this
  //.setColorBackground(color(255,100))
  //.setColorForeground(color(255,100));

  myTextarea = cp5.addTextarea("txtSystemStatus")
    .setPosition(795, 155)
    .setText("System Status")
    .setSize(225, 75)
    .setFont(headerTextBoxFont)
    .setLineHeight(7)
    .setColor(color(buttonblue)); // need to find the correct color for this
  // .setColorBackground(color(255,100))
  //  .setColorForeground(color(255,100));

  myTextarea = cp5.addTextarea("txtWaveDimensions")
    .setPosition(45, 220)
    .setText("Change Wave Dimensions")
    .setSize(300, 40)
    .setFont(textBoxFont)
    .setLineHeight(10)
    .setColor(color(white)); // need to find the correct color for this
  //.setColorBackground(color(255,100))
  //.setColorForeground(color(255,100));             

  myTextarea = cp5.addTextarea("txtWECControls")
    .setPosition(45, 620)
    .setText("Change WEC Controls")
    .setSize(300, 40)
    .setFont(textBoxFont)
    .setLineHeight(10)
    .setColor(color(white)); // need to find the correct color for this
  //.setColorBackground(color(255,100))
  //.setColorForeground(color(255,100));     

  myTextarea = cp5.addTextarea("txtMissionControl")
    .setPosition(35, 155)
    .setText("Mission Control")
    .setSize(225, 75)
    .setFont(headerTextBoxFont)
    .setLineHeight(7)
    .setColor(color(buttonblue)) ;// need to find the correct color for this
  // .setColorBackground(color(255,100));
  //.setColorForeground(color(255,100)); 

  image(wavePic, 0, 0, width, height); //background
  fill(buttonblue); //top banner 
  stroke(buttonblue); //not sure
  strokeWeight(0);
  rect(0, 1120, width, 80); //bottom banner
  image(snlLogo, width-snlLogo.width*0.25-5, height-snlLogo.height*0.25-5, snlLogo.width*0.25, snlLogo.height*0.25); //Logo
  rect(0, 0, width, 95); // Top Banner

  text(fundingState, width/2, 1150);  
  //Mission Control
  fill(turq, 150); //makes the mission control box transparrent 
  stroke(buttonblue, 150);
  strokeWeight(3);
  rect(25, 150, 705, 930, 7); // background for Mission control blue box

  fill(green);
  stroke(buttonblue); //outer color
  rect(15, 130, 225, 75, 7); //Mission Control Title Box 
  //Mission Control Text

  // System Status
  fill(turq, 150);
  stroke(buttonblue, 150);
  rect(780, 150, 1115, 930, 7); // background
  fill(green);
  stroke(buttonblue);
  rect(770, 130, 225, 75, 7); //system title
  fill(buttonblue);
  rect(1387, 185, 480, 400, 7); //power box
  rect(805, 225, 550, 225, 7); // explainer box
  rect(805, 475, 550, 575, 7); //graph background
  rect(1387, 610, 480, 440, 7); //FFT background 

  fill(255, 255, 255);
}
//button functions:
/////////////////// MAKES BUTTONS DO THINGS ////////////////////////////////////

// Console Button
void consoleButton() {
  consoleButton.setColorBackground(hoverblue);

  if (consoleOutput.isVisible()) {
    consoleOutput.hide();
  } else {
    consoleOutput.show();
  }
}

// Motor Buttons 

void jog() {
  jog.setColorBackground(hoverblue);
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
  if (megaConnected) {
    port1.write('!');
    sendFloat(0, port1);
  }
}

void fun() {
  jog.setColorBackground(buttonblue);
  function.setColorBackground(hoverblue);
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
  if (megaConnected) {
    port1.write('!');
    sendFloat(1, port1);
  }
}

void sea() {
  jog.setColorBackground(buttonblue);
  function.setColorBackground(buttonblue);
  sea.setColorBackground(hoverblue);
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
  if (megaConnected) {
    port1.write('!');
    sendFloat(2, port1);
  }
}

void off() {
  jog.setColorBackground(buttonblue);
  function.setColorBackground(buttonblue);
  sea.setColorBackground(buttonblue);
  off.setColorBackground(hoverblue);
  waveMaker.mode = 4;
  h.hide();
  freq.hide();
  h.hide();
  position.hide();
  sigH.hide();
  peakF.hide();
  gamma.hide();
  //set mode on arduino:
  if (megaConnected) {
    port1.write('!');
    sendFloat(-1, port1);
  }
}

// WEC Buttons 

void torque() {
  torque.setColorBackground(hoverblue);
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
  if (dueConnected) {
    port2.write('!');
    sendFloat(0, port2);
  }
}   

void feedback() {
  torque.setColorBackground(buttonblue);
  feedback.setColorBackground(hoverblue);
  seaWEC.setColorBackground(buttonblue);
  offWEC.setColorBackground(buttonblue);
  wec.mode = 2; 
  torqueSlider.hide();
  pGain.show();
  dGain.show();
  sigHWEC.hide();
  peakFWEC.hide();
  gammaWEC.hide();
  if (dueConnected) {
    port2.write('!');
    sendFloat(1, port2);
  }
}

// Slider pGain, dGain, torqueSlider, sigHWEC, peakFWEC, gammaWEC; 
//torque, feedback, seaWEC, offWEC 


void seaWEC() {
  torque.setColorBackground(buttonblue);
  feedback.setColorBackground(buttonblue);
  seaWEC.setColorBackground(hoverblue);
  offWEC.setColorBackground(buttonblue);
  wec.mode = 3; 
  torqueSlider.hide();
  pGain.hide();
  dGain.hide();
  sigHWEC.show();
  peakFWEC.show();
  gammaWEC.show();
  if (dueConnected) {
    port2.write('!');
    sendFloat(2, port2);
  }
  //////////Ideally this does not need to be sent here, but the redundancy improves reliability:
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

void offWEC() {
  torque.setColorBackground(buttonblue);
  feedback.setColorBackground(buttonblue);
  seaWEC.setColorBackground(buttonblue);
  offWEC.setColorBackground(hoverblue);
  wec.mode = 4; 
  torqueSlider.hide();    //hides all sliders
  pGain.hide();
  dGain.hide();
  sigHWEC.hide();
  peakFWEC.hide();
  gammaWEC.hide();
  if (dueConnected) {
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

//Button wavePosData, waveElData, wecPosData, wecVelData, wecTorqData, wecPowData;

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
float FFTHeight = 250;    //height of y axis coordinates. Does not scale data
int yAxisCount = 10;    //how many numbers on the y axis
float FFTXOffset = 10, FFTYOffset = 10;
void drawFFT() {
  int nyquist = (int)frameRate/2;    //sampling frequency/2 NOTE: framerate is not a constant variable
  textSize(10);
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
  image(wavePic, 0, 0, width, height); //background
  fill(buttonblue); //top banner 
  stroke(buttonblue); //not sure
  strokeWeight(0);
  rect(0, 1120, width, 80); //bottom banner
  image(snlLogo, width-snlLogo.width*0.25-5, height-snlLogo.height*0.25-5, snlLogo.width*0.25, snlLogo.height*0.25); //Logo
  rect(0, 0, width, 95); // Top Banner

  text(fundingState, width/2, 1150);  
  //Mission Control
  fill(turq, 150); //makes the mission control box transparrent 
  stroke(buttonblue, 150);
  strokeWeight(3);
  rect(25, 150, 705, 930, 7); // background for Mission control blue box

  fill(green);
  stroke(buttonblue); //outer color
  rect(15, 130, 225, 75, 7); //Mission Control Title Box 
  //Mission Control Text

  // System Status
  fill(turq, 150);
  stroke(buttonblue, 150);
  rect(780, 150, 1115, 930, 7); // background
  fill(green);
  stroke(buttonblue);
  rect(770, 130, 225, 75, 7); //system title
  fill(buttonblue);
  rect(1387, 185, 480, 400, 7); //power box
  rect(805, 225, 550, 225, 7); // explainer box
  rect(805, 475, 550, 575, 7); //graph background
  rect(1387, 610, 480, 440, 7); //FFT background 

  fill(255, 255, 255);
}
