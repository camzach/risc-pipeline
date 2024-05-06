library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity EX is
	port(
		clock: in std_logic;
		ready_at: in UNSIGNED(0 to 1);

		-- FU stuff --
		reg_a: in UNSIGNED(0 to 15);
		reg_b: in UNSIGNED(0 to 15);
		reg_c: in UNSIGNED(0 to 15);
		reg_d: in UNSIGNED(0 to 15);

		-- ALU stuff --
		alu_op: in UNSIGNED(0 to 3);
		val_a: in UNSIGNED(0 to 15);
		imm_a: in std_logic;
		val_b: in UNSIGNED(0 to 15);
		imm_b: in std_logic;

		jump_in: in UNSIGNED(0 to 15);

		-- Passthrough stuff --
		dest_reg_in: in UNSIGNED(0 to 1);
		dest_reg_out: out UNSIGNED(0 to 1);
		mem_addr_in: in UNSIGNED(0 to 1);
		mem_addr_out: out UNSIGNED(0 to 15);
		mem_oper_in: in std_logic;
		mem_oper_out: out std_logic;
		needs_mem: in std_logic;
		needs_mem_out: out std_logic;
		ready_at_out: out UNSIGNED(0 to 1);

		-- Outputs --
		data_out: out UNSIGNED(0 to 15);

		jump: out std_logic;
		jump_addr: out UNSIGNED(0 to 15);

		fu_avail: out std_logic
	);
end EX;

architecture ex_behavior of EX is

signal alu_val_a: UNSIGNED(0 to 15) := x"0000";
signal alu_val_b: UNSIGNED(0 to 15) := x"0000";

signal alu_oper: UNSIGNED(0 to 3) := "0000";
signal alu_a: UNSIGNED(0 to 15) := x"0000";
signal alu_b: UNSIGNED(0 to 15) := x"0000";
signal alu_out: UNSIGNED(0 to 15) := x"0000";

signal dest_reg: UNSIGNED(0 to 1) := "00";
signal mem_addr_buf: UNSIGNED(0 to 15) := x"0000";
signal mem_oper_buf: std_logic := '0';

signal ready_at_buf: UNSIGNED(0 to 1) := "00";
signal needs_mem_buf: std_logic;

signal jump_buf: UNSIGNED(0 to 15) := x"0000";

begin

ALU: entity work.ALU
port map(
	A => alu_a,
	B => alu_b,
	ALU_Sel => alu_oper,
	ALU_Out => alu_out
);

process(clock) is

variable resolved_a, resolved_b: UNSIGNED(0 to 15) := x"0000";

impure function get_reg_value(reg: UNSIGNED(0 to 1)) return UNSIGNED is
begin
	case reg is
		when "00" => return reg_a;
		when "01" => return reg_b;
		when "10" => return reg_c;
		when "11" => return reg_d;
		when others => report("Bad Register!");
	end case;
	return "XXXXXXXXXXXXXXXX";
end function;

begin
	if rising_edge(clock) then
		jump <= '0';
		fu_avail <= '0';
		if alu_oper = "1001" or alu_oper = "1010" then
			data_out <= x"0000";
			jump_addr <= jump_buf;
			jump <= alu_out(15);
		end if;
		if ready_at_buf = "01" then
			fu_avail <= '1';
		end if;
		data_out <= alu_out;
		
		dest_reg_out <= dest_reg;
		mem_addr_out <= mem_addr_buf;
		mem_oper_out <= mem_oper_buf;
		ready_at_out <= ready_at_buf;
		needs_mem_out <= needs_mem_buf;
	end if;

	if falling_edge(clock) then
		ready_at_buf <= ready_at;
		needs_mem_buf <= needs_mem;
		dest_reg <= dest_reg_in;
		mem_oper_buf <= mem_oper_in;

		case mem_addr_in is
		when "00" => mem_addr_buf <= reg_a;
		when "01" => mem_addr_buf <= reg_b;
		when "10" => mem_addr_buf <= reg_c;
		when "11" => mem_addr_buf <= reg_d;
		when others => report("Bad Register for Mem Addr");
		end case;

		if imm_a = '0' then
			resolved_a := get_reg_value(val_a(0 to 1));
		else
			resolved_a := val_a;
		end if;
		if imm_b = '0' then
			resolved_b := get_reg_value(val_b(0 to 1));
		else
			resolved_b := val_b;
		end if;

		alu_a <= resolved_a;
		alu_b <= resolved_b;
		alu_oper <= alu_op;
		jump_buf <= jump_in;
	end if;
end process;

end;
