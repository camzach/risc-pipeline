library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity REGFILE is
	port (
		write_enable: in std_logic;
		write_val: in UNSIGNED(0 to 15);
		dest_reg: in UNSIGNED(0 to 1);

		ex_reg: in UNSIGNED(0 to 1);
		ex_val: in UNSIGNED(0 to 15);
		ex_avail: in std_logic;
		mem_reg: in UNSIGNED(0 to 1);
		mem_val: in UNSIGNED(0 to 15);
		mem_avail: in std_logic;

		reg_a_out: out UNSIGNED(0 to 15);
		reg_b_out: out UNSIGNED(0 to 15);
		reg_c_out: out UNSIGNED(0 to 15);
		reg_d_out: out UNSIGNED(0 to 15)
	);
end entity;

architecture regfile_behavior of REGFILE is

signal out_a, out_b, out_c, out_d: UNSIGNED(0 to 15) := x"0000";
signal in_a, in_b, in_c, in_d: UNSIGNED(0 to 15) := x"0000";
signal write_a, write_b, write_c, write_d: std_logic := '0';

begin
REG_A: entity work.REG
port map(
	write_enable => write_a,
	data_in => in_a,
	data_out => out_a
);

REG_B: entity work.REG
port map(
	write_enable => write_b,
	data_in => in_b,
	data_out => out_b
);

REG_C: entity work.REG
port map(
	write_enable => write_c,
	data_in => in_c,
	data_out => out_c
);

REG_D: entity work.REG
port map(
	write_enable => write_d,
	data_in => in_d,
	data_out => out_d
);

process(write_enable)
begin
if rising_edge(write_enable) then
	-- Write new regsiter values from WB stage --
	case dest_reg is
		when "00" => in_a <= write_val; write_a <= '1';
		when "01" => in_b <= write_val; write_b <= '1';
		when "10" => in_c <= write_val; write_c <= '1';
		when "11" => in_d <= write_val; write_d <= '1';
		when others => report("Bad register");
	end case;
end if;
if falling_edge(write_enable) then
	write_a <= '0';
	write_b <= '0';
	write_c <= '0';
	write_d <= '0';
end if;
end process;

reg_a_out <=
	ex_val when ex_reg = "00" and ex_avail = '1' else
	mem_val when mem_reg = "00" and mem_avail = '1' else
	out_a;
reg_b_out <=
	ex_val when ex_reg = "01" and ex_avail = '1' else
	mem_val when mem_reg = "01" and mem_avail = '1'
	else out_b;
reg_c_out <= 
	ex_val when ex_reg = "10" and ex_avail = '1' else
	mem_val when mem_reg = "10" and mem_avail = '1' else
	out_c;
reg_d_out <= 
	ex_val when ex_reg = "11" and ex_avail = '1' else
	mem_val when mem_reg = "11" and mem_avail = '1' else
	out_d;

end architecture;
