----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:10:25 04/23/2018 
-- Design Name: 
-- Module Name:    ALU - Behavioral 
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


entity ALU is
    Port ( NA : in  STD_LOGIC_VECTOR (27 downto 0);
           NB : in  STD_LOGIC_VECTOR (27 downto 0);
           clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           mux : in  STD_LOGIC_VECTOR (4 downto 0);
           R : out  STD_LOGIC_VECTOR (27 downto 0));
end ALU;

architecture Behavioral of ALU is

component suma is
  Port( 	NA : in std_logic_vector(27 downto 0);
			NB : in std_logic_vector(27 downto 0);
			clk: in std_logic;
	  enable : in std_logic;
			rst: in std_logic;	
			 S : out std_logic_vector(27 downto 0));

end component;


 component resta is
	Port( NA : in std_logic_vector(27 downto 0);
			NB : in std_logic_vector(27 downto 0);
			clk: in std_logic;
	  enable : in std_logic;
			rst: in std_logic;	
			 S : out std_logic_vector(27 downto 0));
 end component;

component multi is
    Port (  NA: in std_logic_vector(27 downto 0);
            NB: in std_logic_vector(27 downto 0);
	 		  clk: in std_logic; 
			  rst: in std_logic;						
		enable : in std_logic;
				s: out std_logic_vector(27 downto 0));
end component;


component div is
    Port ( NA : in  STD_LOGIC_VECTOR (27 downto 0);
           NB : in  STD_LOGIC_VECTOR (27 downto 0);
			 clk : in STD_LOGIC ;
			  rst: in STD_LOGIC;
				 s: out  STD_LOGIC_VECTOR (27 downto 0);
		 enable : in std_logic);
           
end component;

	signal hsuma : std_logic;
	signal hresta: std_logic;
	signal hmulti: std_logic;
	signal hdiv: std_logic;
	signal outs: std_logic_vector (27 downto 0);
	signal outr: std_logic_vector (27 downto 0);
	signal outm: std_logic_vector (27 downto 0);
	signal outd: std_logic_vector (27 downto 0);

begin

 sumafloat: suma
	port map
	(	NA =>NA,
		NB =>NB,
		clk =>clk,
		enable =>hsuma, 
		rst =>rst, 
		s =>outs
	);
 restafloat: resta
	port map
	(	NA =>NA,
		NB =>NB,
		clk =>clk,
		enable =>hresta, 
		rst =>rst, 
		s =>outr
	);
 mulitplicafloat: multi
	port map
	(	NA =>NA,
		NB =>NB,
		clk =>clk,
		enable =>hmulti, 
		rst =>rst, 
		s =>outm
	);
  divifloat: div
	port map
	(	NA =>NA,
		NB =>NB,
		clk =>clk,
		enable =>hdiv, 
		rst =>rst, 
		s =>outd
	);


		hsuma <= '1' when mux = "11010" else
						 '0';
		hresta <= '1' when mux = "11011" else
						 '0';
		hmulti <= '1' when mux = "11100" else
						 '0';
		hdiv <= '1' when mux = "11101" else
						 '0';			 

		R <= outs when mux = "11010" else
			  outr when mux = "11011" else
			  outm when mux = "11100" else
			  outd when mux = "11101" else
			 "0000000000000000000000000000";
end Behavioral;

