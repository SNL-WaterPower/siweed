const float interval = .01;   //time between each interupt call in seconds
const float serialInterval = .03125;   //time between each interupt call in seconds    .03125 is 32 times a second to match processing's speed(32hz)
const float deadzone = 0.0001;  //dead band in meters
bool dir = true;
volatile float futurePos;
volatile float sampleT = 0;  //timestamp in microseconds of sample
volatile float prevSampleT;  //previous timestamp in microseconds
volatile float prevVal;   //value of sample at prevSampleT
void initInterrupts() {
  //This could instead be done with the setFrequency() function, but the control loop uses the time interval,
  //so it's simpler to do this. Unit is microseconds
  Timer.getAvailable().attachInterrupt(sendSerial).start(serialInterval * 1.0e6);
  delay(50);
  Timer.getAvailable().attachInterrupt(controlLoop).start(interval * 1.0e6);
}
/*
  Motor control interupt:
  After calculating desired position with inputFnc(), this controller should estimate the command
  linearly, then apply a PID calculated error correction(not anymore). The sum is then converted from a velociy to
  a frequency.
*/
//volatile float error;
volatile float velCommand;
void controlLoop() {  //due version
  volatile float pos = encPos();
  //error = futurePos - pos;   //where we told it to go vs where it is
  ////////vars for linear interpolation:
  prevSampleT = sampleT;
  sampleT = micros();
  prevVal = futurePos;
  futurePos = inputFnc(t + interval);  //time plus delta time
  if (mode != 1 || abs(futurePos - pos) > deadzone) {    //deadband only if in jog mode.
    velCommand = ((futurePos - pos) / interval); //estimated desired velocity in m/s, in order to hit target by next interupt call
  } else {
    velCommand = 0;
  }
  //Serial.println(velCommand, 5);
  if (velCommand > 0) {
    digitalWrite(dirPin, HIGH);
  } else {
    digitalWrite(dirPin, LOW);
  }
  volatile float sp = speedScalar * abs(velCommand);     //steping is always positive, so convert to speed, * speed scalar to smooth transitions
  if (sp > maxRate) {  //max speed
    sp = maxRate;
    digitalWrite(13, HIGH);   //on board led turns on if max speed was reached
  }
  volatile float stepsPerSecond = mToSteps(sp);
  volatile unsigned long freqReg;
  if (mode == 4 || stepsPerSecond < 12) {  //stop
    AD.setFrequency(MD_AD9833::CHAN_0, 0);
  } else {
    AD.setFrequency(MD_AD9833::CHAN_0, stepsPerSecond); //start moving
  }
}

void sendSerial() { //Due version

  /*
    1: probe 1
    2: probe 2
    p: position
    d: other data for debugging
  */
  pushBuffer(probe1Buffer, mapFloat(analogRead(probe1Pin) - initialProbe1 , 0.0, 560.0, 0.0, 0.27));   //maps to m and adds to data buffer. InitialProbe1 zeros value
  pushBuffer(probe2Buffer, mapFloat(analogRead(probe2Pin), 0.0, 560.0, 0.0, 0.27));
  if (sendUnitTests)    //if in unit testing serial mode
  {
    if (ampUnitTest) {
      Serial.write('u');
      sendFloat(1);
    } else {
      Serial.write('u');
      sendFloat(-1);
    }
    if (TSUnitTest) {
      Serial.write('u');
      sendFloat(2);
    } else {
      Serial.write('u');
      sendFloat(-2);
    }
    if (encoderTest) {
      Serial.write('u');
      sendFloat(3);
    } else {
      Serial.write('u');
      sendFloat(-3);
    }
    Serial.write('u');
    sendFloat(4);     //4 indicates that all tests have been sent at least once
    Serial.write('u');
    sendFloat(4);     //sends again to match the packet size of normal serial
  } else {        //under normal operation
    Serial.write('1');    //to indicate wave probe data
    sendFloat(averageArray(probe1Buffer));
    Serial.write('2');    //to indicate wave probe data
    sendFloat(averageArray(probe2Buffer));
    Serial.write('p');    //to indicate position
    sendFloat(encPos());
    Serial.write('d');    //to indicate alternate data
    volatile float lerpVal = lerp(prevVal, futurePos, (interval * 1.0e6) / (sampleT - prevSampleT)); //linear interpolate(initial value, final value, percentatge)//percentage is desired interval/actual interval
    sendFloat(lerpVal);
    Serial.write('c');
    volatile float checksum = mode + j + a + f + sigH + peakF + gam;//adds the values of anything that can ba changes by processing.
    sendFloat(checksum);
  }
}
