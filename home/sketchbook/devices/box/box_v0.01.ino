// dotfiles/home/sketchbook/boards/esp32s3box.ino ⮞ https://github.com/quackhack-mcblindy/dotfiles
// 🦆 duck say ⮞ quacktastic ESP Nixifier magic for the Box3
// Button: Top Left Button
//      GPIO0	
// Button: Mute
//      GPIO1	
// SPI
//    clk_pin: GPIO7
//    mosi_pin: GPIO6
// Display
//    cs_pin: GPIO5
//    dc_pin: GPIO4
//    reset_pin: GPIO48 (inverted: true)
// Remote Receiver (IR67-21C/TR8)
//    GPIO38
// Remote Transmitter (IRM-H638T)
//    GPIO39 
// LED backlight output
//    GPIO47
// 🦆 says ⮞  libs
#include <vector>
#include <WiFiClientSecure.h>
#include <map>
#include <PubSubClient.h>
#include "driver/temp_sensor.h"
#include <ArduinoJson.h>
#include <Update.h>
#include <Wire.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <WebServer.h>
#include <driver/i2s.h>
// 🦆 says ⮞ pins
#define I2C_SDA         8
#define I2C_SCL         18
#define TS_IRQ          3
#define TFT_BL          47
#define I2S_SDIN        16
#define I2S_LRCK        17
#define I2S_SCLK        7
#define I2S_MCLK        2
#define PA_PIN          46
#define MUTE_PIN        1
#define TFT_RST         48
#define BATTERY_ADC_PIN 10
#define TOUCH_RESET_PIN TFT_RST
#define TOUCH_INT_PIN   TS_IRQ
// 🦆 says ⮞  audio
#define SAMPLE_RATE     16000  // 16KHz
#define SAMPLE_BITS     16
#define BUFFER_SIZE     1024

// 🦆 says ⮞  wifi & api
const char* ssid = "pungkula2";
const char* password = "***REDACTED***";
const char* apiEndpoint = "https://192.168.1.111:25451/audio_upload";
// 🦆 says ⮞  mqtt Configuration
const char* mqtt_server = "192.168.1.211";
const char* mqtt_user = "mqtt";
const char* mqtt_password = "***REDACTED***";
WiFiClient espClient;
PubSubClient mqttClient(espClient);
// 🦆 says ⮞ battery (reversed for BOX3)
#define BATTERY_MIN_VOLTAGE 3.3
#define BATTERY_MAX_VOLTAGE 2.01

// 🦆 says ⮞ globalz yo
volatile bool touchDetected = false;
uint8_t touchAddress = 0x38;
bool touchControllerAvailable = false;
bool isRecording = false;
bool wasTouched = false;
unsigned long lastTouchTime = 0;
WiFiClient client;
HTTPClient http;
WebServer server(80);
struct SystemError {
  String message;
  String details;
  unsigned long timestamp;
};

SystemError lastError = {"None", "", 0};

struct DeviceStatus {
  String name;
  String ip;
  String description;
  bool online;
  unsigned long lastChecked;
};

// 🦆 says ⮞ other esp devices for header
//std::vector<DeviceStatus> deviceStatuses = {
//  { "box", "192.168.1.13", "", false, 0 }
//};

// 🦆 says ⮞ dynamic injection of zigbee devices
String zigbeeDevicesHTML = R"rawliteral(<div class="room-section">
  <h4 style="margin-top: 20px; margin-bottom: 10px; padding-bottom: 5px; border-bottom: 1px solid #e2e8f0; color: #2b6cb0; cursor: pointer;" onclick="toggleRoom('bedroom')">
    <span class="room-toggle">▼</span>
    🛏️ Bedroom
  </h4>
  <div class="room-content" id="room-content-bedroom">
    <div class="device" data-id="0x00178801001ecdaa">
  <div class="device-header" onclick="toggleDeviceControls('0x00178801001ecdaa')">
    <div class="control-label">
      <span>💡</span> Bloom
    </div>
    <label class="toggle">
      <input type="checkbox" onchange="toggleDevice('0x00178801001ecdaa', this.checked)">
      <span class="slider"></span>
    </label>
  </div>
  
  <div class="device-controls" id="controls-0x00178801001ecdaa" style="display:none">
    <div class="control-row">
      <label>Brightness:</label>
      <input type="range" min="1" max="254" value="254" class="brightness-slider" data-device="0x00178801001ecdaa">
    </div>
   
    <div class="control-row">
  <label>Color:</label>
  <input type="range" min="0" max="360" value="0" class="rgb-slider" data-device="0x00178801001ecdaa" oninput="updateRGBColor(this)">
</div>        

<div class="control-row">
  <input type="color" class="color-picker" data-device="0x00178801001ecdaa" value="#ffffff">
</div>

  </div>
</div>
<div class="device" data-id="0x0017880103c7467d">
  <div class="device-header" onclick="toggleDeviceControls('0x0017880103c7467d')">
    <div class="control-label">
      <span>💡</span> Taket Sovrum 2
    </div>
    <label class="toggle">
      <input type="checkbox" onchange="toggleDevice('0x0017880103c7467d', this.checked)">
      <span class="slider"></span>
    </label>
  </div>
  
  <div class="device-controls" id="controls-0x0017880103c7467d" style="display:none">
    <div class="control-row">
      <label>Brightness:</label>
      <input type="range" min="1" max="254" value="254" class="brightness-slider" data-device="0x0017880103c7467d">
    </div>
   
    <div class="control-row">
  <label>Color:</label>
  <input type="range" min="0" max="360" value="0" class="rgb-slider" data-device="0x0017880103c7467d" oninput="updateRGBColor(this)">
</div>        

<div class="control-row">
  <input type="color" class="color-picker" data-device="0x0017880103c7467d" value="#ffffff">
</div>

  </div>
</div>
<div class="device" data-id="0x0017880103f44b5f">
  <div class="device-header" onclick="toggleDeviceControls('0x0017880103f44b5f')">
    <div class="control-label">
      <span>💡</span> Dörr
    </div>
    <label class="toggle">
      <input type="checkbox" onchange="toggleDevice('0x0017880103f44b5f', this.checked)">
      <span class="slider"></span>
    </label>
  </div>
  
  <div class="device-controls" id="controls-0x0017880103f44b5f" style="display:none">
    <div class="control-row">
      <label>Brightness:</label>
      <input type="range" min="1" max="254" value="254" class="brightness-slider" data-device="0x0017880103f44b5f">
    </div>
   
    <div class="control-row">
  <label>Color:</label>
  <input type="range" min="0" max="360" value="0" class="rgb-slider" data-device="0x0017880103f44b5f" oninput="updateRGBColor(this)">
</div>        

<div class="control-row">
  <input type="color" class="color-picker" data-device="0x0017880103f44b5f" value="#ffffff">
</div>

  </div>
</div>
<div class="device" data-id="0x0017880104051a86">
  <div class="device-header" onclick="toggleDeviceControls('0x0017880104051a86')">
    <div class="control-label">
      <span>💡</span> Sänggavel
    </div>
    <label class="toggle">
      <input type="checkbox" onchange="toggleDevice('0x0017880104051a86', this.checked)">
      <span class="slider"></span>
    </label>
  </div>
  
  <div class="device-controls" id="controls-0x0017880104051a86" style="display:none">
    <div class="control-row">
      <label>Brightness:</label>
      <input type="range" min="1" max="254" value="254" class="brightness-slider" data-device="0x0017880104051a86">
    </div>
   
    <div class="control-row">
  <label>Color:</label>
  <input type="range" min="0" max="360" value="0" class="rgb-slider" data-device="0x0017880104051a86" oninput="updateRGBColor(this)">
</div>        

<div class="control-row">
  <input type="color" class="color-picker" data-device="0x0017880104051a86" value="#ffffff">
</div>

  </div>
</div>
<div class="device" data-id="0x0017880106156cb0">
  <div class="device-header" onclick="toggleDeviceControls('0x0017880106156cb0')">
    <div class="control-label">
      <span>💡</span> Taket Sovrum 1
    </div>
    <label class="toggle">
      <input type="checkbox" onchange="toggleDevice('0x0017880106156cb0', this.checked)">
      <span class="slider"></span>
    </label>
  </div>
  
  <div class="device-controls" id="controls-0x0017880106156cb0" style="display:none">
    <div class="control-row">
      <label>Brightness:</label>
      <input type="range" min="1" max="254" value="254" class="brightness-slider" data-device="0x0017880106156cb0">
    </div>
   
    <div class="control-row">
  <label>Color:</label>
  <input type="range" min="0" max="360" value="0" class="rgb-slider" data-device="0x0017880106156cb0" oninput="updateRGBColor(this)">
</div>        

<div class="control-row">
  <input type="color" class="color-picker" data-device="0x0017880106156cb0" value="#ffffff">
</div>

  </div>
</div>
<div class="device" data-id="0x0017880109ac14f3">
  <div class="device-header" onclick="toggleDeviceControls('0x0017880109ac14f3')">
    <div class="control-label">
      <span>💡</span> Sänglampa
    </div>
    <label class="toggle">
      <input type="checkbox" onchange="toggleDevice('0x0017880109ac14f3', this.checked)">
      <span class="slider"></span>
    </label>
  </div>
  
  <div class="device-controls" id="controls-0x0017880109ac14f3" style="display:none">
    <div class="control-row">
      <label>Brightness:</label>
      <input type="range" min="1" max="254" value="254" class="brightness-slider" data-device="0x0017880109ac14f3">
    </div>
   
    <div class="control-row">
  <label>Color:</label>
  <input type="range" min="0" max="360" value="0" class="rgb-slider" data-device="0x0017880109ac14f3" oninput="updateRGBColor(this)">
</div>        

<div class="control-row">
  <input type="color" class="color-picker" data-device="0x0017880109ac14f3" value="#ffffff">
</div>

  </div>
</div>

  </div>
</div>
<div class="room-section">
  <h4 style="margin-top: 20px; margin-bottom: 10px; padding-bottom: 5px; border-bottom: 1px solid #e2e8f0; color: #2b6cb0; cursor: pointer;" onclick="toggleRoom('hallway')">
    <span class="room-toggle">▼</span>
    🚪 Hallway
  </h4>
  <div class="room-content" id="room-content-hallway">
    <div class="device" data-id="0x000b57fffe0e2a04">
  <div class="device-header" onclick="toggleDeviceControls('0x000b57fffe0e2a04')">
    <div class="control-label">
      <span>💡</span> Vägg
    </div>
    <label class="toggle">
      <input type="checkbox" onchange="toggleDevice('0x000b57fffe0e2a04', this.checked)">
      <span class="slider"></span>
    </label>
  </div>
  
  <div class="device-controls" id="controls-0x000b57fffe0e2a04" style="display:none">
    <div class="control-row">
      <label>Brightness:</label>
      <input type="range" min="1" max="254" value="254" class="brightness-slider" data-device="0x000b57fffe0e2a04">
    </div>
   
    
  </div>
</div>
<div class="device" data-id="0x0017880103eafdd6">
  <div class="device-header" onclick="toggleDeviceControls('0x0017880103eafdd6')">
    <div class="control-label">
      <span>💡</span> Tak Hall
    </div>
    <label class="toggle">
      <input type="checkbox" onchange="toggleDevice('0x0017880103eafdd6', this.checked)">
      <span class="slider"></span>
    </label>
  </div>
  
  <div class="device-controls" id="controls-0x0017880103eafdd6" style="display:none">
    <div class="control-row">
      <label>Brightness:</label>
      <input type="range" min="1" max="254" value="254" class="brightness-slider" data-device="0x0017880103eafdd6">
    </div>
   
    
  </div>
</div>

  </div>
</div>
<div class="room-section">
  <h4 style="margin-top: 20px; margin-bottom: 10px; padding-bottom: 5px; border-bottom: 1px solid #e2e8f0; color: #2b6cb0; cursor: pointer;" onclick="toggleRoom('kitchen')">
    <span class="room-toggle">▼</span>
    🍳 Kitchen
  </h4>
  <div class="room-content" id="room-content-kitchen">
    <div class="device" data-id="0x0017880102f0848a">
  <div class="device-header" onclick="toggleDeviceControls('0x0017880102f0848a')">
    <div class="control-label">
      <span>💡</span> Spotlight kök 1
    </div>
    <label class="toggle">
      <input type="checkbox" onchange="toggleDevice('0x0017880102f0848a', this.checked)">
      <span class="slider"></span>
    </label>
  </div>
  
  <div class="device-controls" id="controls-0x0017880102f0848a" style="display:none">
    <div class="control-row">
      <label>Brightness:</label>
      <input type="range" min="1" max="254" value="254" class="brightness-slider" data-device="0x0017880102f0848a">
    </div>
   
    
  </div>
</div>
<div class="device" data-id="0x0017880102f08526">
  <div class="device-header" onclick="toggleDeviceControls('0x0017880102f08526')">
    <div class="control-label">
      <span>💡</span> Spotlight Kök 2
    </div>
    <label class="toggle">
      <input type="checkbox" onchange="toggleDevice('0x0017880102f08526', this.checked)">
      <span class="slider"></span>
    </label>
  </div>
  
  <div class="device-controls" id="controls-0x0017880102f08526" style="display:none">
    <div class="control-row">
      <label>Brightness:</label>
      <input type="range" min="1" max="254" value="254" class="brightness-slider" data-device="0x0017880102f08526">
    </div>
   
    
  </div>
</div>
<div class="device" data-id="0x0017880103a0d280">
  <div class="device-header" onclick="toggleDeviceControls('0x0017880103a0d280')">
    <div class="control-label">
      <span>💡</span> Uppe
    </div>
    <label class="toggle">
      <input type="checkbox" onchange="toggleDevice('0x0017880103a0d280', this.checked)">
      <span class="slider"></span>
    </label>
  </div>
  
  <div class="device-controls" id="controls-0x0017880103a0d280" style="display:none">
    <div class="control-row">
      <label>Brightness:</label>
      <input type="range" min="1" max="254" value="254" class="brightness-slider" data-device="0x0017880103a0d280">
    </div>
   
    <div class="control-row">
  <label>Color:</label>
  <input type="range" min="0" max="360" value="0" class="rgb-slider" data-device="0x0017880103a0d280" oninput="updateRGBColor(this)">
</div>        

<div class="control-row">
  <input type="color" class="color-picker" data-device="0x0017880103a0d280" value="#ffffff">
</div>

  </div>
</div>
<div class="device" data-id="0x0017880103e0add1">
  <div class="device-header" onclick="toggleDeviceControls('0x0017880103e0add1')">
    <div class="control-label">
      <span>💡</span> Golvet
    </div>
    <label class="toggle">
      <input type="checkbox" onchange="toggleDevice('0x0017880103e0add1', this.checked)">
      <span class="slider"></span>
    </label>
  </div>
  
  <div class="device-controls" id="controls-0x0017880103e0add1" style="display:none">
    <div class="control-row">
      <label>Brightness:</label>
      <input type="range" min="1" max="254" value="254" class="brightness-slider" data-device="0x0017880103e0add1">
    </div>
   
    <div class="control-row">
  <label>Color:</label>
  <input type="range" min="0" max="360" value="0" class="rgb-slider" data-device="0x0017880103e0add1" oninput="updateRGBColor(this)">
</div>        

<div class="control-row">
  <input type="color" class="color-picker" data-device="0x0017880103e0add1" value="#ffffff">
</div>

  </div>
</div>
<div class="device" data-id="0xa4c13873044cb7ea">
  <div class="device-header" onclick="toggleDeviceControls('0xa4c13873044cb7ea')">
    <div class="control-label">
      <span>💡</span> Kök Bänk Slinga
    </div>
    <label class="toggle">
      <input type="checkbox" onchange="toggleDevice('0xa4c13873044cb7ea', this.checked)">
      <span class="slider"></span>
    </label>
  </div>
  
  <div class="device-controls" id="controls-0xa4c13873044cb7ea" style="display:none">
    <div class="control-row">
      <label>Brightness:</label>
      <input type="range" min="1" max="254" value="254" class="brightness-slider" data-device="0xa4c13873044cb7ea">
    </div>
   
    
  </div>
</div>

  </div>
</div>
<div class="room-section">
  <h4 style="margin-top: 20px; margin-bottom: 10px; padding-bottom: 5px; border-bottom: 1px solid #e2e8f0; color: #2b6cb0; cursor: pointer;" onclick="toggleRoom('livingroom')">
    <span class="room-toggle">▼</span>
    🛋️ Livingroom
  </h4>
  <div class="room-content" id="room-content-livingroom">
    <div class="device" data-id="0x0017880102de8570">
  <div class="device-header" onclick="toggleDeviceControls('0x0017880102de8570')">
    <div class="control-label">
      <span>💡</span> Rustning
    </div>
    <label class="toggle">
      <input type="checkbox" onchange="toggleDevice('0x0017880102de8570', this.checked)">
      <span class="slider"></span>
    </label>
  </div>
  
  <div class="device-controls" id="controls-0x0017880102de8570" style="display:none">
    <div class="control-row">
      <label>Brightness:</label>
      <input type="range" min="1" max="254" value="254" class="brightness-slider" data-device="0x0017880102de8570">
    </div>
   
    <div class="control-row">
  <label>Color:</label>
  <input type="range" min="0" max="360" value="0" class="rgb-slider" data-device="0x0017880102de8570" oninput="updateRGBColor(this)">
</div>        

<div class="control-row">
  <input type="color" class="color-picker" data-device="0x0017880102de8570" value="#ffffff">
</div>

  </div>
</div>
<div class="device" data-id="0x00178801037e754e">
  <div class="device-header" onclick="toggleDeviceControls('0x00178801037e754e')">
    <div class="control-label">
      <span>💡</span> Takkrona 1
    </div>
    <label class="toggle">
      <input type="checkbox" onchange="toggleDevice('0x00178801037e754e', this.checked)">
      <span class="slider"></span>
    </label>
  </div>
  
  <div class="device-controls" id="controls-0x00178801037e754e" style="display:none">
    <div class="control-row">
      <label>Brightness:</label>
      <input type="range" min="1" max="254" value="254" class="brightness-slider" data-device="0x00178801037e754e">
    </div>
   
    <div class="control-row">
  <label>Color:</label>
  <input type="range" min="0" max="360" value="0" class="rgb-slider" data-device="0x00178801037e754e" oninput="updateRGBColor(this)">
</div>        

<div class="control-row">
  <input type="color" class="color-picker" data-device="0x00178801037e754e" value="#ffffff">
</div>

  </div>
</div>
<div class="device" data-id="0x0017880103c73f85">
  <div class="device-header" onclick="toggleDeviceControls('0x0017880103c73f85')">
    <div class="control-label">
      <span>💡</span> Takkrona 2
    </div>
    <label class="toggle">
      <input type="checkbox" onchange="toggleDevice('0x0017880103c73f85', this.checked)">
      <span class="slider"></span>
    </label>
  </div>
  
  <div class="device-controls" id="controls-0x0017880103c73f85" style="display:none">
    <div class="control-row">
      <label>Brightness:</label>
      <input type="range" min="1" max="254" value="254" class="brightness-slider" data-device="0x0017880103c73f85">
    </div>
   
    <div class="control-row">
  <label>Color:</label>
  <input type="range" min="0" max="360" value="0" class="rgb-slider" data-device="0x0017880103c73f85" oninput="updateRGBColor(this)">
</div>        

<div class="control-row">
  <input type="color" class="color-picker" data-device="0x0017880103c73f85" value="#ffffff">
</div>

  </div>
</div>
<div class="device" data-id="0x0017880103c753b8">
  <div class="device-header" onclick="toggleDeviceControls('0x0017880103c753b8')">
    <div class="control-label">
      <span>💡</span> Takkrona 4
    </div>
    <label class="toggle">
      <input type="checkbox" onchange="toggleDevice('0x0017880103c753b8', this.checked)">
      <span class="slider"></span>
    </label>
  </div>
  
  <div class="device-controls" id="controls-0x0017880103c753b8" style="display:none">
    <div class="control-row">
      <label>Brightness:</label>
      <input type="range" min="1" max="254" value="254" class="brightness-slider" data-device="0x0017880103c753b8">
    </div>
   
    <div class="control-row">
  <label>Color:</label>
  <input type="range" min="0" max="360" value="0" class="rgb-slider" data-device="0x0017880103c753b8" oninput="updateRGBColor(this)">
</div>        

<div class="control-row">
  <input type="color" class="color-picker" data-device="0x0017880103c753b8" value="#ffffff">
</div>

  </div>
</div>
<div class="device" data-id="0x0017880103f94041">
  <div class="device-header" onclick="toggleDeviceControls('0x0017880103f94041')">
    <div class="control-label">
      <span>💡</span> Takkrona 3
    </div>
    <label class="toggle">
      <input type="checkbox" onchange="toggleDevice('0x0017880103f94041', this.checked)">
      <span class="slider"></span>
    </label>
  </div>
  
  <div class="device-controls" id="controls-0x0017880103f94041" style="display:none">
    <div class="control-row">
      <label>Brightness:</label>
      <input type="range" min="1" max="254" value="254" class="brightness-slider" data-device="0x0017880103f94041">
    </div>
   
    <div class="control-row">
  <label>Color:</label>
  <input type="range" min="0" max="360" value="0" class="rgb-slider" data-device="0x0017880103f94041" oninput="updateRGBColor(this)">
</div>        

<div class="control-row">
  <input type="color" class="color-picker" data-device="0x0017880103f94041" value="#ffffff">
</div>

  </div>
</div>
<div class="device" data-id="0x0017880104540411">
  <div class="device-header" onclick="toggleDeviceControls('0x0017880104540411')">
    <div class="control-label">
      <span>💡</span> PC
    </div>
    <label class="toggle">
      <input type="checkbox" onchange="toggleDevice('0x0017880104540411', this.checked)">
      <span class="slider"></span>
    </label>
  </div>
  
  <div class="device-controls" id="controls-0x0017880104540411" style="display:none">
    <div class="control-row">
      <label>Brightness:</label>
      <input type="range" min="1" max="254" value="254" class="brightness-slider" data-device="0x0017880104540411">
    </div>
   
    <div class="control-row">
  <label>Color:</label>
  <input type="range" min="0" max="360" value="0" class="rgb-slider" data-device="0x0017880104540411" oninput="updateRGBColor(this)">
</div>        

<div class="control-row">
  <input type="color" class="color-picker" data-device="0x0017880104540411" value="#ffffff">
</div>

  </div>
</div>

  </div>
</div>
<div class="room-section">
  <h4 style="margin-top: 20px; margin-bottom: 10px; padding-bottom: 5px; border-bottom: 1px solid #e2e8f0; color: #2b6cb0; cursor: pointer;" onclick="toggleRoom('wc')">
    <span class="room-toggle">▼</span>
    🚽 Wc
  </h4>
  <div class="room-content" id="room-content-wc">
    <div class="device" data-id="0x0017880103406f41">
  <div class="device-header" onclick="toggleDeviceControls('0x0017880103406f41')">
    <div class="control-label">
      <span>💡</span> WC 2
    </div>
    <label class="toggle">
      <input type="checkbox" onchange="toggleDevice('0x0017880103406f41', this.checked)">
      <span class="slider"></span>
    </label>
  </div>
  
  <div class="device-controls" id="controls-0x0017880103406f41" style="display:none">
    <div class="control-row">
      <label>Brightness:</label>
      <input type="range" min="1" max="254" value="254" class="brightness-slider" data-device="0x0017880103406f41">
    </div>
   
    
  </div>
</div>
<div class="device" data-id="0x001788010361b842">
  <div class="device-header" onclick="toggleDeviceControls('0x001788010361b842')">
    <div class="control-label">
      <span>💡</span> WC 1
    </div>
    <label class="toggle">
      <input type="checkbox" onchange="toggleDevice('0x001788010361b842', this.checked)">
      <span class="slider"></span>
    </label>
  </div>
  
  <div class="device-controls" id="controls-0x001788010361b842" style="display:none">
    <div class="control-row">
      <label>Brightness:</label>
      <input type="range" min="1" max="254" value="254" class="brightness-slider" data-device="0x001788010361b842">
    </div>
   
    
  </div>
</div>

  </div>
</div>
)rawliteral";

// 🦆 says ⮞ rooms
std::map<String, String> roomIcons = {
  {"livingroom", "🛋️"},
  {"bedroom", "🛏️"},
  {"kitchen", "🍳"},
  {"wc", "🚿"},
  {"hallway", "💻"},
  {"other", "?"}   
};

unsigned long lastZigbeeFetch = 0;
const unsigned long ZIGBEE_UPDATE_INTERVAL = 300000; // 5 minutes
const char* zigbeeEndpoint = "http://192.168.1.111:25451/zigbee_devices";
// 🦆 says ⮞ can't touch diz
bool touchActive = false;
unsigned long lastTouchCheck = 0;
const unsigned long TOUCH_CHECK_INTERVAL = 50; // ms

// ===========================================
// 🦆 says ⮞ TOUCH FUNCTIONS
void recordError(String message, String details = "");
void IRAM_ATTR touchISR() {
  touchDetected = true;
}

bool checkTouch() {
  Wire.beginTransmission(touchAddress);
  Wire.write(0x00);  // Status register
  byte error = Wire.endTransmission(false);
  
  if (error != 0) {
    Serial.printf("I2C error: %d\n", error);
    return false;
  }
  
  uint8_t bytesReceived = Wire.requestFrom(touchAddress, 1);
  if (bytesReceived == 1) {
    return (Wire.read() & 0x80) != 0;
  }
  return false;
}

void updateTouchState() {
  if (millis() - lastTouchCheck < TOUCH_CHECK_INTERVAL) return;
  lastTouchCheck = millis();
  
  bool currentTouch = checkTouch();
  
  if (currentTouch && !touchActive) {
    // plz touch ⮞ 🦆
    touchActive = true;
    if (!isRecording) {
      startRecording();
    }
  } else if (!currentTouch && touchActive) {
    // 🦆 says ⮞ can't touch diz yo
    touchActive = false;
    if (isRecording) {
      stopRecording();
    }
  }
}

// ===========================================
// 🦆 says ⮞ RECORDING CONTROL
WiFiClientSecure audioClient;
HTTPClient audioHttp;
bool httpInitialized = false;

void recordError(String message, String details) {
  lastError.message = message;
  lastError.details = details;
  lastError.timestamp = millis();
}

void startRecording() {
  if (isRecording) return;
  
  Serial.println("Recording started (touch detected)");
  digitalWrite(TFT_BL, HIGH);
  isRecording = true;
  
  // 🦆 says ⮞ start da http connection
  audioClient.setInsecure(); // 🦆 TODO ⮞ not suitable for prod yo 
  if (audioHttp.begin(audioClient, apiEndpoint)) {
    audioHttp.addHeader("Content-Type", "application/octet-stream");
    httpInitialized = true;
  } else {
    recordError("HTTP Begin Failed", "Could not connect to: " + String(apiEndpoint));
    httpInitialized = false;
  }
  
  i2s_start(I2S_NUM_0);
}

void stopRecording() {
  if (!isRecording) return;
  
  Serial.println("Recording stopped (touch released)");
  isRecording = false;
  
  i2s_stop(I2S_NUM_0);
  
  if (httpInitialized) {
    audioHttp.end();
    httpInitialized = false;
  }
}


// ===========================================
// 🦆 says ⮞ MQTT FUNCTIONS
String mqttStateToString(int state) {
  switch(state) {
    case MQTT_CONNECTION_TIMEOUT: return "Connection timeout";
    case MQTT_CONNECTION_LOST: return "Connection lost";
    case MQTT_CONNECT_FAILED: return "Connect failed";
    case MQTT_DISCONNECTED: return "Disconnected";
    case MQTT_CONNECTED: return "Connected";
    case MQTT_CONNECT_BAD_PROTOCOL: return "Bad protocol";
    case MQTT_CONNECT_BAD_CLIENT_ID: return "Bad client ID";
    case MQTT_CONNECT_UNAVAILABLE: return "Unavailable";
    case MQTT_CONNECT_BAD_CREDENTIALS: return "Bad credentials";
    case MQTT_CONNECT_UNAUTHORIZED: return "Unauthorized";
    default: return "Unknown error";
  }
}


void streamAudio() {
  if (!isRecording || !httpInitialized) return;
  
  static uint8_t audioBuffer[BUFFER_SIZE * 2];
  size_t bytesRead = 0;
  
  // 🦆 says ⮞ read audio data
  esp_err_t err = i2s_read(I2S_NUM_0, audioBuffer, sizeof(audioBuffer), &bytesRead, 0);
  if (err != ESP_OK) {
    recordError("I2S Read Error", "Error code: " + String(err));
    return;
  }
  
  if (bytesRead > 0) {
    // 🦆 says ⮞ quacky hacky stream da data
    int httpCode = audioHttp.POST(audioBuffer, bytesRead);
    
    if (httpCode != HTTP_CODE_OK) {
      String errorDetails = "HTTP Code: " + String(httpCode) + "\n";
      errorDetails += "Error: " + audioHttp.errorToString(httpCode);
      recordError("Audio Upload Failed", errorDetails);
      
      stopRecording();
    }
  }
}

void reconnectMQTT() {
  while (!mqttClient.connected()) {
    String errorDetails = "Attempting MQTT connection to ";
    errorDetails += String(mqtt_server) + "...";
    
    if (mqttClient.connect("ESP32Client", mqtt_user, mqtt_password)) {
      errorDetails += "connected";
    } else {
      errorDetails += "failed, rc=";
      errorDetails += String(mqttClient.state());
      errorDetails += " - " + mqttStateToString(mqttClient.state());
    }
    
    recordError("MQTT Connection", errorDetails);
    
    if (!mqttClient.connected()) {
      delay(5000);
    }
  }
}

// ===========================================
// 🦆 says ⮞ DEVICE STATUS CHECKING
//void initializeDeviceStatuses() {
  // This will be filled by Nix injection
//  deviceStatuses = {
//    {"box", "192.168.1.13", "dope dev toolboxin'z crazy", false, 0},
//    {"watch", "192.168.1.101", "yo cool watch - cat!", false, 0}
//  };
//}

///bool checkDeviceOnline(const String& ip) {
//  WiFiClient client;
//  const int port = 80;
//  const int timeout = 500; // ms
  
//7  if (client.connect(ip.c_str(), port)) {
//    client.stop();
//    return true;
//  }
//  return false;
//}

//void updateDeviceStatuses() {
//  for (auto& device : deviceStatuses) {
//    if (millis() - device.lastChecked > 10000) { // Check every 10s
//      device.online = checkDeviceOnline(device.ip);
//      device.lastChecked = millis();
//    }
//  }
//}

// ===========================================
// 🦆 says ⮞ BATTERY FUNCTIONS
float getBatteryVoltage() {
  int raw = analogRead(BATTERY_ADC_PIN);
  const float refVoltage = 3.3;
  const int maxADC = 4095;
  const float dividerRatio = 2.0;  
  return (raw * refVoltage / maxADC) * dividerRatio;
}

int getBatteryPercentage() {
  float voltage = getBatteryVoltage();
  int percentage = (voltage - BATTERY_MIN_VOLTAGE) * 100 / 
                  (BATTERY_MAX_VOLTAGE - BATTERY_MIN_VOLTAGE);
  
  percentage = constrain(percentage, 0, 100);
  return percentage;
}

// ===========================================
// 🦆 says ⮞ ZIGBEE FUNC yeah

void fetchZigbeeDevices() {
  HTTPClient http;
  http.begin(zigbeeEndpoint);
  int httpCode = http.GET();  
  if (httpCode == HTTP_CODE_OK) {
    String payload = http.getString();
    DynamicJsonDocument doc(4096);
    deserializeJson(doc, payload);
    JsonObject devices = doc.as<JsonObject>();
    
    std::map<String, String> roomSections;
    
    for (JsonPair kv : devices) {
      const char* id = kv.key().c_str();
      JsonObject device = kv.value().as<JsonObject>();
      const char* type = device["type"];
      const char* name = device["friendly_name"];
      const char* room = device["room"];
      bool state = device["state"];

      if (strcmp(type, "light") == 0) {
        bool supportsColor = device["supports_color"];
        bool supportsBrightness = device["supports_brightness"];

        String deviceHTML = "<div class=\"device\" data-id=\"" + String(id) + "\">";
        deviceHTML += "<div class=\"device-header\" onclick=\"toggleDeviceControls('" + String(id) + "')\">";
        deviceHTML += "<div class=\"control-label\"><span>💡</span> ";
        deviceHTML += name;
        deviceHTML += "</div>";
        deviceHTML += "<label class=\"toggle\" onclick=\"event.stopPropagation()\">";
        deviceHTML += "<input type=\"checkbox\" onchange=\"toggleDevice('" + String(id) + "', this.checked)\" " + (state ? "checked" : "") + ">";
        deviceHTML += "<span class=\"slider\"></span>";
        deviceHTML += "</label>";
        deviceHTML += "</div>";

        deviceHTML += "<div class=\"device-controls\" id=\"controls-" + String(id) + "\" style=\"display:none\">";

        if (supportsBrightness) {
          deviceHTML += "<div class=\"control-row\">";
          deviceHTML += "<label>Brightness:</label>";
          deviceHTML += "<input type=\"range\" min=\"1\" max=\"254\" value=\"254\" class=\"brightness-slider\" data-device=\"" + String(id) + "\">";
          deviceHTML += "</div>";
        }

        if (supportsColor) {
          deviceHTML += "<div class=\"control-row\">";
          deviceHTML += "<label>Color:</label>";
          deviceHTML += "<input type=\"color\" class=\"color-picker\" data-device=\"" + String(id) + "\" value=\"#ffffff\">";
          deviceHTML += "</div>";
        }

        deviceHTML += "</div></div>"; // 🦆 says ⮞ close controls
        
        if (roomSections.find(room) == roomSections.end()) {
          roomSections[room] = "";
        }
        roomSections[room] += deviceHTML;
      }
    }

    zigbeeDevicesHTML = ""; // 🦆 says ⮞ clear out yo
    for (auto& room : roomSections) {
      String icon = "💡";
      auto iconIt = roomIcons.find(room.first);
      if (iconIt != roomIcons.end()) {
        icon = iconIt->second;
      }
  
      zigbeeDevicesHTML += "<div class=\"room-section\">";
      zigbeeDevicesHTML += "<h4 style=\"margin-top: 20px; margin-bottom: 10px; padding-bottom: 5px; border-bottom: 1px solid #e2e8f0; color: #2b6cb0;\">";
      zigbeeDevicesHTML += icon + " " + room.first;
      zigbeeDevicesHTML += "</h4>";
      zigbeeDevicesHTML += room.second;
      zigbeeDevicesHTML += "</div>";  // Close room-section
    }
  }

  http.end();
}

void handleZigbeeColor() {
  String id = server.arg("id");
  String hexColor = server.arg("color");
  
  long rgb = strtol(hexColor.c_str(), NULL, 16);
  int r = (rgb >> 16) & 0xFF;
  int g = (rgb >> 8) & 0xFF;
  int b = rgb & 0xFF;

  String topic = "zigbee2mqtt/" + id + "/set";
  String payload = "{\"color\":{\"r\":" + String(r) + 
                   ",\"g\":" + String(g) + 
                   ",\"b\":" + String(b) + "}}";
  
  if (mqttClient.publish(topic.c_str(), payload.c_str())) {
    server.send(200, "text/plain", "OK");
  } else {
    server.send(500, "text/plain", "MQTT Publish Failed");
  }
}

void handleZigbeeBrightness() {
  String id = server.arg("id");
  String brightness = server.arg("brightness");
  
  String topic = "zigbee2mqtt/" + id + "/set";
  String payload = "{\"brightness\":" + brightness + "}";
  
  if (mqttClient.publish(topic.c_str(), payload.c_str())) {
    server.send(200, "text/plain", "OK");
  } else {
    server.send(500, "text/plain", "MQTT Publish Failed");
  }
}

// ===========================================
// 🦆 says ⮞ ES7210 INIT
void es7210_init() {
  Wire.beginTransmission(ES7210_ADDR);
  Wire.write(0x00); Wire.write(0x80);  // Reset chip
  Wire.endTransmission();
  delay(10);
  
  Wire.beginTransmission(ES7210_ADDR);
  Wire.write(0x00); Wire.write(0x00);  // Power up
  Wire.write(0x01); Wire.write(0x22);  // OSR=64
  Wire.write(0x02); Wire.write(0x50);  // Clock divider
  Wire.write(0x07); Wire.write(0x01);  // Enable ADC1 (mono)
  Wire.write(0x08); Wire.write(0x00);  // Disable other ADCs
  Wire.write(0x20); Wire.write(0x0A);  // LRCK divider
  Wire.write(0x21); Wire.write(0x0A);  // MCLK divider
  Wire.endTransmission();
  delay(50);
}

// ===========================================
// 🦆 says ⮞ I2S INIT
void initI2S() {
  i2s_config_t i2s_config = {
    .mode = (i2s_mode_t)(I2S_MODE_MASTER | I2S_MODE_RX),
    .sample_rate = SAMPLE_RATE,
    .bits_per_sample = I2S_BITS_PER_SAMPLE_16BIT,
    .channel_format = I2S_CHANNEL_FMT_ONLY_LEFT,
    .communication_format = I2S_COMM_FORMAT_STAND_I2S,
    .intr_alloc_flags = ESP_INTR_FLAG_LEVEL1,
    .dma_buf_count = 8,  // Increased buffer count
    .dma_buf_len = BUFFER_SIZE,
    .use_apll = true,    // Use audio PLL for better clock stability
    .tx_desc_auto_clear = false,
    .fixed_mclk = 0
  };

  i2s_pin_config_t pin_config = {
    .mck_io_num = I2S_MCLK,
    .bck_io_num = I2S_SCLK,
    .ws_io_num = I2S_LRCK,
    .data_out_num = I2S_PIN_NO_CHANGE,
    .data_in_num = I2S_SDIN
  };
  
  // 🦆 says ⮞ install & start I2S driver
  i2s_driver_install(I2S_NUM_0, &i2s_config, 0, NULL);
  i2s_set_pin(I2S_NUM_0, &pin_config);
  
  // 🦆 says ⮞ ES7210 ADC
  es7210_init();
}

void handleRFSend() {
  String code = server.arg("code");
  Serial.println("Received RF code: " + code);  
  // 🦆 TODO ⮞ logic lol 
  server.send(200, "text/plain", "RF code sent: " + code);
}

// ===========================================
// ===========================================
// 🦆 says ⮞ WEB SERVER quack quack

// 🦆 says ⮞ JAVASCRIPT
static const char* jsCode PROGMEM = R"=====(
  function hslToHex(h, s, l) {
    h = h % 360;
    s /= 100;
    l /= 100;
    const k = n => (n + h / 30) % 12;
    const a = s * Math.min(l, 1 - l);
    const f = n =>
      l - a * Math.max(-1, Math.min(k(n) - 3, Math.min(9 - k(n), 1)));
    const toHex = x =>
      Math.round(x * 255).toString(16).padStart(2, "0");
    return `#${toHex(f(0))}${toHex(f(8))}${toHex(f(4))}`;
  }

  function updateRGBColor(slider) {
    const hue = parseInt(slider.value);
    const color = hslToHex(hue, 100, 50);
    slider.style.background = `linear-gradient(to right, 
      red, yellow, lime, cyan, blue, magenta, red)`;
    const deviceId = slider.dataset.device;
    console.log(`Set color of device ${deviceId} to ${color}`);
    const colorPicker = document.querySelector(`.color-picker[data-device="${deviceId}"]`);
    if (colorPicker) colorPicker.value = color;
    setDeviceColor(deviceId, color);
  }

  function toggleRoom(roomId) {
    const content = document.getElementById(`room-${roomId}-content`);
    content.style.display = content.style.display === 'none' ? 'block' : 'none';
  }
  function toggleDevice(id, checked) {
    fetch(`/zigbee/control?id=${encodeURIComponent(id)}&state=${checked ? 'on' : 'off'}`)
      .then(res => {
        if (!res.ok) alert(`Toggle ${id} failed`);
      });
  }
  function toggleRecording(checkbox) {
    const state = checkbox.checked;
    document.getElementById("recording-status").textContent = state ? "Recording" : "Stopped";
    fetch(`/record?state=${state ? 'on' : 'off'}`)
      .then(res => {
        if (!res.ok) alert("Toggle failed");
      });
  } 
  function setDeviceBrightness(deviceId, brightness) {
    fetch(`/zigbee/brightness?id=${encodeURIComponent(deviceId)}&brightness=${brightness}`)
      .then(res => {
        if (!res.ok) alert(`Set brightness failed for ${deviceId}`);
      });
  }  
  function setDeviceColor(deviceId, color) {
    const hexColor = color.substring(1);  // Remove # from hex color
    fetch(`/zigbee/color?id=${encodeURIComponent(deviceId)}&color=${hexColor}`)
      .then(res => {
        if (!res.ok) alert(`Set color failed for ${deviceId}`);
      });
  }  
  document.addEventListener('input', function(event) {
    if (event.target.classList.contains('brightness-slider')) {
      const deviceId = event.target.dataset.device;
      setDeviceBrightness(deviceId, event.target.value);
    }
    else if (event.target.classList.contains('color-picker')) {
      const deviceId = event.target.dataset.device;
      setDeviceColor(deviceId, event.target.value);
    }
  });
  function setDeviceBrightness(deviceId, brightness) {
    fetch(`/zigbee/brightness?id=${encodeURIComponent(deviceId)}&brightness=${brightness}`)
      .then(res => {
        if (!res.ok) alert(`Set brightness failed for ${deviceId}`);
      });
  }
  function setDeviceColor(deviceId, color) {
    const hexColor = color.substring(1);  // Remove # from hex color
    fetch(`/zigbee/color?id=${encodeURIComponent(deviceId)}&color=${hexColor}`)
      .then(res => {
        if (!res.ok) alert(`Set color failed for ${deviceId}`);
      });
  } 
  function toggleDeviceControls(deviceId) {
    const controls = document.getElementById(`controls-${deviceId}`);
    controls.style.display = controls.style.display === 'none' ? 'block' : 'none';
  }  
  document.addEventListener('input', function(event) {
    if (event.target.classList.contains('brightness-slider')) {
      const deviceId = event.target.dataset.device;
      setDeviceBrightness(deviceId, event.target.value);
    }
    else if (event.target.classList.contains('color-picker')) {
      const deviceId = event.target.dataset.device;
      setDeviceColor(deviceId, event.target.value);
    }
  });
)=====";

// ===========================================
// 🦆 says ⮞ HANDLE ROOT

void handleRoot() {
  float batteryVoltage = getBatteryVoltage();
  int batteryPercent = getBatteryPercentage();

  String motionStatus = "No motion";
  String temperature = "23.5 °C";
  String rfCode = "None received";
  String uptime = String(millis() / 1000) + " sec";

  String html;

  html += R"rawliteral(<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>🦆'Dash</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/quackhack-mcblindy/dotfiles@main/modules/themes/css/duckdash.css">
  <script>
)rawliteral";

  // 🦆 says ⮞ add da cool JS functions
  html += jsCode;
  
  // 🦆 says ⮞ error handler
  html += R"(
  function showErrorDetails() {
    document.getElementById('error-message').textContent = ")";
  html += lastError.message;
  html += R"(";
    document.getElementById('error-details').textContent = ")";
  html += lastError.details;
  html += R"(";
    document.getElementById('error-time').textContent = ")";
  html += String(millis() - lastError.timestamp);
  html += R"( ms ago";
    document.getElementById('errorModal').style.display = 'block';
  }
  )";
  
  html += R"rawliteral(
  </script>
</head>
<body>
  <div class="container">
    <!-- 🦆 says ⮞ HEADER -->
    <header>
      <h1>🦆Dash for device ESP32S3BOX3y</h1>
    </header>

  html += R"rawliteral(</script>
  </head>
  <body>
    <div class="container">
  )rawliteral";

  html += R"rawliteral(
    <div class="battery-section">
      <div class="status-icon">🔋</div>
      <div class="battery-percent">)rawliteral";
  html += String(batteryPercent);
  html += R"rawliteral(%</div>
      <div class="battery-bar">
        <div class="battery-fill )rawliteral";
  html += (batteryPercent > 50 ? "battery-high" : batteryPercent > 20 ? "battery-medium" : "battery-low");
  html += R"rawliteral(" style="width:)rawliteral";
  html += String(batteryPercent);
  html += R"rawliteral(%"></div>
      </div>
      <div class="voltage">Voltage: )rawliteral";
  html += String(batteryVoltage, 2);
  html += R"rawliteral(V</div>
    </div>

    <div class="status-grid">
      <!-- 🦆 says ⮞ WIFI STATUS -->
      <div class="status-item"><div class="status-icon">🌐</div><div class="status-content"><div class="status-label">WiFi</div><div class="status-value">)rawliteral";
  html += (WiFi.status() == WL_CONNECTED ? WiFi.localIP().toString() : "Disconnected");
  html += R"rawliteral(</div></div></div>
      <!-- 🦆 says ⮞ ERROR LOG -->
      <div class="status-item" onclick="showErrorDetails()" style="cursor:pointer;">
        <div class="status-icon">❗</div>
        <div class="status-content">
          <div class="status-label">System Error</div>
          <div class="status-value">)rawliteral";
  html += lastError.message;
  html += R"rawliteral(</div>
        </div>
      </div>
  
      <!-- 🦆 says ⮞ ERROR LOG DETAILS -->
      <div id="errorModal" style="display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.5);z-index:1000;">
        <div style="background:white;margin:10% auto;padding:20px;width:80%;border-radius:8px;">
          <h2>Error Details</h2>
          <p><strong>Message:</strong> <span id="error-message"></span></p>
          <p><strong>Details:</strong> <pre id="error-details"></pre></p>
          <p><strong>Timestamp:</strong> <span id="error-time"></span></p>
          <button onclick="document.getElementById('errorModal').style.display='none'">Close</button>
        </div>
      </div>
  
      <!-- 🦆 says ⮞ BATTERY VOLTAGE -->
      <div class="status-item"><div class="status-icon">🔋</div><div class="status-content"><div class="status-label">Battery Voltage</div><div class="status-value">)rawliteral";
  html += String(batteryVoltage, 2);
  html += R"rawliteral(V</div></div></div>
      <!-- 🦆 says ⮞ MOTION SENSOR -->
      <div class="status-item"><div class="status-icon">🕵️</div><div class="status-content"><div class="status-label">Motion Sensor</div><div class="status-value">)rawliteral";
  html += motionStatus;
  html += R"rawliteral(</div></div></div>
      <!-- 🦆 says ⮞ TEMPERATURE SENSOR -->
      <div class="status-item"><div class="status-icon">🌡️</div><div class="status-content"><div class="status-label">Temperature</div><div class="status-value">)rawliteral";
  html += temperature;
  html += R"rawliteral(</div></div></div>
      <!-- 🦆 says ⮞ TOUCH SENSOR -->
      <div class="status-item"><div class="status-icon">👆</div><div class="status-content"><div class="status-label">Touch Controller</div><div class="status-value">)rawliteral";
  html += (touchControllerAvailable ? "Available" : "Not Available");
  html += R"rawliteral(</div></div></div>
      <!-- 🦆 says ⮞ RECORDING SENSOR -->
      <div class="status-item"><div class="status-icon">🎙️</div><div class="status-content"><div class="status-label">Recording</div>
        <div class="status-value" style="display: flex; justify-content: space-between; align-items: center;">
          <span id="recording-status">)rawliteral";
  html += (isRecording ? "Recording" : "Stopped");
  html += R"rawliteral(</span>
          <label class="toggle" style="margin: 0;">
            <input type="checkbox" id="record-toggle" onchange="toggleRecording(this)" )rawliteral";
  html += (isRecording ? "checked" : "");
  html += R"rawliteral(>
            <span class="slider"></span>
          </label>
        </div>
      </div></div>

      <!-- 🦆 says ⮞ LCD BACKLIGHT -->
      <div class="status-item"><div class="status-icon">💡</div><div class="status-content"><div class="status-label">Backlight</div><div class="status-value">)rawliteral";
  html += (digitalRead(TFT_BL) == HIGH ? "On" : "Off");
  html += R"rawliteral(</div></div></div>
      <!-- 🦆 says ⮞ AMPLIFIER -->
      <div class="status-item"><div class="status-icon">📢</div><div class="status-content"><div class="status-label">Amplifier</div><div class="status-value">)rawliteral";
  html += (digitalRead(PA_PIN) == HIGH ? "On" : "Off");
  html += R"rawliteral(</div></div></div>
      <!-- 🦆 says ⮞ UPTIME -->
      <div class="status-item"><div class="status-icon">⏱️</div><div class="status-content"><div class="status-label">Uptime</div><div class="status-value">)rawliteral";
  html += uptime;
  html += R"rawliteral(</div></div></div>
      <!-- 🦆 says ⮞ MUTE -->
      <div class="status-item"><div class="status-icon">🔇</div><div class="status-content"><div class="status-label">Button Mute</div><div class="status-value">)rawliteral";
  html += (digitalRead(MUTE_PIN) == LOW ? "PRESSED" : "RELEASED");
  html += R"rawliteral(</div></div></div>
      <!-- 🦆 says ⮞ RF TRANSMITTER -->
      <div class="status-item"><div class="status-icon">📡</div><div class="status-content"><div class="status-label">RF Transmitter</div><div class="status-value">)rawliteral";
  html += rfCode;
  html += R"rawliteral(</div></div></div>
      <!-- 🦆 says ⮞ RF RECEIVER -->
      <div class="status-item"><div class="status-icon">📡</div><div class="status-content"><div class="status-label">RF Receiver</div><div class="status-value">)rawliteral";
  html += rfCode;
  html += R"rawliteral(</div></div></div>

    </div>

    <!-- 🦆 says ⮞ DEVICE CONTROL -->
    <div class="controls">
      <h2 style="margin-bottom: 20px; text-align: center; color: #2b6cb0;">Device Controls</h2>
      <!-- 🦆 says ⮞ ZIGBEE DEVICE CONTROL -->
      <h3 style="margin-top: 20px; text-align: center; color: #2b6cb0;">Zigbee Lights</h3>
)rawliteral";

  html += zigbeeDevicesHTML;

  html += R"rawliteral(
    </div>
    <div class="footer">
      <br><br><p>🦆'Dash | Firmware v1.2 | ESP32S3BOX</p><br>
      <p>QuackHack-McBLindy | <a href="https://github.com/quackhack-mcblindy/dotfiles">GitHub</a></p>
    </div>
  </div>
</body>
</html>
)rawliteral";

  server.send(200, "text/html", html);
}

void handleRecord() {
  if (server.arg("state") == "on") {
    startRecording();
  } else if (server.arg("state") == "off") {
    stopRecording();
  }
  server.sendHeader("Location", "/");
  server.send(302, "text/plain", "Redirecting...");
}

void handleZigbeeControl() {
  String id = server.arg("id");
  String state = server.arg("state");
  
  String topic = "zigbee2mqtt/" + id + "/set";
  String payload = "{\"state\":\"";
  payload += (state == "on" ? "ON" : "OFF");
  payload += "\"}";
  
  if (mqttClient.publish(topic.c_str(), payload.c_str())) {
    Serial.printf("MQTT command sent: %s = %s\n", topic.c_str(), payload.c_str());
    server.send(200, "text/plain", "OK");
  } else {
    server.send(500, "text/plain", "MQTT Publish Failed");
  }
}

// ===========================================
// 🦆 says ⮞ TOUCH FUNCTIONS

void tt21100_init() {
  Serial.println("Initializing TT21100...");
  bool found = false;
  const uint8_t addresses[] = {0x38, 0x24, 0x25, 0x4A, 0x5A};  
  for (int i = 0; i < sizeof(addresses)/sizeof(addresses[0]); i++) {
    Wire.beginTransmission(addresses[i]);
    byte error = Wire.endTransmission();    
    if (error == 0) {
      Serial.printf("Found device at 0x%02X\n", addresses[i]);
      touchAddress = addresses[i];
      found = true;
      break;
    }
  }  
  if (!found) {
    Serial.println("TT21100 not found. Touch functionality disabled.");
    touchControllerAvailable = false;
    return;
  }
  
  touchControllerAvailable = true;
  Serial.println("TT21100 initialized");
}


// ===========================================
// ===========================================
// 🦆 says ⮞ SETUP & MAIN LOOP

void setup() {
  pinMode(TOUCH_INT_PIN, INPUT_PULLUP);
  Serial.begin(115200);
  delay(1000);
  mqttClient.setServer(mqtt_server, 1883);
  
  pinMode(PA_PIN, OUTPUT);
  pinMode(MUTE_PIN, INPUT_PULLUP);
  pinMode(TFT_BL, OUTPUT);
  pinMode(TFT_RST, OUTPUT);
  pinMode(BATTERY_ADC_PIN, INPUT);
  
  Wire.begin(I2C_SDA, I2C_SCL);
  
  es7210_init();
  
  initI2S();

  // 🦆 says ⮞ touch init
  tt21100_init();  
  if (touchControllerAvailable) {
    pinMode(TOUCH_INT_PIN, INPUT_PULLUP);
    attachInterrupt(digitalPinToInterrupt(TOUCH_INT_PIN), touchISR, FALLING);
  }
  
  // 🦆 says ⮞ connect to da wifi
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi");  
  unsigned long wifiTimeout = millis() + 30000; // 30s timeout
  while (WiFi.status() != WL_CONNECTED && millis() < wifiTimeout) {
    delay(500);
    Serial.print(".");
  }
  // 🦆 says ⮞ log errorz
  if (WiFi.status() != WL_CONNECTED) {
    String errorDetails = "Failed to connect to WiFi\n";
    errorDetails += "SSID: " + String(ssid) + "\n";
    errorDetails += "Status: " + String(WiFi.status()) + " - ";
    
    switch(WiFi.status()) {
      case WL_IDLE_STATUS: errorDetails += "Idle"; break;
      case WL_NO_SSID_AVAIL: errorDetails += "SSID not available"; break;
      case WL_SCAN_COMPLETED: errorDetails += "Scan completed"; break;
      case WL_CONNECT_FAILED: errorDetails += "Connect failed"; break;
      case WL_CONNECTION_LOST: errorDetails += "Connection lost"; break;
      case WL_DISCONNECTED: errorDetails += "Disconnected"; break;
      default: errorDetails += "Unknown error";
    }
    
    recordError("WiFi Connection Failed", errorDetails);
  } else {
    recordError("WiFi Connected", "IP: " + WiFi.localIP().toString());
    Serial.println("MAC Address:");
  }
  
 
  server.on("/", handleRoot);
  server.on("/record", handleRecord);
  server.on("/zigbee/control", handleZigbeeControl);
  server.on("/zigbee/color", handleZigbeeColor);
  server.on("/zigbee/brightness", handleZigbeeBrightness);
  server.begin();

  
  pinMode(TOUCH_INT_PIN, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(TOUCH_INT_PIN), touchISR, FALLING);  
  fetchZigbeeDevices();
  digitalWrite(PA_PIN, HIGH);    
}


// ===========================================
// 🦆 says ⮞ DA LOOP YO
void loop() {
  server.handleClient();  
  if (touchControllerAvailable) {
    if (touchDetected) {
      touchDetected = false;
      updateTouchState();
    }
  }
  
  if (!mqttClient.connected()) {
    reconnectMQTT();
  }
  mqttClient.loop();

  if (millis() - lastZigbeeFetch > ZIGBEE_UPDATE_INTERVAL) {
    fetchZigbeeDevices();
    lastZigbeeFetch = millis();
  }

  //  updateDeviceStatuses();
  
  if (isRecording) {
    streamAudio();
  }
  delay(10);
} // 🦆 says ⮞ bye bye!
