#include <Encoder.h>
#include<math.h>


Encoder waveEnc(2, 3);   //pins 2 and 3(interupts)//for 800 ppr/3200 counts per revolution set dip switches(0100) //2048ppr/8192 counts per revolution max(0000)
const int stepPin = 4, dirPin = 5;
double t;    //time in seconds
int mode = 0;     //0 is jog, 1 is seastate
int n = 1;            //numbe of functions for the sea state
const int maxComponents = 60;   //max needed number of frequency components
float amps[maxComponents];
float phases[maxComponents];
float freqs[maxComponents];
float encPos = 0;   //how many steps have been taken acording to the encoder(in steps)
float desiredPos;   //used for jog mode
unsigned long previousStepMillis;





////////////////////////////////////////////////
//Derived funciton here:
const float pi = 3.14159265358979;
const float leadPitch = 10.0;     //mm/turn
const float gearRatio = 40.0 / 12.0; //motor turns per lead screw turns
const float motorStepsPerTurn = 400.0;   //steps per motor revolution
const float encStepsPerTurn = 3200.0;

float inputFnc(float tm)   //inputs time in seconds //outputs position in mm
{
  float val = 0;
  if (mode == 0)
  {
    val = desiredPos;
  }
  else if (mode == 1)
  {
    for (int i = 0; i < n; i++)
    {
      val += amps[i] * sin(2 * pi * tm * freqs[i] + phases[i]);
      //Serial.println(n);
    }
  }
  Serial.println(val);
  return val;
}
//////////////////////////////////////////////////


float stepInterval = .01;   //in seconds
const float maxRate = 500.0;   //max mm/seconds

void setup()
{
  Serial.begin(9600);
  pinMode(stepPin, OUTPUT);
  pinMode(dirPin, OUTPUT);
  digitalWrite(dirPin, HIGH);
  previousStepMillis = millis();

  ////////////////////////////////////////////// For testing only:
  mode = 1;
  n = 3;
  amps[0] = 1.2;
  phases[0] = 0;
  freqs[0] = .2;

  amps[1] = 2.8;
  phases[1] = 2.4;
  freqs[1] = 2.6;

  amps[2] = 3.8;
  phases[2] = 3.4;
  freqs[3] = 3.2;
}

void loop()
{

  encPos = waveEnc.read() * (1 / encStepsPerTurn) * leadPitch; //steps*(turns/step)*(mm/turn)
  t = millis() / (float)1000;
  readSerial();
  //////////////////
  unsigned long currentMillis = millis();
  if (currentMillis - previousStepMillis >= stepInterval)
  {
    //////////This should instead be called by an interupt
    moveMotor();
    previousStepMillis = currentMillis;
  }
  ////////////////////////
}
float futurePos;
void moveMotor()
{
  float pos = encPos;
  //Serial.println(pos);
  futurePos = inputFnc(t + stepInterval);  //time plus delta time
  float vel = (futurePos - pos) / stepInterval; //desired velocity in mm/second
  //Serial.println(futurePos);
  if (vel > 0)
  {
    digitalWrite(dirPin, HIGH);
  }
  else
  {
    digitalWrite(dirPin, LOW);
  }
  float sp = abs(vel);     //steping is always positive, so convert to speed
  if (sp < 2.6)    //31hz is the lowest frequency of tone(), in mm/s this is 2.6
  {
    sp = 2.6;
    //Serial.println("min");
  }
  else if (sp > maxRate)   //max speed
  {
    sp = maxRate;
    //Serial.println("max");
  }
  tone(stepPin, mmToSteps(sp));     //steps per second
}


float mmToSteps(float mm)
{
  return mm * (1 / leadPitch) * (1 / gearRatio) * motorStepsPerTurn; //mm*(lead turns/mm)*(motor turns/lead turn)*(steps per motor turn)
}

void readSerial()
{
  /* '!' indicates mode switch, next int is mode
     j indicates jog position

     n indicates length of vectors/number of functions in sea state(starting at 1)
     a indicates incoming amp vector
     p indicates incoming phase vector
     f indicates incoming frequency vector
  */
  if (Serial.available())
  {
    char c = Serial.read();
    switch (c)
    {
      case '!':
        mode = (int)readFloat();
        if (mode > maxComponents)
        {
          mode = maxComponents;     //to prevents reading invalid index
        }
        break;
      case 'n':
        n = (int)readFloat();
        break;
      case 'j':
        desiredPos = readFloat();
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
  /*
    Serial.print("mode: ");
    Serial.print(mode);
    Serial.print(" ");
    Serial.print("pos ");
    Serial.print(desiredPos);
    Serial.print(" ");
    Serial.print("amp0 ");
    Serial.print(amps[0]);
    Serial.print(" ");
    Serial.print("amp1 ");
    Serial.print(amps[1]);
    Serial.print(" ");
    Serial.print("amp2 ");
    Serial.print(amps[2]);
    Serial.print(" ");
    Serial.print("amp3 ");
    Serial.print(amps[3]);
    Serial.print(" ");
    Serial.print("amp4 ");
    Serial.println(amps[4]);
  */
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
    return 0.0;
  }
}
