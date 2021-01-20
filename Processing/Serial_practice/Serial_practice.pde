import processing.serial.*;
void setup() {
  frameRate(30);
  float testFloat = 123.456789;
  byte[] byteArray = floatToByteArray(testFloat);
  //println(byteArray);
  float resultFloat = byteArrayToFloat(byteArray);
  if (testFloat == resultFloat) {
    println("Byte Conversion Test PASSED");
  } else {
    println("Byte Conversion Test FAILED");
  }
}
boolean initialized = false;
int min = 0, max = 5;
void draw() {
  if (!initialized) {
    initializeSerial();    //has a 2 second delay
    initialized = true;
  }
  if (initialized) {
    thread("readMegaSerial");    //will run this funciton in parallel thread
    //this code updates what number is being sent every 5 seconds. 0, then 5, then 10, etc.
    if (millis() > min *1000 && millis() < max*1000) {
      println(min);
      port1.write('1');
      sendFloat(10-min, port1);
      port1.write('2');
      sendFloat(10-min, port1);
      port1.write('p');
      sendFloat(10-min, port1);
      port1.write('d');
      sendFloat(min, port1);
    } else {
      println("witch");
      min = max;
      max +=5;
    }
  }
}
