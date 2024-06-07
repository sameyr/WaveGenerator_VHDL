## PWM & Sine Wave Generator Using VHDL

This project details the design and implementation of a function generator using VHDL to produce a sine wave and Pulse Width Modulation (PWM). The design utilizes a state machine and was tested on the DE1-SoC development board using ModelSim for simulation and an oscilloscope for output verification. The MCP4921 DAC was used to convert digital signals to analog for testing.

### Introduction
The function generator project aims to create a system on the DE1-SoC board capable of generating PWM signals with user-adjustable frequency (1Hz to 1kHz) and duty cycle (0% to 100%). Additionally, it generates sine waves using a Lookup Table (LUT) method. The outputs are displayed using the LEDs on the FPGA board and verified through simulation and physical testing.

### Features
- **PWM Generation**: Allows setting of frequency and duty cycle through board buttons and switches. Displayed on LEDs.
- **Sine Wave Generation**: Utilizes a LUT to generate sine waves at user-defined frequencies. Displayed on LEDs.
- **User Input**: Frequency and duty cycle settings are adjusted via buttons and switches on the DE1-SoC board.
- **Output Testing**: Results are visualized using an oscilloscope connected through the MCP4921 DAC.

### Components Used
- DE1-SoC Development Board
- MCP4921 DAC (12-bit Digital-to-Analog Converter)
- ModelSim (for simulation)
- MATLAB (for LUT generation)

### Implementation
- **PWM**: VHDL code structured using a state machine for user input, calculation, and signal generation.
- **Sine Wave**: Generated using a precomputed LUT in VHDL, transitioning through states to produce the desired output.

### Testing & Results
- **PWM**: Successfully generated PWM signals were tested in ModelSim and verified with an oscilloscope.
- **Sine Wave**: Generated sine waves were tested, but encountered noise issues likely due to wiring or code bugs. The DAC chip burned out during testing.

### Evaluation
The project met most technical requirements, but improvements could be made in efficiency by separating the state transition and functionality processes. 

### Contributor
1. Samir Shrestha

    LinkedIn Profile: [Samir Shrestha](https://www.linkedin.com/in/sameyr/)