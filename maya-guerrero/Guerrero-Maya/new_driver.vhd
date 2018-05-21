----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:48:59 04/29/2018 
-- Design Name: 
-- Module Name:    new_driver - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity new_driver is
	port(
			signal clk:	 in  std_logic;
			signal rst: 	 in  std_logic;
			signal col1: 	 in  std_logic;
			signal col2: 	 in  std_logic;
			signal col3: 	 in  std_logic;
			signal col4: 	 in  std_logic;
			signal row_out0: out std_logic;
			signal row_out1: out std_logic;
			signal row_out2: out std_logic;
			signal row_out3: out std_logic;
			signal salida:	 out std_logic_vector(4 downto 0);
			signal ready_in: out std_logic
		);
end new_driver;

architecture Behavioral of new_driver is

	signal cont: integer:=0;
	signal temp: std_logic:='0';
	signal dato: std_logic:='0';
	signal clk2: std_logic:='0';
	signal col: std_logic_vector(3 downto 0);
	signal fila: std_logic_vector(3 downto 0);
	signal pulso: std_logic:='0';

begin

reloj: process(clk)
	variable cont: integer range 0 to 24999:=0;
	
begin
	if rising_edge(clk) then
		if cont=24999 then
			cont:=0;
			clk2<=not(clk2);
		else
			cont:=cont+1;
		end if;
	end if;
end process;



	col<= col1 & col2 & col3 & col4;
	----------------------proceso de rotacion del uno de fila
	secuencia: process(clk2, rst) begin
		if (rst = '1') then
	      cont <= 0;
	   elsif (clk2'event and clk2='1') then
			if (cont > 3) then
	         cont <= 0;
	      elsif (col = "0000") then
	         cont <= cont+1;
	      end if;
	   end if;
	end process;
	
	--flip flop que acciona una sola vez la bandera para guardar el dato
	process (clk,rst)
	begin  
	   if rst = '1' then
	      dato <= '0';
	   elsif (clk'event and clk = '1') then
	      	if ((col > "0000" or col < "0000") and temp = '1') then
				dato <= '1';
				temp <= '0';
			elsif ((col > "0000" or col < "0000") and temp = '0') then
				temp <= '0';
				dato <= '0';
			elsif (col = "0000" ) then
				temp <= '1';
				dato <= '0';     
		  	else
	        	dato <= '0';
			end if;
	   end if;
   end process;
--valor de las filas


   fila <=  "0001" when cont = 0 else
			"0010" when cont = 1 else
			"0100" when cont = 2 else
			"1000" when cont = 3 else
           	x"0";
				
	salida <= 	"11010" when cont = 0 and col = "0001" else	--'A'
				"00011" when cont = 0 and col = "0010" else --'3'
         		"00010" when cont = 0 and col = "0100" else --'2'
				"00001" when cont = 0 and col = "1000" else --'1'
			 
				"11011" when cont = 1 and col = "0001" else --'B'
				"00110" when cont = 1 and col = "0010" else --'6'
				"00101" when cont = 1 and col = "0100" else --'5'
				"00100" when cont = 1 and col = "1000" else --'4'
			 
				"11100" when cont = 2 and col = "0001" else --'C'
				"01001" when cont = 2 and col = "0010" else --'9'
				"01000" when cont = 2 and col = "0100" else --'8'
				"00111" when cont = 2 and col = "1000" else --'7'
			 
				"11101" when cont = 3 and col = "0001" else --'D'
				"11110" when cont = 3 and col = "0010" else --'#'
				"00000" when cont = 3 and col = "0100" else --'0'
				"01111" when cont = 3 and col = "1000" else --'*'
             	"00000";
					
pulso_out: process(clk,dato,pulso)
	variable ban: std_logic:='0';
begin
	if rising_edge(clk) then
		if(dato='1' and ban='0') then
			pulso<='1';
			ban:='1';
		elsif(dato='1' and ban='1') then
			pulso<='0';
		elsif(dato='0') then
			pulso<='0';
			ban:='0';
		end if;
	end if;
end process;

ready_in<=pulso;		
 row_out0 <= fila(0);
 row_out1 <= fila(1);
 row_out2 <= fila(2);
 row_out3 <= fila(3);

end Behavioral;