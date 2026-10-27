// Define the hardware UART2 pins for the ESP32
#define RXD2 16 
#define TXD2 17 // Not physically connected to the FPGA, but required by the UART hardware

void setup() {
  // Initialize the USB serial connection to your PC monitor
  Serial.begin(115200);
  
  // Initialize the hardware UART connection to the FPGA
  // Matches the FPGA: 9600 Baud, 8 Data Bits, No Parity, 1 Stop Bit
  Serial2.begin(9600, SERIAL_8N1, RXD2, TXD2); 
  
  Serial.println("ESP32 Receiver Initialized.");
  Serial.println("Listening for Artix-7 transmissions on GPIO16...");
}

void loop() {
  // Check if a complete 8-N-1 frame has arrived in the hardware buffer
  if (Serial2.available()) {
    
    // Read the 8-bit payload
    char incomingByte = Serial2.read();
    
    // Display the received character on the PC screen
    Serial.print("FPGA transmitted: ");
    Serial.println(incomingByte);
  }
}
