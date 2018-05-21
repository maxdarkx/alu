
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity decoIn is
Port ( 		E : in  STD_LOGIC_VECTOR (27 downto 0);--entrada
			  Ef : in STD_LOGIC_VECTOR(15 downto 0);--entrada decimal
            O : out  STD_LOGIC_VECTOR (27 downto 0);--salida
			  en : in std_logic;
			  signo: in STD_LOGIC_VECTOR (4 downto 0);--signo de entrada por driver
           rst : in  STD_LOGIC; 
           clk : in  STD_LOGIC);
end decoIn;

architecture Behavioral of decoIn is

signal S : std_logic;--signo 
signal Ex : std_logic_vector(9 downto 0);--exponente 10 bits
signal M : std_logic_vector (16 downto 0);--17 mantisa
signal Bias : std_logic_vector(9 downto 0):="0111111111";--bias
begin

--asignacion de signo, 11011 es el dato del teclado que indica negativo
S <= '1' when signo = "11011"  and en ='1' else
	  '0';
-- exponente
Ex <= "0000011011" + Bias when E(27)='1' and en = '1' else       --mirar en donde esta el primer uno
	   "0000011010" + Bias when E(26)='1' and en = '1' else       --ir posicion por posicion y mirar si enable esta en 1
	   "0000011001" + Bias when E(25)='1' and en = '1' else        
	   "0000011000" + Bias when E(24)='1' and en = '1' else
	   "0000010111" + Bias when E(23)='1' and en = '1' else
	   "0000010110" + Bias when E(22)='1' and en = '1' else
	   "0000010101" + Bias when E(21)='1' and en = '1' else
	   "0000010100" + Bias when E(20)='1' and en = '1' else
	   "0000010011" + Bias when E(19)='1' and en = '1' else
	   "0000010010" + Bias when E(18)='1' and en = '1' else
	   "0000010001" + Bias when E(17)='1' and en = '1' else 
	   "0000010000" + Bias when E(16)='1' and en = '1' else
	   "0000001111" + Bias when E(15)='1' and en = '1' else
	   "0000001110" + Bias when E(14)='1' and en = '1' else
	   "0000001101" + Bias when E(13)='1' and en = '1' else
	   "0000001100" + Bias when E(12)='1' and en = '1' else
	   "0000001011" + Bias when E(11)='1' and en = '1' else
	   "0000001010" + Bias when E(10)='1' and en = '1' else
	   "0000001001" + Bias when E(9)='1' and en = '1' else
	   "0000001000" + Bias when E(8)='1' and en = '1' else
	   "0000000111" + Bias when E(7)='1' and en = '1' else
	   "0000000110" + Bias when E(6)='1' and en = '1' else
	   "0000000101" + Bias when E(5)='1' and en = '1' else
	   "0000000100" + Bias when E(4)='1' and en = '1' else
	   "0000000011" + Bias when E(3)='1' and en = '1' else
	   "0000000010" + Bias when E(2)='1' and en = '1' else
	   "0000000001" + Bias when E(1)='1' and en = '1' else
	  Bias  when E(0)='1' and en = '1' else                    --aqui esta el bit 0, fuera de aqui empieza a correr negativos
	  Bias -1 When Ef(15)='1' and en ='1' else                 --si esta en la posicion -1 es decir en la 16 del arreglo decimal
	  Bias -2 When Ef(14)='1' and en ='1' else                 --toma el dato siguiente y agarra desde ahi el exponente
	  Bias -3 When Ef(13)='1' and en ='1' else                  --si hacen falta digitos los llena con ceros al final.
	  Bias -4 When Ef(12)='1' and en ='1' else
	  Bias -5 When Ef(11)='1' and en ='1' else
	  Bias -6 When Ef(10)='1' and en ='1' else
	  Bias -7 When Ef(9)='1' and en ='1' else
	  Bias -8 When Ef(8)='1' and en ='1' else
	  Bias -9 When Ef(7)='1' and en ='1' else
	  Bias -10 When Ef(6)='1' and en ='1' else
	  Bias -11 When Ef(5)='1' and en ='1' else
	  Bias -12 When Ef(4)='1' and en ='1' else
	  Bias -13 When Ef(3)='1' and en ='1' else
	  Bias -14 When Ef(2)='1' and en ='1' else
	  Bias -15 When Ef(1)='1' and en ='1' else
	  Bias -16 When Ef(0)='1' and en ='1' else
	  Bias - Bias;                                   --si no hay nada en los 17 bits que tenemos de decimal entonces mandamos cero de exponente
	  
	 
M <= E(26 downto 10) when E(27)='1' and en = '1' else
	  E(25 downto 9) when E(26)='1' and en = '1' else
	  E(24 downto 8) when E(25)='1' and en = '1' else
	  E(23 downto 7) when E(24)='1' and en = '1' else
	  E(22 downto 6) when E(23)='1' and en = '1' else
	  E(21 downto 5) when E(22)='1' and en = '1' else
	  E(20 downto 4) when E(21)='1' and en = '1' else
	  E(19 downto 3) when E(20)='1' and en = '1' else
	  E(18 downto 2) when E(19)='1' and en = '1' else
	  E(17 downto 1) when E(18)='1' and en = '1' else
	  E(16 downto 0) when E(17)='1' and en = '1' else

	  E(15 downto 0)& Ef(14) when E(15)='1' and en = '1' else
	  E(14 downto 0)& Ef(14 downto 13) when E(14)='1' and en = '1' else
	  E(13 downto 0)& Ef(14 downto 12) when E(13)='1' and en = '1' else
	  E(12 downto 0)& Ef(14 downto 11) when E(12)='1' and en = '1' else
	  E(11 downto 0)& Ef(14 downto 10) when E(11)='1' and en = '1' else
	  E(10 downto 0)& Ef(14 downto 9) when E(10)='1' and en = '1' else
	  E(9 downto 0) & Ef(14 downto 8) when E(9)='1' and en = '1' else
	  E(8 downto 0) & Ef(14 downto 7) when E(8)='1' and en = '1' else
	  E(7 downto 0) & Ef(14 downto 6) when E(7)='1' and en = '1' else
	  E(6 downto 0) & Ef(14 downto 5) when E(6)='1' and en = '1' else
	  E(5 downto 0) & Ef(14 downto 4) when E(5)='1' and en = '1' else
	  E(4 downto 0) & Ef(14 downto 3) when E(4)='1' and en = '1' else
	  E(3 downto 0) & Ef(14 downto 2) when E(3)='1' and en = '1' else
	  E(2 downto 0) & Ef(14 downto 1) when E(2)='1' and en = '1' else
	  E(1 downto 0) & Ef(14 downto 0) when E(2)='1' and en = '1' else
	  E(0) & Ef(14 downto 0) & '0'   when E(1) ='1' and en ='1' else
	  Ef(15 downto 0)& '0' when E(0)='1' and en ='1' else                            --aqui esta el bit cero
	  Ef(14 downto 0) & "00" when Ef(14) ='1' and en ='1' else                --empieza a barrer la parte decimal desde aqui
	  Ef(13 downto 0) & "000" when Ef(13) ='1' and en ='1' else
	  Ef(12 downto 0) & "0000" when Ef(12) ='1' and en ='1' else
	  Ef(11 downto 0) & "00000" when Ef(11) ='1' and en ='1' else
	  Ef(10 downto 0) & "000000" when Ef(10) ='1' and en ='1' else
	  Ef(9 downto 0) & "0000000" when Ef(9) ='1' and en ='1' else
	  Ef(8 downto 0) & "00000000" when Ef(8) ='1' and en ='1' else
	  Ef(7 downto 0) & "000000000" when Ef(7) ='1' and en ='1' else
	  Ef(6 downto 0) & "0000000000" when Ef(6) ='1' and en ='1' else
	  Ef(5 downto 0) & "00000000000" when Ef(5) ='1' and en ='1' else
	  Ef(4 downto 0) & "000000000000" when Ef(4) ='1' and en ='1' else
	  Ef(3 downto 0) & "0000000000000" when Ef(3) ='1' and en ='1' else
	  Ef(2 downto 0) & "00000000000000" when Ef(2) ='1' and en ='1' else
	  Ef(1 downto 0) & "000000000000000" when Ef(1) ='1' and en ='1' else
	  '0' & "0000000000000000";                                                           -- se retorna cero al no hallar nada
	  
O(27)<=S;O(26 downto 17) <=Ex ;O(16 DOWNTO 0) <= M;                                      --salida de lo que se hallo antes

end Behavioral;

