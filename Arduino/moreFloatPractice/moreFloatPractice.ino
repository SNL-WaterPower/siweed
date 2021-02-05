void setup() {
  // put your setup code here, to run once:
  Serial.begin(250000);
  sendFloat(1);

}

void loop() {
  // put your main code here, to run repeatedly:

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
