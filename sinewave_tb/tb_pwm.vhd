
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_pwm is
end tb_pwm;

architecture testbench of tb_pwm is
 signal tb_clk : std_logic :='1';
 signal tb_pwm : std_logic;
 
 
	component pwm is
    port (
        clk  : in std_logic;
        pwm  : out std_logic
    );
	end component;
	
	begin 
	
	DUT: pwm
	port map(
			clk => tb_clk,
			pwm => tb_pwm
			);
	
process			
begin

	tb_clk <= '0';
	wait for 10 ns;
	tb_clk <= '1';
	wait for 10 ns;

end process;

 
 
end ;
   