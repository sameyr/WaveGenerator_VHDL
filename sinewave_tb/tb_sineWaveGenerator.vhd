library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_sineWaveGenerator is
end tb_sineWaveGenerator;

architecture testbench of tb_sineWaveGenerator is

signal tb_clk : std_logic := '0';
signal tb_out : integer:=128;  
  
component sineWaveGenerator is
			 
	port (clk :in  std_logic;
			led_out: out integer
	); 
end component;
begin

DUT:sineWaveGenerator
 generic map (
    NUM_POINTS    => 30,
    MAX_AMPLITUDE => 255
  )
  port map (
    clk      => tb_clk,
    led_out  => tb_out
  );
			
process 
  begin
		 tb_clk <= '0';
		wait for 10 ns;
		tb_clk <= '1';
		wait for 10 ns;
end process;
 
end testbench;
