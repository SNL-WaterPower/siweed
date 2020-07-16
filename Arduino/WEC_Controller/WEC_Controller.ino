#include <Encoder.h>
#include<DueTimer.h>
//#include<math.h>
#include<miniWaveTankJonswap.h>

miniWaveTankJonswap jonswap(512.0 / 32.0, 0.5, 2.5); //period, low frequency, high frequency. frequencies will be rounded to multiples of df(=1/period)
//^ISSUE. Acuracy seems to fall off after ~50 components when using higher frequencies(1,3 at 64 elements seems wrong).
volatile int mode = -1;    //-1 stop, 0 torque control, 1 feedback control, 2 sea state mode
volatile double t = 0;    //time in seconds
volatile float tau = 0, kp = 0, kd = 0, power = 0, vel = 0;
volatile float tauCommand = 0;   //tau after any modifications
const int tauPin = DAC0, enablePin = 6, l1Pin = 10, l2Pin = 11, l3Pin = 12, l4Pin = 13;
const float l1Lim = 1.1, l2Lim = 2.2, l3Lim = 3.3, l4Lim = 4.4;       //!!NEEDS EDITING!!the power threshholds of the led groups
Encoder wecEnc(2, 3); //pins 2 and 3(interupts)//for 800 ppr/3200 counts per revolution set dip switches(0100) //2048ppr/8192 counts per revolution max(0000)
volatile float encPos;
const float pi = 3.14159265358979;
const float encStepsPerTurn = 3200.0;
const float teethPerTurn = 5;   //EDIT
const float mmPerTooth = 10;    //EDIT
const float minTau = -5, maxTau = 5;    //EDIT

volatile float sigH, peakF, _gamma;
bool newJonswapData = false;
const int maxComponents = 100;   //max needed number of frequency components
volatile float amps[maxComponents];
volatile float phases[maxComponents];
volatile float freqs[maxComponents];

void setup()
{
  initSerial();
  analogWriteResolution(12);    //analog write now runs from 0 to 4095
  pinMode(enablePin, OUTPUT);
  digitalWrite(enablePin, LOW);
  pinMode(l1Pin, OUTPUT);
  digitalWrite(l1Pin, HIGH);
  pinMode(l2Pin, OUTPUT);
  digitalWrite(l2Pin, HIGH);
  pinMode(l3Pin, OUTPUT);
  digitalWrite(l3Pin, HIGH);
  pinMode(l4Pin, OUTPUT);
  digitalWrite(l4Pin, HIGH);
  delay(1000);      //keep the lights on for 1 second
  digitalWrite(l1Pin, LOW);
  digitalWrite(l2Pin, LOW);
  digitalWrite(l3Pin, LOW);
  digitalWrite(l4Pin, LOW);
  wecEnc.write(0);     //zero encoder
  initInterrupts();
}

void loop()
{
  encPos = wecEnc.read() * (1 / encStepsPerTurn) * teethPerTurn * mmPerTooth; //steps*(turns/step)*(mm/turn)
  t = micros() / 1.0e6;
  power = -1 * tauCommand * vel;
  readSerial();

  if (power > l4Lim)
  {
  digitalWrite(l1Pin, HIGH);
  digitalWrite(l2Pin, HIGH);
  digitalWrite(l3Pin, HIGH);
  digitalWrite(l4Pin, HIGH);
  }
  else if (power > l3Lim)
  {
  digitalWrite(l1Pin, HIGH);
  digitalWrite(l2Pin, HIGH);
  digitalWrite(l3Pin, HIGH);
  digitalWrite(l4Pin, LOW);
  }
  else if (power > l2Lim)
  {
  digitalWrite(l1Pin, HIGH);
  digitalWrite(l2Pin, HIGH);
  digitalWrite(l3Pin, LOW);
  digitalWrite(l4Pin, LOW);
  }
  else if (power > l1Lim)
  {
  digitalWrite(l1Pin, HIGH);
  digitalWrite(l2Pin, LOW);
  digitalWrite(l3Pin, LOW);
  digitalWrite(l4Pin, LOW);
  }
  else
  {
  digitalWrite(l1Pin, LOW);
  digitalWrite(l2Pin, LOW);
  digitalWrite(l3Pin, LOW);
  digitalWrite(l4Pin, LOW);
  }
}

volatile float mapFloat(volatile long x, volatile long in_min, volatile long in_max, volatile long out_min, volatile long out_max)
{
  return (float)(x - in_min) * (out_max - out_min) / (float)(in_max - in_min) + out_min;
}
