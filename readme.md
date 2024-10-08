# Icestick Development Board Projects

This repository contains a series of projects designed for the Icestick FPGA development board. The projects start from basic concepts like logic gates and move towards intermediate-level designs involving communication protocols like UART.

## Project Structure

### Beginner Level Projects

1. **LED Blink**: A simple LED blinking project.
2. **LED Pattern (AND Gate)**: Controlling an LED using two buttons with an AND gate.
3. **LED Pattern (OR Gate)**: Controlling an LED using an OR gate.
4. **LED Pattern (XOR Gate)**: Controlling an LED using an XOR gate.
5. **Binary Counter**: A 4-bit binary counter displayed with LEDs.
6. **Shift Register LED Pattern**: Sequentially lighting up LEDs using a shift register.
7. **LED Brightness Control with PWM**: Adjusting LED brightness using PWM.
8. **Button Debounce**: Stabilizing input signals by debouncing noisy button inputs.
9. **4x4 Keypad with LED Control**: Controlling LEDs based on input from a matrix keypad.
10. **Binary to 7-Segment Display Decoder**: Displaying a 4-bit binary number on a 7-segment display.

### Intermediate Level Projects

1. **UART Communication**: Sending and receiving data between the FPGA and a PC via UART.
2. **I2C Sensor Reading**: Reading data from a sensor using the I2C protocol.
3. **SPI EEPROM Read/Write**: Communicating with an EEPROM via SPI.
4. **PWM Servo Motor Control**: Controlling the position of a servo motor using PWM.
5. **Frequency Counter**: Measuring the frequency of an input signal.
6. **VGA Signal Generation**: Generating a VGA signal to draw simple shapes on a screen.
7. **Simple Game (Pong)**: Implementing a basic Pong game using VGA output and buttons.
8. **ADC (Analog to Digital Converter) Usage**: Converting analog signals to digital using an external ADC module.
9. **FIFO Buffer Design**: Designing a FIFO buffer for data transfer.
10. **PWM Controlled DC Motor**: Controlling the speed of a DC motor using PWM.

## Getting Started

Each project is organized in its own directory with all the necessary Verilog/VHDL files, simulation files, and testbenches. Follow the instructions in each project's folder to build and run it on your Icestick development board.

## Icestick Pinout and Datasheet

Here is the pinout diagram for the Icestick development board:

![Icestick Pinout](icestick_pinout.png)

For more detailed information, you can refer to the [Icestick Datasheet (PDF)](icestick.pdf).

## Automating Project Setup with `create_project.py`

To simplify the creation of new projects, use the `create_project.py` script. This script automates the setup of the project structure, generates necessary files (like VHDL, Verilog, and PCF files), and configures the Makefile according to your project name.

### Usage

1. Run the script:

    ```bash
    python create_project.py
    ```

2. When prompted, enter your desired project name. If the name contains a number followed by an underscore (e.g., `2_led_pattern`), the script will sanitize the internal names, removing the number and underscore.

3. The script will generate:
    - Project folder structure
    - VHDL and Verilog files, including a PLL module
    - A `Makefile` configured for your project
    - A PCF file named `icestick.pcf` (specific to the Icestick development board)

The generated project is ready to be built using the `make all` command.

## Docker Setup and Usage

This project uses Docker containers to simplify the build process. The following Docker images are used:

- `alpha-nerds-icestick-env`: A custom Docker image that includes all necessary tools (Yosys, nextpnr, icestorm, and GHDL) for building Icestick projects.

### Docker Installation

If you don't have Docker installed, you can install it by following the instructions [here](https://docs.docker.com/get-docker/).

### Building the Project

To build the project, run:

```bash
make all
```
