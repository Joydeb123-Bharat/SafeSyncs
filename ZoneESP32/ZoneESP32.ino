#include <esp_now.h>
#include <WiFi.h>
#include <DHT.h>

// --- CONFIGURATION ---
const int ZONE_ID = 1; 
uint8_t masterAddress[] = {0x20, 0xE7, 0xC8, 0x67, 0x6C, 0xC0};

// --- SENSOR PINS ---
#define MQ2_PIN       35  
#define MQ135_PIN     34  
#define FLAME_PIN     32  
#define DHT_PIN       33  
#define DHT_TYPE      DHT22 

DHT dht(DHT_PIN, DHT_TYPE);

// ==========================================================
// 1. PACKET STRUCTURE (Matched exactly to Master)
// ==========================================================
typedef struct __attribute__((packed)) sensor_packet {
    uint8_t type;     // Will always be 0
    uint8_t temp;     
    uint8_t hum;      
    uint8_t mq2;      
    uint8_t mq135;    
    uint8_t flame;    
} sensor_packet;

esp_now_peer_info_t peerInfo;
unsigned long lastSensorReadTime = 0;
const long sensorInterval = 2000; 

// --- SEND CALLBACK ---
void OnDataSent(const uint8_t *mac_addr, esp_now_send_status_t status) {
  // Silent running - no need to spam the serial monitor
}

// ==========================================================
// 2. MAIN SETUP
// ==========================================================
void setup() {
  Serial.begin(115200);
  
  // 1. Initialize Sensors
  dht.begin();
  pinMode(FLAME_PIN, INPUT);
  
  // 2. Initialize Wireless Network
  WiFi.mode(WIFI_STA);
  if (esp_now_init() != ESP_OK) {
    Serial.println("ESP-NOW Init Failed!");
    return;
  }
  
  esp_now_register_send_cb((esp_now_send_cb_t)OnDataSent);
  
  // Register Master Node
  memcpy(peerInfo.peer_addr, masterAddress, 6);
  peerInfo.channel = 0;
  peerInfo.encrypt = false;
  if (esp_now_add_peer(&peerInfo) != ESP_OK) {
    Serial.println("Failed to add master peer!");
    return;
  }
  
  Serial.println("Zone ESP32 Online. Streaming Core Telemetry...");
}

// ==========================================================
// 3. MAIN LOOP
// ==========================================================
void loop() {
  unsigned long currentMillis = millis();
  
  // Read and send data every 2 seconds
  if (currentMillis - lastSensorReadTime >= sensorInterval) {
    lastSensorReadTime = currentMillis;

    sensor_packet sData;
    sData.type = 0; 
    
    // Read Temperature and Humidity
    float t = dht.readTemperature();
    float h = dht.readHumidity();
    
    // Safety fallback if DHT wire gets bumped
    if(isnan(t)) t = 0.0;
    if(isnan(h)) h = 0.0;

    // Load struct and map Gas/Smoke to 8-bit values for the FPGA
    sData.temp  = (uint8_t)t; 
    sData.hum   = (uint8_t)h; 
    sData.mq2   = map(analogRead(MQ2_PIN), 0, 4095, 0, 255);
    sData.mq135 = map(analogRead(MQ135_PIN), 0, 4095, 0, 255);
    sData.flame = digitalRead(FLAME_PIN); 
    
    // Blast it through the air!
    esp_now_send(masterAddress, (uint8_t *) &sData, sizeof(sData));
    
    // Print to local Serial for debugging
    Serial.printf("Sent -> Temp:%d Hum:%d MQ2:%d MQ135:%d Flame:%d\n", 
                  sData.temp, sData.hum, sData.mq2, sData.mq135, sData.flame);
  }
}