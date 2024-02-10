library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 
use work.ssegPackage.all;

entity sineWaveGenerator is
generic ( NUM_POINTS : integer := 200;
			 MAX_AMPLITUDE : integer := 255
			 );
			 
port (clk :in  std_logic;
		frequency_btn, set_btn, switch0 : in std_logic;
		cs_l,sck,sdi :out std_logic; --DAC input pins
		led_out: out std_logic_vector(4 downto 0) := "00000";
		led0,led1,led2,led3 : out std_logic;
		sseg0,sseg1,sseg2,sseg6 : out std_logic_vector(7 downto 0)
      );
		
end sineWaveGenerator;


architecture Behavioral of sineWaveGenerator is

	type state_type is (s0,s1,s2,s3);

	signal state : state_type := s0;
	signal d_op : std_logic_vector(11 downto 0) := "000000000000"; --DAC input
	signal count : unsigned(11 downto 0) := x"000";
	signal bcd : std_logic_vector (15 downto 0);
	signal clk_50 : std_logic;
	
	component doubleDabble
	port
	(
		clk		 : in std_logic;
		binaryIn	 : in unsigned(11 downto 0);
		bcd		 : out std_logic_vector(15 downto 0)
	);
	end component;
	
	component DAC_interface
	port
	(
		clk		  : in std_logic;  --connected to 50MHz system clock
		d	 			 : in std_logic_vector(11 downto 0); --connected to parallel digital data in binary format, MSB on the left
		cs_l,sck,sdi	  : out std_logic --SPI control pins on MCP4921
	);
end component;

	signal i : integer range 0 to NUM_POINTS := 0;
	
	type memory_type is array (0 to NUM_POINTS-1) of integer range 0 to MAX_AMPLITUDE;
	
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
	clk_50 <= clk;
	
	threeDigit: doubleDabble port map (clk => clk_50, binaryIn => count, bcd => bcd); --converts 12 bit binary to 3 digit binary coded decimal (bcd)
	dacinterface: DAC_interface port map (clk =>clk_50, d => d_op, cs_l => cs_l, sck => sck, sdi => sdi );
	sseg0 <= ssegCode(bcd(3 downto 0));
	sseg1 <= ssegCode(bcd(7 downto 4));
	sseg2 <= ssegCode(bcd(11 downto 8));
	
	process(clk)

		constant clock_freq : integer := 50_000_000;
		variable timer : integer range 0 to 150000000 := 0;
		variable frequency, Tc, counter : integer := 0;
		variable brightness : integer;

		begin
		
		if (rising_edge(clk)) then
			case state is
				when s0=>
					sseg6 <= "10001110";
						led0<='1';
						led1<='0';
						led2<='0';
						led3<='0';
					if switch0= '0' and frequency_btn = '0' then 
						frequency := frequency + 1;
						count <= to_unsigned(frequency, count'length);
						state <= s1;
					elsif switch0= '1' and frequency_btn = '0' then 
						frequency := frequency + 10;
						count <= to_unsigned(frequency, count'length);
						state <= s1;
					elsif set_btn = '0' then 
						timer := 0;
						state <= s2;
					else 
						state<= s0;
					end if;
					
				when s1=>
						led0<='0';
						led1<='1';
						led2<='0';
						led3<='0';
						if frequency_btn = '0' then 
							state<= s1;
						else 
							state<= s0;
						end if;
						
				when s2=>
						led0<='0';
						led1<='0';
						led2<='1';
						led3<='0';
					
					if (set_btn = '0' and timer < 150000000) then
						state <= s2;
						timer := timer + 1;
					elsif (timer >= 150000000) then
						Tc := clock_freq/frequency;
						state <= s3;
						timer := 0;
					else
						state <= s0;
						timer := 0;
					end if;
						
				when s3=>
					sseg6 <= "10010010";
						led0<='0';
						led2<='0';
						led3<='1';
					if counter < Tc then
							d_op <= std_logic_vector(to_unsigned(sine(i), d_op'length));			
							counter := counter +1;
							if sine(i) < 45 then
								led_out <= "00000";
								
							elsif sine(i) < 90 then
								led_out <= "00001";
							
							elsif sine(i) < 135 then
								led_out <= "00011";
				
							elsif sine(i) < 180 then
								led_out<= "00111";
								
							elsif sine(i) < 225 then
								led_out<= "01111";
							else
								led_out<= "11111";
							end if;
					else 
							i <= i + 1;
							counter := 0;
							if i = NUM_POINTS-1 then
								i <= 0;
							end if;
					end if;
			end case;
		end if;
	end process;

end Behavioral;

