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
  powerX = int(width/3.5 + 50);
//  powerY = 500; // commented in my version not commented in seans 

  quad1 = cp5.addButton("quad1")
    .setPosition(powerX, 1115)
    .setColorBackground(grey)
    .setSize(125, 50)
    .setLabel("25%");  

  quad2 = cp5.addButton("quad2")
    .setPosition(powerX + 125, 1115)
    .setColorBackground(grey)
    .setSize(125, 50)
    .setLabel("50%"); 

  quad3 = cp5.addButton("quad3")
    .setPosition(powerX + 250, 1115)
    .setColorBackground(grey)
    .setSize(125, 50)
    .setLabel("75%"); 

  quad4 = cp5.addButton("quad4")
    .setPosition(powerX + 375, 1115)
    .setColorBackground(grey)
    .setSize(125, 50)
    .setLabel("100%");


/*  
 int qX, qY;
 qX = 300;
 qY = 210;

  waveQs = cp5.addButton("waveQs")
    .setPosition(qX, qY)
    .setSize(15, 15)
    .setLabel("?");

  wecQs = cp5.addButton("wecQs")
    .setPosition(qX - 35, qY + 400)
    .setSize(15, 15)
    .setLabel("?");
*/    

 // wave maker buttons //
  int buttonX, buttonY;
  buttonX = int(width/3.5 + 50); //converts float to int
  buttonY = 120;
  
  jog = cp5.addButton("jog")
    .setPosition(buttonX, buttonY)
    .setSize(150, 65)
    .setLabel("Jog Mode")
    .setFont(buttonFont );

  function = cp5.addButton("fun")
    .setPosition(buttonX + 150, buttonY)
    .setSize(150, 65)
    .setLabel("Function Mode")
    .setFont(buttonFont); 

  sea = cp5.addButton("sea")
    .setPosition(buttonX + 300, buttonY)
    .setSize(150, 65)
    .setLabel("Sea State")
    .setFont(buttonFont); 

  off = cp5.addButton("off")
    .setPosition(buttonX + 450, buttonY)
    .setSize(150, 65)
    .setLabel("OFF")
    .setFont(buttonFont); 

 buttonX = int((width/3.5 + 4*(150) + 100));  

  torque = cp5.addButton("torque")
    .setPosition(buttonX, buttonY)
    .setSize(150, 65)
    .setLabel("Torque")
    .setFont(buttonFont);   

  feedback = cp5.addButton("feedback")
    .setPosition(buttonX + 150, buttonY)
    .setSize(150, 65)
    .setLabel("Feedback")
    .setFont(buttonFont); 


  seaWEC = cp5.addButton("seaWEC")
    .setPosition(buttonX + 300, buttonY)
    .setSize(150, 65)
    .setLabel("Sea State")
    .setFont(buttonFont);    

  offWEC = cp5.addButton("offWEC")
    .setPosition(buttonX + 450, buttonY)
    .setSize(150, 65)
    .setLabel("Off")
    .setFont(buttonFont);
    
// Data buttons //     
//Button wavePosData, waveElData, wecPosData, wecVelData, wecTorqData, wecPowData;
int dataButtonX, dataButtonY;
dataButtonX = int(width/3.5);
dataButtonY = 750;

wavePosData = cp5.addButton("wavePosData")
    .setPosition(dataButtonX + 50, 750)
    .setColorBackground(grey)
    .setSize(250, 50)
    .setLabel("Wave Maker\nPosition")
    .setFont(buttonFont); 

waveElData = cp5.addButton("waveElData")
    .setPosition(dataButtonX + 300, 750)
    .setColorBackground(grey)
    .setSize(250, 50)
    .setLabel("Wave\nElevation")
    .setFont(buttonFont); 
   

wecPosData = cp5.addButton("wecPosData")
    .setPosition((dataButtonX + 700), dataButtonY)
    .setColorBackground(grey)
    .setSize(125, 50)
    .setLabel("Wec Position")
    .setFont(buttonFont); 
    
wecVelData = cp5.addButton("wecVelData")
    .setPosition((dataButtonX + 825), dataButtonY)
    .setColorBackground(grey)
    .setSize(125, 50)
    .setLabel("WEC Velocity")
    .setFont(buttonFont);

wecTorqData = cp5.addButton("wecTorqData")
    .setPosition((dataButtonX + 950), dataButtonY)
    .setColorBackground(grey)
    .setSize(125, 50)
    .setLabel("WEC Torque")
    .setFont(buttonFont);
    
wecPowData = cp5.addButton("wecPowData")
    .setPosition((dataButtonX + 1075), dataButtonY)
    .setColorBackground(grey)
    .setSize(125, 50)
    .setLabel("WEC Power")
    .setFont(buttonFont);
    

  // Sliders // 
  //distance between slider and buttons is 150, distance between each slider is 100

  int sliderX, sliderY;
  sliderX = int((width/3.5 + 50));
  sliderY = 200 ; // button Y lcation (240) + size of button + 50 

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
    .setRange(0, 50) //slider range
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

//  sliderY = buttonY + 65 + 50 ; //button y coordinate + button size + 50 (offset)

  // WEC Torque Sliders
  sliderX = int((width/3.5 + 4*(150) + 100));
  torqueSlider = cp5.addSlider("Torque")  //name of button
    //.setRange(-0.006, 0.006)      //max amps * torque constant. I think this will max amperage at max slider value
    .setRange(-6, 6)
    .setFont(sliderFont)
    .setPosition(sliderX, sliderY) //x and y coordinates of upper left corner of button
    .setSize(450, 50); //size (width, height)

  // WEC Feedback Sliders   
  pGain = cp5.addSlider("P Gain")  //name of button
    .setRange(-0.0006, 0.0006)    //user needs to be able to command negative //0.1(wave height in meters) * max torque(above)
    .setFont(sliderFont)
    .setPosition(sliderX, sliderY) //x and y coordinates of upper left corner of button
    .setSize(450, 50) //size (width, height)
    .hide();

  dGain = cp5.addSlider("D Gain")  //name of button
    .setRange(0, 0.0005)    //user needs to only command positive    //!!will find right values by measuring max vel
    .setFont(sliderFont)
    .setPosition(sliderX, sliderY + 100) //x and y coordinates of upper left corner of button
    .setSize(450, 50) //size (width, height)
    .hide();

  //WEC Seastate Sliders 

  sigHWEC = cp5.addSlider("WEC Significant Height (M)")  //name of button
    .setRange(0, 0.05)
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
    .setPosition((width/3.5) + 50, 550)
    .setSize(500, 200)
    .setFont(sliderFont)
//    .setRange(-10, 10) value delaney had 
    .setPosition(830, 540)
    .setSize(500, 175)
    .setRange(-0.10, 0.10) //new value from develop 
    .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
    .setStrokeWeight(10)
    .setColorCaptionLabel(color(40))
    .setColorBackground(buttonblue)
    .setColorLabel(green)
    ;
    
  waveChart.addDataSet("debug");
  waveChart.setData("debug", new float[360]);

  wecChart =  cp5.addChart("WEC Information")
    .setPosition((width/3.5 + 700), 550)
    .setSize(500, 200)
    .setFont(sliderFont)
    .setRange(-10, 10)
    .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
    .setStrokeWeight(10)
    .setColorCaptionLabel(color(40))
    .setColorBackground(buttonblue)
    .setColorLabel(green)
    ;

  h.setValue(5);
  freq.setValue(1.0);
  sigH.setValue(2.5);
  peakF.setValue(3.0);
  gamma.setValue(7.0);

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
    .setText("test of the text")
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
/*   
 wecChart.addDataSet("wecPosition");
 wecChart.setData("wecPosition", new float[360]); 
 
 wecChart.setData("wecVelocity", new float[360]);    //use to set the domain of the plot. This value is = desired domain(secnods) * 30
 wecChart.addDataSet("wecTorque");
 
 
 */

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
void drawFFT() {
  int nyquist = (int)frameRate/2;    //sampling frequency/2 NOTE: framerate is not a constant variable
  float initialX = 0;
  float yScale = 20000;
  textSize(10);
  fill(green);
  stroke(green);
  for (int i=0; i<=queueSize/2; i++) {      //cut in half
    float x = 1250+1.5*i;    //x coordinate
    float y = 1150;            //y coordinate
    if (i == 0) {
      initialX = x;
    }
    line(x, y, x, y - yScale*fftArr[i]);
    if (i%32 == 0) {        //should make 32 into a variable, but frameRate is not an int
      text((int)(i*(1/((float)queueSize/32))), x, y);    //x-axis: frequency spacing is 1/T, where t is length of sample in seconds
    }
    if (i%1 == 0 && i<=5) {
      text(i, initialX, y - 50*i);    //y-axis    //units need to be fixed
    }
  }
}
void displayUpdate() {

  // Background color
  background(dblue);
  //Title 
  textFont(fb, 40);
  fill(green);
  textLeading(15);
  textAlign(CENTER, TOP);
  
  image(wavePic, 0, 0, width, height); //background
  fill(buttonblue);
  stroke(buttonblue);
  strokeWeight(0);
  image(snlLogo, width-snlLogo.width*0.25-5, height-snlLogo.height*0.25-5, snlLogo.width*0.25, snlLogo.height*0.25); //Logo
  rect(0, 0, width/3.5, height); // LHS banner 
  fill(255,255,255);
  stroke(255,255,255);
  rect(width/3.5, 0, width, height/2.5); //mission control banner
  fill(turq);
  stroke(turq);
  rect(width/3.5, height/2.5, width, height); //mission control banner
  fill(green);
  text("SIWEED", (width/3.5)/2, 30);
  fill(255,255,255);
  textSize(12);
  textLeading(14);
  text(fundingState, (width/3.5)/2, 1125);
 
  //Mission Control
//  fill(turq, 150);
//  stroke(buttonblue, 150);
//  strokeWeight(3);
//  rect(25, 150, 705, 930, 7); // background
//  fill(green);
//  stroke(buttonblue);
//  rect(15, 130, 225, 75, 7); //Mission Control Title Box 
  //Mission Control Text
  textFont(fb, 25);
  fill(buttonblue);
  textLeading(15);
  textAlign(LEFT, TOP);
  text("Mission Control", (width/3.5 + 50), 30);
  
  // System Status
/*  fill(turq, 150);
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
  fill(255,255,255);
  textFont(fb, 20);
  text(welcome, 810, 250);
  //System Status Text */
  textFont(fb, 25);
  fill(buttonblue);
  textLeading(15);
  textAlign(LEFT, TOP);
  stroke(buttonblue);
  text("System Status", (width/3.5 + 50), (height/2.5 + 30));
  stroke(green); 
    
  textFont(fb, 20);
  fill(buttonblue);
  textLeading(15);
  textAlign(LEFT, TOP);
  text("Change Wave Dimensions", (width/3.5 + 50), 90);
  
  textFont(fb, 20); 
  fill(buttonblue);
  textLeading(15);
  textAlign(LEFT, TOP);
  text("Change WEC Controls", (width/3.5 + 700), 90);
}
