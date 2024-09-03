library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- VUnit kütüphanesi
library vunit_lib;
context vunit_lib.vunit_context;

entity tb_led_blink is
  generic (
    runner_cfg : string := ""
  );
end tb_led_blink;

architecture test of tb_led_blink is
  -- DUT (Device Under Test) bileşenini tanımlayın
  component led_blink is
    port (
      clk_raw : in std_logic;
      led1, led2, led3, led4, led5 : out std_logic
    );
  end component;

  -- Test sinyalleri
  signal clk_raw : std_logic := '0';
  signal led1, led2, led3, led4, led5 : std_logic;

  -- Clock Periyodu
  constant clk_period : time := 20 ns;

begin
  -- DUT instantiate
  dut: led_blink
    port map (
      clk_raw => clk_raw,
      led1    => led1,
      led2    => led2,
      led3    => led3,
      led4    => led4,
      led5    => led5
    );

  -- Clock üretimi
  clk_process: process
  begin
    while true loop
      clk_raw <= '0';
      wait for clk_period / 2;
      clk_raw <= '1';
      wait for clk_period / 2;
    end loop;
  end process;

  -- Test süreci
  test_proc: process
  begin
    -- VUnit ile test başlatma
    test_runner_setup(runner, runner_cfg);

    -- Log sinyalleri
    log("clk_raw, led1, led2, led3, led4, led5");

    -- Reset işlemi
    wait for 200 ns;

    -- LED sırasını kontrol et
    -- Her bir LED'in sırayla yanmasını bekliyoruz
    assert led1 = '1' and led2 = '0' and led3 = '0' and led4 = '0' and led5 = '0'
      report "LED1 did not light up as expected" severity error;

    wait for 5 ms; -- Yeterli süre geçişi için

    -- Diğer LED'leri kontrol et
    -- Ekstra testler ekleyin

    -- Simülasyonu bitir
    test_runner_cleanup(runner);
    wait;
  end process;
end test;
