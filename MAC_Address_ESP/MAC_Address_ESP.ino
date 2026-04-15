#include <esp_now.h>
#include <WiFi.h>

// 1. The Master's MAC Address
uint8_t masterAddress[] = {0x20, 0xE7, 0xC8, 0x67, 0x6C, 0xC0};

// 2. The Test Data Structure
typedef struct struct_message {
    int zone_id;
    int ping_count;
} struct_message;

struct_message testPacket;
esp_now_peer_info_t peerInfo;
int counter = 0;

// Callback
void OnDataSent(const uint8_t *mac_addr, esp_now_send_status_t status) {
  Serial.print("Sending Ping #");
  Serial.print(counter);
  Serial.print(" -> Delivery: ");
  Serial.println(status == ESP_NOW_SEND_SUCCESS ? "SUCCESS" : "FAIL");
}

void setup() {
  Serial.begin(115200);
  WiFi.mode(WIFI_STA);

  if (esp_now_init() != ESP_OK) {
    Serial.println("Error initializing ESP-NOW");
    return;
  }

  // THE FIX: Typecasting the callback function for ESP32 Core V3.x
  esp_now_register_send_cb((esp_now_send_cb_t)OnDataSent);

  memcpy(peerInfo.peer_addr, masterAddress, 6);
  peerInfo.channel = 0;  
  peerInfo.encrypt = false;
  
  if (esp_now_add_peer(&peerInfo) != ESP_OK){
    Serial.println("Failed to add peer");
    return;
  }
  Serial.println("Zone Router Ready. Starting Ping...");
}

void loop() {
  counter++;
  testPacket.zone_id = 1; // Change to 2 if testing the second router
  testPacket.ping_count = counter;

  esp_now_send(masterAddress, (uint8_t *) &testPacket, sizeof(testPacket));
  delay(2000); 
}