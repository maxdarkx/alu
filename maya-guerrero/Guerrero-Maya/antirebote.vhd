library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity debouncer is
    Port ( I : in  STD_LOGIC;
			  rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
				O  : out  STD_LOGIC);
end debouncer;

architecture Behavioral of debouncer is
---declaracion de estados
type state_type is (s0, s1, s2); 
signal state, next_state : state_type; 
---- instanciacion de estado
--------------senales
signal enable : std_logic := '0';
signal Button : std_logic := '0';
signal count: integer range 0 to 599999 := 0;


begin
--contador que espera para dejar salida en alto un solo ciclo para guardarla en la maquina
antirrebote: process(clk, rst) begin
	if (rst = '1') then
      count <= 0;
   elsif (clk'event and clk='1') then
		if (count = 599999) then
         count <= 0;
			button <= '1';
      elsif (state = s1) then
         count <= count+1;
			button <= '0';
      end if;
   end if;
	end process;

--sync proc de la maquina de estados
SYNC_PROC: process (clk, rst)
   begin
      if (clk'event and clk = '1') then
         if (rst = '1') then
            state <= s0;
         else
            state <= next_state;
				O <= enable;--guardar entrada
         end if;        
      end if;
   end process;
--cambio de estados
OUTPUT_DECODE: process (state,  I, button)
   begin
		if (state = s0 and I = '1') then--si hay entrada de dato
			enable <= '1';--asigno a dato el bit en alto
			
		elsif (state = s0 and I = '0') then
			enable <= '0';--de lo contrario no hay nada y la marca flagkey permanece en 0
			
		elsif (state = s1 and button = '1') then
			enable<= '1';
			   --si hay un dato y sigue en alto lo mando
		elsif (state = s1 and button = '0') then
			enable <= '1';--si se suelta la tecla permanece
			
		elsif (state = s2 and I = '1') then
			enable <= '1';--sigue 
			
		elsif (state = s2 and I = '0') then
			enable <= '1';--y sigue ahi
			
		else
			enable <= '0';--hasta que se suelta la tecla, el dato se cae
			
		end if;
   end process;
-- siguiente estados 
	NEXT_STATE_DECODE: process (state, I, button)
   begin
      case (state) is
         when s0 =>
            if I = '1' then
               next_state <= s1;--si entra un dato paso sino me quedo en s0
				elsif I = '0' then
					next_state <= s0;
            end if;
         when s1 =>
            if button = '1' then--si hay un dato todavia con key habilito la grabacion del dato
               next_state <= s2;
				else
					next_state <= s1;--no pasa nada
            end if;
         when s2 =>
            if I = '1' then
               next_state <= s2;--una vez grabado paso derecho
				elsif I = '0' then
					next_state <= s0;--de lo contrario si se suelta la tecla se va a s0
            end if;
         when others =>
            next_state <= s0;--en otro caso s0 para no generar latch
      end case;      
   end process;
end Behavioral;

