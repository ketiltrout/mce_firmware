
library ieee;
use ieee.std_logic_1164.all;

package fibre_rx_pack is

--------------------------------------
-- fibre_rx
---------------------------------------

   component fibre_rx is
   port( 
      rst_i       : in     std_logic;
      clk_i       : in     std_logic;
      
      nrx_rdy_i   : in     std_logic;
      rvs_i       : in     std_logic;
      rso_i       : in     std_logic;
      rsc_nrd_i   : in     std_logic;  
      rx_data_i   : in     std_logic_vector (7 downto 0);
      cmd_ack_i   : in     std_logic;                          -- command acknowledge
      
      cmd_code_o  : out    std_logic_vector (15 downto 0);     -- command code  
      card_id_o   : out    std_logic_vector (15 downto 0);     -- card id
      param_id_o  : out    std_logic_vector (15 downto 0);     -- parameter id
      num_data_o  : out    std_logic_vector (7 downto 0);      -- number of valid 32 bit data words
      cmd_data_o  : out    std_logic_vector (31 downto 0);     -- 32bit valid data word
      cksum_err_o : out    std_logic;                          -- checksum error flag
      cmd_rdy_o   : out    std_logic;                          -- command ready flag (checksum passed)
      data_clk_o  : out    std_logic                           -- data clock
    );

   end component;

end fibre_rx_pack;
