----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:56:34 04/18/2018 
-- Design Name: 
-- Module Name:    digits_show - Behavioral 
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
library work;
use work.array_machine.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity digits_show is
generic (
		dl: integer:=50 ;
		dh: integer:=100;
		lw: integer:=5
	);
port(	
		number1: 	 	 in  std_logic_vector(59 downto 0);
		number2: 	 	 in  std_logic_vector(59 downto 0);
		number_sol: 	 in  std_logic_vector(59 downto 0);
		op:				in std_logic_vector(4 downto 0);
		hcount:      in  std_logic_vector(10 downto 0);
	   vcount:      in  std_logic_vector(10 downto 0);
		posx: 		 out integer range 0 to 480;
		posy:		 	 out integer range 0 to 640;
		value:		 out std_logic_vector(4 downto 0)
	);




end digits_show;

architecture Behavioral of digits_show is
	--constant dl:  integer := 50; 	--largo del caracter
	--constant dh:  integer := 100; 	--altura del caracter
	--constant lw:  integer := 5; 	--ancho de las lineas
	constant esh: integer := 10; 	--espacio entre caracterers

	constant th: integer := 640;
	constant tv: integer := 480;
    --"numero (8+4)"+ "punto(1)" + "operacion (1)"=14
	constant CC1 : integer := 14; 	-- cantidad de letras para primera fila (14) 
	constant CC2 : integer := 13; 	-- cantidad de letras para segunda fila (13) 
    constant CC3 : integer := 13; 	-- cantidad de letras para ultima fila (13) 
	
	
	constant RESET_DATA: std_logic_vector(7 downto 0):=(others=>'0');

begin

print: process(hcount,vcount,number1,op,number2,number_sol)
	variable esl : integer := dl+lw; --espacio entre palabras

	variable EVU : integer; -- espacio vertical utilizado
	variable EHU1: integer; -- Espacio horizontal total utilizado fila 1 
	variable EHU2: integer; -- Espacio horizontal total utilizado fila 2
	variable EHU3: integer; -- Espacio horizontal total utilizado fila 3
	variable px1,px10,px11,px12,px13,px14,px15,px16,px17,px18,px19,px110,px111,px112,px113,px101 : integer range 0 to 640 :=0;
	variable px2,px20,px21,px22,px23,px24,px25,px26,px27,px28,px29,px210,px211,px212,px213,px201: integer range 0 to 640:=0;
	variable px3,px30,px31,px32,px33,px34,px35,px36,px37,px38,px39,px310,px311,px312,px313,px301: integer range 0 to 640:=0;
	
	variable py1,py2,py3,py4: integer range 0 to 480;
	
begin
	--centrado vertical y horizontalmente
	EVU:= 2*(dh+esh);
	EHU1:= cc1*(dl+esh) ;
	EHU2:= cc2*(dl+esh) ;
	EHU3:= cc3*(dl+esh) ;
	
	px1 := 0;
	px2 := 0;
	px3 := 0;

	py1 := 0;
	py2 := py1+dh+esl;
	py3 := py2+dh+esl;
	py4 := py3+dh+esl;


--para centrar
	--px1 := (th-ehu1)/2 ;
	--px2 := (th-ehu2)/2;
	--px3 := (th-ehu3)/2;

	--py1 := (tv - EVU)/2;
	--py2:=py1+dh+esl;											   
	--py3:=py1+2*dh+esl;
	--py4:=py1+3*dh+esl;	

	--simbolos para primer operando
	px10:= px1;
	px11:= px1 + dl + esh;
	px12:= px1 + 2*(dl + esh);
	px13:= px1 + 3*(dl + esh);
	px14:= px1 + 4*(dl + esh);
	px15:= px1 + 5*(dl + esh);
	px16:= px1 + 6*(dl + esh);
	px17:= px1 + 7*(dl + esh);
	px18:= px1 + 8*(dl + esh);
	px19:= px1 + 9*(dl + esh); --punto
	px110:= px1 + 10*(dl + esh);
	px111:= px1 + 11*(dl + esh);
	px112:= px1 + 12*(dl + esh);
	px101:= px1 + 13*(dl + esh);

	--simbolos para segundo operando
	px20:= px2;
	px21:= px2 + dl + esh;
	px22:= px2 + 2*(dl + esh);
	px23:= px2 + 3*(dl + esh);
	px24:= px2 + 4*(dl + esh);
	px25:= px2 + 5*(dl + esh);
	px26:= px2 + 6*(dl + esh);
	px27:= px2 + 7*(dl + esh);
	px28:= px2 + 8*(dl + esh);
	px29:= px2 + 9*(dl + esh);--punto
	px210:= px2 + 10*(dl + esh);
	px211:= px2 + 11*(dl + esh);
	px212:= px2 + 12*(dl + esh);
	px201:= px2 + 12*(dl + esh);
	--simbolos para resultado
--	px30:= px3;
--	px31:= px3 + dl + esh;
--	px32:= px3 + 2*(dl + esh);
--	px33:= px3 + 3*(dl + esh);
--	px34:= px3 + 4*(dl + esh);
--	px35:= px3 + 5*(dl + esh);
--	px36:= px3 + 6*(dl + esh);
--	px37:= px3 + 7*(dl + esh);
--	px38:= px3 + 8*(dl + esh);
--	px39:= px3 + 9*(dl + esh);
--	px310:= px3 + 10*(dl + esh);
--	px311:= px3 + 11*(dl + esh);
--	px312:= px3 + 12*(dl + esh);
--	px301:= px3 + 13*(dl + esh);
--	
	


	if (vcount > py1) and (vcount <py2) then -- operando 1
		posy<=py1;

		if hcount>px10 and hcount<px11 then
			posx<=px10;
			value<= number1(4 downto 0);
		elsif hcount>px11 and hcount<px12 then
			posx<=px11;
			value<=number1(9 downto 5);
		elsif hcount>px12 and hcount<px13 then
			posx<=px12;
			value<=number1(14 downto 10);
		elsif hcount>px13 and hcount<px14 then
			posx<=px13;
			value<=number1(19 downto 15);
		elsif hcount>px14 and hcount<px15 then
			posx<=px14;
			value<=number1(24 downto 20);
		elsif hcount>px15 and hcount<px16 then
			posx<=px15;
			value<=number1(29 downto 25);
		elsif hcount>px16 and hcount<px17 then
			posx<=px16;
			value<=number1(34 downto 30);
		elsif hcount>px17 and hcount<px18 then
			posx<=px17;
			value<=number1(39 downto 35);
		elsif hcount>px18 and hcount<px19 then
			posx<=px18;
			value<=number1(44 downto 40);
		elsif hcount>px19 and hcount<px110 then
			posx<=px19;
			value<=number1(49 downto 45);
		elsif hcount>px110 and hcount<px111 then
			posx<=px110;
			value<=number1(54 downto 50);
		elsif hcount>px111 and hcount<px112 then
			posx<=px111;
			value<=number1(59 downto 55);
		elsif hcount>px112 and hcount<px101 then
			posx<=px112;
			value<=op;
		else
			null;
		end if;



	elsif vcount > py2 and vcount <py3 then --operando 2
		posy<=py2;
		
	if hcount>px20 and hcount<px21 then
			posx<=px20;
			value<= number2(4 downto 0);
		elsif hcount>px21 and hcount<px22 then
			posx<=px21;
			value<= number2(9 downto 5);
		elsif hcount>px22 and hcount<px23 then
			posx<=px22;
			value<= number2(14 downto 10);
		elsif hcount>px23 and hcount<px24 then
			posx<=px23;
			value<= number2(19 downto 15);
		elsif hcount>px24 and hcount<px25 then
			posx<=px24;
			value<= number2(24 downto 20);
		elsif hcount>px25 and hcount<px26 then
			posx<=px25;
			value<= number2(29 downto 25);
		elsif hcount>px26 and hcount<px27 then
			posx<=px26;
			value<= number2(34 downto 30);
		elsif hcount>px27 and hcount<px28 then
			posx<=px27;
			value<= number2(39 downto 35);
		elsif hcount>px28 and hcount<px29 then
			posx<=px28;
			value<= number2(44 downto 40);
		elsif hcount>px29 and hcount<px210 then
			posx<=px29;
			value<= number2(49 downto 45);
		elsif hcount>px210 and hcount<px211 then
			posx<=px210;
			value<= number2(54 downto 50);
		elsif hcount>px211 and hcount<px201 then
			posx<=px211;
			value<= number2(59 downto 55);
		else
			null;
		end if;


--	elsif vcount > py3 and vcount < py4 then --resultado
--		posy<=py3;
		
--		if hcount>px30 and hcount<px31 then
--			posx<=px30;
--			value<='0' & number_sol(3 downto 0);
--		elsif hcount>px31 and hcount<px32 then
--			posx<=px31;
--			value<='0' & number_sol(7 downto 4);
--		elsif hcount>px32 and hcount<px33 then
--			posx<=px32;
--			value<='0' & number_sol(11 downto 8);
--		elsif hcount>px33 and hcount<px34 then
--			posx<=px33;
--			value<='0' & number_sol(15 downto 12);
--		elsif hcount>px34 and hcount<px35 then
--			posx<=px34;
--			value<='0' & number_sol(19 downto 16);
--		elsif hcount>px35 and hcount<px36 then
--			posx<=px35;
--			value<='0' & number_sol(23 downto 20);
--		elsif hcount>px36 and hcount<px37 then
--			posx<=px36;
--			value<='0' & number_sol(27 downto 24);
--		elsif hcount>px37 and hcount<px38 then
--			posx<=px37;
--			value<='0' & number_sol(31 downto 28);
--		elsif hcount>px38 and hcount<px39 then
--			posx<=px38;
--			value<='0' & number_sol(35 downto 32);
--		elsif hcount>px39 and hcount<px310 then
--			posx<=px39;
--			value<='0' & number_sol(39 downto 36);
--		elsif hcount>px310 and hcount<px311 then
--			posx<=px310;
--			value<='0' & number_sol(43 downto 40);
--		elsif hcount>px311 and hcount<px312 then
--			posx<=px311;
--			value<='0' & number_sol(47 downto 44);
--		elsif hcount>px312 and hcount<px301 then
--			posx<=px312;
--			value<='0' & number_sol(51 downto 48);
--		else 
--			null;
--		end if;
	else
		null;
	end if;
end process;





end Behavioral;

