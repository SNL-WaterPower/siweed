/*! \file 		SuperDroidEncoderBuffer.h
	\brief 		Main header for the SuperDroid Robots Encoder Breakout Library
	
	\details	Contains a class with necessary methods for interfacing with the SuperDroid Robots Encoder Breakout, hardware v1.0. 
	This library is designed for use with Arduino MCUs
	
	\author		Austin Motes
	\version	1.0
	\date		2020
*/



#ifndef SuperDroidEncoderBuffer_h

  #define SuperDroidEncoderBuffer_h
  
  #include "Arduino.h"
  #include <SPI.h>
  #include "SuperDroidEncoderBuffer_Defs.h"
  
  
  
/*! \class 	SuperDroidEncoderBuffer SuperDroidEncoderBuffer.h
	\brief 	A definition of the encoder buffer object, internal vars, and methods
	
	\details	This class contains all necessary methods and variables to interface with the LS7366 IC.
	
*/



/*! \publicsection
*/
  class SuperDroidEncoderBuffer{
    public:
/*!	\fn 	SuperDroidEncoderBuffer(uint8_t SS_pin)
*/
      SuperDroidEncoderBuffer(uint8_t SS_pin);
	  
/*! \fn		bool begin(uint32_t SPI_clockFreq)
*/	
      bool begin(uint32_t SPI_clockFreq);
	  
/*! \fn		bool begin()
*/	
      bool begin(void);
      
/*! \fn		bool 	setMDR0(unsigned char MDR0_setting)
*/	
      bool setMDR0(unsigned char MDR0_setting);
	  
/*! \fn		bool 	setMDR1(unsigned char MDR1_setting)
*/	
      bool setMDR1(unsigned char MDR1_setting);
	  
/*! \fn		bool 	setDTR(unsigned char* DTRsetting, int numberOfBytes)
*/	
      bool setDTR(unsigned char* DTRsetting, int numberOfBytes);
	  
/*! \fn		bool 	setDTR(long DTRsetting)
*/	
      bool setDTR(long DTRsetting);
	  
/*! \fn		long 	readCNTR()
*/	
      long readCNTR();
    
/*! \fn		void 	command2Reg(unsigned char reg, unsigned char command)
*/	
      void command2Reg(unsigned char reg, unsigned char command);
	  
/*! \fn		unsigned char 	readReg(unsigned char reg)
*/	
      unsigned char readReg(unsigned char reg);
	  
/*! \fn		long 	readReg(unsigned char reg, int numberOfBytes)
*/	
      long readReg(unsigned char reg, int numberOfBytes);
	  
/*! \fn		void 	readReg(unsigned char reg, unsigned char* readBuffer, int numberOfBytes)
*/	
      void readReg(unsigned char reg, unsigned char* readBuffer, int numberOfBytes);
  
/*! \fn		bool 	write2Reg(unsigned char reg, unsigned char val)
*/	
      bool write2Reg(unsigned char reg, unsigned char val);
	  
/*! \fn 	bool 	write2Reg(unsigned char reg, unsigned char* val, int valNumber)
*/
      bool write2Reg(unsigned char reg, unsigned char* val, int valNumber);   
	  
/*! \privatesection
*/
    private:
	
/*!	@var int $_SD_ENCODER_SS
	\brief	Holds the object's arduino pin number used for SPI slave-select.
*/
	  int _SD_ENCODER_SS;
	  
/*!	\var uint32_t $_SD_ENCODER_SPI_FREQ
	\brief Contains the object's preferred SPI frequency in Hz
*/
	  uint32_t _SD_ENCODER_SPI_FREQ;
  };

#endif
