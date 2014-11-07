#ifndef _UDEV_H_
#define _UDEV_H_

#include <Arduino.h>
#include <HardwareSerial.h>
#include <EEPROM.h>

typedef enum {
    ID_NOP     = 0x00,
    ID_WRITTEN = 0x01,
    ID_READ    = 0x02,
    ID_FAIL_CRC= 0x03
} udev_state_t;

class UDEV {
 public:
  UDEV(HardwareSerial &serial, int eepromBase = 0x0, int maxLen = 8);
  udev_state_t read_and_process(float block = 0, int pin_led = -1, int delay=50);
  udev_state_t process(char cmd, char value);
  void setup(int pin_led = -1);
  void begin(void) { _serial.flush(); }
 private:
  HardwareSerial &_serial;
  int _eepromBase;
  int _maxLen;
};
#endif

