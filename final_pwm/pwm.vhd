library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ssegPackage.all;

entity pwm is port
(
	button, switch10, switch100, changeState_switch, set_btn, reset, clk 		: in std_logic;
	pwm 																								:out std_logic; 
	sseg0, sseg1, sseg2, sseg6	  			   												: out std_logic_vector(7 downto 0)	
);
end pwm;

architecture behavioural of pwm is

-- Build an enumerated type for the state machine
type state_type is (s0, s1, s2, s3,s4, s5,s6);

signal state : state_type := s2;
signal count : unsigned(11 downto 0):= x"000";
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

begin

clk_50 <= clk;

	threeDigit: doubleDabble port map (clk => clk_50, binaryIn => count, bcd => bcd); --converts 12 bit binary to 3 digit binary coded decimal (bcd)
	sseg0 <= ssegCode(bcd(3 downto 0));
	sseg1 <= ssegCode(bcd(7 downto 4));
	sseg2 <= ssegCode(bcd(11 downto 8));

process(clk, button, switch100, switch10, changeState_switch, reset)

	constant clock_freq : integer := 50000000;
	variable frequency, counter, dutyCycle, period, dutyCyclePeriod: integer := 0;
	variable timer : integer range 0 to 150000000 := 0;

	
	begin

	if (rising_edge(clk)) then
	case state is 
	
	
		when s0 =>
			sseg6 <= "10001110";
			
			if frequency >= 999 then  --maximum value for 3 decimal digits
					frequency := 0;
					count <= to_unsigned(frequency, count'length);		
			else
				if switch10 = '0' and switch100 = '0' and button = '0' then
					frequency := frequency + 1;
					count <= to_unsigned(frequency, count'length);
					state <= s1;
						
				elsif switch10='1' and switch100='0' and button='0' then
					frequency := frequency + 10;
					count <= to_unsigned(frequency, count'length);
					state <= s1;
						
				elsif switch10='0' and switch100='1' and button='0' then
					frequency := frequency + 100;
					count <= to_unsigned(frequency, count'length);
					state <= s1;
					
				elsif reset ='0' then
					timer := 0;
					state <= s4;
					
				elsif set_btn = '0' then 
					timer := 0;
					dutyCyclePeriod := ((clock_freq/100) * dutyCycle) / (frequency);
					period := clock_freq / frequency ;
					state <= s5;
				
				elsif changeState_switch = '1' then 
					count <=to_unsigned(dutyCycle, count'length);
					state <= s2;
					
				else
				
					state <= s0;
				end if;
			end if;
			
		when s1 =>
			if button = '0'  then 
				state <= s1;
			else
				state<= s0;
			end if;
			
			
		when s2=>
		
			sseg6 <= "10100001";
		
			if dutyCycle >= 100 then  --maximum value for 3 decimal digits
				dutyCycle := 0;
				count <= to_unsigned(dutyCycle, count'length);
			else
				if switch10 = '0' and button = '0' then
					dutyCycle := dutyCycle + 1;
					count <= to_unsigned(dutyCycle, count'length);
					state <= s3;
						
				elsif switch10='1' and button='0' then
					dutyCycle := dutyCycle + 10;
					count <= to_unsigned(dutyCycle, count'length);
					state <= s3;
					
				elsif reset ='0' then
					timer := 0;
					state<=s4;
					
				elsif changeState_switch = '0' then 
					count <=to_unsigned(frequency, count'length);
					state <= s0;
					
				elsif set_btn = '0' then 
					timer := 0;
					dutyCyclePeriod := ((clock_freq/100) * dutyCycle) / (frequency);
					period := clock_freq / frequency ;
					state <= s5;
			
				else
					state <= s2;
				end if;
			end if;
			
		when s3 =>
			if button = '0'  then 
				state <= s1;
			else
				state<= s2;
			end if;
			
		
		when s4=>
		
			sseg6 <= "10001000";
			
			if (reset = '0' and timer < 150000000) then
				state <= s4;
				timer := timer + 1;
							
			elsif (timer >= 150000000) then
				if (changeState_switch = '0')then
					state <= s0;
					frequency := 0;
					count <= x"000";
					timer := 0;
				elsif (changeState_switch = '1') then
					state <= s3;
					dutyCycle := 0;
					count <= x"000";
					timer := 0;
				end if;
			else
				if (changeState_switch = '0')then
					timer := 0;
					state <= s0;
				else
					timer :=0;
					state <= s3;
				end if;
			end if;
		
		when s5 =>
		
			if (dutyCyclePeriod > 1) then
			
				sseg6 <= "00000000";
				
			end if;
			
			if (set_btn ='0' and timer<150000000) then
				state <= s5;
				timer := timer + 1;
				
			elsif  timer >= 150000000 then 
				state <= s6;
				timer:=0;
			else 
			
				state <= s0;
				timer := 0;
			end if;
			
		when s6 =>
			sseg6 <= "10001100";
			
			if counter < dutyCyclePeriod  then 
						PWM <='1';
			end if;
							
			if counter >dutyCyclePeriod and counter < period  then
						PWM <='0';
			end if;
							
			if counter  > period then
						counter:=0;
			end if;
			
				counter := counter + 1;
				state <= s6;
			
	end case;
end if;
end process;
end behavioural;