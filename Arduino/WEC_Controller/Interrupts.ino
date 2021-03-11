const float interval = .01;    //interval of updateTau interupt in seconds
const float serialInterval = .03125; //interval of serial interupt

void initInterrupts() {
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
    case -1:
      digitalWrite(enablePin, LOW);   //stop
      break;
    case 0:
      tauCommand = tau;       //direct control
      break;
    case 1:
      tauCommand = kp * pos + kd * vel;      //PD feedback control
      break;
    case 2:
      tauCommand = calcTS(t);
      break;
  }
  if (mode != -1) {
    //arduino needs to write a pwm signal to the motor controller with a duty cycle between 10% and 90%
    if (tauCommand > 0) {   //write direction
      digitalWrite(dirPin, HIGH);
    } else {
      digitalWrite(dirPin, LOW);
    }
    tauCommand = abs(tauCommand);
    //convert torque to amperage:
    float ampCommand = tauCommand/torqueConstant;
    if (ampCommand > maxAmps) {    //ensure maximum so that duty cycle does not exceed 90%
      ampCommand = maxAmps;
    }
    float minCommand = mapFloat(10, 0, 100, 0, 4095);    //maps 10% to 0-4095 for analogWrite   //!could be a constant
    float maxCommand = mapFloat(90, 0, 100, 0, 4095);    //maps 10% to 0-4095 for analogWrite   //!could be a constant
    analogWrite(tauPin, mapFloat(ampCommand, minAmps, maxAmps, minCommand, maxCommand));    //sends to the motor controller after mapping from newtom/meters to pwm
    digitalWrite(enablePin, HIGH);
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

  } else {        //under normal operation
    Serial.write('e');
    sendFloat(encPos());
    Serial.write('t');
    sendFloat(tauCommand);
    Serial.write('p');
    sendFloat(power);
    Serial.write('v');
    sendFloat(vel);
  }
  /*
    Serial.println();
    Serial.println(encoderBuffInit);
    Serial.print((char)MDR0_settings, BIN);
    Serial.print(" <-mdr0settings:if it worked-> ");
    Serial.println(didItWork_MDR0);
    Serial.print((char)MDR1_settings,BIN);
    Serial.print(" <-mdr1settings:if it worked-> ");
    Serial.println(didItWork_MDR1);
    Serial.println(encPos());//*/
}
