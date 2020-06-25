#include <Encoder.h>
#include<DueTimer.h>
#include<math.h>
volatile int mode = -1;    //-1 stop, 0 torque control, 1 feedback control, 2 function mode
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

const float interval = .01;    //interval of updateTau interupt in seconds
const float serialInterval = .0333; //interval of serial interupt

volatile int n = 1;            //number of components
const int maxComponents = 100;   //max needed number of frequency components
volatile float amps[maxComponents];
volatile float phases[maxComponents];
volatile float freqs[maxComponents];

void setup()
{
  Serial.begin(500000);
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
  Timer.getAvailable().attachInterrupt(sendSerial).start(serialInterval * 1.0e6);
  delay(50);
  Timer.getAvailable().attachInterrupt(updateTau).start(interval * 1.0e6);
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
volatile float pos;
void updateTau()    //called by interupt
{
  volatile float prevPos = pos;
  pos = encPos;
  vel = (pos - prevPos) / interval;
  switch (mode)
  {
    case -1:
      digitalWrite(enablePin, LOW);   //stop
      break;
    case 0:
      tauCommand = tau;       //direct control
      break;
    case 1:
      tauCommand = kp * pos + kd * vel;      //PD feedback control
      break;
    case 2:
      tauCommand = 0;
      for (volatile int i = 0; i < n; i++)           //function mode
      {
        tauCommand += amps[i] * sin(2 * pi * t * freqs[i] + phases[i]);
      }
      break;
  }
  if (mode != -1)
  {
    analogWrite(tauPin, mapFloat(tauCommand, minTau, maxTau, 0, 4095));    //!!!!!!!NEEDS TO ACCOUNT FOR EDGE ZONES//sends to the motor controller after mapping from newtom/meters to analog
    digitalWrite(enablePin, HIGH);
  }
}
void sendSerial()   //called by interupt
{
  /*
    e: encoder position
    t: tau commanded to motor
    p: power
  */
  Serial.write('e');
  sendFloat(encPos);
  Serial.write('t');
  sendFloat(tauCommand);
  Serial.write('p');
  sendFloat(power);
}
void readSerial()
{
  /* '!' indicates mode switch, next int is mode
    t indicates torque command
    k indicates kp -p was taken
    d indicates kd
    n indicates length of vectors/number of functions in sea state(starting at 1)
    a indicates incoming amp vector
    p indicates incoming phase vector
    f indicates incoming frequency vector
  */
  if (Serial.available() > 0)
  {
    char c = Serial.read();
    switch (c)
    {
      case '!':
        mode = (int)readFloat();
        break;
      case 'n':
        n = (int)readFloat();
        if (n > maxComponents)
        {
          n = maxComponents;     //to prevents reading invalid index
        }
        break;
      case 't':
        tau = readFloat();
        break;
      case 'k':
        kp = readFloat();
        break;
      case 'd':
        kd = readFloat();
        break;
      case 'a':
        for (int i = 0; i < n; i++)
        {
          amps[i] = readFloat();
        }
        break;
      case 'p':
        for (int i = 0; i < n; i++)
        {
          phases[i] = readFloat();
        }
        break;
      case 'f':
        for (int i = 0; i < n; i++)
        {
          freqs[i] = readFloat();
        }
        break;
    }
  }
}
float readFloat()
{
  while (Serial.available() < 1) {}
  if (Serial.read() == '<')
  {
    String str = Serial.readStringUntil('>');
    return str.toFloat();
  }
  else
  {
    return -1.0;
  }
}
volatile void sendFloat(volatile float f)
{
  f = round(f * 100.0) / 100.0; //limits to two decimal places
  String dataStr = "<";    //starts the string
  dataStr += String(f);
  dataStr += ">";    //end of string
  Serial.print(dataStr);
}
volatile float mapFloat(volatile long x, volatile long in_min, volatile long in_max, volatile long out_min, volatile long out_max)
{
  return (float)(x - in_min) * (out_max - out_min) / (float)(in_max - in_min) + out_min;
}
