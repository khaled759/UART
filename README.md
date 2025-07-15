# UART
This repository contains a basic implementation of a UART (Universal Asynchronous Receiver/Transmitter) in VHDL. It includes the UART transmitter (UART_TX), UART receiver (UART_RX), and a top-level module (UART_TOP) that connects both, the design following the 1N(width) (1 start bit, no parity bit, width bits generic type)

# 🧩 Components
1. UART_TX.vhd
This module implements the UART Transmitter.
Features:
  - Configurable baud rate through a generic parameter
  - Serial transmission of width-bit data (generic type can be modified)
  - Idle-high line, start/stop bit handling

Output signals:
  - TX_OUT: Transmitted serial output
  - TX_BUSY: Indicates when transmission is ongoing

2. UART_RX.vhd
This module implements the UART Receiver.
Features:
  - Configurable baud rate
  - width-bit serial data reception
  - Synchronization and start-bit detection

Output signals:
  - RX_DATA_OUT: Received data byte
  - RX_VALID: High when new valid byte is available

3. UART_TOP.vhd
Top-level module that connects the UART transmitter and receiver.
Integrates UART_TX and UART_RX into a single design.
