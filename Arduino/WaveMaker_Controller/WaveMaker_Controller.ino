#include <miniWaveTankJonswap.h>
#include <SuperDroidEncoderBuffer.h>
#include<DueTimer.h>
#include<math.h>
#include <SPI.h>
#include <MD_AD9833.h>
MD_AD9833  AD(10);  // Hardware SPI
miniWaveTankJonswap jonswap(512.0 / 64.0, 0.5, 2.5); //period, low frequency, high frequency. frequencies will be rounded to multiples of df(=1/period)
//jonswap(512.0 / 32.0, 0.5, 2.5);
//df = 1 / _period; num_fs = (int)((f_high - f_low) / df);
//^ISSUE. Acuracy seems to fall off after ~50 components when using higher frequencies(1,3 at 64 elements seems wrong).
SuperDroidEncoderBuffer encoderBuff(52);
bool encoderBuffInit, didItWork_MDR0, didItWork_MDR1, didItWork_DTR;   //variables for unit testing
unsigned char MDR0_settings = MDRO_x4Quad | MDRO_freeRunningCountMode | MDRO_indexDisable | MDRO_syncIndex | MDRO_filterClkDivFactor_1;
unsigned char MDR1_settings = MDR1_4ByteCounterMode | MDR1_enableCounting | MDR1_FlagOnIDX_NOP | MDR1_FlagOnCMP_NOP | MDR1_FlagOnBW_NOP | MDR1_FlagOnCY_NOP;
const int  dirPin = 5, limitPin = A0, probe1Pin = A1, probe2Pin = A2;
float initialProbe1;    //initial height of probe 1
volatile double t = 0;    //time in seconds
volatile float speedScalar = 0;
volatile int mode = 1;     // 1 = jog, 2 = function, 3 = sea, 4 = off
volatile int n = 1;            //number of functions for the time series(either 1 or jonswap.getNum())
const int maxComponents = 100;   //max needed number of frequency components
volatile float amps[maxComponents];
volatile float phases[maxComponents];
volatile float freqs[maxComponents];
volatile float sigH, peakF, gam, a, f;  //jonswap vars and amplitude and frequncy of sine wave //"gamma" is used in another library
//volatile float encPos;
bool newJonswapData = false, sendUnitTests = false;
volatile float j = 0;   //used for jog mode, starts at 0
const int buffSize = 10;    //number of data points buffered in the moving average filter
volatile float probe1Buffer[buffSize];
volatile float probe2Buffer[buffSize];
volatile float jogBuffer[buffSize];
const float maxRate = 0.25;   //max m/seconds
//Derived funciton here:
const float leadPitch = .01;     //m/turn
const float gearRatio = 12.0 / 60.0; //motor turns per lead screw turns
const float motorStepsPerTurn = 400.0;   //steps per motor revolution
const float encStepsPerTurn = 3200.0;

void setup() {
  initSerial();
  initialProbe1 = analogRead(probe1Pin);
  AD.begin();
  AD.setMode(MD_AD9833::MODE_SQUARE1);
  //encoder buffer setup:
  for (int i = 0; i < 10; i++)      //tries i times or until it works. Messy but functional
  {
    encoderBuffInit = encoderBuff.begin();    //configure encoder buffer and assign bools for unit testing
    didItWork_MDR0 = encoderBuff.setMDR0(MDR0_settings);
    didItWork_MDR1 = encoderBuff.setMDR1(MDR1_settings);
    if (encoderBuffInit && didItWork_MDR0 && didItWork_MDR1)
    {
      break;
    }
  }

  pinMode(dirPin, OUTPUT);
  pinMode(13, OUTPUT);
  digitalWrite(13, LOW);    //initialization of maxRate indicator led
  /////////Zero encoder:
  digitalWrite(dirPin, HIGH);
  AD.setFrequency(MD_AD9833::CHAN_0, 100);
  float initialPos = encPos();
  delay(20);
  while (analogRead(limitPin) > 500) {   //move up until the beam is broken
    if (encPos() - initialPos == 0)    //if motor is not moving(software testing), move on.
      break;
  }
  digitalWrite(dirPin, LOW);    //switch direction
  delay(20);
  while (analogRead(limitPin) < 500) {  //move down until the beam is unbroken
    if (encPos() - initialPos == 0)    //if motor is not moving(software testing), move on.
      break;
  }
  AD.setFrequency(MD_AD9833::CHAN_0, 0);

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
    speedScalar += .00007;   //value determined by testing
  } else {
    speedScalar = 1.0;
  }
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
int intScaleFactor = 100000;
volatile int checksum() {     //adds the values of anything that can ba changes by processing.
  return (int)(intScaleFactor * mode) +
         (int)(intScaleFactor * j) +
         (int)(intScaleFactor * a) +
         (int)(intScaleFactor * f) +
         (int)(intScaleFactor * sigH) +
         (int)(intScaleFactor * peakF) +
         (int)(intScaleFactor * gam);
}
bool ampUnitTest = true, TSUnitTest = true, encoderTest = true;
//float exampleAmps[] = {0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.01, 0.02, 0.05, 0.11, 0.20, 0.33, 0.48, 0.67, 0.87, 1.09, 1.30, 1.51, 1.7, 1.88, 2.03, 2.16};
//float exampleAmps[] = {0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.01, 0.09, 0.32, 0.77, 1.39, 2.08, 2.72, 3.25};
float exampleAmps[] = {0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00};
//float exampleTS[] = {2.13, -1.08, 3.21, 3.02, -0.65, 0.42, 0.96, -3.35, 3.49, -3.32, 1.43, 4.24, 3.59, 2.01, -7.29, 4.79, 2.13, -1.08, 3.21, 3.02, -0.65, 0.42, 0.96, -3.35, 3.49, -3.32, 1.43, 4.24, 3.59, 2.01, -7.29, 4.79};
//float exampleTS[] = {2.24, -0.75, 3.53, -3.00, -3.04, 8.26, 2.77, 0.98, 2.24, -0.75, 3.53, -3.00, -3.04, 8.26, 2.77, 0.98};
float exampleTS[] = {0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00};
void unitTests() {
  newJonswapData = true;
  int oldMode = mode;
  //miniWaveTankJonswap jonswapTest(16.0, 1.0, 2.0)
  mode = 2;
  //jonswap.update(5.0, 3.0, 7.0);
  sigH = 5.0;
  peakF = 3.0;
  gam = 7.0;
  posFnc(0);   //assign amps and update jonswap
  for (int i = 0; i < jonswap.getNum(); i++) {
    //test amplitude array:
    if (abs(amps[i] - exampleAmps[i]) > 0.01) {
      ampUnitTest = false;
    }

    //test time series:
    if (abs(posFnc(i) - exampleTS[i]) > 0.01) {      //i acts as an arbitrary time
      TSUnitTest = false;
    }
    //////////////////////////////
    //Serial.print(amps[i]);    //To get the data that fills the example arrays
    //Serial.print(posFnc(i));
    //Serial.print(", ");
    ////////////////////////////
  }
  //Serial.println("done");
  //while(1);
  sigH = 0;   //return values to 0, so checksum is correct
  peakF = 0;
  gam = 0;
  //////////////////test encoder buffer:
  //If the initialization and setting functions worked, move on, otherwise, throw error and halt execution.
  if (encoderBuffInit && didItWork_MDR0 && didItWork_MDR1) {
    //passed
  } else {
    encoderTest = false;
  }
  mode = oldMode;   //reset mode to what it was before unit tests

}
