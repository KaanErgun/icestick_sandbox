# UART Communication Project (VHDL)

This project implements a complete UART communication system on the IceStick FPGA board using VHDL, with only the PLL module remaining in Verilog as required.

## Project Overview

The project creates a UART echo system that receives data via UART RX and immediately transmits it back via UART TX. LED indicators provide visual feedback for system status and communication activity.

## Features

- **UART Communication**: 9600 baud, 8 data bits, 1 start bit, 1 stop bit
- **Echo Functionality**: Received data is automatically transmitted back
- **LED Status Indicators**:
  - LED1: RX activity (lights up for 100ms when data is received)
  - LED2: TX activity (lights up for 100ms when data is transmitted)
  - LED3: Error indicator (lights up for 500ms on frame errors)
  - LED4: Heartbeat (toggles every 500ms to show system is alive)
- **Clock Management**: 12MHz input clock converted to 60MHz via PLL
- **Reset Synchronization**: Proper reset handling with PLL lock detection

## File Structure

```
int_1_uart_communication/
├── src/
│   ├── vhdl/
│   │   ├── int_1_uart_communication.vhdl  # Top-level module
│   │   ├── uart_controller.vhdl           # UART controller with echo
│   │   ├── uart_tx.vhdl                   # UART transmitter
│   │   └── uart_rx.vhdl                   # UART receiver
│   ├── verilog/
│   │   └── pll.v                          # PLL module (Verilog)
│   └── const/
│       └── icestick.pcf                   # Pin constraints
├── sim/
│   └── uart_controller_tb.vhdl            # Testbench
├── bin/                                   # Build outputs
└── Makefile                               # Build configuration
```

## Pin Assignments (IceStick Board)

| Signal   | Pin | Description                    |
|----------|-----|--------------------------------|
| clk_raw  | 21  | 12 MHz input clock            |
| rst      | 64  | Reset button (active high)    |
| uart_rx  | 9   | UART receive pin              |
| uart_tx  | 8   | UART transmit pin             |
| led1     | 99  | RX activity indicator         |
| led2     | 98  | TX activity indicator         |
| led3     | 97  | Error indicator               |
| led4     | 96  | Heartbeat indicator           |

## Building the Project

1. **Prerequisites**: Docker environment with IceStorm toolchain
2. **Build**: Run `make` to synthesize and generate bitstream
3. **Program**: Run `make burn` to program the FPGA

```bash
# Build the project
make

# Program the FPGA
make burn

# Clean build files
make clean
```

## Testing

### Hardware Testing

1. Connect a USB-to-UART adapter to pins 8 (TX) and 9 (RX)
2. Program the FPGA with `make burn`
3. Open a serial terminal (9600 baud, 8N1)
4. Type characters - they should be echoed back
5. Observe LED behavior:
   - LED4 should blink continuously (heartbeat)
   - LED1 flashes briefly when receiving data
   - LED2 flashes briefly when transmitting data
   - LED3 indicates communication errors

### Simulation Testing

Run the testbench to verify UART functionality:

```bash
# The testbench is located in sim/uart_controller_tb.vhdl
# Use GHDL or ModelSim to run the simulation
```

## Module Descriptions

### uart_tx.vhdl
- Implements UART transmitter with configurable baud rate
- State machine: IDLE → START_BIT → DATA_BITS → STOP_BIT
- Provides busy and done status signals

### uart_rx.vhdl
- Implements UART receiver with input synchronization
- Detects start bits and samples data at bit centers
- Provides data valid and error flags

### uart_controller.vhdl
- Manages TX and RX operations
- Implements echo functionality
- Controls LED indicators with timing

### int_1_uart_communication.vhdl
- Top-level module integrating all components
- Instantiates PLL for clock generation
- Provides reset synchronization

## Configuration

The UART parameters can be modified in the generic declarations:

```vhdl
generic (
    CLK_FREQ : integer := 60_000_000;  -- 60 MHz clock
    BAUD_RATE : integer := 9600        -- 9600 baud
);
```

## Troubleshooting

- **No echo response**: Check UART connections and baud rate settings
- **LED3 (error) active**: Check for proper UART framing and baud rate
- **No LED4 heartbeat**: Check clock and reset connections
- **Build errors**: Ensure all VHDL files are in the correct directories

## Technical Notes

- The project uses mixed VHDL/Verilog synthesis with GHDL plugin
- Input synchronization prevents metastability issues
- LED timing counters provide visual feedback duration
- Reset is synchronized with PLL lock status
