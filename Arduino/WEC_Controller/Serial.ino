void initSerial() {
  Serial.begin(250000);
}
void readSerial()
{
  /*
    '!' indicates mode switch, next int is mode
    t indicates torque command
    k indicates kp -p was taken
    d indicates kd
    s :sigH
    p :peakF
    g :gamma
  */
  if (Serial.available() > 5) {   //if a whole float is through: n+100>
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

volatile void float2bin(volatile float target, volatile byte *byteArray){
  volatile uint32_t temp32;
  memcpy(&temp32,&target,4);
  for(volatile int i = 0; i<4; i++){
    byteArray[i] = (byte)(temp32 >> (8*(3-i)));
  }
}

volatile float bin2float(volatile byte *byteArray){
  volatile uint32_t temp32;

  for(volatile int i = 0; i<4; i++){
    temp32 = temp32 | ((uint32_t)byteArray[i] << (8*(3-i)));
  }

  float returnFloat;
  memcpy(&returnFloat,&temp32,4);
  return returnFloat;
}
