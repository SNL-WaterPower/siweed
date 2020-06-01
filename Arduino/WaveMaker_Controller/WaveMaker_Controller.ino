#include <Encoder.h>
#include<math.h>


Encoder waveEnc(2, 3);   //pins 2 and 3(interupts)//for 800 ppr/3200 counts per revolution set dip switches(0100) //2048ppr/8192 counts per revolution max(0000)
const int stepPin = 4, dirPin = 5, limitPin = A0, probe1Pin = A1, probe2Pin = A2;
volatile double t = 0;    //time in seconds
volatile float speedScalar = 0;
volatile int mode = 0;     //-1 is stop, 0 is jog, 1 is seastate
volatile int n = 1;            //number of functions for the sea state
const int maxComponents = 100;   //max needed number of frequency components
volatile float amps[maxComponents];
volatile float phases[maxComponents];
volatile float freqs[maxComponents];
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

volatile float inputFnc(volatile float tm)   //inputs time in seconds //outputs position in mm
{
  volatile float val = 0;
  if (mode == 0)
  {
    val = desiredPos;
  }
  else if (mode == 1)
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
///////////////////////////////////////////////////////////////////////////////////////////////
const float interval = .01;   //time between each interupt call in seconds //max value: 1.04
const float serialInterval = .0333;//.0333;   //time between each interupt call in seconds //max value: 1.04    .0333 is ~30 times a second to match processing's speed(30hz)
const float maxRate = 500.0;   //max mm/seconds

void setup()
{
  Serial.begin(500000);
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
  //fill amps freqs and phases with 0's:
  for (int i = 0; i < maxComponents; i++)
  {
    amps[i] = 0;
    freqs[i] = 0;
    phases[i] = 0;
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

void loop()   //__ microseconds
{
  encPos = waveEnc.read() * (1 / encStepsPerTurn) * leadPitch; //steps*(turns/step)*(mm/turn)
  t = micros() / 1.0e6;
  readSerial();
  /////for testing:
  /*
    while(Serial.available())
    {
    char c = Serial.read();
    Serial.print(c);
    delay(10);
    }
  */
  updateSpeedScalar();
}

volatile float futurePos;
volatile float error;
ISR(TIMER4_COMPA_vect)    //function called by interupt     //Takes about .4 milliseconds
{
  volatile float pos = encPos;
  error = futurePos - pos;   //where we told it to go vs where it is
  futurePos = inputFnc(t + interval);// + error;  //time plus delta time plus previous error. maybe error should scale as a percentage of speed? !!!!!!!!!!!!!!NEEDS TESTING
  volatile float vel = speedScalar * (futurePos - pos) / interval; //desired velocity in mm/second   //ramped up over about a second   //LIKELY NEEDS TUNING
  if (vel > 0)
  {
    digitalWrite(dirPin, HIGH);
  }
  else
  {
    digitalWrite(dirPin, LOW);
  }
  volatile float sp = abs(vel);     //steping is always positive, so convert to speed
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
  Serial.println();
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
  if (Serial.available() >= 6)    //if a whole float is through: n+100>   !!!this may break with larger numbers
  {
    //Serial.print('b');
    //Serial.println(Serial.available());
    speedScalar = 0;    //if anything happens, reset the speed scalar(and ramp up speed)
    char c = Serial.read();
    //Serial.print('x');
    //Serial.println(c);
    switch (c)
    {
      float f;
      int index;
      case '!':
        mode = (int)readFloat();
        break;
      case 'n':
        n = (int)readFloat();
        if (n > maxComponents)
        {
          n = maxComponents;     //to prevent reading invalid index
        }
        break;
      case 'j':
        desiredPos = readFloat();
        break;
      case 'a':
        f = readFloat();
        index = Serial.read();
        amps[index] = f;
        //Serial.println(index);
        break;
      case 'p':
        f = readFloat();
        index = Serial.read();
        phases[index] = f;
        break;
      case 'f':
        f = readFloat();
        index = Serial.read();
        freqs[index] = f;
        break;
    }
  }
}
float readFloat()
{
  char charArr[5];    //+123\0
  char c;
  int i;
  for (i = 0; Serial.available() > 0 && c != '>'; i++)
  {
    c = Serial.read();
    charArr[i] = c;
  }
  charArr[i] = '\0';
  float f = atof(charArr) / 100.0;
  return f;
}
volatile void sendFloat(volatile float f)
{
  volatile int i = (int)(f * 100.0);
  if (i >= 0)
  {
    Serial.print('+');
  }
  else
  {
    Serial.print('-');
  }
  Serial.print(abs(i));
  Serial.print('>');
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
volatile float mmToSteps(volatile float mm)
{
  return mm * (1 / leadPitch) * (1 / gearRatio) * motorStepsPerTurn; //mm*(lead turns/mm)*(motor turns/lead turn)*(steps per motor turn)
}
volatile float mapFloat(volatile long x, volatile long in_min, volatile long in_max, volatile long out_min, volatile long out_max)
{
  return (float)(x - in_min) * (out_max - out_min) / (float)(in_max - in_min) + out_min;
}
volatile float averageArray(volatile float* arr)
{
  volatile float total = 0;
  for (volatile int i = 0; i < buffSize; i++)
  {
    total += arr[i];
  }
  total /= buffSize;
  return total;
}
volatile void pushBuffer(volatile float* arr, volatile float f)
{
  for (volatile int i = buffSize - 1; i > 0; i--)
  {
    arr[i] = arr[i - 1];
  }
  arr[0] = f;
}
