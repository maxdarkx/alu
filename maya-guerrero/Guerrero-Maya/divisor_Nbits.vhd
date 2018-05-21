----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Ricardo Andres Velasquez
-- 
-- Create Date:    22:02:43 10/27/2015 
-- Design Name: 
-- Module Name:    divisor_Nbits - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity divisor_Nbits is
    Generic (N : INTEGER:= 36);
    Port ( A : in  STD_LOGIC_VECTOR (N-1 downto 0);
           B : in  STD_LOGIC_VECTOR (N-1 downto 0);
           C : out  STD_LOGIC_VECTOR (N-1 downto 0);
           R : out  STD_LOGIC_VECTOR (N-1 downto 0));
end divisor_Nbits;

architecture Behavioral of divisor_Nbits is
   type div_type1 is array (N-1 downto 0) of STD_LOGIC_VECTOR(N-1 downto 0);
   type div_type2 is array (N-1 downto 0) of STD_LOGIC_VECTOR(N downto 0);
   signal num, temp : div_type1;
   signal res : div_type2;
   constant zero: STD_LOGIC_VECTOR(N-1 downto 0):=(others=>'0');
begin

   num(0) <= A;
   
   TEMPS:
   for I in 0 to N-2 generate
      begin
         temp(I) <= zero(N-1 downto I+1)&num(I)(N-1 downto N-1-I);
         res(I) <= ('0'&temp(I))-('0'&B);
         num(I+1) <= num(I) when res(I)(N)='1' else
                     res(I)(I downto 0)&num(I)(N-2-I downto 0);
   end generate;
   
	temp(N-1) <= num(N-1);
   res(N-1) <= ('0'&temp(N-1))-('0'&B);
   R <= num(N-1) when res(N-1)(N)='1' else
        res(N-1)(N-1 downto 0);

   COCIENTE:
   for I in 0 to N-1 generate
      begin
      C(N-1-I) <= not res(I)(N);
   end generate;
   
end Behavioral;

