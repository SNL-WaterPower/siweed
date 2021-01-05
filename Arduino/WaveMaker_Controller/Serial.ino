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
  if (Serial.available() > 4) {   //if a whole float is through: 1 byte tag + 4 byte float
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
        break;
    }
  }
}
volatile float readFloat() {
  volatile byte byteArray[4];
  for (volatile int i = 0; i < 4; i++) {
    byteArray[i] = Serial.read();
  }
  volatile float f = bin2float((byte*)&byteArray); 
  return f;
}

volatile void sendFloat(volatile float f) {
  volatile byte byteArray[4];
  float2bin(f,(byte*)&byteArray);
  for (volatile int i = 0; i < 4; i++) {
    Serial.write(byteArray[i]);
  }
}

volatile void float2bin(volatile float target, volatile byte *byteArray) {
  volatile uint32_t temp32;
  temp32 = (uint32_t)(*(uint32_t*)&target);
  for (volatile int i = 0; i < 4; i++) {
    byteArray[i] = (byte)(temp32 >> (8 * (3 - i)));
  }
}

volatile float bin2float(volatile byte *byteArray) {
  volatile uint32_t temp32 = 0;
  volatile byte temp8;

  for (volatile int i = 0; i < 4; i++) {
    temp8 = byteArray[i];
    temp32 |= ((uint32_t)temp8 << (8 * (3 - i)));
  }

  float returnFloat;
  returnFloat = (float)(*(float*)&temp32);
  return returnFloat;
}
