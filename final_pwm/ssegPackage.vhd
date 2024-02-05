--converts binary coded decimal to seven segment code for DE1-SoC 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package ssegPackage is

	function ssegCode  (count : std_logic_vector) return std_logic_vector;

end package ssegPackage;

package body ssegPackage is

	function ssegCode  (count : std_logic_vector) return std_logic_vector is
	
	variable sseg: std_logic_vector(7 downto 0);
	variable num: std_logic_vector(3 downto 0);
	
	begin
		num := count;
		case num is
			when x"0" =>
				sseg := "11000000";
			when x"1" =>
				sseg := "11111001";
			when x"2" =>
				sseg := "10100100";
			when x"3" =>
				sseg := "10110000";
			when x"4" =>
				sseg := "10011001";
			when x"5" =>
				sseg := "10010010";
			when x"6"=>
				sseg := "10000010";
			when x"7" =>
				sseg := "11111000";
			when x"8"=>
				sseg := "10000000";
			when x"9"=>
				sseg := "10011000";
			when others =>
				sseg := "11111111";  --should never happen
		end case;
		return sseg;
	end;

end package body ssegPackage;