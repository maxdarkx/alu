----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:25:13 04/18/2018 
-- Design Name: 
-- Module Name:    div - Behavioral 
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

entity div is
	Generic ( 
			N: INTEGER:=18
				); 
	Port ( clk: in std_logic; 
			 rst: in std_logic;						
			 NA: in std_logic_vector(27 downto 0);
          NB: in std_logic_vector(27 downto 0);
	  enable : in std_logic;
			  S: out std_logic_vector(27 downto 0));
				
end div;

 architecture Behavioral of div is
	constant Bias: std_logic_vector (9 downto 0):= "0111111111";
	constant NaN : std_logic_vector(27 downto 0) := "0111111111100000000000000001";
	constant ceros: std_logic_vector(27 downto 0):="0000000000000000000000000000";
	constant infi: std_logic_vector(27 downto 0):= "0111111111100000000000000000";
 
	signal EA, EB : std_logic_vector (9 downto 0);
	signal MA,MB : std_logic_vector(16 downto 0);
	signal SA, SB : std_logic;
	signal Am,Bm : std_logic_vector (2*N-1 downto 0);
	signal MR : std_logic_vector (2*N-1 downto 0);
	
	signal ST : std_logic;
	signal MT : std_logic_vector (16 downto 0);
	signal ET, ES: std_logic_vector(9 downto 0);
	signal sum: std_logic_vector(27 downto 0);
 
 
	COMPONENT divisor_Nbits
	Generic (N: INTEGER :=36);
	Port ( A : in  STD_LOGIC_VECTOR (N-1 downto 0); --Numerador
          B : in  STD_LOGIC_VECTOR (N-1 downto 0); -- denominador
          C : out  STD_LOGIC_VECTOR (N-1 downto 0); -- cociente
          R : out  STD_LOGIC_VECTOR (N-1 downto 0)); -- residuo
	END COMPONENT;
				
	begin
	
	SA<= NA(27);
	SB <= NB(27);
	EA <= NA(26 downto 17);
	EB <= NB(26 downto 17);
	MA <= NA(16 downto 0);
	MB <= NB(16 downto 0);
	
	
-- signo
	ST <= SA xor SB;
--Exponente
	ES <= EA - EB + Bias when MA >= MB else
			EA - EB + 510;
--opero mantisas
	Am <= '1'& MA &"000000000000000000"; --agrego 1 invisible Y 
	Bm <= "000000000000000000"&'1'& MB; -- ceros necesarios para division
	
	division: divisor_Nbits
	GENERIC MAP (N => 36)
	PORT MAP(
		A => Am,
		B => Bm,
		C => MR,
		R => OPEN
		);
 
 MT <= MR(34 downto 18)when MR(35)='1' else
		 MR(33 downto 17)when MR(34)='1' else
		 MR(32 downto 16)when MR(33)='1' else
	    MR(31 downto 15)when MR(32)='1' else
	    MR(30 downto 14)when MR(31)='1' else
	    MR(29 downto 13)when MR(30)='1' else
	    MR(28 downto 12)when MR(29)='1' else
		 MR(27 downto 11)when MR(28)='1' else		 
		 MR(26 downto 10) when MR(27)='1' else
       MR(25 downto 9) when MR(26)='1' else
       MR(24 downto 8) when MR(25)='1' else
		 MR(23 downto 7) when MR(24)='1' else
		 MR(22 downto 6) when MR(23)='1' else
		 MR(21 downto 5) when MR(22)='1' else
		 MR(20 downto 4) when MR(21)='1' else
		 MR(19 downto 3) when MR(20)='1' else
		 MR(18 downto 2) when MR(19)='1' else
		 MR(17 downto 1) when MR(18)='1' else
		 MR(16 downto 0);

	sum(27)<= ST;
	sum(26 downto 17)<= ES;
	sum(16 downto 0) <= MT;
	
 s<= "0000000000000000000000000000" when enable = '0' else
	  NaN when (EA = "1111111111" and MA /="00000000000000000") or (EB= "1111111111" and MB /="00000000000000000") else
	  NaN when (MA= "00000000000000000" and MB= "00000000000000000") else
	  NaN when (EA = "1111111111" and MA = "00000000000000000")and(EB= "1111111111" and MB = "00000000000000000") else
	  infi when (EA = "1111111111" and MA = "00000000000000000")and(EB /= "1111111111" and MB /= "00000000000000000") else
	  ceros when (EA = "0000000000" and MA ="00000000000000000")and(EB /= "0000000000" and MB /="00000000000000000") else
--	  ceros when (EB ="1111111111" and MB ="00000000000000000")and (EA /= "1111111111" and MA /="00000000000000000)")else
	  sum;	
	
	
	
 end Behavioral;

