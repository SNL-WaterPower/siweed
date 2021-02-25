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
    char c = Serial.read();
    //Serial.print('x');
    //Serial.println(c);
    switch (c) {
      case '1':
        d1 = readFloat();
        break;
      case '2':
        d2 = readFloat();
        break;
      case 'p':
        dp = readFloat();
        break;
      case 'd':
        dd = readFloat();
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
  float2bin(f, (byte*)&byteArray);
  for (volatile int i = 0; i < 4; i++) {
    Serial.write(byteArray[i]);
  }
}

volatile void float2bin(volatile float target, volatile byte *byteArray) {
  volatile uint32_t temp32;
  //memcpy(&temp32, &target, 4);
  temp32 = (uint32_t)(*(uint32_t*)&target);
  for (volatile int i = 0; i < 4; i++) {
    byteArray[i] = (byte)(temp32 >> (8 * (3 - i)));
  }
}

volatile float bin2float(volatile byte *byteArray) {
  volatile uint32_t temp32 = 0;
  //volatile uint32_t temp33;
  volatile byte temp8;

  for (volatile int i = 0; i < 4; i++) {
    //temp33 = 0;
    temp8 = byteArray[i];
    
    //memcpy(&temp33,&temp8,1);
    //temp32 |= (temp33 << (8 * (3 - i)));
    temp32 |= ((uint32_t)temp8 << (8 * (3 - i)));
  }

  float returnFloat;
  //memcpy(&returnFloat, &temp32, 4);
  returnFloat = (float)(*(float*)&temp32);
  return returnFloat;
}