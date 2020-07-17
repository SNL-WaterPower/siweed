import at.mukprojects.console.*;

Console console;

boolean showConsole;

void setup() {
  size(500, 400);

  smooth();
  frameRate(1);

  // Initialize the console 
  console = new Console(this);
  
  // Start the console
  console.start();
  
  console.setTimestamp(true);
  console.setAutoPrint(true);
  console.setCutMove(true);
  
  showConsole = true;
}

void draw() {
  background(200);

  println("Frame: " + frameCount);
  
  // Draw the console to the screen.
  console.draw();
}

void mousePressed() {
  if (mouseButton == LEFT) {
    
    // Starts the console again.
    console.start();
    
    showConsole = true;
  } else if (mouseButton == RIGHT) {
    
    // Stops the console
    console.stop();
    
    showConsole = false;
  }
}