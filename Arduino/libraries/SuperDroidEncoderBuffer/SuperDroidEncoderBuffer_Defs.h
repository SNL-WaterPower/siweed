/*! @file SuperDroidEncoderBuffer)_Defs.h
*	@brief	The main source of macro definitions for SuperDroidEncoderBuffer library
	@details	Contains all of the binary macros used to build bit-register commands
	See the LM3766 datasheet for details
	
	\author		Austin Motes
	\version	1.0
	\date		2020
*/


#ifndef SuperDroidEncoderBuffer_Defs_h
  #define SuperDroidEncoderBuffer_Defs_h
  
  //************************************************MDR0 Register Settings**************************************************8
  #define MDRO_noQuad 0b00000000
  #define MDRO_x1Quad 0b00000001
  #define MDRO_x2Quad 0b00000010
  #define MDRO_x4Quad 0b00000011
  
  #define MDRO_freeRunningCountMode 0b00000000
  #define MDRO_singleCarryCountMode 0b00000100
  #define MDRO_rangeLimitCountMode 0b00001000
  #define MDRO_moduloN_CountMode 0b00001100
  
  #define MDRO_indexDisable 0b00000000
  #define MDRO_indexLoadDTR_2_CNTR 0b00010000
  #define MDRO_indexResetCNTR 0b00100000
  #define MDRO_indexLoadCNTR_2_OTR 0b00110000
  
  #define MDRO_AsyncIndex 0b00000000
  #define MDRO_syncIndex 0b01000000
  
  #define MDRO_filterClkDivFactor_1 0b00000000
  #define MDRO_filterClkDivFactor_2 0b10000000
  //*************************************************************************************************************************
  
  //***********************************************MDR1 Register Settings****************************************************
  #define MDR1_4ByteCounterMode 0b00000000
  #define MDR1_3ByteCounterMode 0b00000001
  #define MDR1_2ByteCounterMode 0b00000010
  #define MDR1_1ByteCounterMode 0b00000011
  
  #define MDR1_enableCounting 0b00000000
  #define MDR1_disableCounting 0b00000100
  
  #define MDR1_FlagOnIDX_NOP 0b00000000
  #define MDR1_FlagOnIDX 0b00010000
  
  #define MDR1_FlagOnCMP_NOP 0b00000000
  #define MDR1_FlagOnCMP 0b00100000
  
  #define MDR1_FlagOnBW_NOP 0b00000000
  #define MDR1_FlagOnBW 0b01000000
  
  #define MDR1_FlagOnCY_NOP 0b00000000
  #define MDR1_FlagOnCY 0b10000000
  //**************************************************************************************************************************
  
  //*********************************************IR Register Settings*******************************************************
  #define IR_RegisterAction_CLR 0b00000000
  #define IR_RegisterAction_RD 0b01000000
  #define IR_RegisterAction_WR 0b10000000
  #define IR_RegisterAction_LOAD 0b11000000
  
  #define IR_RegisterSelect_NONE 0b00000000
  #define MDR0 0b00001000
  #define MDR1 0b00010000
  #define DTR 0b00011000
  #define CNTR 0b00100000
  #define OTR 0b00101000
  #define STR 0b00110000
  #define IR_RegisterSelect_NONE1 0b00111000
  //************************************************************************************************************************

#endif
