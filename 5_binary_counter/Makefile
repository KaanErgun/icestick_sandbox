PROJ = binary_counter

PIN_DEF = src/const/icestick.pcf  # Fixed PCF file name
DEVICE = hx1k

TOP_LEVEL = $(PROJ)
VHDL_FILES = $(shell find src/vhdl/ -name '*.vhdl')
VERILOG_FILES = $(shell find src/verilog/ -name '*.v')
PCF_FILES = $(PIN_DEF)

DOCKER_CMD = docker run --rm -it -v $(shell pwd):/wrk -w /wrk alpha-nerds-icestick-env
ICEPACK = $(DOCKER_CMD) icepack
NEXTPNR = $(DOCKER_CMD) nextpnr-ice40
YOSYS = $(DOCKER_CMD) yosys -m /ghdl-yosys-plugin/ghdl.so

# Output directory
OUTPUT_DIR = bin

all: $(OUTPUT_DIR)/$(PROJ).bin

$(OUTPUT_DIR)/%.json: $(VHDL_FILES) $(VERILOG_FILES) $(PCF_FILES)
	$(YOSYS) -p \
		"ghdl $(VHDL_FILES) -e $(TOP_LEVEL); \
		read_verilog $(VERILOG_FILES); \
		synth_ice40 -json $@"

$(OUTPUT_DIR)/%.asc: $(OUTPUT_DIR)/%.json $(PCF_FILES)
	$(NEXTPNR) --package $(DEVICE) --pcf $(PIN_DEF) --pcf-allow-unconstrained --json $< --asc $@

$(OUTPUT_DIR)/%.bin: $(OUTPUT_DIR)/%.asc
	$(ICEPACK) $< $@

burn: $(OUTPUT_DIR)/$(PROJ).bin
	iceprog $<

clean:
	rm -f $(OUTPUT_DIR)/$(PROJ).json $(OUTPUT_DIR)/$(PROJ).asc $(OUTPUT_DIR)/$(PROJ).bin

.SECONDARY:

.PHONY: all burn clean
