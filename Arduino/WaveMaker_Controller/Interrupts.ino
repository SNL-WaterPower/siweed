bool dir = true;

const float deadzone = 0.0001;  //dead band in meters
volatile float futurePos;
volatile float sampleT = 0;  //timestamp in microseconds of sample
volatile float prevSampleT;  //previous timestamp in microseconds
volatile float prevVal;   //value of sample at prevSampleT
void initInterrupts() {
  //interupt setup:
  cli();//stop interrupts

  TCCR4A = 0;// set entire TCCR4A register to 0
  TCCR4B = 0;// same for TCCR4B
  TCNT4  = 0;//initialize counter value to 0
  OCR4A = interval * 16000000.0 / 256.0 - 1; // = (interval in seconds)(16*10^6) / (1*1024)  (must be <65536) -1 to account for overflow(255 -> 0)
  TCCR4B |= (1 << WGM12);   // turn on CTC mode aka reset on positive compare(I think)
  TCCR4B |= (1 << CS42);// Set CS42 bit for 256 prescaler
  TIMSK4 |= (1 << OCIE4A);  // enable timer compare interrupt
  /*
    //////timer 5 for serial sending
    TCCR5A = 0;// set entire TCCR5A register to 0
    TCCR5B = 0;// same for TCCR5B
    TCNT5  = 0;//initialize counter value to 0
    OCR5A = serialInterval * 16000000.0 / 256.0 - 1; // = (interval in seconds)(16*10^6) / (1*1024)  (must be <65536) -1 to account for overflow(255 -> 0)
    TCCR5B |= (1 << WGM12);   // turn on CTC mode aka reset on positive compare(I think)
    TCCR5B |= (1 << CS52);// Set CS42 bit for 256 prescaler
    TIMSK5 |= (1 << OCIE5A);  // enable timer compare interrupt
  */
  sei();//allow interrupts
}
/*
  Motor control interupt:
  After calculating desired position with inputFnc(), this controller should estimate the command
  linearly, then apply a PID calculated error correction. The sum is then converted from a velociy to
  a frequency.

  TODO: triple check unit conversions, and test linear controller on it's own. Then
  tune PID with 0P, maybe 0D
*/
volatile float error;
volatile float velCommand;
ISR(TIMER4_COMPA_vect) {    //function called by interupt
  volatile float pos = encPos();
  error = futurePos - pos;   //where we told it to go vs where it is
  ////////vars for linear interpolation:
  prevSampleT = sampleT;
  sampleT = micros();
  prevVal = futurePos;
  futurePos = inputFnc(t + interval);  //time plus delta time
  //PID calculation:
  pidSet = 0; //desired error is 0
  pidIn = error;
  //myPID.Compute();    //sets pidOut
  /////////
  if (mode != 0 || abs(futurePos - pos) > deadzone) {    //deadband only if in jog mode.
    velCommand = ((futurePos - pos) / interval) + pidOut; //estimated desired velocity in m/s, in order to hit target by next interupt call, + pid error adjustment
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
  if (mode == -1 || stepsPerSecond < 12) {  //stop
    freqReg = gen.freqCalc(0);
    gen.adjustFreq(MiniGen::FREQ0, freqReg); //stop moving
  } else {
    freqReg = gen.freqCalc(stepsPerSecond);
    gen.adjustFreq(MiniGen::FREQ0, freqReg); //start moving
  }

  //}

  //ISR(TIMER5_COMPA_vect) {   //takes ___ milliseconds
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
  } else {        //under normal operation
    Serial.write('1');    //to indicate wave probe data
    sendFloat(averageArray(probe1Buffer));
    Serial.write('2');    //to indicate wave probe data
    sendFloat(averageArray(probe2Buffer));
    Serial.write('p');    //to indicate position
    sendFloat(encPos());
    Serial.write('d');    //to indicate alternate data
    float lerpVal = lerp(prevVal, futurePos, (interval * 1.0e6) / (sampleT - prevSampleT)); //linear interpolate(initial value, final value, percentatge)//percentage is desired interval/actual interval
    sendFloat(lerpVal);
  }
}
