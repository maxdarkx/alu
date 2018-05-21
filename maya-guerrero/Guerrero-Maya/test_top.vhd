library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
library work;
use work.array_machine.all;

entity test_top is
	port(
		clk: 			in  std_logic;						--reloj interno fpga, mirar manual
		rst: 			in  std_logic;						--boton reset
	   
		row_out0:   out std_logic;
	   row_out1:   out std_logic;
		row_out2:   out std_logic;
	   row_out3:   out std_logic;						--filas para el teclado
		
		column_in0: in  STD_LOGIC;					--columnas para el teclado
		column_in1: in  STD_LOGIC;
		column_in2: in  STD_LOGIC;
		column_in3: in  STD_LOGIC;
		led:			out std_logic_vector(7 downto 0);
		
		hs: 			out std_logic;						--senales para la pantalla
		vs: 			out std_logic;
		hcount1:		out std_logic_vector(10 downto 0); --para simulacion
		vcount1:		out std_logic_vector(10 downto 0); --para simulacion
		rgb:			out std_logic_vector(7 downto 0);
		
		frame_take: out std_logic --pulso de boton presionado, solo para simulacion
	);
	attribute loc: string;
	attribute loc of clk : signal is "B8"; -- Pin de reloj
	attribute loc of rst : signal is "B18"; -- Pulsador BTN0
	attribute loc of hs : signal is "T4"; -- Driver VGA
	attribute loc of vs	: signal is "U3"; -- Driver VGA
	attribute loc of row_out0: signal is "L15"; --PMOD JA para salida de datos arriba
	attribute loc of row_out1: signal is "K12"; --PMOD JA para salida de datos arriba
	attribute loc of row_out2: signal is "L17"; --PMOD JA para salida de datos arriba
	attribute loc of row_out3: signal is "M15"; --PMOD JA para salida de datos arriba
	attribute loc of column_in0: signal is "K13";
	attribute loc of column_in1: signal is "L16";
	attribute loc of column_in2: signal is "M14";
	attribute loc of column_in3: signal is "M16";
	attribute loc of rgb : signal is "R9,T8,R8,N8,P8,P6,U5,U4"; -- Driver VGA
	attribute loc of led : signal is "J14,J15,K15,K14,E17,P15,F4,R4";
end entity test_top;


architecture test_design of test_top is
	constant lw1:	integer:=5;		--tamano de los display
	constant dw1:	integer:=20;
	constant dl1:	integer:=20;

component display is					--display generico
	Generic (   
		LW: 		integer:=lw1;
		DW: 		integer:=dw1;
		DL: 		integer:=dl1
    ); 
   Port(
    	HCOUNT : 	in  std_logic_vector(10 downto 0);
      VCOUNT : 	in  std_logic_vector (10 downto 0);
		PAINT :  	out std_logic;
		VALUE :  	in  std_logic_vector (4  downto 0);
		POSX:			in  integer range 0 to 480;
		POSY: 		in  integer range 0 to 640
		
    );
end component;

component deco is		--decodificador para los datos a mostrar en pantalla
	Port(  
		val:	 in   std_logic_vector (4 downto 0);
      seg: 	 out  std_logic_vector (7 downto 0)
    );
end component;

component vga_ctrl_640x480_60Hz is --controlador vga
	port(
	   rst: 		in  std_logic;
	   clk: 		in  std_logic; 
	   rgb_in: 	in  std_logic_vector(7 downto 0);	--señal a mostrar(color)
	   HS:      out std_logic;								--sincronizacion horizontal
	   VS:      out std_logic;								--sincronizacion vertical
	   hcount:  out std_logic_vector(10 downto 0);	--contador horizontal
	   vcount:  out std_logic_vector(10 downto 0);	--contador vertical
	   rgb_out: out std_logic_vector(7 downto 0);	--R2R1R0 G2G1G0 B1B0
	   blank:   out std_logic								--estoy dentro o fuera de la pantalla?
	);
end component;

component debouncer is				--antirrebotes
    Port (  I  : in  STD_LOGIC;
			  rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
				O  : out  STD_LOGIC);
end component;


component new_driver is			--driver para el teclado matricial
	port(
			signal clk:	 in  std_logic;		
			signal rst: 	 in  std_logic;
			signal col1: 	 in  std_logic;		--columnas de entrada (boton en teclado matricial)
			signal col2: 	 in  std_logic;
			signal col3: 	 in  std_logic;
			signal col4: 	 in  std_logic;
			signal row_out0: out std_logic;		--filas de salida (hacia el teclado matricial)
			signal row_out1: out std_logic;
			signal row_out2: out std_logic;
			signal row_out3: out std_logic;
			
			signal salida:	 out std_logic_vector(4 downto 0);	--boton presionado en codigo codificado
			signal ready_in: out std_logic							--pulso de boton presionado
		);
end component;

component data_save is --maquina de estados para el guardado de los datos
	port(
		clk:			in    std_logic;						--reloj de entrada
		rst:			in 	std_logic;
		data_in: 	in	 	std_logic_vector(4 downto 0);		--bits de entrada directos del teclado numerico codificados
		button:   	in 	std_logic;								--los bits de entrada estan listos para ser leidos
		data_out1: 	out  	std_logic_vector(59 downto 0);	--el array de salida (num1) con los digitos ingresados
		data_out2: 	out  	std_logic_vector(59 downto 0);	--el array de salida (num2) con los digitos ingresados
		op_out:		out	std_logic_vector(4 downto 0)
	);
end component;

component digits_show is
	generic (
		dl: integer:= dl1;
		dh: integer:= dw1;
		lw: integer:= lw1
	);
	port(
		number1: 	 	in  std_logic_vector(59 downto 0);		--primer operando
		number2: 	 	in  std_logic_vector(59 downto 0);		--segundo operando
		number_sol: 	in  std_logic_vector(59 downto 0);		--solucion
		op:				in std_logic_vector(4 downto 0);			--operacion
		hcount:      	in  std_logic_vector(10 downto 0);		--contador horizontal de puntos en pantalla
	   vcount:      	in  std_logic_vector(10 downto 0);		--contador vertical de puntos en pantalla
		posx: 		 	out integer range 0 to 480;				--posicion horizontal en pantalla
		posy:		 	 	out integer range 0 to 640;				--posicion vertical en pantalla
		value:		 	out std_logic_vector(4 downto 0)			--dato actual a mostrar, codificado
	);
end component;
-- divisor de frecuencia
component clk1khz
	port(
		I : IN std_logic;
	 rst : IN std_logic;          
		O : OUT std_logic
		);
end component;

  	signal rgb_aux: std_logic_vector(7 downto 0);
  	signal paint0: std_logic:='0';
  	signal val: std_logic_vector(4 downto 0);
	signal col :std_logic_vector(3 downto 0);
  	signal b: std_logic;

  	signal numero1, numero2, numero_sol: std_logic_vector(59 downto 0):= (others=>'0');
  	signal tposx: integer range 0 to 640;
  	signal tposy: integer range 0 to 480;
  	signal val1: std_logic_vector(4 downto 0);
  	signal status: std_logic_vector(3 downto 0);
	signal op: std_logic_vector(4 downto 0);
	signal hcount2: std_logic_vector(10 downto 0);
	signal vcount2: std_logic_vector(10 downto 0);

	signal temp: STD_LOGIC := '0';
	signal cont: integer range 0 to 3 := 0;
	signal fila : STD_LOGIC_VECTOR (3 downto 0);
	signal salida: STD_LOGIC_VECTOR (4 downto 0);
	signal salidateclado : STD_LOGIC_VECTOR (4 downto 0);
	signal dato : STD_LOGIC;
	signal clk2: STD_LOGIC; 
	
begin
	hcount1<=hcount2;
	vcount1<=vcount2;
	
	
Key0: debouncer PORT MAP(
	   I => column_in0 ,
	   rst => rst,
	   clk => clk,
	   O => col(0)
);
Key1: debouncer PORT MAP(
	   I => column_in1 ,
	   rst => rst,
	   clk => clk,
	   O => col(1)
);
Key2: debouncer PORT MAP(
	   I => column_in2,
	   rst => rst,
	   clk => clk,
	   O => col(2)
);
Key3: debouncer PORT MAP(
	   I => column_in3 ,
	   rst => rst,
	   clk => clk,
	   O => col(3)
);

keyboard: new_driver 
	port map(
			clk 		=> clk,
			rst 		=> rst,
			col1 		=> col(0),
			col2 		=> col(1),
			col3 		=> col(2),
			col4 		=> col(3),
			row_out0 	=> row_out0,
			row_out1 	=> row_out1,
			row_out2 	=> row_out2,
			row_out3 	=> row_out3,
			salida 		=> val,
			ready_in 	=> b
		);
frame_take<=b;
sending_data: data_save
	port map
	(
		clk				=>clk,		
		rst				=>rst,
		data_in			=>val,
		button			=>b,
		data_out1		=>numero1, 
		data_out2		=>numero2, 
		op_out			=>op
	);

--numero1(4 downto 0)<=val;
--numero1(59 downto 5)<=(others=>'0');
--
--numero2(59 downto 0)<=(others=>'0');

display_data: digits_show
	port map
	(
		number1			=> numero1,
		number2			=> numero2,
		number_sol		=> numero_sol,
		op					=> op,
		hcount 			=> hcount2,
		vcount 			=> vcount2,
		posx 				=> tposx,
		posy 				=> tposy,
		value 			=> val1
	);

	
show: display
	Port map(
			HCOUNT 	=> hcount2,
         VCOUNT 	=> vcount2,
			PAINT 	=> paint0,
			VALUE 	=> val1,
			POSX	=> tposx,
			POSY	=> tposy
    );

videoOutput: vga_ctrl_640x480_60Hz
	port map(
	   rst 		=> rst,
	   clk 		=> clk,
	   rgb_in 	=> rgb_aux,
	   HS 		=> hs,
	   VS 		=> vs,
	   hcount 	=> hcount2,
	   vcount 	=> vcount2,
	   rgb_out 	=> rgb,
	   blank 	=> open 
	);


color: process(paint0)
	begin
	  if paint0='1' then
	    rgb_aux<="11111111";
	  else
	    rgb_aux<="00000000";
	  end if;
	end process; 
	
led(0)<=val(0);
led(1)<=val(1);
led(2)<=val(2);
led(3)<=val(3);
led(4)<=val(4);
led(5)<='0';
led(6)<='0';
led(7)<='0';

end architecture test_design;

