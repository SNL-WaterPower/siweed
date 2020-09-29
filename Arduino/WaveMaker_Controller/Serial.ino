void initSerial() {
  Serial.begin(250000);
}
/* '!' indicates mode switch, next int is mode
   j indicates jog position
   a indicates incoming amplitude
   f indicates incoming frequency
   s :sigH
   p :peakF
   g :gamma
*/
void readSerial() {
  if (Serial.available() > 5) {   //if a whole float is through: n+100>
    //delay(1000);
    //Serial.print('b');
    //Serial.println(Serial.available());
    speedScalar = 0;    //if anything happens, reset the speed scalar(and ramp up speed)
    char c = Serial.read();
    //Serial.print('x');
    //Serial.println(c);
    switch (c) {
      case '!':
        mode = (int)readFloat();
        if (mode == 1) {
          n = 1;    //sine wave
        }
        break;
      case 'j':
        desiredPos = readFloat();
        break;
      case 'a':
        amps[0] = readFloat();
        break;
      case 'f':
        freqs[0] = readFloat();
        break;
      case 's':
        sigH = readFloat();
        break;
      case 'p':
        peakF = readFloat();
        break;
      case 'g':     //should always be recieved after s and p
        gamma = readFloat();
        newJonswapData = true;
        break;
      case 'u':
        readFloat();    //get rid of placeholder float
        if (ampUnitTest) {
          Serial.write('u');
          sendFloat(1);       //this may get interupted by the send serial interupt, which might cause an issue
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
