library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 


entity sineWaveGenerator is
generic ( NUM_POINTS : integer := 30;
			 MAX_AMPLITUDE : integer := 255
			 );
			 
port (clk :in  std_logic;
		led_out: out std_logic_vector(2 downto 0) := "000"
);

end sineWaveGenerator;

architecture Behavioral of sineWaveGenerator is

	signal i : integer range 0 to NUM_POINTS := 0;
	type memory_type is array (0 to NUM_POINTS-1) of integer range 0 to MAX_AMPLITUDE;
	signal frequency : integer := 0;
	signal sine : memory_type :=(128, 154, 179, 202, 222, 238, 249, 254,
											254, 249, 238, 222, 202, 179, 154, 128,
											101, 76, 53, 33, 17, 6, 1, 1,
											6, 17, 33, 53, 76, 101);									
	begin
	
	process(clk)
	
		constant clock_freq : integer := 50_000_000;
		variable timer : integer range 0 to 150000000 := 0;
		variable Tc, counter : integer := 0;
		
		
		begin
		
		if (rising_edge(clk)) then
		
			Tc := clock_freq/frequency;
		
			if counter < Tc then
							counter := counter +1;
							if sine(i) < 127 then
								led_out <= "000";
							else
								led_out<= "111";
							end if;
					else 
							i <= i + 1;
							counter := 0;
							if i = NUM_POINTS-1 then
								i <= 0;
							end if;
			end if;
	
		end if;
		
	end process;

end Behavioral;

		
		
		
		