import serial
import time

# =====================================================
# CONFIGURATION
# =====================================================
# Change this to your FPGA's COM port (e.g., 'COM3' for Windows, '/dev/ttyUSB0' for Mac/Linux)
SERIAL_PORT = 'COM5'  
BAUD_RATE = 9600
# Perfectly synced with your Verilog code

def read_from_fpga():
    print(f"Connecting to FPGA on {SERIAL_PORT} at {BAUD_RATE} baud...")
    
    try:
        # Open the serial port connection
        fpga_serial = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1)
        time.sleep(2) # Brief pause to allow the hardware connection to settle
        print("Connected! Listening for Neural Network output...\n")
        print("-" * 50)

        while True:
            # Check if there is data waiting in the USB buffer
            if fpga_serial.in_waiting > 0:
                
                # Read the line, decode the ASCII bytes into text, and strip hidden newline characters
                raw_data = fpga_serial.readline().decode('utf-8', errors='ignore').strip()
                
                if raw_data:
                    # Print exactly what the FPGA says
                    print(f"FPGA -> {raw_data}")

    except serial.SerialException as e:
        print(f"\n[ERROR] Could not open {SERIAL_PORT}.")
        print(f"Details: {e}")
        print("\nCRITICAL CHECK: Make sure you have clicked 'Disconnect' in your Google Chrome Terminal or Arduino IDE!")
        print("A COM port can only be opened by one program at a time.")
        
    except KeyboardInterrupt:
        print("\n\nScript stopped by user.")
        
    finally:
        # Always safely close the port when the script stops or crashes
        if 'fpga_serial' in locals() and fpga_serial.is_open:
            fpga_serial.close()
            print("Serial port closed safely.")

if __name__ == '__main__':
    read_from_fpga()