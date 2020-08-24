#include <Encoder.h>
#include<DueTimer.h>
#include<math.h>
#include <miniWaveTankJonswap.h>
miniWaveTankJonswap jonswap(512.0 / 32.0, 0.5, 2.5); //period, low frequency, high frequency. frequencies will be rounded to multiples of df(=1/period)
//^ISSUE. Acuracy seems to fall off after ~50 components when using higher frequencies(1,3 at 64 elements seems wrong).
bool newJonswapData = false;
volatile float sigH, peakF, _gamma;
volatile int mode = -1;    //-1 stop, 0 torque control, 1 feedback control, 2 sea state
volatile int n;   //number of components
bool ampUnitTest = true, TSUnitTest = true;
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
  unitTests();
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
volatile float calcTS(volatile float tm) {      //calculate jonswap timeseries values at time tm
  if (newJonswapData) {
    newJonswapData = false;
    jonswap.update(sigH, peakF, _gamma);
    n = jonswap.getNum();
    for (int i = 0; i < n; i++) {
      amps[i] = jonswap.getAmp()[i];
      freqs[i] = jonswap.getF()[i];
      phases[i] = jonswap.getPhase()[i];
    }
  }
  volatile float val = 0;
  for (volatile int i = 0; i < n; i++)           //function mode
  {
    val += amps[i] * sin(2 * pi * tm * freqs[i] + phases[i]);
  }
  return val;
}

float exampleAmps[] = {0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.01, 0.02, 0.05, 0.11, 0.20, 0.33, 0.48, 0.67, 0.87, 1.09, 1.30, 1.51, 1.70, 1.88, 2.03, 2.16};
float exampleTS[] = {2.13, -1.08, 3.21, 3.02, -0.65, 0.42, 0.96, -3.35, 3.49, -3.32, 1.43, 4.24, 3.59, 2.01, -7.29, 4.79, 2.13, -1.08, 3.21, 3.02, -0.65, 0.42, 0.96, -3.35, 3.49, -3.32, 1.43, 4.24, 3.59, 2.01, -7.29, 4.79};
void unitTests() {
  delay(100);
  newJonswapData = true;
  int oldMode = mode;
  //miniWaveTankJonswap jonswapTest(16.0, 1.0, 2.0)
  mode = 2;
  //jonswap.update(5.0, 3.0, 7.0);
  sigH = 5.0;
  peakF = 3.0;
  _gamma = 7.0;
  calcTS(0);   //assign amps and update jonswap
  for (int i = 0; i < jonswap.getNum(); i++) {
    //test amplitude array:
    if (abs(amps[i] - exampleAmps[i]) > 0.01) {
      ampUnitTest = false;
    }

    //test time series:
    if (abs(calcTS(i) - exampleTS[i]) > 0.01) {      //i acts as an arbitrary time
      TSUnitTest = false;
    }
    //Serial.print(amps[i]);    //To get the data that fills the example arrays
    //Serial.print(calcTS(i));
    //Serial.print(", ");
  }
  mode = oldMode;   //reset mode to what it was before unit tests
}
