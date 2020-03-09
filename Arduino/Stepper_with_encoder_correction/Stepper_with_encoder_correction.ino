#include <Encoder.h>
#include<math.h>

////////////////////////////////////////////////
//Position funciton here:
const float pi = 3.14159265358979;
const float leadPitch = 10.0;     //mm/turn
const float gearRatio = 40.0 / 12.0; //motor turns per lead screw turns
const float motorStepsPerTurn = 400.0;   //steps per motor revolution
const float encStepsPerTurn = 3200.0;   //steps per encoder revolution
volatile float amp = 20.0; //in mm
volatile float hz = 1.5;

float inputFnc(float tm)   //inputs time in seconds //outputs velocity in mm/second
{
  return cos(tm * 2 * pi * hz) * amp;
}
//////////////////////////////////////////////////

Encoder waveEnc(2, 3);   //pins 2 and 3(interupts)//for 800 ppr/3200 counts per revolution set dip switches(0100) //2048ppr/8192 counts per revolution max(0000)
const int stepPin = 4, dirPin = 5;
float encPos = 0;   //distace travelled in mm
unsigned long previousStepMillis;
double t;    //time in seconds
float stepInterval = .05;   //in seconds  //min: .02
const float maxRate = 400.0;   //max mm/seconds   //may need to be adjusted

void setup()
{
  Serial.begin(9600);
  pinMode(stepPin, OUTPUT);
  pinMode(dirPin, OUTPUT);
  digitalWrite(dirPin, HIGH);
  previousStepMillis = millis();
}

void loop()
{
  recieveSerial();
  encPos = waveEnc.read() * (1 / encStepsPerTurn) * leadPitch; //steps*(turns/step)*(mm/turn)
  t = millis() / (float)1000;
  Serial.println(encPos);

  unsigned long currentMillis = millis();
  if (currentMillis - previousStepMillis >= stepInterval)
  {
    //////////This should instead be called by an interupt
    moveMotor();
    previousStepMillis = currentMillis;
  }

}
void moveMotor()
{
  float pos = encPos;
  float futurePos = inputFnc(t + stepInterval);  //time plus delta time
  float vel = (futurePos - pos) / stepInterval; //desired velocity in mm/second
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
    Serial.println("min");
  }
  else if(sp > maxRate)    //max speed
  {
    sp = maxRate;
    Serial.println("max");
  }
  tone(stepPin, mmToSteps(sp));
}


float mmToSteps(float mm)
{
  return mm * (1 / leadPitch) * (1 / gearRatio) * motorStepsPerTurn; //mm*(lead turns/mm)*(motor turns/lead turn)*(steps per motor turn)
}

void recieveSerial()
{
  if(Serial.available())
  {
    String str = Serial.readStringUntil('e');   //e marks ending character    
    //needs ending character and a way to identify which variable is being assigned
  }
}
