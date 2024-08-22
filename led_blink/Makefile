PROJ = led_blink

PIN_DEF = icestick.pcf
DEVICE = hx1k

TOP_LEVEL = led_blink
VHDL_FILES = src/led_blink.vhdl
VERILOG_FILES = $(shell find src/ -name '*.v')

DOCKER_CMD = docker run --rm -it -v /$(shell pwd)://wrk -w //wrk
ICEPACK = $(DOCKER_CMD) ghdl/synth:icestorm icepack
NEXTPNR = $(DOCKER_CMD) ghdl/synth:nextpnr nextpnr-ice40
YOSYS = $(DOCKER_CMD) ghdl/synth:beta yosys

all: $(PROJ).bin

%.json: $(VHDL_FILES) $(VERILOG_FILES)
	$(YOSYS) -m ghdl -p \
		"ghdl $(VHDL_FILES) -e $(TOP_LEVEL); \
		read_verilog $(VERILOG_FILES); \
		synth_ice40 -json $@"

%.asc: %.json
	$(NEXTPNR) --package $(DEVICE) --pcf $(PIN_DEF) --pcf-allow-unconstrained --json $< --asc $@

%.bin: %.asc
	$(ICEPACK) $< $@

burn: $(PROJ).bin
	iceprog $<

clean:
	rm -f $(PROJ).json $(PROJ).asc $(PROJ).bin

.SECONDARY:

.PHONY: all burn clean
