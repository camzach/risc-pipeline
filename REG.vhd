library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity REG is
	port (
		write_enable : in std_logic;
		data_out : out UNSIGNED(15 downto 0);
		data_in : in UNSIGNED(15 downto 0)
	);
end REG;


architecture reg_behavior of REG is

signal data: UNSIGNED(15 downto 0) := x"0000";

begin
	process(write_enable)
	begin
		if (rising_edge(write_enable)) then
			 data <= data_in;
		end if;
	end process;
data_out <= data;
end reg_behavior;
