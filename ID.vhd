library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ID is
	port(
		clock: in std_logic;
		instr_in: in UNSIGNED(0 to 21);

		ready_at: out UNSIGNED(0 to 1);
		needs_mem: out std_logic;

		alu_op: out UNSIGNED(0 to 3);
		alu_val_a: out UNSIGNED(0 to 15);
		alu_imm_a: out std_logic;
		alu_val_b: out UNSIGNED(0 to 15);
		alu_imm_b: out std_logic;
		jump_to: out UNSIGNED(0 to 15);

		mem_addr: out UNSIGNED(0 to 1);
		mem_oper: out std_logic;

		wb_reg: out UNSIGNED(0 to 1)
	);
end ID;

architecture id_behavior of ID is

signal ready_at_buf: UNSIGNED(0 to 1) := "00";
signal needs_mem_buf: std_logic := '0';

signal alu_op_buf: UNSIGNED(0 to 3) := x"0";
signal val_a_buf: UNSIGNED(0 to 15) := x"0000";
signal imm_a_buf: std_logic := '0';
signal val_b_buf: UNSIGNED(0 to 15) := x"0000";
signal imm_b_buf: std_logic := '0';

signal jump_addr_buf: UNSIGNED(0 to 15) := x"0000";

signal mem_addr_buf: UNSIGNED(0 to 1) := "00";
signal mem_oper_buf: std_logic := '0';

signal wb_reg_buf: UNSIGNED(0 to 1) := "00";

begin

process(clock)

variable opcode: UNSIGNED(0 to 3);
begin
	if rising_edge(clock) then
		ready_at <= ready_at_buf;
		needs_mem <= needs_mem_buf;

		alu_op <= alu_op_buf;
		alu_val_a <= val_a_buf;
		alu_imm_a <= imm_a_buf;
		alu_val_b <= val_b_buf;
		alu_imm_b <= imm_b_buf;

		jump_to <= jump_addr_buf;

		mem_addr <= mem_addr_buf;
		mem_oper <= mem_oper_buf;

		wb_reg <= wb_reg_buf;
	end if;
	if falling_edge(clock) then
		ready_at_buf <= "00";
		needs_mem_buf <= '0';

		alu_op_buf <= x"0";
		val_a_buf <= x"0000";
		imm_a_buf <= '0';
		val_b_buf <= x"0000";
		imm_b_buf <= '0';
		jump_addr_buf <= x"0000";
		mem_addr_buf <= "00";
		mem_oper_buf <= '0';
		wb_reg_buf <= "00";

		opcode := instr_in(0 to 3);

		-- Jump --
		if opcode = "0001" then
			ready_at_buf <= "00";
			alu_op_buf <= "1010";
			val_a_buf <= x"0000";
			imm_a_buf <= '1';
			val_b_buf <= x"0000";
			imm_b_buf <= '1';
			jump_addr_buf <= instr_in(4 to 19);
		-- Store --
		elsif opcode = "0010" then
			ready_at_buf <= "00";
			needs_mem_buf <= '1';
			alu_op_buf <= x"0";
			val_a_buf(0 to 1) <= instr_in(4 to 5);
			val_b_buf <= x"0000";
			imm_b_buf <= '1';
			mem_oper_buf <= '1';
			mem_addr_buf <= instr_in(6 to 7);
		-- JNZ --
		elsif opcode = "0011" then
			ready_at_buf <= "00";
			alu_op_buf <= x"9";
			val_a_buf(0 to 1) <= instr_in(4 to 5);
			val_b_buf <= x"0000";
			imm_b_buf <= '1';
			jump_addr_buf <= instr_in(6 to 21);
		-- JEZ --
		elsif opcode = "0100" then
			ready_at_buf <= "00";
			alu_op_buf <= x"A";
			val_a_buf(0 to 1) <= instr_in(4 to 5);
			val_b_buf <= x"0000";
			imm_b_buf <= '1';
			jump_addr_buf <= instr_in(6 to 21);
		-- LOAD --
		elsif opcode = "0101" then
			ready_at_buf <= "10";
			needs_mem_buf <= '1';
			wb_reg_buf <= instr_in(4 to 5);
			mem_addr_buf <= instr_in(6 to 7);
		-- LOADI --
		elsif opcode = "0110" then
			ready_at_buf <= "01";
			wb_reg_buf <= instr_in(4 to 5);
			val_a_buf <= instr_in(6 to 21);
			imm_a_buf <= '1';
			val_b_buf <= x"0000";
			imm_b_buf <= '1';
		-- Regular ALU Operations --
		elsif UNSIGNED(opcode) >= 7 and UNSIGNED(opcode) <= 15 then
			ready_at_buf <= "01";
			alu_op_buf <= UNSIGNED(UNSIGNED(opcode) - 7);
			wb_reg_buf <= instr_in(4 to 5);
			val_a_buf(0 to 1) <= instr_in(6 to 7);
			val_b_buf(0 to 1) <= instr_in(8 to 9);
		end if;
	end if;
end process;

end architecture;
