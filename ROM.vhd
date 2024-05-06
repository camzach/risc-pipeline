library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.util_pkg;

entity ROM is
	generic(package util is new work.util_pkg generic map (wordlen=>21));
	port (
		address : in unsigned(0 to 15);
		data_out : out unsigned(0 to 21)
	);
end ROM;


architecture rom_behavior of ROM is

use util.all;
signal ROM_CONTENTS: util.mem_arr := util.init_memory_from_file("IMEM.mem");

begin
data_out <= ROM_CONTENTS(to_integer(unsigned(address)));
end rom_behavior;
