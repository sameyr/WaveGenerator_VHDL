library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm is
    port (
        clk  : in std_logic;
        pwm  : out std_logic
    );
end pwm;

architecture behavioural of pwm is
	 signal clk_freq : integer := 5000; 
    constant frequency : integer := 10;
    constant dutyCycle : integer := 50; -- Duty cycle as a percentage
	 signal period, dutyCyclePeriod, counter : integer :=0; -- Using integer for calculations
    begin
        process(clk)
            
        begin
            if rising_edge(clk) then
                period <= clk_freq / frequency;
                dutyCyclePeriod <= (dutyCycle * period)/100 ;

					if counter < dutyCyclePeriod  then 
						pwm <='0';
					end if;
				
					if counter >dutyCyclePeriod and counter < period  then
						pwm <='1';
					end if;
					
					if counter  > period then
						counter<=0;
					else
						counter <= counter + 1;
					end if;
                
            end if;
        end process;
end behavioural;
