library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MEM is
	port (
		clock : in std_logic;
		ready_at: in UNSIGNED(0 to 1);
		needs_mem: in std_logic;
		addr_in: in UNSIGNED(0 to 15);
		data_in: in UNSIGNED(0 to 15);
		reg_in: in UNSIGNED(0 to 1);
		mode_in: in std_logic;
		data_out: out UNSIGNED(0 to 15);
		dest_reg: out UNSIGNED(0 to 1);
		ready_at_out: out UNSIGNED(0 to 1);
		fu_avail: out std_logic
	);
end MEM;


architecture mem_behavior of MEM is

signal data_in_buf: UNSIGNED(0 to 15) := x"0000";
signal mem_out: UNSIGNED(0 to 15) := x"0000";
signal ready_at_buf: UNSIGNED(0 to 1) := "00";
signal needs_mem_buf: std_logic := '0';
signal write_enable: std_logic := '0';
signal reg_buf: UNSIGNED(0 to 1) := "00";
signal mode_buf: std_logic := '0';
signal addr_buf: UNSIGNED(0 to 15) := x"0000";

begin
	DMEM: entity work.RAM
	port map (
		address => addr_buf,
		write_enable => write_enable,
		data_in => data_in_buf,
		data_out => mem_out
	);

	process(clock)
	begin
		if rising_edge(clock) then
			fu_avail <= '0';
			if needs_mem_buf = '1' then
				if mode_buf = '1' then
					write_enable <= '1';
				end if;
				data_out <= mem_out;
			else
				data_out <= data_in_buf;
			end if;
			if ready_at_buf = "01" or ready_at_buf = "10" then
				fu_avail <= '1';
			end if;
			ready_at_out <= ready_at_buf;
			dest_reg <= reg_buf;
		end if;
		if falling_edge(clock) then
			write_enable <= '0';
			ready_at_buf <= ready_at;
			needs_mem_buf <= needs_mem;
			reg_buf <= reg_in;
			mode_buf <= mode_in;
			addr_buf <= addr_in;
			data_in_buf <= data_in;
		end if;
	end process;

end architecture;
