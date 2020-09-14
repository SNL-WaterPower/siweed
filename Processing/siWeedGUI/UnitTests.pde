boolean[] megaUnitTests = {false, false, false};      //serial, jonswap amplitude array, jonswap timeSeries
boolean[] dueUnitTests = {false, false, false};
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
  ////////////verify mega jonswap:
  readMegaSerial();    //clear buffer
  if (dueConnected) {
    port2.write('u');    //sends to begin test
    sendFloat(0, port2);    //placeholder float to maintain format of letter>number
  }
  delay(100);          //give time to complete
  readMegaSerial();
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
  ////////////verify due jonswap:
  readDueSerial();    //clear buffer
  if (dueConnected) {
    port2.write('u');    //sends to begin test
    sendFloat(0, port1);    //placeholder float to maintain format of letter>number
  }
  delay(100);          //give time to complete
  readDueSerial();
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
}
