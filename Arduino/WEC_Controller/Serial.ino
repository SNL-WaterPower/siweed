void initSerial() {
  Serial.begin(500000);
}
void readSerial() {
  /* '!' indicates mode switch, next int is mode
    t indicates torque command
    k indicates kp -p was taken
    d indicates kd
    s :sigH
    p :peakF
    g :gamma
  */
  if (Serial.available() >= 6) {   //if a whole float is through: n+100>
    char c = Serial.read();
    switch (c)
    {
      case '!':
        mode = (int)readFloat();
        break;
      case 't':
        tau = readFloat();
        break;
      case 'k':
        kp = readFloat();
        break;
      case 'd':
        kd = readFloat();
        break;
      case 's':
        sigH = readFloat();
        break;
      case 'p':
        peakF = readFloat();
        break;
      case 'g':     //should always be recieved after s and p
        _gamma = readFloat();
        newJonswapData = true;
        break;
    }
  }
}
float readFloat() {
  char charArr[7];    //+123\0
  char c;
  int i;
  for (i = 0; Serial.available() > 0 && c != '>'; i++) {
    c = Serial.read();
    charArr[i] = c;
  }
  charArr[i] = '\0';
  float f = atof(charArr) / 100.0;
  return f;
}
volatile void sendFloat(volatile float f) {
  volatile int i = (int)(f * 100.0);
  if (i >= 0) {
    Serial.print('+');
  } else {
    Serial.print('-');
  }
  Serial.print(abs(i));
  Serial.print('>');
}