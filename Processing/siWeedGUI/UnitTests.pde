int onboardTestDelay = 200;    //ms to wait for arduino to send unit tests
boolean[] WMUnitTests = {false, false, false, false, false};      //serial, jonswap amplitude array, jonswap timeSeries, encoder buffer, unit tests recieved
boolean[] WECUnitTests = {false, false, false, false, false};
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
  /////////////verify WM serial:    //maybe change method to : send value -> recieve value
  readWMSerial();    //reads serial buffer and sets bool true if recieving normal results
  if (WMUnitTests[0]) {
    println("WM Serial Test PASSED");
  } else {
    println("WM Serial Test FAILED");
  }
  ////////////verify WEC serial:
  readWECSerial();    //reads serial buffer and sets bool true if recieving normal results
  if (WECUnitTests[0]) {
    println("WEC Serial Test PASSED");
  } else {
    println("WEC Serial Test FAILED");
  }
  ////////////verify WM on board unit tests:
  if (WMConnected) { 
    port1.clear();    //clear buffer
    port1.write('u');    //sends to begin test
    sendFloat(1.0, port1);    //flips to unit test serial mode
    delay(onboardTestDelay);    //time for arduino to send tests
    for (int i = 0; i < 10 && !WMUnitTests[4]; i++) {   //tries i times or until the confimation flag is recieved
      readWMSerial();
      if (debug) {
        println("retrieving WM unit tests");
      }
      if (i == 5) {    //if failed after 5 tries, send command again.
        port1.clear();    //clear buffer
        port1.write('u');    //sends to begin test
        sendFloat(1.0, port1);    //flips to unit test serial mode
        delay(onboardTestDelay);    //time for arduino to send tests
        if (debug) {
          println("did not recieve WM unit tests, sending new request");
        }
      }
    }
    if (debug && WMUnitTests[4]) {
      println("WM unit tests recieved");
    } else if (debug) {
      println("WM unit tests timed out");
    }
    WMUnitTests[0] = false;
    for (int i = 0; i < 10 && !WMUnitTests[0]; i++) {    //tries i times or until back to normal operation.
      port1.clear();
      port1.write('u'); 
      sendFloat(0, port1);    //back to normal operation
      delay(onboardTestDelay);
      WMUnitTests[0] = false;
      readWMSerial();
      if (debug){
        println("testing if WM returned to normal operation");
      }
    }
    if(!WMUnitTests[0]){
      println("WM failed to exit Unit Testing mode");
    }
  }
  if (!WMConnected) {
  } else if (WMUnitTests[4]) {    //if the tests were recived correctly
    if (WMUnitTests[1]) {
      println("WM Jonswap Amplitide Test PASSED");
    } else {    
      println("WM Jonswap Amplitude Test FAILED");
    }
    if (WMUnitTests[2]) {
      println("WM Jonswap TimeSeries Test PASSED");
    } else {    
      println("WM Jonswap TimeSeries Test FAILED");
    }
    if (WMUnitTests[3]) {
      println("WM Encoder Buffer Test PASSED");
    } else {    
      println("WM Encoder Buffer Test FAILED");
    }
  } else {          //if the tests were not recieved correctly
    println("WM On-Board Units Tests FAILED");
  }
  ////////////verify WEC on board unit tests:
  if (WECConnected) {
    port2.clear();    //clear buffer
    port2.write('u');    //sends to begin test
    sendFloat(1.0, port2);    //flips to unit test serial mode
    delay(onboardTestDelay);    //time for arduino to send tests
    for (int i = 0; i < 10 && !WECUnitTests[4]; i++)    //tries i times or until the confimation flag is recieved
    {
      readWECSerial();      
      if (debug) {
        println("retrieving WEC unit tests");
      }
      if (i == 5) {    //if failed after 5 tries, send command again.
        port2.clear();    //clear buffer
        port2.write('u');    //sends to begin test
        sendFloat(1.0, port2);    //flips to unit test serial mode
        delay(onboardTestDelay);    //time for arduino to send tests
        if (debug) {
          println("did not recieve WEC unit tests, sending new request");
        }
      }
    }
    if (debug && WECUnitTests[4]) {
      println("WEC unit tests recieved");
    } else if (debug) {
      println("WEC unit tests timed out");
    }
    WECUnitTests[0] = false;
    for (int i = 0; i < 10 && !WECUnitTests[0]; i++) {    //tries i times or until back to normal operation.
      port2.clear();
      port2.write('u');
      sendFloat(0, port2);    //back to normal operation
      delay(onboardTestDelay);
      WECUnitTests[0] = false;
      readWECSerial();
      if (debug){
        println("testing if WEC returned to normal operation");
      }
    }
    if(WECUnitTests[0] == false){
      println("WEC failed to exit Unit Testing mode");
    }
  }
  if (!WECConnected) {
  } else if (WECUnitTests[4]) {
    if (WECUnitTests[1]) {
      println("WEC Jonswap Amplitide Test PASSED");
    } else {    
      println("WEC Jonswap Amplitude Test FAILED");
    }
    if (WECUnitTests[2]) {
      println("WEC Jonswap TimeSeries Test PASSED");
    } else {    
      println("WEC Jonswap TimeSeries Test FAILED");
    }
    if (WECUnitTests[3]) {
      println("WEC Encoder Buffer Test PASSED");
    } else {    
      println("WEC Encoder Buffer Test FAILED");
    }
  } else {    
    println("WEC On-Board Units Tests FAILED");
  }
}
