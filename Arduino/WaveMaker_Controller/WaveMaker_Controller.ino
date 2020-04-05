#include <Encoder.h>
#include<math.h>


Encoder waveEnc(2, 3);   //pins 2 and 3(interupts)//for 800 ppr/3200 counts per revolution set dip switches(0100) //2048ppr/8192 counts per revolution max(0000)
const int stepPin = 4, dirPin = 5, limitPin = A0, probe1Pin = A1, probe2Pin = A2;
double t = 0;    //time in seconds
float speedScalar = 0;
int mode = 0;     //-1 is stop, 0 is jog, 1 is seastate
int n = 1;            //number of functions for the sea state
const int maxComponents = 60;   //max needed number of frequency components
float amps[maxComponents];
float phases[maxComponents];
float freqs[maxComponents];
float encPos = 0;
float desiredPos;   //used for jog mode
unsigned long previousStepMillis;
const int buffSize = 10;    //number of data points buffered in the moving average filter
float probe1Buffer[buffSize];
float probe2Buffer[buffSize];



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
    }
  }
  return val;
}
//////////////////////////////////////////////////


float interval = .01;   //time between each interupt call in seconds //max value: 1.04
float serialInterval = .0333;//.0333;   //time between each interupt call in seconds //max value: 1.04    .0333 is ~30 times a second to match processing's speed(30hz)
const float maxRate = 500.0;   //max mm/seconds

void setup()
{
  Serial.begin(19200);
  pinMode(stepPin, OUTPUT);
  pinMode(dirPin, OUTPUT);
  pinMode(13, OUTPUT);
  digitalWrite(13, LOW);    //initialization of maxRate indicator led
  digitalWrite(dirPin, HIGH);
  /////////Zero encoder:
  tone(stepPin, 100);   //start moving
  while (analogRead(limitPin) > 500) {}   //do nothing until the beam is broken
  tone(stepPin, 0);     //stop moving
  waveEnc.write(0);     //zero encoder

  //fill probe buffers with 0's:
  for (int i = 0; i < buffSize; i++)
  {
    probe1Buffer[i] = 0;
    probe2Buffer[i] = 0;
  }


  //interupt setup:
  cli();//stop interrupts
  TCCR4A = 0;// set entire TCCR4A register to 0
  TCCR4B = 0;// same for TCCR4B
  TCNT4  = 0;//initialize counter value to 0
  OCR4A = interval * 16000000.0 / 256.0 - 1; // = (interval in seconds)(16*10^6) / (1*1024)  (must be <65536) -1 to account for overflow(255 -> 0)
  TCCR4B |= (1 << WGM12);   // turn on CTC mode aka reset on positive compare(I think)
  TCCR4B |= (1 << CS42);// Set CS42 bit for 256 prescaler
  TIMSK4 |= (1 << OCIE4A);  // enable timer compare interrupt
  //////timer 5 for serial sending

  TCCR5A = 0;// set entire TCCR5A register to 0
  TCCR5B = 0;// same for TCCR5B
  TCNT5  = 0;//initialize counter value to 0
  OCR5A = serialInterval * 16000000.0 / 256.0 - 1; // = (interval in seconds)(16*10^6) / (1*1024)  (must be <65536) -1 to account for overflow(255 -> 0)
  TCCR5B |= (1 << WGM12);   // turn on CTC mode aka reset on positive compare(I think)
  TCCR5B |= (1 << CS52);// Set CS42 bit for 256 prescaler
  TIMSK5 |= (1 << OCIE5A);  // enable timer compare interrupt

  sei();//allow interrupts
  ////////////////////////////////////////////// For testing only:
  /*
    mode = 1;
    n = 4;
    amps[0] = 1.2;
    phases[0] = 0;
    freqs[0] = .2;

    amps[1] = 2.8;
    phases[1] = 2.4;
    freqs[1] = .3;

    amps[2] = 3.8;
    phases[2] = 3.4;
    freqs[2] = .2;

    amps[3] = 3.8;
    phases[3] = 3.4;
    freqs[3] = .1;
  */
}

void loop()   //60 microseconds
{
  encPos = waveEnc.read() * (1 / encStepsPerTurn) * leadPitch; //steps*(turns/step)*(mm/turn)
  t = micros() / 1000000.0;
  readSerial();
  updateSpeedScalar();
}

float futurePos;
float error;
ISR(TIMER4_COMPA_vect)    //function called by interupt     //Takes about .4 milliseconds
{
  float pos = encPos;
  error = futurePos - encPos;   //where we told it to go vs where it is
  futurePos = inputFnc(t + interval);// + error;  //time plus delta time plus previous error. maybe error should scale as a percentage of speed? !!!!!!!!!!!!!!NEEDS TESTING
  float vel = speedScalar * (futurePos - pos) / interval; //desired velocity in mm/second   //ramped up over about a second   //LIKELY NEEDS TUNING
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
    digitalWrite(13, HIGH);   //on board led turns on if max speed was reached
    //Serial.println("max");
  }
  if (mode != -1)   //only plays a tone if mode is not STOP
  {
    tone(stepPin, mmToSteps(sp));     //steps per second
  }
  else
  {
    noTone(stepPin);
  }
}
ISR(TIMER5_COMPA_vect)    //takes ___ milliseconds
{
  /*
    1: probe 1
    2: probe 2
    p: position
    d: other data for debugging
  */
  //Serial.println(mapFloat(analogRead(probe1Pin), 0.0, 560.0, 0.0, 27.0));
  pushBuffer(probe1Buffer, mapFloat(analogRead(probe1Pin), 0.0, 560.0, 0.0, 27.0));     //maps to cm and adds to data buffer
  pushBuffer(probe2Buffer, mapFloat(analogRead(probe2Pin), 0.0, 560.0, 0.0, 27.0));
  Serial.write('1');    //to indicate wave probe data
  sendFloat(averageArray(probe1Buffer));
  Serial.write('2');    //to indicate wave probe data
  sendFloat(averageArray(probe2Buffer));
  Serial.write('p');    //to indicate position
  sendFloat(encPos);
  Serial.write('d');    //to indicate alternate data
  sendFloat(futurePos);
}
/* '!' indicates mode switch, next int is mode
   j indicates jog position
   n indicates length of vectors/number of functions in sea state(starting at 1)
   a indicates incoming amp vector
   p indicates incoming phase vector
   f indicates incoming frequency vector
*/
void readSerial()
{
  if (Serial.available() > 0)
  {
    speedScalar = 0;    //if anything happens, reset the speed scalar(and ramp up speed)
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
void sendFloat(float f)
{
  f = round(f * 100.0) / 100.0; //limits to two decimal places
  String dataStr = "<";    //starts the string
  dataStr += String(f);
  dataStr += ">";    //end of string
  Serial.print(dataStr);
}
void updateSpeedScalar()    //used to prevent jumps/smooth start
{
  //Serial.println(speedScalar);
  if (speedScalar < 1)
  {
    speedScalar += .005;
  }
  else
  {
    speedScalar = 1.0;
  }
}
float mmToSteps(float mm)
{
  return mm * (1 / leadPitch) * (1 / gearRatio) * motorStepsPerTurn; //mm*(lead turns/mm)*(motor turns/lead turn)*(steps per motor turn)
}
float mapFloat(long x, long in_min, long in_max, long out_min, long out_max)
{
  return (float)(x - in_min) * (out_max - out_min) / (float)(in_max - in_min) + out_min;
}
float averageArray(float *arr)
{
  float total = 0;
  for (int i = 0; i < buffSize; i++)
  {
    total += arr[i];
  }
  total /= buffSize;
  return total;
}
void pushBuffer(float* arr, float f)
{
  for (int i = buffSize - 1; i > 0; i--)
  {
    arr[i] = arr[i - 1];
  }
  arr[0] = f;
}
