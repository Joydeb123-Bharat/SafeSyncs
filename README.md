# 🔥 SafeSyncs: Edge-AI Industrial Hazard Detection

**An FPGA-Accelerated Heterogeneous System for Real-Time Safety & Telemetry**

SafeSyncs is a router-less, cloud-less, ultra-low latency industrial safety pipeline. It utilizes ESP32 microcontrollers communicating via the peer-to-peer ESP-NOW protocol to aggregate environmental data (Temperature, Humidity, Toxic Gas, Combustible Smoke, and Physical Flame). This data is streamed via UART to a Xilinx Nexys 4 DDR FPGA, which runs a custom, hardware-accelerated Q7.7 quantized Neural Network to deterministically infer room safety in real-time.

**Team:** Tanishk Raj, Joydeb Sarkar, Yash Raj Awashti

---

## 🏗️ System Architecture
1. **The Sensory Edge (Zone Node):** An ESP32 samples analog/digital sensors and compresses the payload into an 8-bit struct.
2. **The Wireless Bridge:** Router-less transmission using ESP-NOW for millisecond latency.
3. **The Brain (FPGA):** A Xilinx Artix-7 FPGA acts as a Centralized Data Fusion engine, passing the telemetry through a Multilayer Perceptron (MLP) neural network.
4. **The SCADA Dashboard:** A Python Streamlit interface providing live telemetry, gauge tracking, and a hardware-driven Emergency Override.

---

## 🧰 Hardware Used
* **Compute:** Xilinx Nexys 4 DDR (Artix-7 FPGA), 2x ESP32 Development Boards
* **Sensors:** DHT22 (Temp/Hum), MQ-2 (Smoke), MQ-135 (Air Toxins), IR Flame Sensor
* **Power:** Split-rail 20,000mAh independent power delivery for high-draw heater coils.

---

## 📂 Repository Structure
* `/Zone_ESP32` - Edge node data aggregation and ESP-NOW transmitter (C++).
* `/Master_ESP32` - ESP-NOW receiver and UART bridge (C++).
* `/FPGA_Nexys4` - RTL Verilog code and quantized `.mem` weights for the neural network.
* `/Dashboard` - Python logger and Streamlit frontend application.

---

## 🚀 How to Run the Dashboard
1. Flash the FPGA and connect the Master ESP32 via USB.
2. Navigate to the `/Dashboard` folder.
3. Install dependencies: `pip install -r requirements.txt`
4. Start the serial logger: `python logger.py` (Ensure you update the COM port).
5. In a new terminal, launch the UI: `streamlit run app.py`
