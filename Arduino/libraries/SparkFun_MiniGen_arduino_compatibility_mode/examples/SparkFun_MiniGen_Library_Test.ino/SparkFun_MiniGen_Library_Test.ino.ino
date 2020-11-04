/******************************************************************************
SparkFun_MiniGen_Library_Test.ino
Library test file for the MiniGen library.
Mike Hord @ SparkFun Electronics
23 October 2020
https://github.com/sparkfun/SparkFun_MiniGen_Arduino_Library

This is a simple test/example file for the MiniGen board and library.

The MiniGen is a Pro Mini shield-type board (although it can be used as a 
standalone product as well) that generates sine, square and triangle waves up
to a frequency of approximately 3MHz; above 3MHz, you'll start to see rolloff
as the anti-aliasing filter on the output begins to affect the signal. Expect
a peak-to-peak amplitude of about 1V and a DC offset of Vcc/2.

Resources:
Uses the MiniGen library and the built-in SPI library.

Development environment specifics:
Code developed in Arduino 1.0.5, on an Arduino Pro Mini 5V.
Compatibility updates developed in Arduino 1.8.12 on an Arduino MEGA.

**Updated to Arduino 1.6.4 5/2015**
**Updated to include an enhanced compatibility mode 10/2020**

This code is beerware; if you see me (or any other SparkFun employee) at the
local, and you've found our code helpful, please buy us a round!

Distributed as-is; no warranty is given.
******************************************************************************/
// Due to limitations in the Arduino environment, SPI.h must be included both
//  in the library which uses it *and* any sketch using that library.
#include <SPI.h>
#include <SparkFun_MiniGen.h>

// Because the library is optimized to be as fast as possible, running multiple
//  SPI peripherals with different SPI modes or bitorders can cause a lack of 
//  functionality. If this occurs, define the following macro, which will very 
//  very slightly affect performance, but will lock in compatibility.
//#define MINIGEN_COMPATIBILITY_MODE

// Create an instance of the MiniGen device; note that this has no provision for
//  alternate CLK and MOSI pins, but you *can* pass it a different CS (or FSYNC,
//  as it's referred to elsewhere) pin number and a desired SPI clock frequency.
//  Uncomment only one at a time. 
MiniGen gen;                  // default FSYNC (pin 10), default SPI clock frequency (2MHz)
//MiniGen gen = MiniGen(11);  // specified FSYNC (pin 11), default SPI clock frequency (2MHz)
//MiniGen gen = MiniGen(11,4000000); // specified FSYNC (pin 11), specified SPI clock frequency (2MHz)

void setup()
{
  // Clear the registers in the AD9837 chip, so we're starting from a known
  //  location. Note that since the AD9837 has no DOUT, we can't use the
  //  read-modify-write method of control. At power up, the output frequency
  //  will be 100Hz.
  gen.reset();
  delay(2000);
  
  // SQUARE is, as it suggests, a square wave. SQUARE is at the current output
  //  frequency.
  gen.setMode(MiniGen::SQUARE);
  delay(3000);
  
  // SQUARE_2 is at half the normal output frequency.
  gen.setMode(MiniGen::SQUARE_2);
  delay(3000);
  
  // Exactly what you think it is.
  gen.setMode(MiniGen::TRIANGLE);
  delay(3000);
  
  // Yep.
  gen.setMode(MiniGen::SINE);
  
  // This needs a little explanation. The choices are FULL, COARSE, and FINE.
  //  a FULL write takes longer but writes the entire frequency word, so you
  //  can change from any frequency to any other frequency. COARSE only allows
  //  you to change the upper bits; the lower bits remain unchanged, so you
  //  can do a fast write of a large step size. FINE is the opposite; quick
  //  writes but smaller steps.
  gen.setFreqAdjustMode(MiniGen::FULL);
}

void loop()
{
  // Loop is going to increase the frequency in steps of 10Hz, basically
  //  forever. Since the upper limit is 3MHz, you'll probably not sit
  //  around long enough for frequency to overflow.
  static float frequency = 10.0;
  
  // freqCalc() makes a useful 32-bit value out of the frequency value (in
  //  Hz) passed to it.
  unsigned long freqReg = gen.freqCalc(frequency);
  
  // Adjust the frequency. This is a full 32-bit write.
  gen.adjustFreq(MiniGen::FREQ0, freqReg);
  delay(100);
  frequency += 10.0;
}
