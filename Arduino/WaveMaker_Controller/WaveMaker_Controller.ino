#define MINIGEN_COMPATIBILITY_MODE
#include <miniWaveTankJonswap.h>
#include <SuperDroidEncoderBuffer.h>
#include<math.h>
#include <PID_v1.h>
#include <SPI.h>
#include <SparkFun_MiniGen.h>

MiniGen gen(10); //initalize signal generator with FSYNC pin 10
miniWaveTankJonswap jonswap(512.0 / 128.0, 0.5, 2.5); //period, low frequency, high frequency. frequencies will be rounded to multiples of df(=1/period)
//jonswap(512.0 / 32.0, 0.5, 2.5);
//df = 1 / _period; num_fs = (int)((f_high - f_low) / df);
//^ISSUE. Acuracy seems to fall off after ~50 components when using higher frequencies(1,3 at 64 elements seems wrong).
volatile double pidOut, pidSet, pidIn;
PID myPID(&pidIn, &pidOut, &pidSet, 0, 0, 0, P_ON_M, DIRECT); //input, output, setpoint, kp,  ki, kd
SuperDroidEncoderBuffer encoderBuff = SuperDroidEncoderBuffer(42);
bool encoderBuffInit, didItWork_MDR0, didItWork_MDR1, didItWork_DTR;   //variables for unit testing
unsigned char MDR0_settings = MDRO_x4Quad | MDRO_freeRunningCountMode | MDRO_indexDisable | MDRO_syncIndex | MDRO_filterClkDivFactor_1;
unsigned char MDR1_settings = MDR1_4ByteCounterMode | MDR1_enableCounting | MDR1_FlagOnIDX_NOP | MDR1_FlagOnCMP_NOP | MDR1_FlagOnBW_NOP | MDR1_FlagOnCY_NOP;
const int  dirPin = 5, limitPin = A0, probe1Pin = A1, probe2Pin = A2;
volatile double t = 0;    //time in seconds
volatile float speedScalar = 0;
volatile int mode = 0;     //-1 is stop, 0 is jog, 1 is sine, 2 is sea state
volatile int n = 1;            //number of functions for the time series(either 1 or jonswap.getNum())
const int maxComponents = 100;   //max needed number of frequency components
volatile float amps[maxComponents];
volatile float phases[maxComponents];
volatile float freqs[maxComponents];
volatile float sigH, peakF, gam;   //"gamma" is used in another library
//volatile float encPos;
bool newJonswapData = false, sendUnitTests = false;
volatile float desiredPos = 0;   //used for jog mode, starts at 0
const int buffSize = 10;    //number of data points buffered in the moving average filter
volatile float probe1Buffer[buffSize];
volatile float probe2Buffer[buffSize];
volatile float jogBuffer[buffSize];
const float maxRate = 0.25;   //max m/seconds
/////////would like to put these in the interrupts tab, but cant without changing proect structure to .cpp and .h files.
const float interval = .01;   //time between each interupt call in seconds //max value: 1.04
const float serialInterval = .03125;   //time between each interupt call in seconds //max value: 1.04    .03125 is 32 times a second to match processing's speed(32hz)
//////////
//Derived funciton here:
const float leadPitch = .01;     //m/turn
const float gearRatio = 12.0 / 60.0; //motor turns per lead screw turns
const float motorStepsPerTurn = 400.0;   //steps per motor revolution
const float encStepsPerTurn = 3200.0;

volatile float inputFnc(volatile float tm) {  //inputs time in seconds //outputs position in m
  volatile float val = 0;
  if (mode == 0) {    //jog
    val = desiredPos;
  }
  else if (mode > 0) {   //1 or 2
    if (newJonswapData && mode == 2) {
      newJonswapData = false;
      jonswap.update(sigH, peakF, gam);
      n = jonswap.getNum();
      for (volatile int i = 0; i < n; i++) {
        amps[i] = jonswap.getAmp(i);
        freqs[i] = jonswap.getF(i);
        phases[i] = jonswap.getPhase(i);
      }
    }
    for (volatile int i = 0; i < n; i++) {
      val += amps[i] * sin(2 * M_PI * tm * freqs[i] + phases[i]);
    }
  }
  return val;
}


void setup() {
  initSerial();
  gen.reset(); //reset signal generator, that way we have a known starting location.
  //At power up, the singal generator will output 100hz
  gen.setMode(MiniGen::SQUARE); //setting signal generator to make a square wave.
  gen.setFreqAdjustMode(MiniGen::FULL); //Full takes the longest longer to write, but allows to change from any frequency to any other frequency

  unsigned long freqReg = gen.freqCalc(0);
  gen.adjustFreq(MiniGen::FREQ0, freqReg); //Making sure the signal generator isnt making the motor move at start

  encoderBuffInit = encoderBuff.begin();    //configure encoder buffer and assign bools for unit testing
  didItWork_MDR0 = encoderBuff.setMDR0(MDR0_settings);
  didItWork_MDR1 = encoderBuff.setMDR1(MDR1_settings);

  myPID.SetMode(AUTOMATIC);   //starts pid
  myPID.SetSampleTime((int)(interval * 1000));    //pid interval in milliseconds

  pinMode(dirPin, OUTPUT);
  pinMode(13, OUTPUT);
  digitalWrite(13, LOW);    //initialization of maxRate indicator led
  /////////Zero encoder:
  digitalWrite(dirPin, HIGH);
  freqReg = gen.freqCalc(100); //setting the signal generator to 10hz
  gen.adjustFreq(MiniGen::FREQ0, freqReg); //start moving
  float initialPos = encPos();
  delay(10);
  while (analogRead(limitPin) > 500) {   //move up until the beam is broken
    if (encPos() - initialPos == 0)    //if motor is not moving(software testing), move on.
      break;
  }
  digitalWrite(dirPin, LOW);
  delay(10);
  while (analogRead(limitPin) < 500) {  //move down until the beam is unbroken
    if (encPos() - initialPos == 0)    //if motor is not moving(software testing), move on.
      break;
  }
  freqReg = gen.freqCalc(0); //stop moving motor
  gen.adjustFreq(MiniGen::FREQ0, freqReg);

  encoderBuff.command2Reg(CNTR, IR_RegisterAction_CLR); //zero encoder

  //fill moving average buffers with 0's:
  for (int i = 0; i < buffSize; i++) {
    probe1Buffer[i] = 0;
    probe2Buffer[i] = 0;
    jogBuffer[i] = 0;
  }
  //fill amps freqs and phases with 0's:
  for (int i = 0; i < maxComponents; i++) {
    amps[i] = 0;
    freqs[i] = 0;
    phases[i] = 0;
  }
  unitTests();
  initInterrupts();
}
volatile float encPos() {
  return encoderBuff.readCNTR() * (1 / encStepsPerTurn) * leadPitch * -1.0; //steps*(turns/step)*(m/turn)
}
void loop() {   //__ microseconds
  t = micros() / 1.0e6;
  readSerial();
  updateSpeedScalar();
//  newJonswapData = true;    //to see what n is
//  inputFnc(0);
//  Serial.println(n);
}
void updateSpeedScalar() {    //used to prevent jumps/smooth start
  //Serial.println(speedScalar);

  if (speedScalar < 1) {
    speedScalar += .0007;   //value determined by testing
  } else {
    speedScalar = 1.0;
  }

  //speedScalar = 1.0;
}
volatile float mToSteps(volatile float m) {
  return m * (1 / leadPitch) * gearRatio * motorStepsPerTurn; //m*(lead turns/m)*(motor turns/lead turn)*(steps per motor turn)
}
volatile float mapFloat(volatile float x, volatile float in_min, volatile float in_max, volatile float out_min, volatile float out_max) {
  return (float)(x - in_min) * (out_max - out_min) / (float)(in_max - in_min) + out_min;
}
volatile float averageArray(volatile float* arr) {
  volatile float total = 0;
  for (volatile int i = 0; i < buffSize; i++) {
    total += arr[i];
  }
  total /= buffSize;
  return total;
}
volatile void pushBuffer(volatile float* arr, volatile float f) {
  for (volatile int i = buffSize - 1; i > 0; i--) {
    arr[i] = arr[i - 1];
  }
  arr[0] = f;
}
float lerp(float a, float b, float f) {
  return a + f * (b - a);
}
bool ampUnitTest = true, TSUnitTest = true, encoderTest = true;
//float exampleAmps[] = {0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.01, 0.02, 0.05, 0.11, 0.20, 0.33, 0.48, 0.67, 0.87, 1.09, 1.30, 1.51, 1.70, 1.88, 2.03, 2.16};
//float exampleTS[] = {4.07, -3.45, 1.12, 1.56, 0.69, -2.25, -1.17, -6.01, 0.74, 2.85, -4.79, 5.71, -1.66, -3.66, -2.78, 1.38, 4.07, -3.45, 1.12, 1.56, 0.69, -2.25, -1.17, -6.01, 0.74, 2.85, -4.79, 5.71, -1.66, -3.66, -2.78, 1.38};
float exampleAmps[] = {0.00, 0.00, 0.00, 0.00, 0.02, 0.59, 2.58, 5.03};
float exampleTS[] = {2.11, -3.28, -6.69, -1.38, 2.11, -3.28, -6.69, -1.38};
void unitTests() {
  newJonswapData = true;
  int oldMode = mode;
  //miniWaveTankJonswap jonswapTest(16.0, 1.0, 2.0)
  mode = 2;
  //jonswap.update(5.0, 3.0, 7.0);
  sigH = 5.0;
  peakF = 3.0;
  gam = 7.0;
  inputFnc(0);   //assign amps and update jonswap
  for (int i = 0; i < jonswap.getNum(); i++) {
    //test amplitude array:
    if (abs(amps[i] - exampleAmps[i]) > 0.01) {
      ampUnitTest = false;
    }

    //test time series:
    if (abs(inputFnc(i) - exampleTS[i]) > 0.01) {      //i acts as an arbitrary time
      TSUnitTest = false;
    }
    //////////////////////////////
    //Serial.print(amps[i]);    //To get the data that fills the example arrays
    //Serial.print(inputFnc(i));
    //Serial.print(", ");
    ////////////////////////////
  }
//  Serial.println("done");
//  while(1);
  //////////////////test encoder buffer:
  //If the initialization and setting functions worked, move on, otherwise, throw error and halt execution.
  if (encoderBuffInit && didItWork_MDR0 && didItWork_MDR1) {
    //passed
  } else {
    encoderTest = false;
  }
  mode = oldMode;   //reset mode to what it was before unit tests

}
