import controlP5.*;
// import processing.serial.*;
// import java.text.SimpleDateFormat;
// import java.util.Date;
// import java.io.File; 

// Custom colors
color green = color(190,214,48);
color turq = color(0,173,208);
color dblue = color(0,83,118);

ControlP5 cp5;

// Fonts
PFont f; // Regular font
PFont fb; // Bold font

// Sandia logo
PImage snlLogo;

float gr;
float vdiv;

Slider slider_kp;
float Kp = 0;

void setup() {

	gr = 1.61803398875;  // golden ratio
	vdiv = width/pow(gr,2);

	// int[] scrnSz = {1920, 1280}; // Dell's resolution
  size(1000, 800);
  // fullScreen();

  // Fonts
  f = createFont("Arial",16,true);
  fb = createFont("Arial-BoldItalicMT",32,true);

  // Background color
  background(dblue);

  // Title
  textFont(fb,16);
  fill(green);
  textLeading(15);
  textAlign(CENTER, TOP);
  text("CAPTURING the POWER\nof WAVES",100,5);

  // Sandia Labs logo
  snlLogo = loadImage("SNL_Stacked_White.png");
  tint(255, 126);  // Apply transparency without changing color
  image(snlLogo, 5, height-snlLogo.height*0.25-5, snlLogo.width*0.25, snlLogo.height*0.25);

  stroke(green);
  line(vdiv,0+5,vdiv,height-5);

  rectMode(CENTER);
  fill(turq);
  noStroke();
  rect(vdiv+width/gr/2, height/4, (vdiv+width/gr/2)/gr, height/pow(gr,2));

  rectMode(CENTER);
  fill(turq);
  noStroke();
  rect(vdiv+width/gr/2, 3*height/4, (vdiv+width/gr/2)/gr, height/pow(gr,2));


  cp5 = new ControlP5(this);

  slider_kp = cp5.addSlider("Kp")
  .setPosition(100,305)
  .setSize(200,20)
  .setRange(0,5)
  .setNumberOfTickMarks(5)
  .snapToTickMarks(false)
  .setValue(128)
  ;

  slider_kp = cp5.addSlider("Ki")
  .setPosition(100,405)
  .setSize(200,20)
  .setRange(0,5)
  .setNumberOfTickMarks(5)
  .snapToTickMarks(false)
  .setValue(128)
  ;

  ButtonBar b = cp5.addButtonBar("Wave maker mode")
  .setPosition(100, 205)
  .setSize(200, 20)
  .addItems(split("a b c d"," "))
  .setColorCaptionLabel(green)
  ;
  b.changeItem("a","text","Off");
  b.changeItem("b","text","Jog");
  b.changeItem("c","text","Regular");
  b.changeItem("d","text","JONSWAP");
}

void draw() {

}

