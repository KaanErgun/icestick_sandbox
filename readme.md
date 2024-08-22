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

Each project is organized in its own directory with all the necessary Verilog files, simulation files, and testbenches. Follow the instructions in each project's folder to build and run it on your Icestick development board.

## Contributing

Feel free to fork this repository and contribute your own projects or improvements.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
