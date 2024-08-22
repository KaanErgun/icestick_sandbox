import os
import re

def sanitize_project_name(project_name):
    # Proje ismindeki sayı ve ilk alt çizgiye kadar olan kısmı kaldırıyoruz.
    sanitized_name = re.sub(r'^\d+_', '', project_name)
    return sanitized_name

def create_directory_structure(project_name):
    base_dir = f"./{project_name}"
    folders = [
        f"{base_dir}/bin",
        f"{base_dir}/docs",
        f"{base_dir}/sim/testbenches",
        f"{base_dir}/sim/waveforms",
        f"{base_dir}/src/const",
        f"{base_dir}/src/verilog",
        f"{base_dir}/src/vhdl",
    ]

    # Create folders
    for folder in folders:
        os.makedirs(folder, exist_ok=True)
    
    print(f"Directory structure for project '{project_name}' created successfully.")

def create_pcf_file(project_name):
    pcf_content = """# Pin configuration for IceStick
# This file defines the pin mappings for the FPGA

# Example:
# set_io led A2
"""
    file_path = f"./{project_name}/src/const/icestick.pcf"  # PCF dosyası adı sabit kaldı
    with open(file_path, "w") as file:
        file.write(pcf_content)
    print(f"PCF file created at: {file_path}")

def create_vhdl_top_file(project_name, sanitized_name):
    vhdl_content = f"""-- {sanitized_name}.vhdl
-- This is the top-level VHDL file for the {sanitized_name} project.
-- All LEDs are initialized to HIGH, with a PLL for clock stabilization.

library ieee;
use ieee.std_logic_1164.all;

entity {sanitized_name} is
    port (
        clk_raw : in std_logic;
        rst : in std_logic;
        led : out std_logic
    );
end entity {sanitized_name};

architecture Behavioral of {sanitized_name} is
    signal clk : std_logic;
    signal led_signal : std_logic := '1'; -- Initialize the LED signal to HIGH

    -- PLL component declaration
    component pll is
        port (
            clk_in  : in std_logic;
            clk_out : out std_logic;
            locked  : out std_logic
        );
    end component pll;

begin

    -- PLL instantiation
    pll_inst : pll
        port map(
            clk_in  => clk_raw,
            clk_out => clk,
            locked  => open
        );

    -- Assign the signal to the output port
    led <= led_signal;

    led_process: process(clk, rst)
    begin
        if rst = '1' then
            led_signal <= '1'; -- Set LED to HIGH on reset
        elsif rising_edge(clk) then
            -- Logic for LED control (can be customized here)
            led_signal <= not led_signal;
        end if;
    end process;
end architecture Behavioral;
"""
    file_path = f"./{project_name}/src/vhdl/{sanitized_name}.vhdl"
    with open(file_path, "w") as file:
        file.write(vhdl_content)
    print(f"VHDL top file created at: {file_path}")

def create_verilog_pll_file(project_name, sanitized_name):
    verilog_content = """/**
 * PLL configuration
 *
 * This Verilog module was generated automatically
 * using the icepll tool from the IceStorm project.
 * Use at your own risk.
 *
 * Given input frequency:        12.000 MHz
 * Requested output frequency:   60.000 MHz
 * Achieved output frequency:    60.000 MHz
 */

module pll(
    input  clk_in,
    output clk_out,
    output locked
    );

SB_PLL40_CORE #(
        .FEEDBACK_PATH("SIMPLE"),
        .DIVR(4'b0000),        // DIVR =  0
        .DIVF(7'b1001111),    // DIVF = 79
        .DIVQ(3'b100),        // DIVQ =  4
        .FILTER_RANGE(3'b001)    // FILTER_RANGE = 1
    ) uut (
        .LOCK(locked),
        .RESETB(1'b1),
        .BYPASS(1'b0),
        .REFERENCECLK(clk_in),
        .PLLOUTCORE(clk_out)
        );

endmodule
"""
    file_path = f"./{project_name}/src/verilog/pll.v"
    with open(file_path, "w") as file:
        file.write(verilog_content)
    print(f"Verilog PLL file created at: {file_path}")

def create_makefile(project_name, sanitized_name):
    makefile_content = f"""PROJ = {sanitized_name}

PIN_DEF = src/const/icestick.pcf  # Sabit PCF dosyası adı
DEVICE = hx1k

TOP_LEVEL = $(PROJ)
VHDL_FILES = $(shell find src/vhdl/ -name '*.vhdl')
VERILOG_FILES = $(shell find src/verilog/ -name '*.v')

DOCKER_CMD = docker run --rm -it -v $(shell pwd):/wrk -w /wrk alpha-nerds-icestick-env
ICEPACK = $(DOCKER_CMD) icepack
NEXTPNR = $(DOCKER_CMD) nextpnr-ice40
YOSYS = $(DOCKER_CMD) yosys

# Output directory
OUTPUT_DIR = bin

all: $(OUTPUT_DIR)/$(PROJ).bin

$(OUTPUT_DIR)/%.json: $(VHDL_FILES) $(VERILOG_FILES) $(PIN_DEF)
	$(YOSYS) -m /ghdl-yosys-plugin/ghdl.so -p \\
		"ghdl $(VHDL_FILES) -e $(TOP_LEVEL); \\
		read_verilog $(VERILOG_FILES); \\
		synth_ice40 -json $@"

$(OUTPUT_DIR)/%.asc: $(OUTPUT_DIR)/%.json $(PIN_DEF)
	$(NEXTPNR) --package $(DEVICE) --pcf $(PIN_DEF) --pcf-allow-unconstrained --json $< --asc $@

$(OUTPUT_DIR)/%.bin: $(OUTPUT_DIR)/%.asc
	$(ICEPACK) $< $@

burn: $(OUTPUT_DIR)/$(PROJ).bin
	iceprog $<

clean:
	rm -f $(OUTPUT_DIR)/$(PROJ).json $(OUTPUT_DIR)/$(PROJ).asc $(OUTPUT_DIR)/$(PROJ).bin

.SECONDARY:

.PHONY: all burn clean
"""
    file_path = f"./{project_name}/Makefile"
    with open(file_path, "w") as file:
        file.write(makefile_content)
    print(f"Makefile created at: {file_path}")


def main():
    project_name = input("Enter the project name: ")
    sanitized_name = sanitize_project_name(project_name)
    
    create_directory_structure(project_name)
    create_pcf_file(project_name)
    create_vhdl_top_file(project_name, sanitized_name)
    create_verilog_pll_file(project_name, sanitized_name)
    create_makefile(project_name, sanitized_name)
    
    print(f"Project '{project_name}' setup completed. Internal names sanitized to '{sanitized_name}'.")

if __name__ == "__main__":
    main()
