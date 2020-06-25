#include <miniWaveTankJonswap.h>
#include <Encoder.h>
#include<math.h>

miniWaveTankJonswap jonswap(512.0 / 32.0, 0.5, 2.5); //period, low frequency, high frequency. frequencies will be rounded to multiples of df(=1/period)
//^ISSUE. Acuracy seems to fall off after ~50 components when using higher frequencies(1,3 at 64 elements seems wrong).
Encoder waveEnc(2, 3);   //pins 2 and 3(interupts)//for 800 ppr/3200 counts per revolution set dip switches(0100) //2048ppr/8192 counts per revolution max(0000)
const int stepPin = 4, dirPin = 5, limitPin = A0, probe1Pin = A1, probe2Pin = A2;
volatile double t = 0;    //time in seconds
volatile float speedScalar = 0;
volatile int mode = 0;     //-1 is stop, 0 is jog, 1 is sine, 2 is sea state
volatile int n = 1;            //number of functions for the time series(either 1 or jonswap.getNum())
const int maxComponents = 100;   //max needed number of frequency components
volatile float amps[maxComponents];
volatile float phases[maxComponents];
volatile float freqs[maxComponents];
volatile float sigH, peakF, gamma;
volatile float encPos = 0;
volatile float desiredPos;   //used for jog mode
const int buffSize = 10;    //number of data points buffered in the moving average filter
volatile float probe1Buffer[buffSize];
volatile float probe2Buffer[buffSize];

////////////////////////////////////////////////
//Derived funciton here:
const float pi = 3.14159265358979;
const float leadPitch = 10.0;     //mm/turn
const float gearRatio = 40.0 / 12.0; //motor turns per lead screw turns
const float motorStepsPerTurn = 400.0;   //steps per motor revolution
const float encStepsPerTurn = 3200.0;

volatile float inputFnc(volatile float tm) {  //inputs time in seconds //outputs position in mm
  volatile float val = 0;
  if (mode == 0)    //jog
  {
    val = desiredPos;
  }
  else if (mode > 0)    //1 or 2
  {
    for (volatile int i = 0; i < n; i++)
    {
      val += amps[i] * sin(2 * pi * tm * freqs[i] + phases[i]);
      //Serial.println(amps[i]);// + " " + freqs[i]+" "+phases[i]);
      //Serial.println(freqs[i]);
      //Serial.println(phases[i]);
    }
  }
  return val;
}
const float maxRate = 500.0;   //max mm/seconds

void setup()
{
  initSerial();
  pinMode(stepPin, OUTPUT);
  pinMode(dirPin, OUTPUT);
  pinMode(13, OUTPUT);
  digitalWrite(13, LOW);    //initialization of maxRate indicator led
  digitalWrite(dirPin, HIGH);
  /////////Zero encoder:
  tone(stepPin, 100);   //start moving
  while (analogRead(limitPin) > 500) {}   //do nothing until the beam is broken
  noTone(stepPin);   //stop moving
  waveEnc.write(0);     //zero encoder

  //fill probe buffers with 0's:
  for (int i = 0; i < buffSize; i++)
  {
    probe1Buffer[i] = 0;
    probe2Buffer[i] = 0;
  }
  //fill amps freqs and phases with 0's:
  for (int i = 0; i < maxComponents; i++)
  {
    amps[i] = 0;
    freqs[i] = 0;
    phases[i] = 0;
  }
  initInterupts();
}

void loop() {   //__ microseconds 
  encPos = waveEnc.read() * (1 / encStepsPerTurn) * leadPitch; //steps*(turns/step)*(mm/turn)
  t = micros() / 1.0e6;
  readSerial();
  updateSpeedScalar();
}
void updateSpeedScalar() {    //used to prevent jumps/smooth start
  //Serial.println(speedScalar);
  if (speedScalar < 1) {
    speedScalar += .005;
  }else{
    speedScalar = 1.0;
  }
}
volatile float mmToSteps(volatile float mm) {
  return mm * (1 / leadPitch) * (1 / gearRatio) * motorStepsPerTurn; //mm*(lead turns/mm)*(motor turns/lead turn)*(steps per motor turn)
}
volatile float mapFloat(volatile long x, volatile long in_min, volatile long in_max, volatile long out_min, volatile long out_max) {
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
