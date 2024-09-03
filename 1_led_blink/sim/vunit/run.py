import os
import glob
from vunit import VUnit
from vunit.sim_if.ghdl import GHDLInterface

# Docker komutları
DOCKER_CMD = "docker run --rm -it -v {}:/wrk -w /wrk alpha-nerds-icestick-env".format(os.getcwd())
GHDL_CMD = "{} ghdl".format(DOCKER_CMD)

# VUnit'i başlat ve dahili bileşenlerin derlenmesini devre dışı bırak
vu = VUnit.from_argv(compile_builtins=False)

# GHDL simülatörünü Docker üzerinden kullanacak şekilde yapılandırın
vu.set_sim_option("ghdl.elab_e", GHDL_CMD)

# Dahili bileşenleri açıkça ekle
vu.add_vhdl_builtins()

# Kütüphane oluştur
lib = vu.add_library("lib")

# VHDL dosyalarının bulunduğu dizinler
vhdl_dir = os.path.join(os.path.dirname(__file__), "..", "..", "src", "vhdl")
testbench_dir = os.path.join(os.path.dirname(__file__), "..", "..", "sim", "testbenches")

# VHDL dosyalarını ekle
for vhdl_file in glob.glob(os.path.join(vhdl_dir, "*.vhdl")):
    lib.add_source_files(vhdl_file)

for tb_file in glob.glob(os.path.join(testbench_dir, "*.vhdl")):
    lib.add_source_files(tb_file)

# GHDL ile VCD dosyası oluşturma için simülasyon bayrağı ekleyin
vu.set_sim_option("ghdl.sim_flags", ["--vcd=waveform.vcd"])

# Simülasyonu başlat
vu.main()
