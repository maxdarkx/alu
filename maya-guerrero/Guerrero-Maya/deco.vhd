library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity deco is
	Port (  
			  val : in  STD_LOGIC_VECTOR (4 downto 0);
           seg : out  STD_LOGIC_VECTOR (8 downto 0)
        );
	end deco;

architecture behavioral of deco is
begin

	with val select seg <=
					--abcdefg + hi (especial)
					"001111110" when "00000", --0--activo alto
					"000110000" when "00001", --1
					"001101101" when "00010", --2
					"001111001" when "00011", --3
					"000110011" when "00100", --4
					"001011011" when "00101", --5
					"001011111" when "00110", --6
					"001110000" when "00111", --7
					"001111111" when "01000", --8
					"001110011" when "01001", --9
					"001110111" when "11010", --A reservado para suma
					"000000001" when "11011", --B reservado para resta
					"001001110" when "11100", --C reservado para multiplicacion
					"000111110" when "11101", --D reservado para division
					"001001111" when "11110", --# 'E' reservado para igual
					"000000111" when "01111", --* 'F' reservado para punto
					"000000000" when "01010", -- display apagado
					"000000000" when others;
end behavioral;