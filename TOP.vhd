library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CPU is
end entity;

architecture cpu_behavior of CPU is

signal clock: std_logic := '0';

-- IF outputs --
signal instr_out: UNSIGNED(0 to 21) := "0000000000000000000000";

-- REGFILE outputs --
signal reg_a_out: UNSIGNED(0 to 15) := x"0000";
signal reg_b_out: UNSIGNED(0 to 15) := x"0000";
signal reg_c_out: UNSIGNED(0 to 15) := x"0000";
signal reg_d_out: UNSIGNED(0 to 15) := x"0000";

-- ID outputs --
signal ready_at: UNSIGNED(0 to 1) := "00";
signal needs_mem: std_logic := '0';

signal alu_op: UNSIGNED(0 to 3) := x"0";
signal alu_val_a: UNSIGNED(0 to 15) := x"0000";
signal alu_imm_a: std_logic := '0';
signal alu_val_b: UNSIGNED(0 to 15) := x"0000";
signal alu_imm_b: std_logic := '0';

signal jump_to: UNSIGNED(0 to 15) := x"0000";

signal mem_addr: UNSIGNED(0 to 1) := "00";
signal mem_oper: std_logic := '0';

signal wb_reg: UNSIGNED(0 to 1) := "00";

-- EX outputs --
signal ex_reg_out: UNSIGNED(0 to 1) := "00";
signal ex_mem_addr_out: UNSIGNED(0 to 15) := x"0000";
signal ex_mem_oper_out: std_logic := '0';
signal ex_ready_at_out: UNSIGNED(0 to 1) := "00";
signal ex_needs_mem_out: std_logic := '0';
signal ex_data_out: UNSIGNED(0 to 15) := x"0000";
signal ex_jump: std_logic := '0';
signal ex_jump_addr: UNSIGNED(0 to 15) := x"0000";
signal ex_fu_avail: std_logic := '0';

-- MEM outputs --
signal mem_data_out: UNSIGNED(0 to 15) := x"0000";
signal mem_dest_reg: UNSIGNED(0 to 1) := "00";
signal mem_fu_avail: std_logic := '0';
signal mem_ready_at_out: UNSIGNED(0 to 1) := "00";

-- WB outputs --
signal wb_data_out: UNSIGNED(0 to 15) := x"0000";
signal wb_dest_reg: UNSIGNED(0 to 1) := "00";
signal wb_write_enable: std_logic := '0';

begin

IFetch: entity work.IFetch
port map (
	clock => clock,
	jump => ex_jump,
	jump_addr => ex_jump_addr,
	instr_out => instr_out
);

REGFILE: entity work.REGFILE
port map(
	write_enable => wb_write_enable,
	write_val => wb_data_out,
	dest_reg => wb_dest_reg,

	ex_reg => ex_reg_out,
	ex_val => ex_data_out,
	ex_avail => ex_fu_avail,
	mem_reg => mem_dest_reg,
	mem_val => mem_data_out,
	mem_avail => mem_fu_avail,

	reg_a_out => reg_a_out,
	reg_b_out => reg_b_out,
	reg_c_out => reg_c_out,
	reg_d_out => reg_d_out
);

ID: entity work.ID
port map (
	clock => clock,
	instr_in => instr_out,

	ready_at => ready_at,
	needs_mem => needs_mem,

	alu_op => alu_op,
	alu_val_a => alu_val_a,
	alu_imm_a => alu_imm_a,
	alu_val_b => alu_val_b,
	alu_imm_b => alu_imm_b,

	jump_to => jump_to,

	mem_addr => mem_addr,
	mem_oper => mem_oper,

	wb_reg => wb_reg
);

EX: entity work.EX
port map (
	clock => clock,
	ready_at => ready_at,
	needs_mem => needs_mem,

	reg_a => reg_a_out,
	reg_b => reg_b_out,
	reg_c => reg_c_out,
	reg_d => reg_d_out,

	alu_op => alu_op,
	val_a => alu_val_a,
	imm_a => alu_imm_a,
	val_b => alu_val_b,
	imm_b => alu_imm_b,

	jump_in => jump_to,

	dest_reg_in => wb_reg,
	dest_reg_out => ex_reg_out,
	mem_addr_in => mem_addr,
	mem_addr_out => ex_mem_addr_out,
	mem_oper_in => mem_oper,
	mem_oper_out => ex_mem_oper_out,
	ready_at_out => ex_ready_at_out,
	needs_mem_out => ex_needs_mem_out,

	data_out => ex_data_out,

	jump => ex_jump,
	jump_addr => ex_jump_addr,

	fu_avail => ex_fu_avail
);

MEM: entity work.MEM
port map (
	clock => clock,
	ready_at => ex_ready_at_out,
	needs_mem => ex_needs_mem_out,
	addr_in => ex_mem_addr_out,
	reg_in => ex_reg_out,
	data_in => ex_data_out,
	mode_in => ex_mem_oper_out,
	data_out => mem_data_out,
	dest_reg => mem_dest_reg,
	ready_at_out => mem_ready_at_out,
	fu_avail => mem_fu_avail
);

WB: entity work.WB
port map(
	clock => clock,
	ready_at => mem_ready_at_out,
	data_in => mem_data_out,
	reg_in => mem_dest_reg,
	data_out => wb_data_out,
	reg_out => wb_dest_reg,
	write_enable => wb_write_enable
);

process begin
clock <= '0'; wait for 50 ns;
clock <= '1'; wait for 50 ns;
end process;

end architecture;
