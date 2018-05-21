----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:45:56 04/23/2018 
-- Design Name: 
-- Module Name:    data_save - Behavioral 
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

entity data_save is
	port(
		clk:			in    std_logic;						--reloj de entrada, agregar un divisor de reloj
		rst:			in 	std_logic;
		data_in: 	in	 	std_logic_vector(4 downto 0);	--bits de entrada directos del teclado numerico
		button:   	in 	std_logic;						--los bits de entrada estan listos para ser leidos
		data_out1: 	out  	std_logic_vector(59 downto 0);				--el array de salida 
		data_out2: 	out  	std_logic_vector(59 downto 0);				--el array de salida 
		op_out:		out	std_logic_vector(4 downto 0)
	);
end data_save;


architecture behavioral of data_save is
		signal num0,num1,num2,num3,num4,num5,num6,num7,num8,num9,num10,num11,num12,num13: std_logic_vector(4 downto 0):="00000";
		signal num14, num15,num16,num17,num18,num19,num20,num21,num22,num23,num24: std_logic_vector(4 downto 0):="00000";
		signal punto : std_logic:='0';
		signal punto2: std_logic:='0';
		signal count : integer :=0;  --Contador que aumenta para la parte entera el numero 1
		signal count1: integer:=0;	  --Contador que aumenta para la parte decimal numero 1
		signal count2: integer :=0;	--Contador que aumenta para la parte entera numero 2
		signal count3: integer :=0;	--Contador que aumenta para la parte decimal numero 2
		signal signo : std_logic_vector(4 downto 0);
		signal clk2: std_logic:='0';
		
begin


corrimiento1 : process(CLK,data_in, punto, count1, count2,num1,num2,num3,num4,num5,num6,num7,num8,num9,num10
								,num11,num12,num13,num14,num15,num16,num17,num18,num19,num20,num21,num22,num23,num24) 
	begin  
 	 
  if (CLK'event and CLK = '1') then		--Menos
  		if (button = '1' and data_in /= "11011" and punto ='0' and count1 = 0 and count = 0) then
			signo<="00000";
			count <= count +1;
		elsif (button = '1' and data_in = "11011" and punto ='0'  and count1 = 0 and count = 0) then
			signo<=data_in;
			count <= count +1;
		elsif (button = '1' and count1 = 0 and punto = '1' and data_in = "01111" and count2 = 0 and count = 0) then
			num1 <= "10001";
			count1 <= count1 + 1;
		elsif (button = '1' and (data_in = "11010" or data_in = "11011" or data_in = "11100" or data_in = "11101" )) then
			num0 <= data_in;
			count2 <= count2 + 1;
		elsif (button = '1' and data_in /= "11011" and data_in /= "11010" and data_in /= "11011" and data_in /= "11100" and data_in/= "11101" and  punto = '0' and count1 = 0 and count2 = 0)then
			num1 <= data_in;
			num2 <= num1;
			num3 <= num2;
			num4 <= num3;
			num5 <= num4;
			num6 <= num5;
			num7 <= num6;
			num8 <= num7;
			count <= count+1; 
													                              --Punto  						
		elsif (button = '1' and count1 = 0 and punto = '1'  and data_in = "01111" and count2 = 0 and count /= 0)then
			count1 <= count1 + 1;	--aca va el punto en el display, agregarlo										      --SUMA                Resta                  --Por                 --Entre
		elsif (button = '1' and count1 = 1 and punto = '1' and data_in /= "11010" and data_in /= "11011" and data_in /= "11100" and data_in /= "11101" and count2 = 0) then
			num9 <= data_in;
			count1 <= count1 + 1;
		elsif (button = '1' and count1 = 2 and punto = '1'  and data_in /= "11010" and data_in /= "11011" and data_in /= "11100" and data_in /= "11101" and count2 = 0) then
			num10 <= data_in;
			count1 <= count1 + 1;
		elsif (button = '1' and count1 = 3 and punto = '1' and data_in /= "11010" and data_in /= "11011" and data_in /= "11100" and data_in /= "11101" and count2 = 0) then
			num11 <= data_in;
			count1 <= count1 + 1;
		elsif (button = '1' and count1 = 4 and punto = '1' and data_in /= "11010" and data_in /= "11011" and data_in /= "11100" and data_in /= "11101" and count2 = 0) then
			num12 <= data_in;
			count1 <= count1 + 1;
		elsif (button = '1' and data_in /= "11011" and data_in /= "01111" and punto2='0' and count3 = 0) then
			num13 <= data_in;
			num14 <= num13;
			num15 <= num14;
			num16 <= num15;
			num17 <= num16;
			num18 <= num17; 
			num19 <= num18;
			num20 <= num19;
			count2 <= count2 + 1;	  
		elsif (button = '1' and count3 = 0 and punto = '1' and count2 /=0 and data_in = "01111" ) then
			count3 <= count3 + 1; --aca va el punto en el display, agregarlo
		elsif (button = '1' and count3 = 1 and  data_in /= "11010" and data_in /= "11011" and data_in /= "11100" and data_in /= "11101") then
			num21 <= data_in;
			count3 <= count3 + 1;
		elsif (button = '1' and count3 = 2 and data_in /= "11010" and data_in /= "11011" and data_in /= "11100" and data_in /= "11101" ) then
			num22 <= data_in;
			count3 <= count3 + 1;
		elsif (button = '1' and count3 = 3 and data_in /= "11010" and data_in /= "11011" and data_in /= "11100" and data_in /= "11101" ) then
			num23 <= data_in;
			count3 <= count3 + 1;
		elsif (button = '1' and count3 = 4 and data_in /= "11010" and data_in /= "11011" and data_in /= "11100" and data_in /= "11101" ) then
			num24 <= data_in;
			count3 <= count3 + 1;
		end if;
  end if;
  
  data_out1<= num1  & num2  & num3  & num4  & num5  & num6  & num7  & num8  & num9  & num10 & num11 & num12;
  data_out2<= num13 & num14 & num15 & num16 & num17 & num18 & num19 & num20 & num21 & num22 & num23 & num24;
end process;


process(CLK2) 
	begin  
  if (CLK2'event and CLK2 = '1') then
		if (data_in = "01111") then       
			punto <= '1';
		elsif (count1 /= 0) then
			punto <= '1';
		elsif(count3 /= 0)then
			punto2 <= '1';
		else 
			punto <= '0';
			punto2 <= '0';
	  end if;
  end if;
end process;		
end behavioral;
