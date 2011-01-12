-- rc_test_pack.vhd
--
-- Project:	  MCE
-- Author:	  MA    
-- Organisation:  UBC
--
-- Description:
-- Package file for test module for readout card
-- 
-- Revision History:
--
-- $Log$
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

package rc_test_pack is

component rc_test_pll
port(inclk0 : in std_logic;
     c0 : out std_logic;
     c1 : out std_logic;
     c2 : out std_logic);
end component;

component rc_serial_dac_test_wrapper
port(rst_i     : in std_logic; 
     clk_i     : in std_logic; 
     clk_4_i   : in std_logic;
     en_i      : in std_logic; 
     mode      : in std_logic_vector(1 downto 0); 
     done_o    : out std_logic;
     dac_dat_o : out std_logic_vector (7 downto 0); 
     dac_ncs_o : out std_logic_vector (7 downto 0); 
     dac_clk_o : out std_logic_vector (7 downto 0)); 
end component;

component rc_parallel_dac_test_wrapper
port(rst_i      : in std_logic;
     clk_i      : in std_logic;
     en_i       : in std_logic;
     mode       : in std_logic_vector(1 downto 0);
     done_o     : out std_logic;
     dac0_dat_o : out std_logic_vector(13 downto 0);
     dac1_dat_o : out std_logic_vector(13 downto 0);
     dac2_dat_o : out std_logic_vector(13 downto 0);
     dac3_dat_o : out std_logic_vector(13 downto 0);
     dac4_dat_o : out std_logic_vector(13 downto 0);
     dac5_dat_o : out std_logic_vector(13 downto 0);
     dac6_dat_o : out std_logic_vector(13 downto 0);
     dac7_dat_o : out std_logic_vector(13 downto 0);
     dac_clk_o  : out std_logic_vector(7 downto 0));   
end component;

end rc_test_pack;
