---------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity dec2bin is
Port ( 		Ep : in  STD_LOGIC_VECTOR (27 downto 0);
				Fp : in  STD_LOGIC_VECTOR (13 downto 0);
		     clk : in  STD_LOGIC; 											 
		   signo : in std_logic_vector(4 downto 0);  
			  rst : in  STD_LOGIC;
			 fout : out  STD_LOGIC_VECTOR (27 downto 0));
end dec2bin;
 
architecture Behavioral of dec2bin is


component decoIn is
    Port ( E  : in  STD_LOGIC_VECTOR (27 downto 0);                       --entrada entera 99999999
			  EF : in STD_LOGIC_VECTOR(15 downto 0);                         --entrada fraccion 9999
            o : out  STD_LOGIC_VECTOR (27 downto 0);                      --salida
			  en : in std_logic;                                             --esperar para dar salida
			signo: in STD_LOGIC_VECTOR (4 downto 0);                         --signo de entrada 
          rst : in  STD_LOGIC;
          clk : in  STD_LOGIC);
end component;

component Cdecimal is
    Port ( E : in  STD_LOGIC_VECTOR (13 downto 0);                      --entrada de la fraccion
           O : out  STD_LOGIC_VECTOR(15 downto 0);                      --salida decimal de la fraccion.
         clk : in  STD_LOGIC;
			  en: out std_logic;                                           --salida enable al componente decoIn solo hara operaciones cuando sea el enable 1
			  rst : in STD_LOGIC
           );
end component;

signal decimal: STD_LOGIC_VECTOR (15 downto 0);
signal reset : std_logic;
signal sigen: std_logic;

begin

conversor2deci : Cdecimal
port map(
		clk => clk,
		rst => rst,
		 E	 => Fp,
		en  => sigen,
		 O  => decimal
	);
union: decoIn
port map(
	E  => Ep,
	Ef => decimal,
	O  => fout,
	en => sigen,
 signo => signo,
	rst => rst,
	clk => clk
);

end Behavioral;

