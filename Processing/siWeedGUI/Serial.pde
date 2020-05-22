void initializeSerial() {
  ///////////initialize Serial
  port1 = new Serial(this, "COM4", 1000000); // all communication with Megas
  port2 = new Serial(this, "COM5", 500000); // all communication with Due
  delay(2000);
}
void sendFloat(float f, Serial port)
{
  /* 
   For mega:
   '!' indicates mode switch
   j indicates jog position
   
   n indicates length of vectors/number of functions in sea state(starting at 1)
   a indicates incoming amp vector
   p indicates incoming phase vector
   f indicates incoming frequency vector
   
   ex:  !<1>n<2>a<1.35><2.36>p<1.35><2.36>f<1.35><2.36>    
   
   with this function sending data will look something like this:
   if(values have changed)    //or run certain lines on a button press
   port1.write('!');    set mode(only needs to be done when switching)
   sendFloat(1);
   
   port1.write('n');    set number of components(only needs to be done once)
   sendFloat(30);        
   
   port1.write('a');
   sendFloat(2.3);
   sendFloat(1.2);
   .
   .
   .
   .
   //needs to send n number of floats
   
   For Due:
   '!' indicates mode switch, next int is mode
   t indicates torque command
   k indicates kp -p was taken
   d indicates kd
   n indicates length of vectors/number of functions in sea state(starting at 1)
   a indicates incoming amp vector
   p indicates incoming phase vector
   f indicates incoming frequency vector
   */
  f= Math.round(f*100.0)/100.0;    //limits to two decimal places
  String posStr = "<";    //starts the string
  posStr = posStr.concat(Float.toString(f));
  posStr = posStr.concat(">");    //end of string "keychar"
  readMegaSerial();    //called right before sending to clear the incoming buffer
  port.write(posStr);

  waitForSerial(port);
  println(port.readChar());    //clears confirmation '*'
  //for testing:
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
      fftQueue.add(debugData);      //adds to the tail
      if(fftQueue.size() > queueSize)
      {
        fftQueue.remove();          //removes from the head
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
  if (port.readChar() == '<') {
    String str = "";    //port.readStringUntil('>');
    do {
      waitForSerial(port);
      str += port.readChar();
    } while (str.charAt(str.length()-1) != '>');
    str = str.substring(0, str.length()-1);    //removes the '>'
    return float(str);
  } else {
    return -1.0;
  }
}
void waitForSerial(Serial port) {
  while (port.available() < 1) {    //wait for port to not be empty
    delay(1);    //give serial some time to come through
  }
}
