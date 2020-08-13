Serial port1;    //arduino mega
Serial port2;    //arduino Due
boolean serialConnected;
void initializeSerial() {
  ///////////initialize Serial

  //mac serial com
  printArray(Serial.list()); 
  try {
    port1 = new Serial(this, Serial.list()[1], 500000); // all communication with Megas
    port2 = new Serial(this, Serial.list()[2], 250000); // all communication with Due
    delay(2000);
    serialConnected = true;
    //initialize the modes on the arduinos:
    port1.write('!');
    sendFloat(0, port1);    //jog mode
    port1.write('j');
    sendFloat(0, port1);    //at position 0

    port2.write('!');
    sendFloat(-1, port2);    //off
  }
  catch(Exception e) {
    serialConnected = false;
  }
}
void sendFloat(float f, Serial port)
{
  /* 
   For mega:
  /* '!' indicates mode switch, next int is mode
   j indicates jog position
   a indicates incoming amplitude
   f indicates incoming frequency
   s :sigH
   p :peakF
   g :gamma
   
   For Due:
   '!' indicates mode switch, next int is mode
   t indicates torque command
   k indicates kp -p was taken
   d indicates kd
   s :sigH
   p :peakF
   g :gamma
   
   EDIT: numbers are now in this format:  p1234>  has a scalar of 100, so no decimal, and no start char
   */
  int i = (int)(f*100);    //convert to int(so decimal place does not need to be sent)
  String posStr = "";    //starts the string
  if (f >= 0) {
    posStr = posStr.concat("+");
  } else {
    posStr = posStr.concat("-");
  }
  posStr = posStr.concat(Integer.toString(abs(i)));
  posStr = posStr.concat(">");    //end of string "keychar"
  port.write(posStr);
  //println(posStr);
}
void readMegaSerial() {
  /*
  mega:
   1:probe 1
   2:probe 2
   p:position
   d:other data for debugging
   */
  while (serialConnected && port1.available() > 0) {    //recieves until buffer is empty. Since it runs 30 times a second, the arduino will send many samples per execution.
    switch(port1.readChar()) {
    case '1':
      probe1 = readFloat(port1);
      if (waveElClicked == true) {
        waveChart.push("waveElevation", probe1);
      }
      break;
    case '2':
      probe2 = readFloat(port1);
      break;
    case 'p':
      waveMakerPos = readFloat(port1);
      break;
    case 'd':
      megaUnitTests[0] = true;      //for unit testing;
      debugData = readFloat(port1);
      if (wavePosClicked == true) {
        waveChart.push("waveMakerPosition", debugData);
      }
      if (waveMaker.mode == 3||waveMaker.mode == 2) fftList.add(debugData);      //adds to the tail if in the right mode
      if (fftList.size() > queueSize)
      {
        fftList.remove();          //removes from the head
      }
      break;
    case 'u':
      int testNum = (int)readFloat(port1);    //indicates which jonswap test passed(1 or 2). Negative means that test failed.
      if (testNum > 0) {    //only changes if test was passed
        megaUnitTests[testNum] = true;
      }
      break;
    }
  }
}
void readDueSerial() {
  /*
  Due:
   e: encoder position
   t: tau commanded to motor
   p: power
   v: velocity
   */
  while (serialConnected && port2.available() > 0)
  {
    switch(port2.readChar()) {
    case 'e':
      wecPos = readFloat(port2);
      //wec data
      if (wecPosClicked == true) {
        wecChart.push("wecPosition", wecPos);
      }
      break;
    case 't':
      tau = readFloat(port2);
      if (wecTorqClicked == true) {
        wecChart.push("wecTorque", tau);
      }
      break;
    case 'p':
      dueUnitTests[0] = true;
      pow = readFloat(port2);
      if (wecPowClicked == true) {
        wecChart.push("wecPower", pow);
      }
      break;
    case 'v':
      wecVel = readFloat(port2);
      if (wecVelClicked == true) {
        wecChart.push("wecVelocity", wecVel);
      }      
      break;
    case 'u':
      int testNum = (int)readFloat(port2);    //indicates which jonswap test passed(1 or 2)
      if (testNum > 0) {    //only changes if test was passed
        dueUnitTests[testNum] = true;
      }   
      break;
    }
  }
}
float readFloat(Serial port) {
  waitForSerial(port);
  String str = "";    //port.readStringUntil('>');
  do {
    waitForSerial(port);
    str += port.readChar();
  } while (str.charAt(str.length()-1) != '>');
  str = str.substring(0, str.length()-1);    //removes the '>'
  return float(str)/100.0;
}
void waitForSerial(Serial port) {
  while (port.available() < 1) {    //wait for port to not be empty
    delay(1);    //give serial some time to come through
  }
}
