#include <esp_now.h>
#include <WiFi.h>

// ==========================================================
// 1. DUAL-PACKET STRUCTURES (Packed to prevent memory bugs!)
// ==========================================================
typedef struct __attribute__((packed)) sensor_packet {
    uint8_t type;     // Will always be 0
    uint8_t temp;     
    uint8_t hum;      
    uint8_t mq2;      
    uint8_t mq135;    
    uint8_t flame;    
} sensor_packet;

typedef struct __attribute__((packed)) rfid_packet {
    uint8_t type;     // Will always be 1
    char uid[15];     // The RFID Tag string
} rfid_packet;

sensor_packet sData;
rfid_packet rData;

// ==========================================================
// 2. ESP-NOW RECEIVE CALLBACK & X-RAY DEBUGGING
// ==========================================================
void OnDataRecv(const esp_now_recv_info *info, const uint8_t *incomingData, int len) {
    if (len == 0) return;
    
    uint8_t packet_type = incomingData[0]; // Identify the packet type

    // --- HANDLE SENSOR PACKET ---
    if (packet_type == 0 && len == sizeof(sensor_packet)) {
        memcpy(&sData, incomingData, sizeof(sData));
        
        // 1. Laptop Debug: See what arrived via Wi-Fi
        Serial.printf("[WIFI IN]  Sensors -> Temp:%d, Hum:%d, MQ2:%d, MQ135:%d, Flame:%d\n", 
                      sData.temp, sData.hum, sData.mq2, sData.mq135, sData.flame);
        Serial.printf("[FPGA OUT] String  -> S,%d,%d,%d,%d,%d\n", 
                      sData.temp, sData.hum, sData.mq2, sData.mq135, sData.flame);
        Serial.println("--------------------------------------------------");

        // 2. Send down the wire to the FPGA
        Serial2.print("S,");
        Serial2.print(sData.temp);  Serial2.print(",");
        Serial2.print(sData.hum);   Serial2.print(",");
        Serial2.print(sData.mq2);   Serial2.print(",");
        Serial2.print(sData.mq135); Serial2.print(",");
        Serial2.print(sData.flame); Serial2.print("\n");
    } 
    // --- HANDLE RFID PACKET ---
    else if (packet_type == 1 && len == sizeof(rfid_packet)) {
        memcpy(&rData, incomingData, sizeof(rData));
        
        // 1. Laptop Debug: See what arrived via Wi-Fi
        Serial.printf("\n>>> [WIFI IN]  RFID TAG DETECTED: %s <<<\n", rData.uid);
        Serial.printf(">>> [FPGA OUT] String -> R,%s <<<\n", rData.uid);
        Serial.println("--------------------------------------------------");
        
        // 2. Send down the wire to the FPGA
        Serial2.print("R,");
        Serial2.print(rData.uid); 
        Serial2.print("\n");
    }
}

// ==========================================================
// 3. MAIN SETUP
// ==========================================================
void setup() {
    Serial.begin(115200); // For Laptop Debugging
    
    // Connect to FPGA using your Custom Pins!
    // RX = 25, TX = 26. Make sure the FPGA jumper wire is in Pin 26!
    Serial2.begin(9600, SERIAL_8N1, 25, 26); 

    WiFi.mode(WIFI_STA);
    if (esp_now_init() != ESP_OK) {
        Serial.println("Error initializing ESP-NOW");
        ESP.restart();
    }
    esp_now_register_recv_cb(OnDataRecv);
    
    Serial.println("Master ESP32 Online. Waiting for Zone Data...");
}

void loop() { 
    delay(1000); 
}