void setup(){
  
   size(1920,1200);
}

// Custom colors
color green = color(190, 214, 48);
color turq = color(0, 173, 208);
color dblue = color(0, 83, 118);
color buttonblue = color(0, 45, 90);
color hoverblue = color(0, 116, 217);

// Fonts

// Sandia logo
PImage snlLogo;
PImage wavePic;

PFont f; // Regular font
PFont fb; // Bold font



void draw(){
 fb = createFont("Arial Bold Italic", 32, true);
   // Background color
  background(dblue);
  //Title 
  textFont(fb, 32);
  fill(green);
  textLeading(15);
  textAlign(CENTER, TOP);
  // header image
  image(wavePic, 0, 0, width, 150);
  text("Sandia Interactive Wave Energy Educational Display", width/2, 50);
  
}
