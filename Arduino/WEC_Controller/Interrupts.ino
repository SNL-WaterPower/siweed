const float interval = .01;    //interval of updateTau interupt in seconds
const float serialInterval = .0333; //interval of serial interupt

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
    if (tauCommand > maxTau) {    //ensure that maxTau is max, so that duty cycle does not exceed 90%
      tauCommand = maxTau;
    }
    float minCommand = mapFloat(10, 0, 100, 0, 4095);    //maps 10% to 0-4095 for analogWrite   //!could be a constant
    float maxCommand = mapFloat(90, 0, 100, 0, 4095);    //maps 10% to 0-4095 for analogWrite   //!could be a constant
    analogWrite(tauPin, mapFloat(tauCommand, minTau, maxTau, minCommand, maxCommand));    //sends to the motor controller after mapping from newtom/meters to pwm
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
  Serial.write('e');
  sendFloat(encPos());
  Serial.write('t');
  sendFloat(tauCommand);
  Serial.write('p');
  sendFloat(power);
  Serial.write('v');
  sendFloat(vel);
  Serial.println();
}
