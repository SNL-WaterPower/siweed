import at.mukprojects.console.*;

final int MODE_1 = 1;
final int MODE_2 = 2;
final int MODE_3 = 3;

Console console;

boolean showConsole;
int mode;

void setup() {
  size(800, 450);

  smooth();
  frameRate(1);

  // Initialize the console 
  console = new Console(this);

  // Start the console
  console.start();

  showConsole = true;
  mode = MODE_1;
}

void draw() {
  background(200);

  println("Frame: " + frameCount);

  println("Short Text: Lorem ipsum dolor sit amet");
  println("Long Text: Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod " +
    "tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo");

  switch(mode) {
  case MODE_1:
    // Draw the console to the screen.
    // (x, y, width, height)
    console.draw(100, 20, 600, 220);
    break;
  case MODE_2:
    // Draw the console to the screen.
    // (x, y, width, height, preferredTextSize, minTextSize)
    console.draw(0, height - 120, width, height, 14, 10);
    break;
  case MODE_3:
    // Draw the console to the screen. 
    // (x, y, width, height, preferredTextSize, minTextSize, linespace, padding, strokeColor, backgroundColor, textColor)
    console.draw(0, height - 120, width, height, 14, 10, 4, 4, color(220), color(0), color(0, 255, 0));
    break;
  default:
    // Draw the console to the screen. 
    // (default mode)
    console.draw();
  }
}

void mousePressed() {
  if (mouseButton == LEFT) {
    
    // Restarts the console.
    console.stop();
    console.start();
    
    showConsole = true;

    mode++;
    if (mode > MODE_3) {
      mode = MODE_1;
    }
  } else if (mouseButton == RIGHT) {
    
    // Stops the console.
    console.stop();
    
    showConsole = false;
  }
}