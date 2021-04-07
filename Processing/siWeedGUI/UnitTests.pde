int onboardTestDelay = 200;    //ms to wait for arduino to send unit tests
boolean[] megaUnitTests = {false, false, false, false, false};      //serial, jonswap amplitude array, jonswap timeSeries, encoder buffer, unit tests recieved
boolean[] dueUnitTests = {false, false, false, false, false};
void unitTests() {
  /////////////FFT:
  for (int i = 0; i < queueSize; i++) {
    float sinVal = 5.0 * sin(2.0*PI*(float)i/16);
    fftList.add(sinVal);
  }
  updateFFT();
  boolean pass = true;
  for (int i = 0; i < queueSize/2; i++) {
    float f = fftArr[i];
    if ((i == queueSize/16 && f == 2.5) || f < 1e-5) {
      //test passes
    } else {
      pass = false;
      break;
    }
  }
  while (fftList.size() > 0)    //empty list
  {
    fftList.remove();          //removes from the head
  }
  if (pass) {
    println("FFT Test PASSED");
  } else {
    println("FFT Test FAILED");
  }
  ////////////////////Byte conversions:
  float testFloat = 123.456789;
  byte[] byteArray = floatToByteArray(testFloat);
  //println(byteArray);
  float resultFloat = byteArrayToFloat(byteArray);
  if (testFloat == resultFloat) {
    println("Byte Conversion Test PASSED");
  } else {
    println("Byte Conversion Test FAILED");
  }
  /////////////verify mega serial:    //maybe change method to : send value -> recieve value
  readMegaSerial();    //reads serial buffer and sets bool true if recieving normal results
  if (megaUnitTests[0]) {
    println("Mega Serial Test PASSED");
  } else {
    println("Mega Serial Test FAILED");
  }
  ////////////verify due serial:
  readDueSerial();    //reads serial buffer and sets bool true if recieving normal results
  if (dueUnitTests[0]) {
    println("Due Serial Test PASSED");
  } else {
    println("Due Serial Test FAILED");
  }
  ////////////verify mega on board unit tests:
  if (megaConnected) { 
    port1.clear();    //clear buffer
    port1.write('u');    //sends to begin test
    sendFloat(1.0, port1);    //flips to unit test serial mode
    delay(onboardTestDelay);    //time for arduino to send tests
    for (int i = 0; i < 10 && !megaUnitTests[4]; i++) {   //tries i times or until the confimation flag is recieved
      readMegaSerial();
      if (debug) {
        println("retrieving mega unit tests");
      }
      if (i == 5) {    //if failed after 5 tries, send command again.
        port1.clear();    //clear buffer
        port1.write('u');    //sends to begin test
        sendFloat(1.0, port1);    //flips to unit test serial mode
        delay(onboardTestDelay);    //time for arduino to send tests
        if (debug) {
          println("did not recieve mega unit tests, sending new request");
        }
      }
    }
    if (debug && megaUnitTests[4]) {
      println("mega unit tests recieved");
    } else if (debug) {
      println("mega unit tests timed out");
    }
    megaUnitTests[0] = false;
    for (int i = 0; i < 10 && !megaUnitTests[0]; i++) {    //tries i times or until back to normal operation.
      port1.clear();
      port1.write('u'); 
      sendFloat(0, port1);    //back to normal operation
      delay(onboardTestDelay);
      megaUnitTests[0] = false;
      readMegaSerial();
      if (debug){
        println("testing if mega returned to normal operation");
      }
    }
    if(!megaUnitTests[0]){
      println("Mega failed to exit Unit Testing mode");
    }
  }
  if (!megaConnected) {
  } else if (megaUnitTests[4]) {    //if the tests were recived correctly
    if (megaUnitTests[1]) {
      println("Mega Jonswap Amplitide Test PASSED");
    } else {    
      println("Mega Jonswap Amplitude Test FAILED");
    }
    if (megaUnitTests[2]) {
      println("Mega Jonswap TimeSeries Test PASSED");
    } else {    
      println("Mega Jonswap TimeSeries Test FAILED");
    }
    if (megaUnitTests[3]) {
      println("Mega Encoder Buffer Test PASSED");
    } else {    
      println("Mega Encoder Buffer Test FAILED");
    }
  } else {          //if the tests were not recieved correctly
    println("Mega On-Board Units Tests FAILED");
  }
  ////////////verify due on board unit tests:
  if (dueConnected) {
    port2.clear();    //clear buffer
    port2.write('u');    //sends to begin test
    sendFloat(1.0, port2);    //flips to unit test serial mode
    delay(onboardTestDelay);    //time for arduino to send tests
    for (int i = 0; i < 10 && !dueUnitTests[4]; i++)    //tries i times or until the confimation flag is recieved
    {
      readDueSerial();      
      if (debug) {
        println("retrieving due unit tests");
      }
      if (i == 5) {    //if failed after 5 tries, send command again.
        port2.clear();    //clear buffer
        port2.write('u');    //sends to begin test
        sendFloat(1.0, port2);    //flips to unit test serial mode
        delay(onboardTestDelay);    //time for arduino to send tests
        if (debug) {
          println("did not recieve due unit tests, sending new request");
        }
      }
    }
    if (debug && dueUnitTests[4]) {
      println("due unit tests recieved");
    } else if (debug) {
      println("due unit tests timed out");
    }
    dueUnitTests[0] = false;
    for (int i = 0; i < 10 && !dueUnitTests[0]; i++) {    //tries i times or until back to normal operation.
      port2.clear();
      port2.write('u');
      sendFloat(0, port2);    //back to normal operation
      delay(onboardTestDelay);
      dueUnitTests[0] = false;
      readDueSerial();
      if (debug){
        println("testing if Due returned to normal operation");
      }
    }
    if(dueUnitTests[0] == false){
      println("Due failed to exit Unit Testing mode");
    }
  }
  if (!dueConnected) {
  } else if (dueUnitTests[4]) {
    if (dueUnitTests[1]) {
      println("Due Jonswap Amplitide Test PASSED");
    } else {    
      println("Due Jonswap Amplitude Test FAILED");
    }
    if (dueUnitTests[2]) {
      println("Due Jonswap TimeSeries Test PASSED");
    } else {    
      println("Due Jonswap TimeSeries Test FAILED");
    }
    if (dueUnitTests[3]) {
      println("Due Encoder Buffer Test PASSED");
    } else {    
      println("Due Encoder Buffer Test FAILED");
    }
  } else {    
    println("Due On-Board Units Tests FAILED");
  }
}
