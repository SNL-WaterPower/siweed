/*
Had an issue where jonswap.update would not run properly in a switch statement
*/

#include <miniWaveTankJonswap.h>    //dependent on <StandardCplusplus.h>
miniWaveTankJonswap jonswap(512.0 / 32.0, 0.5, 2.5); //period, low frequency, high frequency. frequencies will be rounded to multiples of df(=1/period)
//^ISSUE. Acuracy seems to fall off after ~50 components when using higher frequencies(1,3 at 64 elements seems wrong).
void setup() {
  Serial.begin(9600);

}
void loop() {
  long timestamp = micros();
  jonswap.update(5.0, 3.0, 7.0);    //takes about 50ms on arduino mega
  long timestamp2 = micros();
  Serial.print("Took ");
  Serial.print((float)(timestamp2 - timestamp) / 1000.0);
  Serial.println("milliseconds");
  printJonswap();
  delay(500);
}
void printJonswap() {
  Serial.println(jonswap.getNum());
  for (int i = 0; i < jonswap.getNum(); i++) {
    Serial.print(jonswap.getAmp()[i]);
    Serial.print("  ");
  }
  Serial.println();
  for (int i = 0; i < jonswap.getNum(); i++) {
    Serial.print(jonswap.getF()[i]);
    Serial.print("  ");
  }
  Serial.println();
  for (int i = 0; i < jonswap.getNum(); i++) {
    Serial.print(jonswap.getPhase()[i]);
    Serial.print("  ");
  }
  Serial.println();
}