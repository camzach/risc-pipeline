library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity RAM is
	generic(package util is new work.util_pkg generic map (wordlen=>15));
	port (
		address : in UNSIGNED(15 downto 0);
		write_enable : in std_logic;
		data_out : out UNSIGNED(15 downto 0);
		data_in : in UNSIGNED(15 downto 0)
		);
end RAM;
		
architecture ram_behavior of RAM is
			
use util.all;
signal RAM_CONTENTS: util.mem_arr := init_memory_from_file("DMEM.mem");

begin
	process(write_enable)
	begin
		if (rising_edge(write_enable)) then
			 RAM_CONTENTS(to_integer(UNSIGNED(address))) <= data_in;
		end if;	end process;
data_out <= RAM_CONTENTS(to_integer(UNSIGNED(address)));
end ram_behavior;
