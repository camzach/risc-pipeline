library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-----------------------------------------------
---------- ALU 8-bit VHDL ---------------------
-----------------------------------------------
entity ALU is
	generic ( 
		constant N: natural := 1  -- number of shited or rotated bits
	);
  
	Port (
		A, B     : in  UNSIGNED(0 to 15);  -- 2 inputs 8-bit
		ALU_Sel  : in  UNSIGNED(0 to 3);  -- 1 input 4-bit for selecting function
		ALU_Out   : out  UNSIGNED(0 to 15); -- 1 output 8-bit 
		Carryout : out std_logic        -- Carryout flag
	);
end ALU;


architecture alu_behavior of ALU is

signal ALU_Result : UNSIGNED (15 downto 0);
signal tmp: UNSIGNED (16 downto 0);

begin
	process(A,B,ALU_Sel)
	begin
	case(ALU_Sel) is
  when "0000" => -- Addition
   ALU_Result <= A + B ; 
  when "0001" => -- Subtraction
   ALU_Result <= A - B ;
  when "0010" => -- Multiplication
   ALU_Result <= UNSIGNED(to_UNSIGNED((to_integer(UNSIGNED(A)) * to_integer(UNSIGNED(B))),16)) ;
  when "0011" => -- Division
   ALU_Result <= UNSIGNED(to_UNSIGNED(to_integer(UNSIGNED(A)) / to_integer(UNSIGNED(B)),16)) ;
  when "0100" => -- Logical and 
   ALU_Result <= A and B;
  when "0101" => -- Logical or
   ALU_Result <= A or B;
  when "0110" => -- Logical xor 
   ALU_Result <= A xor B;
  when "0111" => -- Logical nor
   ALU_Result <= A nor B;
  when "1000" => -- Logical nand 
   ALU_Result <= A nand B;
  when "1001" => -- Greater comparison
   if(A>B) then
    ALU_Result <= x"0001" ;
   else
    ALU_Result <= x"0000" ;
   end if; 
  when "1010" => -- Equal comparison   
   if(A=B) then
    ALU_Result <= x"0001" ;
   else
    ALU_Result <= x"0000" ;
   end if;
  when others => ALU_Result <= A ; 
  end case;
 end process;
 ALU_Out <= ALU_Result; -- ALU out
 tmp <= ('0' & A) + ('0' & B);
 Carryout <= tmp(16); -- Carryout flag
end alu_behavior;
