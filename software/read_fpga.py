import serial 
import sys
import time


PORT = 'COM5'         # Change to your actual COM port
BAUD_RATE = 9600      # Updated for stability (Requires 10417 divider in Verilog)
TIMEOUT = 1

def main():
    print(f"Connecting to {PORT} at {BAUD_RATE} baud...")

    try:
        ser = serial.Serial(PORT, BAUD_RATE, timeout=TIMEOUT)
        print("Connected. Waiting for data... (Press Ctrl+C to stop)\n" + "-"*40)
    except serial.SerialException as e:
        print(f"Error opening port {PORT}: {e}")
        sys.exit(1)

    try:
        while True:
            if ser.in_waiting > 0:
                raw_bytes = ser.readline()
                
                if not raw_bytes:
                    continue

                try:
                    # Tries to read it as a clean text string
                    decoded_text = raw_bytes.decode('utf-8').strip()
                    print(f"[TEXT]: {decoded_text}")
                    
                except UnicodeDecodeError:
                    # Catches raw binary/garbage data and prints the Hex
                    hex_output = raw_bytes.hex().upper()
                    formatted_hex = " ".join(hex_output[i:i+2] for i in range(0, len(hex_output), 2))
                    print(f"[HEX]:  {formatted_hex}")

            time.sleep(0.01)

    except KeyboardInterrupt:
        print("\nExiting.")
        ser.close()
        sys.exit(0)

if __name__ == "__main__":
    main()
