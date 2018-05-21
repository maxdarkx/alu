----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:32:31 04/22/2018 
-- Design Name: 
-- Module Name:    Resta - Behavioral 
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

 entity Resta is
	Port( NA : in std_logic_vector(27 downto 0);
			NB : in std_logic_vector(27 downto 0);
			clk: in std_logic; 
			rst: in std_logic;
	  enable : in std_logic;			
			 s : out std_logic_vector(27 downto 0));
 end Resta;

 architecture Behavioral of Resta is
 
 	constant NaN : std_logic_vector(27 downto 0) := "0111111111100000000000000001";
	constant infi: std_logic_vector(27 downto 0):= "0111111111100000000000000000";
	
	signal EA, EB : std_logic_vector (9 downto 0);
	signal MA, MB, Am, Bm : std_logic_vector (16 downto 0);
	signal SA,SB,ST,SR : std_logic;
 	signal ET : std_logic_vector(9 downto 0);
	signal MT,MR : std_logic_vector(16 downto 0);
	Signal Max : std_logic_vector(9 downto 0); -- maximo corrimiento
	signal diffe : std_logic_vector(9 downto 0); -- resta exponentes
	signal sum,AA,AB: std_logic_vector(35 downto 0); ---suma
	signal Z : std_logic_vector (16 downto 0):="00000000000000000";
	signal total : std_logic_vector(27 downto 0);
	
begin
--sacar signos, exponente y mantissa para especiales
	SA<= NA(27);
	SB <= NB(27);
	EA <= NA(26 downto 17);
	EB <= NB(26 downto 17);
	MA <= NA(16 downto 0);
	MB <= NB(16 downto 0);

-- signo
	ST <= SA xor SB;
-- Defino casos exponente para corrimiento
	diffe <= EA-EB;
	Max <= not(diffe)+"0000000001" when diffe(9)= '1' else 
			 diffe+"0000000000";
	AA <= Z(conv_integer(max) downto 0)&'1'& MA & z(16 downto conv_integer(max)) when diffe(9)= '1' else
	"01" & MA &"00000000000000000";
	AB <= Z(conv_integer(max) downto 0)&'1'& MB & z(16 downto conv_integer(max)) when diffe(9)= '0' else
	"01" & MB &"00000000000000000";
	
	process(clk)
	begin
	if(clk'event and clk='1')then
		if ST='1' then --not suma
			sum <= AA+AB;
			if sum(35)='1' then ----- overflow
				MR <= sum(34 downto 18);
				if diffe = 0 then
					ET <= EA+"0000000001";
				else
					ET <= EB+"0000000001";
				end if;
			else
				MR <= sum(33 downto 17);
				if diffe = 0 then
					ET <= EA;
				else 
					ET <= EB;
				end if;
			end if;
		else ---si xor=0
			if(diffe="0000000000" AND AA>AB)then
				sum <= AA-AB;
			elsif(diffe="0000000000" AND AB>AA)then
				sum <= AB-AA;
			elsif	diffe(9)='0' then
				sum <= AA-AB;
			else 
				sum<= AB-AA;
			end if;
			
-- para mantisa
		if sum(33)='1' then MR <= sum(32 downto 16);
		elsif sum(32)='1' then MR <= sum(31 downto 15);
		elsif sum(31)='1' then MR <= sum(30 downto 14);
		elsif sum(30)='1' then MR <= sum(29 downto 13);
		elsif sum(29)='1' then MR <= sum(28 downto 12);
		elsif sum(28)='1' then MR <= sum(27 downto 11);
		elsif sum(27)='1' then MR <= sum(26 downto 10);
		elsif sum(26)='1' then MR <= sum(25 downto 9);
		elsif sum(25)='1' then MR <= sum(24 downto 8);
		elsif sum(24)='1' then MR <= sum(23 downto 7);
		elsif sum(23)='1' then MR <= sum(22 downto 6);
		elsif sum(22)='1' then MR <= sum(21 downto 5);
		elsif sum(21)='1' then MR <= sum(20 downto 4);
		elsif sum(20)='1' then MR <= sum(19 downto 3);
		elsif sum(19)='1' then MR <= sum(18 downto 2);
		elsif sum(18)='1' then MR <= sum(17 downto 1);
		elsif sum(17)='1' then MR <= sum(16 downto 0); -- no estoy segura, si no sirve, eliminar esta condicion 
		else 
		MR <= "00000000000000000";
		end if;
-- para exponente
		if diffe(9)='0' then 
			if (sum(33)='1') then ET  <= EA-1;
			elsif (sum(32)='1') then ET  <= EA-2;
			elsif (sum(31)='1') then ET  <= EA-3;
			elsif (sum(30)='1') then ET  <= EA-4;
			elsif (sum(29)='1') then ET  <= EA-5;
			elsif (sum(28)='1') then ET  <= EA-6;
			elsif (sum(27)='1') then ET  <= EA-7;
			elsif (sum(26)='1') then ET  <= EA-8;
			elsif (sum(25)='1') then ET  <= EA-9;
			elsif (sum(24)='1') then ET  <= EA-10;
			elsif (sum(23)='1') then ET  <= EA-11;
			elsif (sum(22)='1') then ET  <= EA-12;
			elsif (sum(21)='1') then ET  <= EA-13;
			elsif (sum(20)='1') then ET  <= EA-14;
			elsif (sum(19)='1') then ET  <= EA-15;
			elsif (sum(18)='1') then ET  <= EA-16;
			elsif (sum(17)='1') then ET  <= EA-17;
			else 
			ET <= "0000000000";
			end if;
		else
			if (sum(33)='1') then ET  <= EB-1;
			elsif (sum(32)='1') then ET  <= EB-2;
			elsif (sum(31)='1') then ET  <= EB-3;
			elsif (sum(30)='1') then ET  <= EB-4;
			elsif (sum(29)='1') then ET  <= EB-5;
			elsif (sum(28)='1') then ET  <= EB-6;
			elsif (sum(27)='1') then ET  <= EB-7;
			elsif (sum(26)='1') then ET  <= EB-8;
			elsif (sum(25)='1') then ET  <= EB-9;
			elsif (sum(24)='1') then ET  <= EB-10;
			elsif (sum(23)='1') then ET  <= EB-11;
			elsif (sum(22)='1') then ET  <= EB-12;
			elsif (sum(21)='1') then ET  <= EB-13;
			elsif (sum(20)='1') then ET  <= EB-14;
			elsif (sum(19)='1') then ET  <= EB-15;
			elsif (sum(18)='1') then ET  <= EB-16;
			elsif (sum(17)='1') then ET  <= EB-17;
			else 
			ET <= "0000000000";
			end if;
		end if;	
	end if;
 end if;

	
end process;
-- resultado
--signo
 SR <= NA(27) when diffe = "0000000000" and ST ='0' else
		 NA(27) when diffe = "0000000000" and ST ='1' and AA>AB else
		 NB(27) when diffe = "0000000000" and ST ='1' and AB>AA else
			'0'  when diffe = "0000000000" and ST ='1' and AA=AB else
		 NA(27) when diffe(9)= '0' else
		 NB(27);
-- mantisa
 MT <= MR;
--- total
 total(27)<= SR;
 total(26 downto 17)<= ET;
 total(16 downto 0) <= MT;
 
 s<= "0000000000000000000000000000" when enable = '0' else
	  NaN when (EA = "1111111111" and MA /="00000000000000000") or (EB= "1111111111" and MB /="00000000000000000") else
	  NaN when (EA = "1111111111" and MA = "00000000000000000") and(EB= "1111111111" and MB = "00000000000000000") and ST='1' else
	 infi when (EA = "1111111111" and MA = "00000000000000000") and(EB /= "1111111111") else
	 infi when (EB = "1111111111" and MB = "00000000000000000") and(EA /= "1111111111") else
	 NA(27 downto 0) when (EB = "0000000000" and MB="00000000000000000")else
    NB(27 downto 0) when (EA = "0000000000" and MA="00000000000000000")else
	 NA(27 downto 0) when diffe>="0000010010" and diffe(9)='0' else
	 NB(27 downto 0) when not(diffe)>="0000010010" and diffe(9)='1' else
	 total;




end Behavioral;






