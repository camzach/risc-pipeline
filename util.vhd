library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;

package util_pkg is
	generic (
		WORDLEN: integer:=15
	);
	type mem_arr is array(0 to 65535) of unsigned(WORDLEN downto 0);

	impure function init_memory_from_file(
		file_name : string
	) return mem_arr;
end package util_pkg;

package body util_pkg is
	impure function read_memory_file(
		file_name : string
	) return mem_arr is
		file file_handle : text open read_mode is file_name;
		variable current_line : line;
		variable good         : boolean;
		variable result       : mem_arr :=
			(others => (others => '0'));
	begin
		for i in 0 to 65535 loop
			exit when endfile(file_handle);
			readline(file_handle, current_line);

			hread(current_line, result(i), good);
			if not good then
				report "Not a hex literal in memory file '" & file_name & "': " & current_line.all
				severity failure;
			end if;
		end loop;

		return result;
	end read_memory_file;

	impure function init_memory_from_file(
		file_name : string
	) return mem_arr is
		constant uninitialized : mem_arr :=
			(others => (others => 'U'));
	begin
		if file_name'length = 0 then
			return uninitialized;
		else
			return read_memory_file(file_name);
		end if;
	end init_memory_from_file;
end package body util_pkg;
