#define MINIGEN_COMPATIBILITY_MODE
#include <SPI.h>
#include <SparkFun_MiniGen.h>
MiniGen gen; //signal generator
const int  dirPin = 5, limitPin = A0, probe1Pin = A1, probe2Pin = A2;

void setup() {
    Serial.begin(57600);

  // put your setup code here, to run once:
  gen = MiniGen(10, 500000);//initalize signal generator with FSYNC pin 10. This constructor needs to be run in setup, not before
  gen.reset(); //reset signal generator, that way we have a known starting location.
  //At power up, the singal generator will output 100hz
  gen.setMode(MiniGen::SQUARE); //setting signal generator to make a square wave.
  gen.setFreqAdjustMode(MiniGen::FULL); //Full takes the longest longer to write, but allows to change from any frequency to any other frequency

  //unsigned long freqReg = gen.freqCalc(0);
  //gen.adjustFreq(MiniGen::FREQ0, freqReg); //Making sure the signal generator isnt making the motor move at start
  pinMode(dirPin, OUTPUT);
  digitalWrite(dirPin, HIGH);
  //freqReg = gen.freqCalc(3); //setting the signal generator to 10hz
  //gen.adjustFreq(MiniGen::FREQ0, freqReg); //start moving
  pinMode(LED_BUILTIN, OUTPUT);

}

void loop() {
  if (millis() < 5000) {
    // put your main code here, to run repeatedly:
    //unsigned long freqReg = gen.freqCalc(millis()/10000);
    unsigned long freqReg = gen.freqCalc(10);
    //Serial.println(BOARD_SPI_DEFAULT_SS);
    gen.adjustFreq(MiniGen::FREQ0, freqReg); //start moving
    delay(100);
    digitalWrite(LED_BUILTIN, LOW);
  } else {
    digitalWrite(LED_BUILTIN, HIGH);
  }
}
