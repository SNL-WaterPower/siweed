#define usb Serial

void setup() {
  usb.begin(9600);
}

void loop() {
  float derp = 1.23455;
  uint32_t lerp;
  byte byteArray[4];

  usb.print(F("The float derp = "));
  usb.println(derp,DEC);

  int flt2bin_startTime = micros();
  float2bin(derp,(byte*)&byteArray);
  int flt2bin_execTime = micros() - flt2bin_startTime;
  
  usb.print(F("The byte array byteArray = "));
  for(int i = 0; i < 4; i++){
    usb.print(byteArray[i],BIN);
    usb.print(" ");
  }
  usb.print("\n");

  int bin2flt_startTime = micros();
  float herp = bin2float((byte*)&byteArray);
  int bin2flt_execTime = micros() - bin2flt_startTime
  ;
  usb.print(F("The float herp = "));
  usb.println(herp,DEC);

  usb.print(F("float2bin execution time = "));
  usb.print(flt2bin_execTime);
  usb.println(F(" microSeconds"));
  usb.print(F("bin2float execution time = "));
  usb.print(bin2flt_execTime);
  usb.println(F(" microSeconds"));
  
  while(1);
}

void float2bin(float target, byte *byteArray){
  uint32_t temp32;
  memcpy(&temp32,&target,4);
  for(int i = 0; i<4; i++){
    byteArray[i] = (byte)(temp32 >> (8*(3-i)));
  }
}

float bin2float(byte *byteArray){
  uint32_t temp32;

  for(int i = 0; i<4; i++){
    temp32 = temp32 | ((uint32_t)byteArray[i] << (8*(3-i)));
  }

  float returnFloat;
  memcpy(&returnFloat,&temp32,4);
  return returnFloat;
}
