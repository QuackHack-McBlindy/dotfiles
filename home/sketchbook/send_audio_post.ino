#include <WiFi.h>
#include <HTTPClient.h>
#include <driver/i2s.h>

const char* ssid = "XX";
const char* password = "XX";
const char* serverURL = "http://192.168.1.111:8111/upload_audio";


const int sampleRate = 16000;
const int recordDuration = 3;
const int bufferSize = sampleRate * recordDuration * sizeof(int16_t);

uint8_t* audioBuffer = NULL;


#define I2S_WS   42 
#define I2S_SD   41
#define I2S_SCK  40

void setup() {
  Serial.begin(115200);
  delay(1000);

  Serial.println("Connecting to WiFi...");
  WiFi.begin(ssid, password);
  unsigned long start = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - start < 10000) {
    delay(500);
    Serial.print(".");
  }
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi connect failed.");
    ESP.restart();
  }
  Serial.println("\nWiFi connected!");


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

void loop() {}
