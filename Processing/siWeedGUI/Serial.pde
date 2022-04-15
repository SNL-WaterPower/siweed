Serial port1;    //arduino wavemaker due //<>// //<>//
Serial port2;    //arduino WEC due
Serial probe1Port, probe2Port;   //wave probes
boolean probe1Connected = false, probe2Connected = false;
boolean WMConnected, WECConnected;
int connectionDelay  = 3500;      //how many ms to wait after connecting to a device. Can greatly slow the startup
int baudRate = 57600;    //only for arduinos. Wave probe baud rate is set in modifiers.

BandPass bpf1, bpf2;
float WMChecksum, WECChecksum;
int WMCmdCount, WECCmdCount;    //The cmdCount is the number of items sent with the last command ie. amplitude and frequency would give 2. This helps when verifying checksums
public class Cmd {      //used to store each command
  public char c;
  public float f;
  Cmd(char _c, float _f) {
    c = _c;
    f = _f;
  }
}
LinkedList<Cmd> WMCmdList, WECCmdList;
void initializeSerial() {
  ///initialize wave probe band pass filters:
  bpf1 = new BandPass();
  bpf2 = new BandPass();
  /////

  WMCmdList = new LinkedList<Cmd>();
  WECCmdList = new LinkedList<Cmd>();
  //First try wave probes
  try {
    probe1Port = new Serial(this, probe1PortName);
    println("Probe 1 CONNECTED");
    probe1Connected = true;
  }
  catch(Exception e) {
    println("Probe 1 connection FAILED");
  }
  try {
    probe2Port = new Serial(this, probe2PortName);
    println("Probe 2 CONNECTED");
    probe2Connected = true;
  }
  catch(Exception e) {
    println("Probe 2 connection FAILED");
  }
  //connect to arduinos:
  if (debug) printArray(Serial.list());     //for debugging, shows all attached devices
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
    for (int i = 0; i < port1.available()/5; i++) {    //runs as many times to empty the buffer(bytes availible/ bytes read per loop).
      switch(port1.readChar()) {
      case '1':
        WMUnitTests[0] = true;      //for unit testing and acquiring serial.
        //This used to be how wave probe data was aquired. Now depreciated
        readFloat(port1);    //discard data
        //if (waveElClicked == true && !Float.isNaN(probe1)) {
        //  waveChart.push("waveElevation", probe1*waveElevationScale);
        //}
        break;
      case '2':
        //Same as probe 1, but only used for data logging.
        readFloat(port1);    //discard data
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
          //waveChart.push("debug", debugData*WMPosScale);
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
      case 'c':
        WMChecksum = readFloat(port1);  
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
    for (int i = 0; i < port2.available()/5; i++) {    //runs as many times to empty the buffer(bytes availible/ bytes read per loop).
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
      case 'c':
        WECChecksum = readFloat(port2);  
        break;
      }
    }
  }
}
void sendSerial(char c, float f, Serial port, int cmdCount) {      //to send a command as a part of a set, cmdcount should be more than 1. For example, mode and then amplitude and frequency makes 3 commands. This is used for checksum verification.
  port.write((char)c);
  sendFloat(f, port);
  if (cmdCount == 0) {    //if the count is 0, don't add to log or update cmdCount. This allows commands in the resend function to be sent without logging
  } else if (port == port1) {      //assigns the cmd count based on which port is sent to.
    WMCmdCount = cmdCount;
    WMCmdList.add(new Cmd(c, f));    //!!make sure this doesn't cause memory leak
    /////
    //for(int i = 0; i < WMCmdList.size(); i++) println(WMCmdList.get(i).c);    //can print the list of commands
    ///
    if (WMCmdList.size() > 5) WMCmdList.remove();    //number of items stored in the list. Just needs to be at least the largest group of commands
  } else if (port == port2) {
    WECCmdCount = cmdCount;
    WECCmdList.add(new Cmd(c, f));
    if (WECCmdList.size() > 5) WECCmdList.remove();
  }
}
void sendSerial(char c, float f, Serial port) {    //used for checksum verification of standalone commands.
  sendSerial(c, f, port, 1);
}
void sendFloat(float f, Serial port) {
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
   */
  byte[] byteArray = floatToByteArray(f);
  port.write(byteArray);
  if (debug) println("sent float: "+f);
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
int WMFailCount = 0, WECFailCount = 0;
void verifyChecksum() {
  if (WMConnected && WMChecksum != WMChecksumCalc()) {      //checks if calculated checksum and serial recieved checksum match
    if (debug) println("Wavemaker checksum match failed "+ (WMFailCount+1) +" times. Arduino checksum: "+WMChecksum+" calculated checksum: "+WMChecksumCalc());
    WMFailCount++;
    if (WMFailCount > 2) {      //only resends serial if the check is contiuously failing.
      resendSerial(port1, WMCmdList, WMCmdCount, waveMaker.mode);
      WMFailCount = 0;    //reset the count
    }
  } else if (WMConnected) {
    //if (debug) println("Wavemaker checksum match Passed: "+WMChecksum+" "+WMChecksumCalc());
    WMFailCount = 0;    //reset failCount if the the checksum passes
  }
  if (WECConnected && WECChecksum != WECChecksumCalc()) {
    if (debug) println("WEC checksum match failed "+ (WECFailCount+1) +" times. Arduino checksum: "+WECChecksum+" calculated checksum: "+WECChecksumCalc());
    WECFailCount++;
    if (WECFailCount > 2) {    //only resends serial if the check is contiuously failing. This often happens at least once
      resendSerial(port2, WECCmdList, WECCmdCount, wec.mode);
      WECFailCount = 0;    //reset the count
    }
  } else if (WECConnected) {
    //if (debug) println("WEC checksum match Passed: "+WECChecksum+" "+WECChecksumCalc());
    WECFailCount = 0;      //reset failCount if the the checksum passes
  }
  if ((!WECConnected || WECChecksum == WECChecksumCalc()) && (!WMConnected || WMChecksum == WMChecksumCalc())) {    //color of console button indicates if any connected arduinos are in sync
    consoleButton.setColorBackground(green);
  } else {
    consoleButton.setColorBackground(grey);
  }
}
void resendSerial(Serial port, LinkedList<Cmd> cmdList, int count, int mode) {
  if (cmdList.size() < count)    //this may happen the first call, as the checksum is unlikely to match at initialization
  {
    if (debug) println("did not resend Serial, not enough command history");
    return;
  }
  sendSerial('!', mode, port, 0);     //always update mode. The 0 prevents it from being added to the log
  for (int i = count; i > 0; i--) {    //for the number of cmds
    Cmd tempCmd = cmdList.get(cmdList.size() - i);          //resends in the order the commands were sent.
    sendSerial(tempCmd.c, tempCmd.f, port, 0);    //resend the values, and preserve cmdCount and don't add to log
    if (debug) println("resent mode and command: " + tempCmd.c + " " + tempCmd.f);
    //println(millis());
  }
}
float WMChecksumCalc() {
  return waveMaker.mode + waveMaker.mag + waveMaker.amp + waveMaker.freq + waveMaker.sigH + waveMaker.peakF + waveMaker.gamma;
}
float WECChecksumCalc() {
  return wec.mode + wec.mag + wec.amp + wec.freq + wec.sigH + wec.peakF + wec.gamma;
}
void readProbes() {
  if (probe1Connected) {
    while (probe1Port.available() > 5) {    //reads until buffer is empty. 4 data chars and 1 carriage return per measurement
      int c = probe1Port.read();
      if (c == 13) {   //data ends in carriage return(ascii code 13)
        float val = readProbeVal(probe1Port);
        probe1 = bpf1.update(val);
        //graph probe 1:
        //if (waveElClicked == true && !Float.isNaN(probe1)) {
        //  waveChart.push("waveElevation", probe1*waveElevationScale);
        //}
      }
    }
  }
  if (probe2Connected) {
    while (probe2Port.available() > 5) {
      int c = probe2Port.read();
      if (c == 13) {   //data ends in carriage return(ascii code 13)
        float val = readProbeVal(probe2Port);
        probe2 = bpf2.update(val);
        //graph probe 2:
        if (waveElClicked == true && !Float.isNaN(probe2)) {
          waveChart.push("waveElevation", probe2*waveElevationScale);
        }
      }
    }
  }
}
float readProbeVal(Serial port) {
  String s = "";
  for (int i = 0; i < 4; i++) {
    s += port.readChar();
  }
  try {
    return(0.5*Float.parseFloat(s)/4095);    //convert string to float and mulitply by staff length and divide by 4095 to convert to meters(as stated in Wave probe manual)
  }
  catch(Exception e) {
    return 0;
  }
}
