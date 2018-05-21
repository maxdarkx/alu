
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity Cdecimal is
 Port ( E : in  STD_LOGIC_VECTOR (13 downto 0);                 --entrada de 14 bits
        O : out  STD_LOGIC_VECTOR (15 downto 0);                --salida de 16 bits
      clk : in  STD_LOGIC;
		  en: out std_logic;                                      --salida enable al componente de la parte entera
	   rst : in STD_LOGIC
           );
end Cdecimal;


architecture Behavioral of Cdecimal is

begin
process(clk,E)

	variable A1 : std_logic_vector(27 downto 0):="0000000000000000000000000000";
	variable A2 : std_logic_vector(15 downto 0):="0000000000000000";
	variable ready : std_logic_vector(13 downto 0):="00000000000000";       --Ready verifica si en algun instante cambia la entrada
	                                                                        --si cambia, hace reset
	begin
		
	if (clk'event and clk='1')then
	if E="00000000000000" then                                                   --si la entrada es cero
		O<="0000000000000000";                                                    --se arroja ceros y enable
		en<='1';
	else
			if ready-E > 0 or ready-E < 0 then
				count:="10010";
				A1:="0000000000000000000000000000";
				A2:="0000000000000000";
				en<='0';
			end if;
			
			if count="10010" then                                --si el contador es 18 se hace set a A1 de la informacion y set a A2 de la salida
				A1 := "00000000000000"&E;
				A2 := "0000000000000000";
			elsif A1="0000000000000010011100010000" then
					A1:=A1;		                                   --si el dato es 10MIL, se represento totalmente el valor
			elsif count > "0000" and count < "10001" then
					A1 := (A1)+(A1);                               --multiplicar por dos, es decir sumarse a si mismo...				
				if A1 >= "0000000000000010011100010000" then      --verificar si es mayor a 10MIL
					A1 := (A1) - "0000000000000010011100010000";   --restar 10MIL
					A2(conv_integer(count)-1):='1';               --Mandar un 1 a la posicion de la salida que indica el contador
				else
					A2(conv_integer(count)-1):='0';
				end if;
				
		
			end if;
			en<='0';                                              -- enable mientras no haya salida estable
			O<=A2;                                                --asignar a la salida 
			
			if count="0000" then                                  --al llegar a cero el contador deja salir el dato mediante enable y no  sigue restando
				en<='1';
			else
				count := count -1;
				en<='0';
			end if;
			ready:=E;                                             --almacena y verifica
			
	end if;
	end if;
	end process;
	

end Behavioral;

