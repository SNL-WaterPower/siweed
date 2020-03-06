#include <Encoder.h>
#include<math.h>

Encoder waveEnc(2,3);    //pins 2 and 3(interupts)//for 800 ppr/3200 counts per revolution set dip switches(0100) //2048ppr/8192 counts per revolution max(0000)
int motorPos = 0;   //how many steps have been taken acording to the motor(in steps)
int encPos = 0;   //how many steps have been taken acording to the encoder(in steps)
const float pi = 3.14159265358979;
const int stepPin = 4, dirPin = 5;
unsigned long previousStepMicros;
unsigned long previousDirMicros;
long stepInterval = 150;    //motor controller should be able to handle down to 2.5us  //tests yeild down to ~130us
long dirInterval = 300000;
float amp = 5;    //in ______
float freq = .5;     //hz
float leadPitch = 1;   //m/rad
float k = 6.28/400;      //rad/pulse


void setup()
{
  Serial.begin(9600); 
  pinMode(stepPin, OUTPUT);
  pinMode(dirPin, OUTPUT);
  digitalWrite(dirPin, HIGH);
  previousStepMicros = micros();
  previousDirMicros = micros();
  waveEnc.write(0);   //initialized at 0
}
int x;
void loop()
{
  encPos = round( (float)waveEnc.read()/8 );    //this allows for rounding up(as opposed to just "waveEnc.read()/8")
  
  //stepInterval = asin(x+.001)-asin(x);
  //Serial.print("encPos: ");
  //Serial.println(encPos);
  float t = (float)millis()/1000;
  Serial.println(motorPos);
  spinMotor();
}
void spinMotor()
{
  float t = (float)millis()/1000;   //time in seconds
  
  if(cos(t*freq) != 0)
  {
    stepInterval = 1000000*(leadPitch*k)/(freq*(float)cos(t*2*pi*freq)*amp);
  }
  if (stepInterval > 0)       //set direction
  {
     digitalWrite(dirPin, HIGH);
  }
  else
  {
    digitalWrite(dirPin, LOW);
  }
  stepInterval = abs(stepInterval);   //make steps positive

  ////////////////////////////////////////////////////////////////
  //float sinWave = amp*sin(2*t*pi*freq);
  //stepInterval = abs(asin(motorPos)-asin(motorPos +1));
  //////////////////////////////////////////////////////////////

  
  unsigned long currentMicros = micros();
  if (currentMicros - previousStepMicros >= stepInterval)   //step motor
  {
    previousStepMicros = currentMicros;
    digitalWrite(stepPin, !digitalRead(stepPin));
    if(digitalRead(stepPin) == LOW)      //only counts at the end of a step
    {
      if(digitalRead(dirPin) == HIGH)   //Direction not tested, might have to be reversed
      {
        motorPos++;
      }
      else
      {
        motorPos--;
      }
    }
  }
}
void correctDrift()   //compares motor steps to encoder steps and adjusts accordingly
{
  
}
