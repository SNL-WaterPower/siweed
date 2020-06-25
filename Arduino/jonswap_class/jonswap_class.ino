#include <miniWaveTankJonswap.h>    //dependent on <StandardCplusplus.h>
miniWaveTankJonswap jonswap(512.0/32.0, 0.5,2.5);    //period, low frequency, high frequency. frequencies will be rounded to multiples of df(=1/period)
//^ISSUE. Acuracy seems to fall off after ~50 components when using higher frequencies(1,3 at 64 elements seems wrong). 
void setup() {
  Serial.begin(500000);
  Serial.println(micros*1000.0);
  jonswap.update(5.0, 3.0, 7.0);
  Serial.println(micros*1000.0);
  printJonswap();
}
void loop() {

}
void printJonswap(){
  Serial.println(jonswap.getNum());
  for(int i = 0; i<jonswap.getNum(); i++){
    Serial.print(jonswap.getAmp()[i]);
    Serial.print("  ");
  }
  Serial.println();
  for(int i = 0; i<jonswap.getNum(); i++){
    Serial.print(jonswap.getF()[i]);
    Serial.print("  ");
  }
  Serial.println();
  for(int i = 0; i<jonswap.getNum(); i++){
    Serial.print(jonswap.getPhase()[i]);
    Serial.print("  ");
  }
  Serial.println();
}
