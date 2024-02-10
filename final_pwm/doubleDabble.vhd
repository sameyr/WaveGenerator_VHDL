--(Krabicka, 2023)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity doubleDabble is port
(
	clk :      in std_logic;
	binaryIn : in unsigned(11 downto 0);
	bcd :      out std_logic_vector(15 downto 0)
);
end doubleDabble;
--
architecture rtl of doubleDabble is

begin

process(clk)

variable i: integer:=12;
variable scratch : unsigned(27 downto 0);

begin
	if rising_edge(clk) then
		
		if i = 12 then
			bcd <= std_logic_vector(scratch(27 downto 12));
			i := 0;
			scratch := "0000000000000000" & unsigned(binaryIn);
		else
			i := i + 1;
	 
			if scratch(27 downto 24) > 4 then
				scratch(27 downto 24) := scratch(27 downto 24) + 3;
			end if;
			if scratch(23 downto 20) > 4 then
				scratch(23 downto 20) := scratch(23 downto 20) + 3;
			end if;
			if scratch(19 downto 16) > 4 then
				scratch(19 downto 16) := scratch(19 downto 16) + 3;
			end if;		
			if scratch(15 downto 12) > 4 then
				scratch(15 downto 12) := scratch(15 downto 12) + 3;
			end if;	
			scratch := shift_left(scratch,1);
		end if;
			
	end if;	
end process;
	
end rtl;