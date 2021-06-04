/****************************************************************
hardware.cpp

Hardware support file for the MiniGen. Change the functions in
this file to use the MiniGen with different hardware.

This code is beerware; if you use it, please buy me (or any other
SparkFun employee) a cold beverage next time you run into one of
us at the local.

2 Jan 2014- Mike Hord, SparkFun Electronics

Code developed in Arduino 1.0.5, on an Arduino Pro Mini 5V.
Tested and working on Teensy 3.2 and ATMEGA328.

**Updated to Arduino 1.6.4 5/2015**

****************************************************************/

#include "SparkFun_MiniGen.h"
#include <SPI.h>

// configSPIPeripheral() is an abstraction of the SPI setup code. This
//  minimizes difficulty in porting to a new target: simply change this
//  code to fit the new target.
void MiniGen::configSPIPeripheral()
{
  pinMode(_FSYNCPin, OUTPUT);    // Make the FSYCPin an output; this is analogous
                                 //  to chip select in most systems.
  digitalWrite(_FSYNCPin, HIGH);
  SPI.setDataMode(SPI_MODE2);  // Clock idle high, data capture on falling edge
  SPI.begin();

  #ifndef MINIGEN_COMPATIBILITY_MODE
    if (SPI_HAS_TRANSACTION) {     // needed for Teensy and Teensy-like uCs
      SPI.begin();
      SPI.beginTransaction(SPISettings(20000000,MSBFIRST,SPI_MODE2));
    } else {
      SPI.setDataMode(SPI_MODE2);  // Clock idle high, data capture on falling edge
      SPI.begin();
    }
  #endif
}

// SPIWrite is optimized for this part. All writes are 16-bits; some registers
//  require multiple writes to update all bits in the registers. The address of
//  the register to be written is embedded in the data; corresponding write
//  functions will properly prepare the data with that information.
void MiniGen::SPIWrite(uint16_t data)
{
  //#if defined(MINIGEN_COMPATIBILITY_MODE)
    SPI.beginTransaction(SPISettings(_SPI_CLK_FREQ,MSBFIRST,SPI_MODE2));
  //#endif

  digitalWrite(_FSYNCPin, LOW);
  SPI.transfer((byte)(data>>8));
  SPI.transfer((byte)data);
  digitalWrite(_FSYNCPin, HIGH);

  //#if defined(MINIGEN_COMPATIBILITY_MODE)
    SPI.endTransaction();
  //#endif
}
