library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 
use work.ssegPackage.all;

entity sineWaveGenerator is
generic ( NUM_POINTS : integer := 30;
			 MAX_AMPLITUDE : integer := 255
			 );
			 
port (clk :in  std_logic;
		frequency_btn, set_btn, switch0 : in std_logic;
     -- dataout : out integer range 0 to MAX_AMPLITUDE;
		led_out: out std_logic_vector(2 downto 0) := "000";
		led0,led1,led2,led3 : out std_logic;
		sseg0,sseg1,sseg2 : out std_logic_vector(7 downto 0)
      );
		
end sineWaveGenerator;

architecture Behavioral of sineWaveGenerator is

	type state_type is (s0,s1,s2,s3);

	signal state : state_type := s0;
	
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

	signal i : integer range 0 to NUM_POINTS := 0;
	type memory_type is array (0 to NUM_POINTS-1) of integer range 0 to MAX_AMPLITUDE;

	signal sine : memory_type :=(128, 154, 179, 202, 222, 238, 249, 254,
											254, 249, 238, 222, 202, 179, 154, 128,
											101, 76, 53, 33, 17, 6, 1, 1,
											6, 17, 33, 53, 76, 101);
	begin
	clk_50 <= clk;
	
	threeDigit: doubleDabble port map (clk => clk_50, binaryIn => count, bcd => bcd); --converts 12 bit binary to 3 digit binary coded decimal (bcd)
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
						led0<='0';
						led2<='0';
						led3<='1';
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
			end case;
		end if;
	end process;

end Behavioral;

