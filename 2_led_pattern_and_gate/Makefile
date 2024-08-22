PROJ = led_pattern_and_gate

PIN_DEF = src/const/icestick.pcf  # Sabit PCF dosyası adı
DEVICE = hx1k

TOP_LEVEL = $(PROJ)
VHDL_FILES = $(shell find src/vhdl/ -name '*.vhdl')
VERILOG_FILES = $(shell find src/verilog/ -name '*.v')
PCF_FILES = $(PIN_DEF)

DOCKER_CMD = docker run --rm -it -v $(shell pwd):/wrk -w /wrk
ICEPACK = $(DOCKER_CMD) ghdl/synth:icestorm icepack
NEXTPNR = $(DOCKER_CMD) ghdl/synth:nextpnr nextpnr-ice40
YOSYS = $(DOCKER_CMD) ghdl/synth:beta yosys

# Output directory
OUTPUT_DIR = bin

all: $(OUTPUT_DIR)/$(PROJ).bin

$(OUTPUT_DIR)/%.json: $(VHDL_FILES) $(VERILOG_FILES) $(PCF_FILES)
	$(YOSYS) -m ghdl -p \
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
