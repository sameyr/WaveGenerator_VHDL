library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_sineWaveGenerator is
end tb_sineWaveGenerator;

architecture testbench of tb_sineWaveGenerator is
    signal clk : std_logic := '0';
    signal led_out : std_logic_vector(2 downto 0);
	 signal frequency : integer := 1;
    constant clock_period : time := 20 ns;  -- Adjust as needed

    component sineWaveGenerator
        generic (
            NUM_POINTS    : integer := 30;
            MAX_AMPLITUDE : integer := 255
        );
        port (
            clk          : in  std_logic;
            led_out      : out std_logic_vector(2 downto 0)
        );
    end component;

    begin
        dut : sineWaveGenerator
            generic map (
                NUM_POINTS    => 30,
                MAX_AMPLITUDE => 255
            )
            port map (
                clk          => clk,
                led_out      => led_out
            );

        process
        begin
            -- Initialize clock
            clk <= '0';
            wait for clock_period / 2;

            -- Apply clock cycles and observe output
            for i in 1 to 1000 loop
                clk <= not clk;  -- Toggle clock
                wait for clock_period / 2;

            end loop;

            wait;
        end process;

end testbench;
