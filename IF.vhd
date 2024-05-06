library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity IFetch is
	port (
		clock : in std_logic;
		jump: in std_logic;
		jump_addr: in UNSIGNED(0 to 15);
		instr_out : out UNSIGNED(0 to 21)
	);
end IFetch;


architecture if_behavior of IFetch is

signal addr: UNSIGNED(0 to 15) := x"0000";
signal inst: UNSIGNED(0 to 21);

begin
	IMEM: entity work.ROM
	port map (
		address => addr,
		data_out => inst
	);

	process(clock)
	begin
		if rising_edge(clock) then
			instr_out <= inst;
		end if;
		if falling_edge(clock) then
			if jump='1' then
				addr <= jump_addr;
			else
				addr <= UNSIGNED(UNSIGNED(addr) + 1);
			end if;
		end if;
	end process;

end architecture;
