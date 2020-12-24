//Plan: Processing will send numbers with tags, arduino will send them back with same tags

const float serialInterval = .03125;   //time between each interupt call in seconds //max value: 1.04    .03125 is 32 times a second to match processing's speed(32hz)
float d1 = -1, d2 = -1, dp = -1, dd = -1;   //data values

void setup() {
  // put your setup code here, to run once:
  initSerial();
  
  float testFloat = 123.456789;
  byte byteArray[4];
  float2bin(testFloat, (byte*)&byteArray);
  //println(byteArray);
  float resultFloat = bin2float((byte*)&byteArray);
  if (testFloat == resultFloat) {
    Serial.println("Byte Conversion Test PASSED");
  } else {
    Serial.println("Byte Conversion Test FAILED");
    Serial.println(resultFloat);
  }
  delay(5000);
  //interupt setup:
  cli();//stop interrupts
  //////timer 5 for serial sending
  TCCR5A = 0;// set entire TCCR5A register to 0
  TCCR5B = 0;// same for TCCR5B
  TCNT5  = 0;//initialize counter value to 0
  OCR5A = serialInterval * 16000000.0 / 256.0 - 1; // = (interval in seconds)(16*10^6) / (1*1024)  (must be <65536) -1 to account for overflow(255 -> 0)
  TCCR5B |= (1 << WGM12);   // turn on CTC mode aka reset on positive compare(I think)
  TCCR5B |= (1 << CS52);// Set CS42 bit for 256 prescaler
  TIMSK5 |= (1 << OCIE5A);  // enable timer compare interrupt

  sei();//allow interrupts
  
}

void loop() {
  // put your main code here, to run repeatedly:
  readSerial();
}
ISR(TIMER5_COMPA_vect) {   //takes ___ milliseconds
  /*
    1: probe 1
    2: probe 2
    p: position
    d: other data for debugging
  */

  Serial.write('1');    //to indicate wave probe data
  sendFloat(d1);
  Serial.write('2');    //to indicate wave probe data
  sendFloat(d2);
  Serial.write('p');    //to indicate position
  //Serial.print(encPos);
  sendFloat(dp);
  Serial.write('d');    //to indicate alternate data
  sendFloat(dd);
  Serial.println();
  //Serial.println(mode);
}
