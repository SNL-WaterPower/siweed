Serial port1;    //arduino mega
Serial port2;    //arduino Due
boolean megaConnected, dueConnected;
void initializeSerial() {
  ///////////initialize Serial

  printArray(Serial.list()); 
  port1 = new Serial(this, Serial.list()[1], 250000); // all communication with Megas
  delay(2000);
}
void sendFloat(float f, Serial port)
{
  byte[] byteArray = floatToByteArray(f);

  port.write(byteArray);
}
void readMegaSerial() {
  /*
  mega:
   1:probe 1
   2:probe 2
   p:position
   d:other data for debugging
   */
  while (port1.available() > 0) {    //recieves until buffer is empty. Since it runs 30 times a second, the arduino can send many samples per execution.
    switch(port1.readChar()) {
    case '1':
      print("1 ");
      println(readFloat(port1));
      break;
    case '2':
      print("2 ");
      println(readFloat(port1));
      break;
    case 'p':
      print("p ");
      println(readFloat(port1));
      break;
    case 'd':
      print("d ");
      println(readFloat(port1));
      break;
    }
  }
}

float readFloat(Serial port) {
  while (port.available() <= 4) {    //wait for full array to be in buffer
    delay(1);    //give serial some time to come through
  }  
  byte[] byteArray = new byte[4];
  //for (int i = 0; i < 4; i++) {
  //inBuffer = myPort.readBytes();
  port.readBytes(byteArray);
  //}
  //float f = ByteBuffer.wrap(byteArray).getFloat();
  float f = byteArrayToFloat(byteArray);
  //println(f);
  return f;
}

public static byte[] floatToByteArray(float value) {
  int intBits =  Float.floatToIntBits(value);
  return new byte[] {
    (byte) (intBits >> 24), (byte) (intBits >> 16), (byte) (intBits >> 8), (byte) (intBits) };
}
public static float byteArrayToFloat(byte[] bytes) {
  int intBits = 
    bytes[0] << 24 | (bytes[1] & 0xFF) << 16 | (bytes[2] & 0xFF) << 8 | (bytes[3] & 0xFF);
  return Float.intBitsToFloat(intBits);
}
