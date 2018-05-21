library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity Display is
	Generic ( 
				LW: INTEGER:=4;
				DW: INTEGER:=32;
				DL: INTEGER:=64
				); 
   Port (   HCOUNT : in  STD_LOGIC_VECTOR (10 downto 0);
            VCOUNT : in  STD_LOGIC_VECTOR (10 downto 0);
				PAINT :  out STD_LOGIC;
				VALUE :  in  STD_LOGIC_VECTOR (4  downto 0);
				POSX: in integer;
				POSY: in integer
			);
end Display;

architecture Behavioral of Display is
	-- Segmentos del display
	signal seg : 	STD_LOGIC_VECTOR  (8 downto 0);
	--signal POSX,POSY: integer;
	-- Constantes Geometricas Display
	-- Segmentos horizontales
	
	component deco
	Port (  
			   val : in  STD_LOGIC_VECTOR (4 downto 0);
            seg : out  STD_LOGIC_VECTOR (8 downto 0)
        );
	end component;	
begin

	
	
decodificador: deco port map(
		val	=>	 VALUE,
		seg 	=>	 seg
	);
	
	

  
DISPLAY: process(seg,HCOUNT,VCOUNT,POSX,POSY)
	variable px:integer;
	variable py: integer;
	variable SHX1 : INTEGER ;
	variable SHX2 : INTEGER ;
	variable SHY1 : INTEGER ;
	variable SHY2 : INTEGER ;
	variable SHY3 : INTEGER ;
	variable SHY4 : INTEGER ;
	variable SHY5 : INTEGER ;
	variable SHY6 : INTEGER ;
	-- Segmentos Verticales
	variable SVY1 : INTEGER ;
	variable SVY2 : INTEGER ;
	variable SVY3 : INTEGER ;
	variable SVY4 : INTEGER ;
	variable SVX1 : INTEGER ;
	variable SVX2 : INTEGER ;
	variable SVX3 : INTEGER ;
	variable SVX4 : INTEGER ;
	--nuevos segmentos
	variable svx5:	 integer;
	variable svx6:	 integer;
	variable svy7:	 integer;
	variable svy8:	 integer;
	variable vl: 	 integer;
	variable m: 	 integer;
	variable sd1: 	 integer;
	variable sd1u:	 integer;
	variable sd1d: 	 integer;
	
	begin
	px:=POSX;
	py:=POSY;
	
	 SHX1:= px;
	 SHX2 := px + DW;
	 SHY1 := py;
	 SHY2 := py + LW;
	 SHY3 := py + DL/2 - LW/2;
	 SHY4 := py + DL/2 + LW/2;
	 SHY5 := py + DL - LW;
	 SHY6 := py + DL;
	-- Segmentos Verticales
	 SVY1 :=py;
	 SVY2 := py + DL/2 + LW/2;
	 SVY3 := py + DL/2 - LW/2;
	 SVY4 := py + DL;
	 SVX1 := px;
	 SVX2 :=px + LW;
	 SVX3 :=px + DW - LW;
	 SVX4 := px + DW;
	--segmentos especiales
	svx5:= px+dw/2-lw/2;
	svx6:= px+dw/2+lw/2;
	
	svy7:= py+dl/2+lw/2;
	svy8:= py+dl/2+lw/2;
	
	
	vl:=conv_integer(vcount);
	m:=1;

	sd1  := -(vl-svy4)/m+svx1;
	sd1d :=  sd1-lw/2;
	sd1u :=  sd1 +lw/2;


	
	


	
		-- segmento a
		if(seg(6)='1' and (HCOUNT>=SHX1)and(HCOUNT<=SHX2)and(VCOUNT>=SHY1)and(VCOUNT<=SHY2)) then
			PAINT <= '1';
		-- segmento g
		elsif (seg(0)='1' and (HCOUNT>=SHX1)and(HCOUNT<=SHX2)and(VCOUNT>=SHY3)and(VCOUNT<=SHY4)) then
			PAINT <= '1';
		-- segmento d
		elsif (seg(3)='1' and (HCOUNT>=SHX1)and(HCOUNT<=SHX2)and(VCOUNT>=SHY5)and(VCOUNT<=SHY6)) then
			PAINT <= '1';
		-- segmento b
		elsif (seg(5)='1' and (HCOUNT>=SVX3)and(HCOUNT<=SVX4)and(VCOUNT>=SVY1)and(VCOUNT<=SVY2)) then
			PAINT <= '1';
		-- segmento c
		elsif (seg(4)='1' and (HCOUNT>=SVX3)and(HCOUNT<=SVX4)and(VCOUNT>=SVY3)and(VCOUNT<=SVY4)) then
			PAINT <= '1';
		-- segmento f
		elsif (seg(1)='1' and (HCOUNT>=SVX1)and(HCOUNT<=SVX2)and(VCOUNT>=SVY1)and(VCOUNT<=SVY2)) then
			PAINT <= '1';
		-- segmento e
		elsif (seg(2)='1' and (HCOUNT>=SVX1)and(HCOUNT<=SVX2)and(VCOUNT>=SVY3)and(VCOUNT<=SVY4)) then
			PAINT <= '1';
		
		--especial h
		elsif (seg(7)='1' and (hcount>=shx1) and (hcount<=shx2) and (vcount>=shy1) and (vcount<=shy6)) then
			PAINT <= '1';
		
		--especial i (diagonal ascendente)
		elsif (seg(8)='1' and (hcount>=sd1d) and (hcount<sd1u) and (vcount>= svy1) and (vcount <= svy4)) then
			PAINT <= '1';
		else
			PAINT <= '0';
		end if;
	end process;
end Behavioral;

