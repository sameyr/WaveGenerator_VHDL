library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ssegPackage.all;

entity pwm is port
(
	button, switch10, switch100, changeState_switch, set_btn, reset, clk	: in std_logic;
	pwm 																						:out std_logic; 
	sseg0, sseg1, sseg2, sseg6	  			   									   : out std_logic_vector(7 downto 0)	
);
end pwm;

architecture behavioural of pwm is

-- enumerated type for the state machine
type state_type is (s0, s1, s2, s3,s4, s5,s6);

signal state : state_type := s2;
signal count : unsigned(11 downto 0):= x"000"; --counter to be shown in sseg
signal bcd : std_logic_vector (15 downto 0);   --binary coded decimal using double dabble
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

	constant clock_freq : integer := 50000000;	--internal clock frequency
	variable frequency, counter, dutyCycle, period, dutyCyclePeriod: integer := 0;	-- all the required variable 
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
				if switch10 = '0' and switch100 = '0' and button = '0' then		--increases frequency by 1
					frequency := frequency + 1;
					count <= to_unsigned(frequency, count'length);
					state <= s1;
						
				elsif switch10='1' and switch100='0' and button='0' then	--increases frequency by 10
					frequency := frequency + 10;
					count <= to_unsigned(frequency, count'length);
					state <= s1;
						
				elsif switch10='0' and switch100='1' and button='0' then		--increases frequency by 100
					frequency := frequency + 100;
					count <= to_unsigned(frequency, count'length);
					state <= s1;
					
				elsif reset ='0' then			--transition to reset state
					timer := 0;
					state <= s4;
					
				elsif set_btn = '0' then 		--transition to set state for Pwm generation 
					timer := 0;
					dutyCyclePeriod := ((clock_freq/100) * dutyCycle) / (frequency);	--calculating neccessary parameters 
					period := clock_freq / frequency ;
					state <= s5;
				
				elsif changeState_switch = '1' then 			--transition to duty cycle state 
					count <=to_unsigned(dutyCycle, count'length);
					state <= s2;
					
				else
					state <= s0;
				end if;
			end if;
			
		when s1 => 	--hold state  
			if button = '0'  then	--loops in the same state if button not release 
				state <= s1;
			else
				state<= s0;			--goes back to S0
			end if;
			
			
		when s2=>
		
			sseg6 <= "10100001";
		
			if dutyCycle >= 100 then  --maximum value for 3 decimal digits
				dutyCycle := 0;
				count <= to_unsigned(dutyCycle, count'length);
			else
				if switch10 = '0' and button = '0' then		--increases duty cycle by 1
					dutyCycle := dutyCycle + 1;
					count <= to_unsigned(dutyCycle, count'length);
					state <= s3;
						
				elsif switch10='1' and button='0' then			--increases duty cycle by 10
					dutyCycle := dutyCycle + 10;
					count <= to_unsigned(dutyCycle, count'length);
					state <= s3;
					
				elsif reset ='0' then	--transition to reset state
					timer := 0;
					state<=s4;
					
				elsif changeState_switch = '0' then 	--transition to frequency state 	
					count <=to_unsigned(frequency, count'length);
					state <= s0;
					
				elsif set_btn = '0' then 		--transition to reset state
					timer := 0;
					dutyCyclePeriod := ((clock_freq/100) * dutyCycle) / (frequency);	--calculating neccessary parameters
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
		-- reset state
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
		-- check state		
			if (set_btn ='0' and timer<150000000) then	--looping through the same state until time >= 3sec
				state <= s5;
				timer := timer + 1;
				
			elsif  timer >= 150000000 then 	--moving to s6 as soon as timer hits 3 sec
				state <= s6;
				timer:=0;
			else 
				if (changeState_switch = '0')then  -- moving back to it's pervious state when condition is not met 
					state <= s0;
					timer := 0;
				elsif (changeState_switch = '1') then
					state <= s3;
					timer := 0;
			end if;
			
		when s6 =>
			sseg6 <= "10001100";
			
			if counter < dutyCyclePeriod  then --checking if counter is less than high period
						PWM <='1';		-- setting output to 1 & LED is turned onn
			end if;
							
			if counter >dutyCyclePeriod and counter < period  then
						PWM <='0';		-- setting output to 0 & LED is turned off
			end if;
							
			if counter  > period then
						counter:=0;		--resetting counter
			end if;
			
				counter := counter + 1;	--increasing counter
				state <= s6;
			
	end case;
end if;
end process;
end behavioural;