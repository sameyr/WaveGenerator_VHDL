library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 


entity sineWaveGenerator is
generic ( NUM_POINTS : integer := 200;
			 MAX_AMPLITUDE : integer := 255
			 );
			 
port (clk :in  std_logic;
		led_out: out integer 
);

end sineWaveGenerator;

architecture Behavioral of sineWaveGenerator is
	
	
	signal Tc, counter : integer := 0;
	signal i : integer range 0 to NUM_POINTS := 0;
	type memory_type is array (0 to NUM_POINTS-1) of integer range 0 to MAX_AMPLITUDE;
	signal frequency : integer := 500;
	signal sine : memory_type :=(128, 132, 136, 140, 144, 148, 152, 155, 159, 163, 167, 171,
											174, 178, 182, 185, 189, 192, 196, 199, 203, 206, 209, 212,
											215, 218, 220, 223, 226, 228, 231, 233, 235, 237, 239, 241,
											243, 245, 246, 247, 249, 250, 251, 252, 253, 253, 254, 254,
											255, 255, 255, 255, 255, 254, 254, 253, 253, 252, 251, 250,
											249, 247, 246, 245, 243, 241, 239, 237, 235, 233, 231, 228,
											226, 223, 220, 218, 215, 212, 209, 206, 202, 199, 196, 192,
											189, 185, 182, 178, 174, 171, 167, 163, 159, 155, 151, 147,
											143, 139, 136, 132, 128, 123, 119, 116, 112, 108, 104, 100,
											96, 92, 88, 84, 81, 77, 73, 70, 66, 63, 59, 56,
											53, 49, 46, 43, 40, 37, 35, 32, 29, 27, 24, 22,
											20, 18, 16, 14, 12, 10, 9, 8, 6, 5, 4, 3,
											2, 2, 1, 1, 0, 0, 0, 0, 0, 1, 1, 2,
											2, 3, 4, 5, 6, 8, 9, 10, 12, 14, 16, 18,
											20, 22, 24, 27, 29, 32, 35, 37, 40, 43, 46, 49,
											52, 56, 59, 62, 66, 70, 73, 77, 81, 84, 88, 92,
											96, 100, 104, 108, 112, 116, 119, 123);									
	begin
	
	process(clk)
	
		constant clock_freq : integer := 50000;
		variable timer : integer range 0 to 150000000 := 0;
	
		
		
		begin
		
		if (rising_edge(clk)) then
		
			Tc <= clock_freq/frequency;
		
			if counter < Tc then
							counter <= counter +1;
							if sine(i) < 127 then
								led_out <= sine(i);
							else
								led_out<= sine(i);
							end if;
					else 
							i <= i + 1;
							counter <= 0;
							if i = NUM_POINTS-1 then
								i <= 0;
							end if;
			end if;
	
		end if;
		
	end process;

end Behavioral;

		
		
		
		