#ifndef Pins_Arduino_h
#define Pins_Arduino_h

#include <stdint.h>

// USB serial (default)
static const uint8_t TX = 43;
static const uint8_t RX = 44;

// TFT SPI display interface (2.4″ 320×240 capacitive touch)
static const uint8_t TFT_CS   = 5;
static const uint8_t TFT_DC   = 4;
static const uint8_t TFT_MOSI = 6;
static const uint8_t TFT_CLK  = 7;
static const uint8_t TFT_RST  = 48;
static const uint8_t TFT_BL   = 45;

// Touch sensor (TT21100) I2C + IRQ
static const uint8_t TOUCH_SDA = 41;
static const uint8_t TOUCH_SCL = 40;
static const uint8_t TOUCH_IRQ = 3;

// I²S audio (dual mic + speaker)
static const uint8_t I2S_MCLK = 2;
static const uint8_t I2S_SCLK = 17;
static const uint8_t I2S_LRCK = 47;
static const uint8_t I2S_DIN  = 16; // Mic data
static const uint8_t I2S_DOUT = 15; // Speaker output

// I2C devices (ES7210, ES8311, IMU on Wire1)
#define I2C_SDA 8
#define I2C_SCL 18

// Audio device I2C addresses  
#define ES7210_ADDR    0x40  
#define ES8311_ADDR    0x18  

// IMU & Touch panel addresses  
#define ICM42607P_ADDR 0x68  
#define TT21100_ADDR   0x24  

// Audio amp control
static const uint8_t PA_PIN   = 46;
static const uint8_t MUTE_PIN = 1;

#endif /* Pins_Arduino_h */

