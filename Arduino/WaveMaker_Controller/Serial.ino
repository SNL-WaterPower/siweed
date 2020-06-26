void initSerial() {
  Serial.begin(500000);
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
  if (Serial.available() >= 6) {   //if a whole float is through: n+100>
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
        //noInterrupts();
        /*
        Serial.println("start");
        //jonswap.update(sigH, peakF, gamma);
        jonswap.update(5.0, 3.0, 7.0);
        Serial.println("finished");
        n = jonswap.getNum();
        Serial.println(n);
        
        for (int i = 0; i < n; i++) {
          amps[i] = jonswap.getAmp()[i];
          freqs[i] = jonswap.getF()[i];
          phases[i] = jonswap.getPhase()[i];
          Serial.println("copy");
        }
        for (int i = 0; i < n; i++) {
          Serial.println(jonswap.getAmp()[i]);
        }
        //interrupts();
        */
        break;
    }
  }
}
float readFloat() {
  char charArr[5];    //+123\0
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
