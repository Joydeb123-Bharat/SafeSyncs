import serial
import time
import csv
import os

SERIAL_PORT = 'COM5'  
BAUD_RATE = 9600      

# Create the CSV file with headers if it doesn't exist
csv_file = 'sensor_data.csv'
if not os.path.exists(csv_file):
    with open(csv_file, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["Timestamp", "Temp", "Humidity", "MQ2", "MQ135", "Flame", "AI_Status"])

def log_data():
    try:
        fpga_serial = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1)
        print("Logger running. Saving FPGA data to CSV...")
        
        while True:
            if fpga_serial.in_waiting > 0:
                raw_data = fpga_serial.readline().decode('utf-8', errors='ignore').strip()
                
                # Only log Sensor packets (ignore RFID for the charts)
                if raw_data.startswith("S,"):
                    parts = raw_data.split(',')
                    if len(parts) == 7:  # S, Temp, Hum, MQ2, MQ135, Flame, Status
                        timestamp = time.strftime('%H:%M:%S')
                        
                        # Save to CSV
                        with open(csv_file, mode='a', newline='') as file:
                            writer = csv.writer(file)
                            writer.writerow([timestamp, parts[1], parts[2], parts[3], parts[4], parts[5], parts[6]])
                        
                        print(f"Logged: {raw_data}")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == '__main__':
    log_data()