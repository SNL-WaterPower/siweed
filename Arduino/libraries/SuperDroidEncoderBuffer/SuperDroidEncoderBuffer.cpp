

/*! @file SuperDroidEncoderBuffer.cpp
*	@brief	The cpp source code for the SuperDroidEncoderBuffer library.
	@details	Contains all of the method source code
	
	\author		Austin Motes
	\version	1.0
	\date		2020
*/


#if ARDUINO >= 100
 #include "Arduino.h"
#else
 #include "WProgram.h"
#endif

#include <SPI.h>
#include "SuperDroidEncoderBuffer_Defs.h"
#include "SuperDroidEncoderBuffer.h"

//#define debug_encoderBuff


// ***********************************************************************************************
//                                        Constructor
// ***********************************************************************************************
/*!	\brief	Constructor
*	\param[in]	SS_pin	The object's SPI slave select pin number
*/	
SuperDroidEncoderBuffer::SuperDroidEncoderBuffer(uint8_t SS_PIN){
  _SD_ENCODER_SS = SS_PIN;

  pinMode(_SD_ENCODER_SS,OUTPUT);
  digitalWrite(_SD_ENCODER_SS,HIGH);
  #ifdef debug_encoderBuff
	  Serial.println(F("Constructor complete"));
  #endif
  return;
}

// ***********************************************************************************************
//                                           begin
// ***********************************************************************************************
/*!	\brief		Initialization function of the object (Overloaded)
*	\details	Initializes the object by testing some of the functionality
*	\param[in] 	SPI_clockFreq	Defines the object's preffered SPI clock frequency (in Hz)
*	\return		A boolean representing the method's success
*/
bool SuperDroidEncoderBuffer::begin(uint32_t SPI_clockFreq){
  #ifdef debug_encoderBuff
	  Serial.println(F("begin init"));
  #endif
  _SD_ENCODER_SPI_FREQ = SPI_clockFreq;
  
  SPI.begin();
  
  unsigned char MDR0_settings = MDRO_x4Quad | MDRO_singleCarryCountMode | MDRO_indexResetCNTR | MDRO_syncIndex | MDRO_filterClkDivFactor_1;
  bool didItWork_MDR0 = setMDR0(MDR0_settings);
  command2Reg(MDR0,IR_RegisterAction_CLR);
  
  #ifdef debug_encoderBuff 
	  Serial.println(F("begin() complete"));
	  Serial.print(F("didItWork_MDR0 = "));
	  Serial.println(didItWork_MDR0);
  #endif

  return didItWork_MDR0;
}

/*!	\brief		Initialization function of the object (Overloaded)
*	\details	Initializes the object by testing some of the functionality
*	Sets the SPI clock frequency to a default value of 500000;
*	\return		A boolean representing the method's success
*/
bool SuperDroidEncoderBuffer::begin(void){
  #ifdef debug_encoderBuff
	  Serial.println(F("begin init"));
  #endif
  _SD_ENCODER_SPI_FREQ = 500000;
  
  SPI.begin();

  unsigned char MDR0_settings = MDRO_x4Quad | MDRO_singleCarryCountMode | MDRO_indexResetCNTR | MDRO_syncIndex | MDRO_filterClkDivFactor_1;
  bool didItWork_MDR0 = setMDR0(MDR0_settings);
  command2Reg(MDR0,IR_RegisterAction_CLR);
  
  #ifdef debug_encoderBuff
	  Serial.println(F("begin() complete"));
	  Serial.print(F("didItWork_MDR0 = "));
	  Serial.println(didItWork_MDR0);
  #endif

  return didItWork_MDR0;
}

// ***********************************************************************************************
//                                           setMDR0
// ***********************************************************************************************
/*!	
		\brief		sets the 8-bit MDR0 register to desired value
		\details	Macros for the various MDR0 settings are found in SuperDroidEncoderBuffer_Defs.h
		\param[in]	MDR0_setting	An 8-bit value containing the desired bit-register values, MSB (B7) first
		\return		A boolean representing the method's success
*/	
bool SuperDroidEncoderBuffer::setMDR0(unsigned char MDR0_setting){
  #ifdef debug_encoderBuff
	  Serial.println(F("setMDR0 init"));
  #endif
  bool didItWork = write2Reg(MDR0, MDR0_setting);
  #ifdef debug_encoderBuff
	  Serial.println(F("setMDR0() complete"));
	  Serial.print(F("didItWork = "));
	  Serial.println(didItWork);
  #endif
  return didItWork;
}

// ***********************************************************************************************
//                                           setMDR1
// ***********************************************************************************************
/*!
		\brief		sets the 8-bit MDR1 register to desired value
		\details	Macros for the various MDR1 settings are found in SuperDroidEncoderBuffer_Defs.h
		\param[in]	MDR1_setting	An 8-bit value containing the desired bit-register values, MSB (B7) first
		\return		A boolean representing the method's success
*/
bool SuperDroidEncoderBuffer::setMDR1(unsigned char MDR1_setting){
  #ifdef debug_encoderBuff
	  Serial.println(F("setMDR1 init"));
  #endif
  bool didItWork = write2Reg(MDR1, MDR1_setting);
  #ifdef debug_encoderBuff
	  Serial.println(F("setMDR1() complete"));
	  Serial.print(F("didItWork = "));
	  Serial.println(didItWork);
  #endif
  return didItWork;
}

// ***********************************************************************************************
//                                           readCNTR
// ***********************************************************************************************
/*!
	\brief		Reads the variable-sized CNTR register.
	\details	Passes a READ command to the IC, receives the value as a n-byte array, and combines the elements of the array into a Long Integer for return
	\return		A long integer representing the value read from the CNTR
*/
long SuperDroidEncoderBuffer::readCNTR(){
  #ifdef debug_encoderBuff
	  Serial.println(F("readCNTR init"));
  #endif
  unsigned char MDR1_currentSet = readReg(MDR1);
  uint8_t numberOfBytes = 4 - (MDR1_currentSet & (0b00000011));
  long returnVal = readReg(CNTR, numberOfBytes);
  #ifdef debug_encoderBuff
	  Serial.println(F("readCNTR() complete"));
	  Serial.print(F("returnVal = "));
	  Serial.println(returnVal);
  #endif
  return returnVal;
}

// ***********************************************************************************************
//                                           setDTR
// ***********************************************************************************************
/*!
		\brief		Sets the variable-sized DTR register to desired value (Overloaded)
		\details	Sets the DTR register to a value, loads the value into CNTR, reads from CNTR and validates that it matches the desired value, then resets the CNTR register to 0.
		\param[in]	DTRsetting		A pointer to a 1 to 4 element array of 8-bit values to be loaded into DTR.
		\param[in]	numberOfBytes 	An integer specifying the size (in bytes) of DTRsetting.
		\return		A boolean representing the method's success.
*/	
bool SuperDroidEncoderBuffer::setDTR(unsigned char* DTRsetting, int numberOfBytes){
  #ifdef debug_encoderBuff
	  Serial.println(F("setDTR init"));
  #endif
  
  bool didItWork = write2Reg(DTR, DTRsetting, numberOfBytes);
  return didItWork;
}

/*!	
		\brief		Sets the variable-sized DTR register to desired value (Overloaded)
		\details	Sets the DTR register to a value, loads the value into CNTR, reads from CNTR and validates that it matches the desired value, then resets the CNTR register to 0.
		\param[in]	DTRsetting	A Long Integer to be written to a 4-byte DTR register.
		\return		A boolean representing the method's success.
*/	
bool SuperDroidEncoderBuffer::setDTR(long DTRsetting){
  unsigned char sendBuffer[4];
  for(int i = 0; i < 4; i++){
    sendBuffer[i] = (unsigned char)(DTRsetting >> (8 * (3 - i)));
  }
  bool didItWork = write2Reg(DTR, &sendBuffer[0], 4);
  
  #ifdef debug_encoderBuff
	  Serial.println(F("setDTR() complete"));
	  Serial.print(F("didItWork = "));
	  Serial.println(didItWork);
  #endif
  
  return didItWork;
}


// ***********************************************************************************************
//                                           command2Reg
// ***********************************************************************************************
/*!	
		\brief		Sends a command to a register.
		\details	Sends an 8-bit value to the IR register, which contains a Command Word and a Target Register to perform the command on.
					The specific set of commands and available registers are included in SuperDroidEncoderBuffer_Defs.h
		\param[in]	reg		The 8-bit value specifying the target register
		\param[in]	command	The 8-bit value specifying the desired command word
*/
void SuperDroidEncoderBuffer::command2Reg(unsigned char reg, unsigned char command){
  #ifdef debug_encoderBuff
	  Serial.println(F("command2Reg init"));
  #endif

  unsigned char IR_ActionWord = (command | reg);

  SPI.beginTransaction(SPISettings(_SD_ENCODER_SPI_FREQ, MSBFIRST, SPI_MODE0));

  digitalWrite(_SD_ENCODER_SS, LOW);
  SPI.transfer(IR_ActionWord);
  digitalWrite(_SD_ENCODER_SS, HIGH);

  SPI.endTransaction();
  
  return;
    
}

// ***********************************************************************************************
//                                           readReg
// ***********************************************************************************************
/*!
		\brief		Reads values form a register (Overloaded)
		\details	Sends a READ command for the Target Register to the IR register, and returns the value returned from the IC.
					The specific set of available registers are included in SuperDroidEncoderBuffer_Defs.h
		\param[in]	reg		The 8-bit value specifying the target register
		\return		The 8-bit value returned from the IC, representing the value of the Target Register.
*/	
unsigned char SuperDroidEncoderBuffer::readReg(unsigned char reg) {
  #ifdef debug_encoderBuff
	  Serial.println(F("readReg init"));
  #endif
  
  unsigned char IR_ActionWord = (IR_RegisterAction_RD | reg);

  SPI.beginTransaction(SPISettings(_SD_ENCODER_SPI_FREQ, MSBFIRST, SPI_MODE0));

  unsigned char returnVal;
  digitalWrite(_SD_ENCODER_SS, LOW);
  SPI.transfer(IR_ActionWord);
  returnVal = SPI.transfer(0x00);
  digitalWrite(_SD_ENCODER_SS, HIGH);

  SPI.endTransaction();

  return returnVal;
  
}

/*!
	@brief Reads values form a register (Overloaded)
	@details Sends a READ command for the Target Register to the IR register, and returns the value returned from the IC.
	The specific set of available registers are included in SuperDroidEncoderBuffer_Defs.h
	@param[in] reg The 8-bit value specifying the target register
	@param[in,out] readBuffer A pointer to the beginning of n-element 8-bit array (preferably empty or zero'd)
	n = numberOfBytes, this pointer will also be the memory address where the read value is returned.
	@param[in] numberOfBytes The integer specifying the size (in bytes) of the expected return value
	@return return values are located in the address provided by readBuffer, with the same size provided by numberOfBytes
*/
void SuperDroidEncoderBuffer::readReg(unsigned char reg, unsigned char* readBuffer, int numberOfBytes) {
  #ifdef debug_encoderBuff
	  Serial.println(F("readReg init"));
  #endif
  
  unsigned char IR_ActionWord = (IR_RegisterAction_RD | reg);

  SPI.beginTransaction(SPISettings(_SD_ENCODER_SPI_FREQ, MSBFIRST, SPI_MODE0));

  IR_ActionWord = (IR_RegisterAction_RD | reg);
  unsigned char returnVal;
  digitalWrite(_SD_ENCODER_SS, LOW);
  SPI.transfer(IR_ActionWord);
  for(int i = 0; i < numberOfBytes; i++){
    *(readBuffer + i) = SPI.transfer(0x00);
  }
  digitalWrite(_SD_ENCODER_SS, HIGH);

  SPI.endTransaction();
  
  return;
  
}


/*!	
		\brief		Reads values form a register (Overloaded)
		\details	Sends a READ command for the Target Register to the IR register, and returns the value returned from the IC.
					The specific set of available registers are included in SuperDroidEncoderBuffer_Defs.h
		\param[in]	reg				The 8-bit value specifying the target register
		\param[in]	numberOfBytes	The integer specifying the size (in bytes) of the expected return value
		\return		The n-byte value returned from the IC, representing the value of the Target Register.
*/	
long SuperDroidEncoderBuffer::readReg(unsigned char reg, int numberOfBytes) {
  #ifdef debug_encoderBuff
	  Serial.println(F("readReg init"));
  #endif
  
  unsigned char IR_ActionWord = (IR_RegisterAction_RD | reg);
  unsigned char returnBuffer[numberOfBytes];
  
  SPI.beginTransaction(SPISettings(_SD_ENCODER_SPI_FREQ, MSBFIRST, SPI_MODE0));

  digitalWrite(_SD_ENCODER_SS, LOW);
  SPI.transfer(IR_ActionWord);
  for(int i = 0; i < numberOfBytes; i++){
    returnBuffer[i] = SPI.transfer(0x00);
  }
  digitalWrite(_SD_ENCODER_SS, HIGH);

  SPI.endTransaction();

  long returnVal = 0x00;

  for(int i = 0; i < numberOfBytes; i++){
    returnVal |= ((long)returnBuffer[i] << (8 *((numberOfBytes - 1) - i)));
  }

  return returnVal;
  
}


// ***********************************************************************************************
//                                           write2Reg
// ***********************************************************************************************
/*!
	@brief		writes values to a register (Overloaded)
	@details	Sends a WRITE command for the Target Register to the IR register, then sends a value to be written to the target buffer.
	The specific set of available registers are included in SuperDroidEncoderBuffer_Defs.h
	@param[in]	reg		The 8-bit value specifying the target register
	@param[in]	val		The 8-bit values to be written to the target register
	@return		A boolean indicating the success of the write operation
*/
bool SuperDroidEncoderBuffer::write2Reg(unsigned char reg, unsigned char val) {
  #ifdef debug_encoderBuff
	  Serial.println(F("write2Reg init"));
  #endif
  
  unsigned char IR_ActionWord = (IR_RegisterAction_WR | reg);

  SPI.beginTransaction(SPISettings(_SD_ENCODER_SPI_FREQ, MSBFIRST, SPI_MODE0));
  digitalWrite(_SD_ENCODER_SS, LOW);
  SPI.transfer(IR_ActionWord);
  SPI.transfer(val);
  digitalWrite(_SD_ENCODER_SS, HIGH);
  SPI.endTransaction();

  unsigned char returnVal = readReg(reg);
  
  if(returnVal == val){
    return true;
  }
  else{
    return false;
  }
  
}

/*!	
	@brief writes values to a register (Overloaded)
	@details Sends a WRITE command for the Target Register to the IR register, then sends a value to be written to the target buffer.
	The specific set of available registers are included in SuperDroidEncoderBuffer_Defs.h
	@param[in] reg The 8-bit value specifying the target register
	@param[in] val The pointer to an n-element 8-bit array containing the value to be written to the target register
	@param[in] valNumber The integer the number of elements in the val array
	@return A boolean indicating the success of the write operation
*/	
bool SuperDroidEncoderBuffer::write2Reg(unsigned char reg, unsigned char* val, int valNumber) {
  #ifdef debug_encoderBuff
	  Serial.println(F("write2Reg init"));
  #endif
  
  unsigned char IR_ActionWord = (IR_RegisterAction_WR | reg);

  SPI.beginTransaction(SPISettings(_SD_ENCODER_SPI_FREQ, MSBFIRST, SPI_MODE0));
  digitalWrite(_SD_ENCODER_SS, LOW);
  SPI.transfer(IR_ActionWord);
  for(int i = 0; i < valNumber; i++){
    SPI.transfer(*(val+i));
  }
  digitalWrite(_SD_ENCODER_SS, HIGH);
  SPI.endTransaction();

  command2Reg(CNTR,IR_RegisterAction_LOAD);

  unsigned char returnVal[valNumber];
  readReg(CNTR, &returnVal[0], 4);

  bool returnBool = true;
  
  for(int i = 0; i < valNumber; i++){
    if(*(val+i) == returnVal[i]){
      returnBool = returnBool && true;
    }
    else{
      returnBool = returnBool && false;
    }
  }

  return returnBool;
  
}
