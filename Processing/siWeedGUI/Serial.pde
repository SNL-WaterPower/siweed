Serial port1;    //arduino wavemaker due //<>//
Serial port2;    //arduino WEC due
boolean WMConnected, WECConnected;
int connectionDelay  = 3500;      //how many ms to wait after connecting to a device. Can greatly slow the startup
int baudRate = 57600;
void initializeSerial() {
  ///////////initialize Serial

  printArray(Serial.list());     //for debugging, shows all attached devices
  if (debug) println("Wavemaker Serial:");
  for (int i = 0; i < Serial.list().length; i++) {    //tries each device
    if (!WMConnected) {
      try {
        if (debug) println("trying port"+Serial.list()[i]);
        port1 = new Serial(this, Serial.list()[i], baudRate); //attempts to connect
        WMConnected = true;
        if (debug) println("Wavemaker test port connected");
      }
      catch(Exception e) {
        WMConnected = false;
        if (debug) println("exception caught");
      }
      if (WMConnected) {    //if the device successfully connected
        if (debug) println("connected to device, waiting for connection to stabilize");
        delay(connectionDelay);          //wait for connection to stabilize
        port1.clear();
        delay(100);        //after the connection stabilizes, this clears all the garbage and gives good data time to come through.

        readWMSerial();    //reads serial buffer and sets bool true if recieving normal results
        if (WMUnitTests[0]) {
          //correct board found
          if (debug) println("correct board found");
        } else {
          WMConnected = false;    //if not found, keep testing
          port1.stop();    //disconnect the port so next function can try
          if (debug) println("wrong board");
        }
      }
    }
    if (debug) println("WEC Serial:");
    if (!WECConnected) {
      try {
        if (debug) println("trying WEC port "+Serial.list()[i]);
        port2 = new Serial(this, Serial.list()[i], baudRate); // all communication with WEC
        WECConnected = true;
        if (debug) println("WEC test port connected");
      }
      catch(Exception e) {
        WECConnected = false;
        if (debug) println("exception caught");
      }
      if (WECConnected) {
        if (debug) println("connected to device, waiting for connection to stabilize");
        delay(connectionDelay);
        port2.clear();
        delay(100);        //after the connection stabilizes, this clears all the garbage and gives good data time to come through.

        readWECSerial();    //reads serial buffer and sets bool true if recieving normal results
        if (WECUnitTests[0]) {
          //correct board found
          if (debug) println("correct board found");
        } else {
          WECConnected = false;
          port1.stop();    //disconnect the port
          if (debug) println("wrong board");
        }
      }
    }
  }
}
void sendFloat(float f, Serial port)
{
  /* 
   For Wavemaker:
  /* '!' indicates mode switch, next int is mode
   j indicates jog position
   a indicates incoming amplitude
   f indicates incoming frequency
   s :sigH
   p :peakF
   g :gamma
   
   For WEC:
   '!' indicates mode switch, next int is mode
   t indicates torque command
   k indicates kp -p was taken
   d indicates kd
   s :sigH
   p :peakF
   g :gamma
   
   EDIT: numbers are now in this format:  p1234>  has a scalar of 100, so no decimal, and no start char
   */
  byte[] byteArray = floatToByteArray(f);

  port.write(byteArray);
  if (debug) {
    println("sent float: "+f);
  }
}
void readWMSerial() {
  /*
  Wavemaker:
   1:probe 1
   2:probe 2
   p:position
   d:other data for debugging
   u:unit tests
   */
  if (WMConnected) {
    for (int i = 0; i <port1.available()/20; i++) {    //runs as many times to empty the buffer(bytes availible/ bytes read per loop).
      switch(port1.readChar()) {
      case '1':
        WMUnitTests[0] = true;      //for unit testing and acquiring serial.
        probe1 = readFloat(port1);
        if (waveElClicked == true && !Float.isNaN(probe1)) {
          waveChart.push("waveElevation", probe1*waveElevationScale);
          //println(probe1);
        }
        break;
      case '2':
        probe2 = readFloat(port1);
        break;
      case 'p':
        waveMakerPos = readFloat(port1);
        if (wavePosClicked == true && !Float.isNaN(probe2)) {
          waveChart.push("waveMakerPosition", waveMakerPos*WMPosScale);
        }
        break;
      case 'd':
        debugData = readFloat(port1);
        if (!Float.isNaN(debugData) && debugData < 0.1 && debugData > -0.1) {    //when starting seastate immediately, a "large" value comes through, messing witht the FFT. The saturation prevents that.
          waveChart.push("debug", debugData*WMPosScale);
          //println(debugData);
          if (waveMaker.mode == 3||waveMaker.mode == 2) fftList.add(debugData);      //adds to the tail if in the right mode
          if (fftList.size() > queueSize) fftList.remove();          //removes from the head
        } else
        {
          waveMaker.sigH += 1;    //if values coming in are too large, this makes the draw loop resend the values
        }
        break;
      case 'u':
        int testNum = (int)readFloat(port1);    //indicates which jonswap test passed(1 or 2). Negative means that test failed.
        if (debug) {
          println("WMUnittestNum: "+testNum);
        }
        if (testNum > 0) {    //only changes if test was passed
          WMUnitTests[testNum] = true;
        }
        break;
      }
    }
  }
}
void readWECSerial() {
  /*
  WEC:
   e: encoder position
   t: tau commanded to motor
   p: power
   v: velocity
   u: unit testing
   */
  if (WECConnected) {
    for (int i = 0; i <port2.available()/20; i++) {    //runs as many times to empty the buffer(bytes availible/ bytes read per loop). Since it runs 30 times a second, the arduino will send many samples per execution.
      switch(port2.readChar()) {
      case 'e':
        wecPos = readFloat(port2);
        if (wecPosClicked == true && !Float.isNaN(wecPos)) {
          wecChart.push("wecPosition", wecPos*WCPosScale);
        }
        break;
      case 't':
        WECUnitTests[0] = true;
        tau = readFloat(port2);
        if (wecTorqClicked == true && !Float.isNaN(tau)) {
          wecChart.push("wecTorque", tau*WCTauScale);
        }
        break;
      case 'p':
        pow = readFloat(port2);
        if (wecPowClicked == true && !Float.isNaN(pow)) {
          wecChart.push("wecPower", pow*WCPowScale);
        }
        break;
      case 'v':
        wecVel = readFloat(port2);
        if (wecVelClicked == true && !Float.isNaN(wecVel)) {
          wecChart.push("wecVelocity", wecVel * WCVelScale);
        }      
        break;
      case 'u':
        int testNum = (int)readFloat(port2);    //indicates which jonswap test passed(1 or 2)
        if (debug) {
          println("WECUnittestNum: "+testNum);
        }
        if (testNum > 0) {    //only changes if test was passed
          WECUnitTests[testNum] = true;
        }   
        break;
      }
    }
  }
}
float readFloat(Serial port) {
  while (port.available() <= 4) {    //wait for full array to be in buffer
    delay(1);    //give serial some time to come through
  }  
  byte[] byteArray = new byte[4];
  port.readBytes(byteArray);
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
//boolean isFloat(float val) {
//  if (Float.isNaN(val)){
//    return false;
//  }
//  else {
//   return true; 
//  }
//}
