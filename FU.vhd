library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FU is
	port(
		ex_reg: in UNSIGNED(0 to 1);
		ex_val: in UNSIGNED(0 to 15);
		mem_reg: in UNSIGNED(0 to 1);
		mem_val: in UNSIGNED(0 to 15);
		wb_reg: in UNSIGNED(0 to 1);
		wb_val: in UNSIGNED(0 to 15);
		
		reg_a: in UNSIGNED(0 to 1);
		val_a: in UNSIGNED(0 to 15);
		reg_b: in UNSIGNED(0 to 1);
		val_b: in UNSIGNED(0 to 15);

		out_a: out UNSIGNED(0 to 15);
		out_b: out UNSIGNED(0 to 15)
	);
end FU;

architecture fu_behavior of FU is
begin

out_a <=
	wb_val when reg_a = wb_reg else
	mem_val when reg_a = mem_reg else
	ex_val when reg_a = ex_reg else
	val_a;

out_b <=
	wb_val when reg_b = wb_reg else
	mem_val when reg_b = mem_reg else
	ex_val when reg_b = ex_reg else
	val_b;


end architecture;
