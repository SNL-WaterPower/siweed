const float interval = .01;   //time between each interupt call in seconds //max value: 1.04
const float serialInterval = .03125;   //time between each interupt call in seconds //max value: 1.04    .03125 is 32 times a second to match processing's speed(32hz)

volatile float futurePos;
volatile float error;
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

  //////timer 5 for serial sending
  TCCR5A = 0;// set entire TCCR5A register to 0
  TCCR5B = 0;// same for TCCR5B
  TCNT5  = 0;//initialize counter value to 0
  OCR5A = serialInterval * 16000000.0 / 256.0 - 1; // = (interval in seconds)(16*10^6) / (1*1024)  (must be <65536) -1 to account for overflow(255 -> 0)
  TCCR5B |= (1 << WGM12);   // turn on CTC mode aka reset on positive compare(I think)
  TCCR5B |= (1 << CS52);// Set CS42 bit for 256 prescaler
  TIMSK5 |= (1 << OCIE5A);  // enable timer compare interrupt

  sei();//allow interrupts
}
ISR(TIMER4_COMPA_vect) {    //function called by interupt     //Takes about .4 milliseconds
  unsigned long freqReg = gen.freqCalc(0);
  volatile float pos = encPos();
  error = futurePos - pos;   //where we told it to go vs where it is
  prevSampleT = sampleT;
  sampleT = micros();
  prevVal = futurePos;
  futurePos = inputFnc(t + interval);// + error;  //time plus delta time plus previous error. maybe error should scale as a percentage of speed? !!!!!!!!!!!!!!NEEDS TESTING
  volatile float vel = speedScalar * (futurePos - pos) / interval; //desired velocity in mm/second   //ramped up over about a second   //LIKELY NEEDS TUNING
  if (vel > 0) {
    digitalWrite(dirPin, HIGH);
  } else {
    digitalWrite(dirPin, LOW);
  }
  volatile float sp = abs(vel);     //steping is always positive, so convert to speed
  /*if (sp < 2.6) {   //31hz is the lowest frequency of tone(), in mm/s this is 2.6
    sp = 2.6;
    noTone(stepPin);
    //Serial.println("min");
    }*/
  if (sp > maxRate) {  //max speed
    sp = maxRate;
    digitalWrite(13, HIGH);   //on board led turns on if max speed was reached
    //Serial.println("max");
  }
  volatile float stepsPerSecond = mmToSteps(sp);
  if (mode == -1) {  //stop
//      stepper.stop();
     freqReg = gen.freqCalc(0); 
      gen.adjustFreq(MiniGen::FREQ0, freqReg); //stop moving
  } 
  else {    
//    stepper.stop(); //
    freqReg = gen.freqCalc(stepsPerSecond); //setting the signal generator to 10hz
    gen.adjustFreq(MiniGen::FREQ0, freqReg); //start moving
  }

}

ISR(TIMER5_COMPA_vect) {   //takes ___ milliseconds
  /*
    1: probe 1
    2: probe 2
    p: position
    d: other data for debugging
  */

  pushBuffer(probe1Buffer, mapFloat(analogRead(probe1Pin), 0.0, 560.0, 0.0, 27.0));     //maps to cm and adds to data buffer
  pushBuffer(probe2Buffer, mapFloat(analogRead(probe2Pin), 0.0, 560.0, 0.0, 27.0));
  Serial.write('1');    //to indicate wave probe data
  sendFloat(averageArray(probe1Buffer));
  Serial.write('2');    //to indicate wave probe data
  sendFloat(averageArray(probe2Buffer));
  Serial.write('p');    //to indicate position
  sendFloat(encPos());
  Serial.write('d');    //to indicate alternate data
  float lerpVal = lerp(prevVal, futurePos, (interval * 1.0e6) / (sampleT - prevSampleT)); //linear interpolate(initial value, final value, percentatge)//percentage is desired interval/actual interval
  sendFloat(lerpVal);
  Serial.println();
  //Serial.println(mode);
}
