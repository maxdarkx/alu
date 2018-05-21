----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:32:01 04/18/2018 
-- Design Name: 
-- Module Name:    multi - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
-- 17 MANTISA 10 EXP
entity multi is
    Port ( clk: in std_logic; 
			  rst: in std_logic;						
			   NA: in std_logic_vector(27 downto 0);
            NB: in std_logic_vector(27 downto 0);
		 enable : in std_logic;
				S: out std_logic_vector(27 downto 0));
end multi;


architecture Behavioral of multi is
 constant Bias: std_logic_vector (9 downto 0):= "0111111111";
 constant NaN : std_logic_vector(27 downto 0) := "0111111111100000000000000001";
 constant ceros: std_logic_vector(27 downto 0):="0000000000000000000000000000";
 constant masinfinito  : std_logic_vector(27 downto 0) := "0111111111100000000000000000";
 constant menosinfinito: std_logic_vector(27 downto 0) := "1111111111100000000000000000";
 constant infi: std_logic_vector(27 downto 0):= "0111111111100000000000000000";
 
 signal EA, EB : std_logic_vector (9 downto 0);
 signal MA, MB : std_logic_vector (16 downto 0);
 signal SA, SB : std_logic;
 signal Am,Bm : std_logic_vector (17 downto 0);
 signal aux : std_logic_vector (35 downto 0);
 
 signal ST : std_logic;
 signal ET, ES: std_logic_vector(9 downto 0);
 signal MT : std_logic_vector(16 downto 0);
 signal sum: std_logic_vector(27 downto 0);
 signal SNaN: std_logic_vector(27 downto 0);
begin
	SA<= NA(27);
	SB <= NB(27);
	EA <= NA(26 downto 17);
	EB <= NB(26 downto 17);
	MA <= NA(16 downto 0);
	MB <= NB(16 downto 0);

------ signo
	ST <= SA xor SB;
--Exponente
	ES <= EA + EB - Bias;
--opero mantisas
	Am <= '1'& MA; --agrego 1 invisible
	Bm <= '1'& MB;

	aux <= Am*Bm;


	MT <= aux(34 downto 18) when (aux(35)='1')else 
			aux(33 downto 17) ;
	ET <= ES+1 when (aux(35)='1')else
			ES;
 	

	sum(27)<= ST;
	sum(26 downto 17)<= ET;
	sum(16 downto 0) <= MT;
	
--	salida con casos especiales 

 s<= "0000000000000000000000000000" when enable = '0' else
	  NaN when (EA = "1111111111" and MA /="00000000000000000") or (EB= "1111111111" and MB /="00000000000000000") else
	  infi when (EA = "1111111111" and MA = "00000000000000000") and(EB="0000000000" and MB="00000000000000000") else
	  menosinfinito when (EA = "1111111111" and MA = "00000000000000000") and(EB= "1111111111" and MB = "00000000000000000") and ST='1' else
	  masinfinito when (EA = "1111111111" and MA = "00000000000000000") and(EB= "1111111111" and MB = "00000000000000000") and ST='0' else
	  ceros when (EA = "0000000000" and MA ="00000000000000000")or(EB = "0000000000" and MB ="00000000000000000")else
	  sum;
	
	 
	 
	



end Behavioral;

