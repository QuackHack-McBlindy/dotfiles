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
#include <ArduinoOTA.h>
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
#define SAMPLE_RATE     16000
#define SAMPLE_BITS     16
#define BUFFER_SIZE     1024
// 🦆 says ⮞ mic
const int sampleRate = 16000;
const int recordDuration = 3;
const int bufferSize = sampleRate * recordDuration * sizeof(int16_t);
uint8_t* audioBuffer = NULL;
#define I2S_WS   42  // 🦆 says ⮞ correct
#define I2S_SD   41 // 🦆 says ⮞ correct
#define I2S_SCK  40 // 🦆 says ⮞ correct

#define ES7210_ADDR 0x40 
// 🦆 says ⮞  wifi & api
const char* ssid = "WIFISSIDHERE";
const char* password = "WIFIPASSWORDHERE";
const char* apiEndpoint = "https://TRANSCRIPTIONHOSTIPHERE:25451/audio_upload";
const char* serverURL = "http://TRANSCRIPTIONHOSTIPHERE:8111/upload_audio";
// 🦆 says ⮞  mqtt Configuration
const char* mqtt_server = "MQTTHOSTIPHERE";
const char* mqtt_user = "MQTTUSERNAMEHERE";
const char* mqtt_password = "MQTTPASSWORDHERE";
WiFiClient espClient;
PubSubClient mqttClient(espClient);
// 🦆 says ⮞ battery
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
std::vector<DeviceStatus> deviceStatuses = {
  DEVICESTATUSINITHERE
};

// 🦆 says ⮞ dynamic injection of zigbee devices
ZIGBEEDEVICESHERE

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
// 🦆 says ⮞ OTA
void setupOTA() {
  ArduinoOTA.setPort(OTAPORTHERE);
  ArduinoOTA.setPassword("OTAPASSWORDHERE");
  
  ArduinoOTA
    .onStart([]() {
      String type;
      if (ArduinoOTA.getCommand() == U_FLASH) {
        type = "sketch";
      } else { // U_SPIFFS
        type = "filesystem";
      }
      Serial.println("Start updating " + type);
    })
    .onEnd([]() {
      Serial.println("\nEnd");
    })
    .onProgress([](unsigned int progress, unsigned int total) {
      Serial.printf("Progress: %u%%\r", (progress / (total / 100)));
    })
    .onError([](ota_error_t error) {
      Serial.printf("Error[%u]: ", error);
      if (error == OTA_AUTH_ERROR) Serial.println("Auth Failed");
      else if (error == OTA_BEGIN_ERROR) Serial.println("Begin Failed");
      else if (error == OTA_CONNECT_ERROR) Serial.println("Connect Failed");
      else if (error == OTA_RECEIVE_ERROR) Serial.println("Receive Failed");
      else if (error == OTA_END_ERROR) Serial.println("End Failed");
    });

  ArduinoOTA.begin();
}
void handleOTA() {
  ArduinoOTA.handle();
}

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
void stopRecording() {
  if (isRecording) return;
  isRecording = true;  
  Serial.println("Recording...");
  size_t bytesRead = 0;
  i2s_read(I2S_NUM_0, audioBuffer, bufferSize, &bytesRead, portMAX_DELAY);
  Serial.printf("Recording done. Bytes read: %d\n", bytesRead);
  WiFiClient client;
  HTTPClient http;
  if (!http.begin(client, serverURL)) {
    Serial.println("HTTP begin failed");
    return;
  }
  http.addHeader("Content-Type", "application/octet-stream");
  Serial.println("Sending audio via POST...");
  int httpCode = http.POST(audioBuffer, bytesRead);
  Serial.printf("HTTP code: %d\n", httpCode);
  if (httpCode > 0) {
    Serial.println(http.getString());
  } else {
    Serial.println(http.errorToString(httpCode));
  }

  http.end();
  free(audioBuffer);
  i2s_driver_uninstall(I2S_NUM_0);
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
  isRecording = true;  
  Serial.println("Recording...");
  size_t bytesRead = 0;
  i2s_read(I2S_NUM_0, audioBuffer, bufferSize, &bytesRead, portMAX_DELAY);
  Serial.printf("Recording done. Bytes read: %d\n", bytesRead);
  WiFiClient client;
  HTTPClient http;
  if (!http.begin(client, serverURL)) {
    Serial.println("HTTP begin failed");
    return;
  }
  http.addHeader("Content-Type", "application/octet-stream");
  Serial.println("Sending audio via POST...");
  int httpCode = http.POST(audioBuffer, bytesRead);
  Serial.printf("HTTP code: %d\n", httpCode);
  if (httpCode > 0) {
    Serial.println(http.getString());
  } else {
    Serial.println(http.errorToString(httpCode));
  }

  http.end();
  free(audioBuffer);
  i2s_driver_uninstall(I2S_NUM_0);
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
void initializeDeviceStatuses() {
  // This will be filled by Nix injection
  deviceStatuses = {
    {"box", "192.168.1.13", "dope dev toolboxin'z crazy", false, 0},
    {"watch", "192.168.1.101", "yo cool watch - cat!", false, 0}
  };
}

bool checkDeviceOnline(const String& ip) {
  WiFiClient client;
  const int port = 80;
  const int timeout = 500; // ms
  
  if (client.connect(ip.c_str(), port)) {
    client.stop();
    return true;
  }
  return false;
}

void updateDeviceStatuses() {
  for (auto& device : deviceStatuses) {
    if (millis() - device.lastChecked > 10000) { // Check every 10s
      device.online = checkDeviceOnline(device.ip);
      device.lastChecked = millis();
    }
  }
}

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
// 🦆 says ⮞ MIC
void recordPOST() {
  Serial.println("Recording...");
  size_t bytesRead = 0;
  i2s_read(I2S_NUM_0, audioBuffer, bufferSize, &bytesRead, portMAX_DELAY);
  Serial.printf("Recording done. Bytes read: %d\n", bytesRead);

  WiFiClient client;
  HTTPClient http;

  if (!http.begin(client, serverURL)) {
    Serial.println("HTTP begin failed");
    return;
  }
  http.addHeader("Content-Type", "application/octet-stream");
  Serial.println("Sending audio via POST...");
  int httpCode = http.POST(audioBuffer, bytesRead);
  Serial.printf("HTTP code: %d\n", httpCode);
  if (httpCode > 0) {
    Serial.println(http.getString());
  } else {
    Serial.println(http.errorToString(httpCode));
  }

  http.end();
  free(audioBuffer);
  i2s_driver_uninstall(I2S_NUM_0);
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

String generateDeviceHeaderHTML() {
  String html = R"(
  <div class="device-header">
    <h2 style="margin-bottom: 15px;">ESP Devices</h2>
    <div class="device-grid">
  )";
  
  for (const auto& device : deviceStatuses) {
    html += R"(
      <div class="device-card" onclick="window.location.href='http://)" + device.ip + R"(';">
        <div class="device-status">)";
    html += device.online ? "🟢" : "⚠️";
    html += R"(</div>
        <div class="device-info">
          <div class="device-name">)" + device.name + R"(</div>
          <div class="device-desc">)" + device.description + R"(</div>
          <div class="device-ip">)" + device.ip + R"(</div>
        </div>
      </div>
    )";
  }
  
  html += R"(
    </div>
  </div>
  )";
  
  return html;
}

// 🦆 says ⮞ JAVASCRIPT
static const char* jsCode PROGMEM = R"=====(
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
  <link rel="stylesheet" href="https://qwackify.duckdns.org/duckdash.css">
  /* 🦆CSSANDJSINJECTFEST🦆 */
  
  <script>
)rawliteral";

  // 🦆 says ⮞ add da cool JS functions
  html += jsCode;

  html += R"=====(
    function toggleRoom(roomId) {
      const roomContent = document.getElementById('room-content-' + roomId);
      const roomToggle = document.querySelector('#room-content-' + roomId)
        .previousElementSibling.querySelector('.room-toggle');
    
      if (roomContent.style.maxHeight) {
        // 🦆 says ⮞ collapse
        roomContent.style.maxHeight = null;
        roomToggle.textContent = '▼';
        localStorage.setItem('room-' + roomId + '-collapsed', 'true');
      } else {
        // 🦆 says ⮞ expand
        roomContent.style.maxHeight = roomContent.scrollHeight + 'px';
        roomToggle.textContent = '▲';
        localStorage.removeItem('room-' + roomId + '-collapsed');
      }
    }

    // 🦆 says ⮞ init room states from localStorage
    document.addEventListener('DOMContentLoaded', function() {
      document.querySelectorAll('.room-content').forEach(roomContent => {
        const roomId = roomContent.id.split('room-content-')[1];
        const roomToggle = roomContent.previousElementSibling.querySelector('.room-toggle');
      
        if (localStorage.getItem('room-' + roomId + '-collapsed') === 'true') {
          roomContent.style.maxHeight = null;
          roomToggle.textContent = '▼';
        } else {
          roomContent.style.maxHeight = roomContent.scrollHeight + 'px';
          roomToggle.textContent = '▲';
        }
      
        // 🦆 says ⮞ smooth transition criminal moonwalk yo
        roomContent.style.transition = 'max-height 0.3s ease-in-out';
        roomContent.style.overflow = 'hidden';
      });
    });
  )=====";
  
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
      <div class="header-container">
        <div class="logo-container">
          <div class="logo">🦆'Dash</div>
          <div class="subtitle">ESP32S3BOX v1.2</div>
        </div>
    
        <div class="status-badges">
          <div class="badge wifi">
            <span class="icon">📶</span>
            <span class="text">${WiFi.status() == WL_CONNECTED ? WiFi.localIP().toString() : "OFFLINE"}</span>
          </div>
      
          <div class="badge battery">
            <span class="icon">🔋</span>
            <span class="text">${batteryPercent}%</span>
            <div class="battery-level" style="width:${batteryPercent}%"></div>
          </div>
      
          <div class="badge recording">
            <span class="icon">${isRecording ? '⏺️' : '⏹️'}</span>
            <span class="text">${isRecording ? 'REC' : 'READY'}</span>
          </div>
        </div>
      </div>
  
      <div class="header-wave">
        <svg viewBox="0 0 1200 120" preserveAspectRatio="none">
          <path d="M0,0 Q150,80 300,20 T600,70 T900,30 T1200,70 L1200,120 L0,120 Z" fill="#f0f9ff"></path>
        </svg>
      </div>
    </header>

  
    <!-- 🦆 says ⮞ BATTERY STATUS -->
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


// ===========================================
// 🦆 says ⮞ 

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
  
  setupOTA(); 
  i2s_config_t i2s_config = {
    .mode = (i2s_mode_t)(I2S_MODE_MASTER | I2S_MODE_RX),
    .sample_rate = sampleRate,
    .bits_per_sample = I2S_BITS_PER_SAMPLE_16BIT,
    .channel_format = I2S_CHANNEL_FMT_ONLY_LEFT,
    .communication_format = I2S_COMM_FORMAT_STAND_I2S,
    .intr_alloc_flags = ESP_INTR_FLAG_LEVEL1,
    .dma_buf_count = 8,
    .dma_buf_len = 1024,
    .use_apll = false,
    .tx_desc_auto_clear = false,
    .fixed_mclk = 0
  };

  i2s_pin_config_t pin_config = {
    .bck_io_num = I2S_SCK,
    .ws_io_num = I2S_WS,
    .data_out_num = I2S_PIN_NO_CHANGE,
    .data_in_num = I2S_SD
  };

  i2s_driver_install(I2S_NUM_0, &i2s_config, 0, NULL);
  i2s_set_pin(I2S_NUM_0, &pin_config);
  i2s_zero_dma_buffer(I2S_NUM_0);

  audioBuffer = (uint8_t*)malloc(bufferSize);
  if (!audioBuffer) {
    Serial.println("Failed to allocate audio buffer.");
    return;
  }

 
  server.on("/", handleRoot);
  server.on("/record", handleRecord);
  server.on("/zigbee/control", handleZigbeeControl);
  server.on("/zigbee/color", handleZigbeeColor);
  server.on("/zigbee/brightness", handleZigbeeBrightness);
  server.begin();

  initializeDeviceStatuses();
  updateDeviceStatuses();
  
  pinMode(TOUCH_INT_PIN, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(TOUCH_INT_PIN), touchISR, FALLING);  
  fetchZigbeeDevices();
  digitalWrite(PA_PIN, HIGH);    
}


// ===========================================
// 🦆 says ⮞ DA LOOP YO
void loop() {
  handleOTA();
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

  updateDeviceStatuses();
  
  if (isRecording) {
    streamAudio();
  }
  delay(10);
} // 🦆 says ⮞ bye bye!
