/*****************************************************************************************
 *  SuperDroidEncoderBufferExample.ino
 *  
 *  Author : Austin Motes, 2020
 *  
 *  An example sketch demonstrating some of the functionality of the
 *  SuperBufferEncoder Library. 
 *  
 *  Details:
 *    Instantiates a SuperBufferEncoder object, initializes the object with a default
 *    SPI clock frequency of 500,000 Hz, Applies standard settings to the encoder buffer, 
 *    writes a test value to the 4-byte input buffer, checks that all test functions have 
 *    completed, and resets the registers back to their original values. 
 *  
 *    Optional: If the line:
 *                  #define setupOnly
 *              Is commented out, then after unit tests, the sketch will continuously 
 *              read from the CNTR register, which typically is where the encoder
 *              increments are counted.
 *            
 *            
 *  Hook-up definitions:
 *    This sketch is designed for the Arduino MEGA2560:
 *    
 *    LS3766 Buffer ->  MEGA2560
 *    GND ----------->  GND
 *    5V ------------>  5V
 *    SCLK ---------->  52
 *    MISO ---------->  50
 *    MOSI ---------->  51
 *    S1 ------------>  42
 *    
 *    This sketch can be run on a DUE, but requires a bi-directional level-shifter
 *    (e.g. Adaruit BSS138 4-channel I2C-safe Bidirectional Level Shifter breakout)
 *    For DUE SPI pinout, see spi_DUE.jpg included in library folder.
 *    
 *    LS3766 Buffer ->  BSS138 LvlShifter ->  ArduinoDUE
 *    5V ------------>  HV ---------------->  SPI_5V
 *    GND ----------->  GND_HV -> GND_LV -->  SPI_GND
 *                      LV ---------------->  3.3V
 *    SLCK ---------->  B1
 *    MISO ---------->  B2
 *    MOSI ---------->  B3
 *    S1 ------------>  B4
 *                      A1 ----------------> SPI_SCK
 *                      A2 ----------------> SPI_MISO
 *                      A3 ----------------> SPI_MOSI
 *                      A4 ----------------> 42
 *      
 * ****************************************************************************************
 */

#include <SuperDroidEncoderBuffer.h>

// Defines the encoder buffer's preferred SPI slave select pin.
#define encoderSS_pin 42

// uncomment this if you only want to run the setup and unit tests
// NOTE: This helps you catch the output of the setup, before the Loop Code drowns it out
#define setupOnly

//Instantiate a new SuperDroidEncoderBuffer object
SuperDroidEncoderBuffer encoderBuff = SuperDroidEncoderBuffer(encoderSS_pin);

//******************************************************************************************
//                                      SETUP                                              *
//******************************************************************************************
void setup(){
  Serial.begin(9600);

  //Initialize the SuperDroidEncoder (using default SPI frequency)
  // NOTE: I've tested the MEGA up to 8MHz and the Due up to 4MHz
  bool encoderBuffInit = encoderBuff.begin();

  // If initialization is unsuccesful, throw error message and halt executtion
  if(encoderBuffInit){
    Serial.println(F("Encoder Buffer Initialized"));
  }
  else{
    Serial.println(F("Encoder Buffer Failed to Initialize! :'("));
    Serial.print(encoderBuff.readReg(MDR0),BIN);
    while(1){}
  }

  // create a couple of 8-bit settings bit-register values to be written to MDR0 and MDR1 registers
  // This is done by bitwise OR-ing several macros defined in SuperDroidEncoderBuffer_Def.h together
  unsigned char MDR0_settings = MDRO_x4Quad | MDRO_freeRunningCountMode | MDRO_indexDisable | MDRO_syncIndex | MDRO_filterClkDivFactor_1;
  unsigned char MDR1_settings = MDR1_4ByteCounterMode | MDR1_enableCounting | MDR1_FlagOnIDX_NOP | MDR1_FlagOnCMP_NOP | MDR1_FlagOnBW_NOP | MDR1_FlagOnCY_NOP;

  //Set the MDR0 and MDR1 bit registers
  bool didItWork_MDR0 = encoderBuff.setMDR0(MDR0_settings);
  bool didItWork_MDR1 = encoderBuff.setMDR1(MDR1_settings);

  //If the setting functions worked, move on, otherwise, throw error and halt execution.
  if(didItWork_MDR0 && didItWork_MDR0){
    Serial.println(F("Encoder Buffer Settings Applied Successfully!"));
  }
  else{
    Serial.println(F("Encoder Buffer Settings Failed to Apply! :'("));
    while(1){}
  }

  // Set the MDR0 to 0x00 in order to enable writing to register DTR 
  encoderBuff.setMDR0(0x00);
  // Then write a 4-byte test value to DTR
  bool didItWork_DTR = encoderBuff.setDTR(0x12131415);
  
  // If the write to DTR worked, then reset DTR to 0 and re-apply MDR0 settings back to the desired value
  // Otherwise, throw error and halt execution
  if(didItWork_DTR){
    Serial.println(F("DTR write functions completed successfully!"));
    didItWork_DTR = encoderBuff.setDTR(0x00000000);
    didItWork_MDR0 = encoderBuff.setMDR0(MDR0_settings);
  }
  else{
    Serial.println(F("DTR write functions failed to complete :'("));
    while(1){}
  }

  // Check to see if the resets of both DTR and MDR0 were successful, and indicate that unit testing is complete!
  // Otherwise, throw error and halt execution
  if(didItWork_DTR && didItWork_MDR0){
    Serial.println(F("DTR set back to zero, and MDR0 settings reapplied!"));
    Serial.println(F("Encoder buffer testing completed successfully! :)"));
  }
  else{
    if(didItWork_DTR){
      Serial.println(F("MDR0 settings reapplication failed! :'("));
    }
    else{
      Serial.println(F("DTR reset to zero failed! :'("));
    }
    while(1){}
  }
  
}

//******************************************************************************************
//                                       LOOP                                              *
//******************************************************************************************
void loop(){
  // Pre-processor directive that conditionally compiles the code held within if setupOnly is defined
  #ifndef setupOnly

    // Read value from CNTR (which counts the increments from the encoder), and output to serial monitor
    Serial.print(F("CNTR = "));
    Serial.println(encoderBuff.readCNTR());
    
  #endif
}
