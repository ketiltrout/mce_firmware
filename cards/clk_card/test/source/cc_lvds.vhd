library ieee;
use ieee.std_logic_1164.all;

entity cc_lvds is
port(inclk : in std_logic;

     dip_sw2 : in std_logic;
     dip_sw3 : in std_logic;
     dip_sw4 : in std_logic;
     dip_sw7 : in std_logic;
     dip_sw8 : in std_logic;
     
     lvds_rx0a : in std_logic;
     lvds_rx0b : in std_logic;
     lvds_rx1a : in std_logic;
     lvds_rx1b : in std_logic;
     lvds_rx2a : in std_logic;
     lvds_rx2b : in std_logic;
     lvds_rx3a : in std_logic;
     lvds_rx3b : in std_logic;
     lvds_rx4a : in std_logic;
     lvds_rx4b : in std_logic;
     lvds_rx5a : in std_logic;
     lvds_rx5b : in std_logic;
     lvds_rx6a : in std_logic;
     lvds_rx6b : in std_logic;
     lvds_rx7a : in std_logic;
     lvds_rx7b : in std_logic;

     lvds_cmd : out std_logic;
     lvds_sync : out std_logic;
     lvds_spare : out std_logic;

     lvds_clk : out std_logic);
end cc_lvds;

architecture behav of cc_lvds is

component cc_lvds_pll
   port(inclk0 : in std_logic;
        c0 : out std_logic;
        e0 : out std_logic);
end component;

signal sel : std_logic_vector(4 downto 0);
signal clk : std_logic;

begin
   clk_gen : cc_lvds_pll
   port map(inclk0 => inclk,
            c0 => clk,
            e0 => lvds_clk);

   sel <= dip_sw2 & dip_sw3 & dip_sw4 & dip_sw7 & dip_sw8;

   with sel select
      lvds_cmd <= lvds_rx0a when "00000",
                  lvds_rx0b when "00001",
                  lvds_rx1a when "00010",
                  lvds_rx1b when "00011",
                  lvds_rx2a when "00100",
                  lvds_rx2b when "00101",
                  lvds_rx3a when "00110",
                  lvds_rx3b when "00111",
                  lvds_rx4a when "01000",
                  lvds_rx4b when "01001",
                  lvds_rx5a when "01010",
                  lvds_rx5b when "01011",
                  lvds_rx6a when "01100",
                  lvds_rx6b when "01101",
                  lvds_rx7a when "01110",
                  lvds_rx7b when "01111",
                  clk when others;

   with sel select
      lvds_sync <= lvds_rx0a when "00000",
                   lvds_rx0b when "00001",
                   lvds_rx1a when "00010",
                   lvds_rx1b when "00011",
                   lvds_rx2a when "00100",
                   lvds_rx2b when "00101",
                   lvds_rx3a when "00110",
                   lvds_rx3b when "00111",
                   lvds_rx4a when "01000",
                   lvds_rx4b when "01001",
                   lvds_rx5a when "01010",
                   lvds_rx5b when "01011",
                   lvds_rx6a when "01100",
                   lvds_rx6b when "01101",
                   lvds_rx7a when "01110",
                   lvds_rx7b when "01111",
                   clk when others;

   with sel select
      lvds_spare <= lvds_rx0a when "00000",
                    lvds_rx0b when "00001",
                    lvds_rx1a when "00010",
                    lvds_rx1b when "00011",
                    lvds_rx2a when "00100",
                    lvds_rx2b when "00101",
                    lvds_rx3a when "00110",
                    lvds_rx3b when "00111",
                    lvds_rx4a when "01000",
                    lvds_rx4b when "01001",
                    lvds_rx5a when "01010",
                    lvds_rx5b when "01011",
                    lvds_rx6a when "01100",
                    lvds_rx6b when "01101",
                    lvds_rx7a when "01110",
                    lvds_rx7b when "01111",
                    clk when others;
end behav;