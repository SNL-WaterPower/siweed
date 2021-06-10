#include <SPI.h>

#define usb Serial

uint32_t SlaveReceived = 0;
uint8_t received = 0;
byte trash = 0;

void setup() {
  usb.begin(2000000);
  usb.println(F("SPI Slave Test"));

  pinMode(MISO, OUTPUT);

  SPCR |= (_BV(CPOL)); // set CPOL to one
  SPCR &= (~_BV(CPHA)); // set CPHA to zero
  SPCR |= _BV(SPE); // enable spi mode
  
  
  SPI.attachInterrupt();;

  usb.print(F("SPCR = "));
  print8(SPCR);
}

void loop() {
  if(received > 3){
    SPCR &= ~(_BV(SPIE)); // disables spi interrupts
    print32(SlaveReceived);
    trash = 0;
    received = 0;
    SPI.attachInterrupt();
  }
}

ISR (SPI_STC_vect){
  uint32_t temp32 = (uint32_t)(SPDR);
  switch(received){
    case 0:
      SlaveReceived = (temp32 << 24);
      received++;
      break;
    case 1:
      SlaveReceived = SlaveReceived | (temp32 << 16);
      received++;
      break;
    case 2:
      SlaveReceived = SlaveReceived | (temp32 << 8);
      received++;
      break;
    case 3:
      SlaveReceived = SlaveReceived | temp32;
      received++;
      break;
    case 4:
      trash = SPDR;
      break;
  }
}

void print32(uint32_t toPrint){
  for(int i = 31; i >= 0; i--){             
    byte val = (byte)((toPrint >> i) & B00000001);
    switch(val){
      case 0:
        usb.print("0");
        break;
      case 1:
        usb.print("1");
        break;
    }
  }
  usb.println("");
}

void print16(uint16_t toPrint){
  for(int i = 15; i >= 0; i--){             
    byte val = (byte)((toPrint >> i) & B00000001);
    switch(val){
      case 0:
        usb.print("0");
        break;
      case 1:
        usb.print("1");
        break;
    }
  }
  usb.println("");
}

void print8(byte toPrint){
  for(int i = 7; i >= 0; i--){             
    byte val = (byte)((toPrint >> i) & B00000001);
    switch(val){
      case 0:
        usb.print("0");
        break;
      case 1:
        usb.print("1");
        break;
    }
  }
  usb.println("");
}
