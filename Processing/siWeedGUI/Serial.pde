Serial port1;    //arduino mega
Serial port2;    //arduino Due
void initializeSerial() {
  ///////////initialize Serial
  port1 = new Serial(this, "COM4", 500000); // all communication with Megas
  port2 = new Serial(this, "COM5", 500000); // all communication with Due
  delay(2000);
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
   n indicates length of vectors/number of functions in sea state(starting at 1)
   a indicates incoming amp vector
   p indicates incoming phase vector
   f indicates incoming frequency vector
   
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
  while (port1.available() > 0) {    //recieves until buffer is empty. Since it runs 30 times a second, the arduino will send many samples per execution.
    switch(port1.readChar()) {
    case '1':
      probe1 = readFloat(port1);
      break;
    case '2':
      probe2 = readFloat(port1);
      break;
    case 'p':
      waveMakerPos = readFloat(port1);
      break;
    case 'd':
      debugData = readFloat(port1);
      
      waveSig.push("incoming", debugData);
      if (waveMaker.mode == 3||waveMaker.mode == 2) fftList.add(debugData);      //adds to the tail if in the right mode
      if (fftList.size() > queueSize)
      {
        fftList.remove();          //removes from the head
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
   */
  while (port2.available() > 0)
  {
    switch(port2.readChar()) {
    case 'e':
      wecPos = readFloat(port2);
      break;
    case 't':
      tau = readFloat(port2);
      break;
    case 'p':
      pow = readFloat(port2);
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
