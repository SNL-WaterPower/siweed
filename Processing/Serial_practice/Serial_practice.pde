import processing.serial.*;
void setup() {
  
}
boolean initialized = false;
void draw() {
  if (!initialized) {
    initializeSerial();    //has a 2 second delay
    initialized = true;
  }
  if (initialized) {
    thread("readMegaSerial");    //will run this funciton in parallel thread
  }
}
