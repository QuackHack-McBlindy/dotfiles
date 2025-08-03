#include <WiFi.h>
#include <HTTPClient.h>

const char* ssid = "pungkula2";
const char* password = "XX";
const char* serverURL = "http://192.168.1.111:8111/upload_audio";

void setup() {
  Serial.begin(115200);
  delay(1000);

  Serial.printf("Free heap at boot: %d bytes\n", ESP.getFreeHeap());

  WiFi.begin(ssid, password);
  unsigned long start = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - start < 10000) {
    Serial.print(".");
    delay(500);
  }
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi connect fail. Rebooting...");
    ESP.restart();
  }
  Serial.println("\nWiFi connected.");

  uint8_t dummyData[100];
  memset(dummyData, 0xAB, sizeof(dummyData));

  HTTPClient http;
  WiFiClient client;

  if (!http.begin(client, serverURL)) {
    Serial.println("http.begin failed");
    return;
  }

  http.addHeader("Content-Type", "application/octet-stream");
  Serial.println("Sending dummy POST...");
  int httpCode = http.POST(dummyData, sizeof(dummyData));
  Serial.printf("HTTP POST code: %d\n", httpCode);
  if (httpCode > 0) {
    Serial.println(http.getString());
  } else {
    Serial.println(http.errorToString(httpCode));
  }
  http.end();
}

void loop() {}

