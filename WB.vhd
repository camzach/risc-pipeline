library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity WB is
port(
	clock: in std_logic;
	ready_at: in UNSIGNED(0 to 1);
	data_in: in UNSIGNED(0 to 15);
	reg_in: in UNSIGNED(0 to 1);
	data_out: out UNSIGNED(0 to 15);
	reg_out: out UNSIGNED(0 to 1);
	write_enable: out std_logic
);
end WB;

architecture wb_behavior of WB is

signal data_out_buf: UNSIGNED(0 to 15) := x"0000";
signal reg_out_buf: UNSIGNED(0 to 1) := "00";
signal ready_at_buf: UNSIGNED(0 to 1) := "00";

begin

process(clock)
begin
	if rising_edge(clock) then
		if ready_at_buf = "01" or ready_at_buf = "10" then
			data_out <= data_out_buf;
			write_enable <= '1';
			reg_out <= reg_out_buf;
		end if;
	end if;
	if falling_edge(clock) then
		write_enable <= '0';
		ready_at_buf <= ready_at;
		data_out_buf <= data_in;
		reg_out_buf <= reg_in;
	end if;
end process;

end architecture;
