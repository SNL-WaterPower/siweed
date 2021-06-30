const float interval = .01;    //interval of updateTau interupt in seconds
const float serialInterval = .03125; //interval of serial interupt

void initInterrupts() {
  //This could instead be done with the setFrequency() function, but the control loop uses the time interval,
  //so it's simpler to do this. Unit is microseconds
  Timer.getAvailable().attachInterrupt(sendSerial).start(serialInterval * 1.0e6);
  delay(50);
  Timer.getAvailable().attachInterrupt(updateTau).start(interval * 1.0e6);
}

volatile float pos;
void updateTau()    //called by interupt
{
  volatile float prevPos = pos;
  pos = encPos();
  vel = (pos - prevPos) / interval;
  switch (mode) {
    case 4:
      digitalWrite(enablePin, LOW);   //stop
      break;
    case 1:
      tauCommand = tau;       //direct control
      //tauCommand = 0.0035*sin(0.05*2*PI*millis()/1000);
      break;
    case 2:
      tauCommand = kp * pos + -kd * vel;      //PD feedback control
      break;
    case 3:
      tauCommand = calcTS(t);
      break;
  }
  if (mode != 4) {
    //arduino needs to write a pwm signal to the motor controller with a duty cycle between 10% and 90%
    if (tauCommand > 0) {   //write direction
      digitalWrite(dirPin, HIGH);
    } else {
      digitalWrite(dirPin, LOW);
    }
    //convert torque to amperage:
    volatile float ampCommand = abs(tauCommand) / torqueConstant;
    if (ampCommand > maxAmps) {    //ensure maximum so that duty cycle does not exceed 90%
      ampCommand = maxAmps;
    }

    float minCommand = mapFloat(minPwm, 0, 1, 0, 4095);    //maps 10% to 0-4095 for analogWrite   //!could be a constant
    float maxCommand = mapFloat(maxPwm, 0, 1, 0, 4095);    //maps 90% to 0-4095 for analogWrite   //!could be a constant
    analogWrite(tauPin, mapFloat(ampCommand, minAmps, maxAmps, minCommand, maxCommand));    //sends to the motor controller after mapping from amps to pwm
    //analogWrite(tauPin, mapFloat(0.76*pos/100, minAmps, maxAmps, minCommand, maxCommand));  //makes a positive spring
    digitalWrite(enablePin, HIGH);
  } else {
    digitalWrite(enablePin, LOW);
  }
}

void sendSerial() {  //called by interupt
  /*
    e: encoder position
    t: tau commanded to motor
    p: power
    v: velocity
  */
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
    Serial.write('e');
    sendFloat(encPos());
    Serial.write('t');
    //takes analog value from pin(0-4095)(0-3.3v), and maps to amperage, and converts to toruqe and adds sign
    tauCommanded = mapFloat(analogRead(tauInPin), 0, 4095, -0.7620, 0.7620) * torqueConstant;
    sendFloat(tauCommanded);
    Serial.write('p');
    sendFloat(power);
    Serial.write('v');
    sendFloat(vel);
    Serial.write('c');
    volatile float checksum = mode + tau + kp + kd + sigH + peakF + gam;//adds the values of anything that can ba changes by processing.
    sendFloat(checksum);
  }
}
