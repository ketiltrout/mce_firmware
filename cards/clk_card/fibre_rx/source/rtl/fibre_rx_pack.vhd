
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.issue_reply_pack.all;


package fibre_rx_pack is

   constant RX_FIFO_DATA_WIDTH   : integer := 8;       -- size of data words in fibre receive FIFO
   constant RX_FIFO_ADDR_SIZE    : integer := 9;       -- size of address bus in fibre receive FIFO 


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
      rx_data_i   : in     std_logic_vector (RX_FIFO_DATA_WIDTH-1 downto 0);
      cmd_ack_i   : in     std_logic;                                           -- command acknowledge
      
      cmd_code_o  : out    std_logic_vector (CMD_CODE_BUS_WIDTH-1 downto 0);    -- command code  
      card_id_o   : out    std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);   -- card id
      param_id_o  : out    std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);      -- parameter id
      num_data_o  : out    std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);   -- number of valid 32 bit data words
      cmd_data_o  : out    std_logic_vector (DATA_BUS_WIDTH-1 downto 0);        -- 32bit valid data word
      cksum_err_o : out    std_logic;                                           -- checksum error flag
      cmd_rdy_o   : out    std_logic;                                           -- command ready flag (checksum passed)
      data_clk_o  : out    std_logic                                            -- data clock
    );

   end component;


--------------------------------------
-- fibre_rx_fifo
---------------------------------------

   component fibre_rx_fifo 
      generic(addr_size : Positive);                                             -- read/write address size
      port(                                                                      -- note: fifo size is 2**addr_size
         rst_i     : in     std_logic;                                           -- global reset
         rx_fr_i   : in     std_logic;                                           -- fifo read request
         rx_fw_i   : in     std_logic;                                           -- fifo write request
         rx_data_i : in     std_logic_vector (RX_FIFO_DATA_WIDTH-1 DOWNTO 0);    -- data input
         rx_fe_o   : out    std_logic;                                           -- fifo empty flag
         rx_ff_o   : out    std_logic;                                           -- fifo full flag
         rxd_o     : out    std_logic_vector (RX_FIFO_DATA_WIDTH-1 DOWNTO 0)     -- data output
      );

   end component;

--------------------------------------
-- fibre_rx_protocol
---------------------------------------

component fibre_rx_protocol 
   port( 
      rst_i       : in     std_logic;                                             -- reset
      clk_i       : in     std_logic;                                             -- clock 
      rx_fe_i     : in     std_logic;                                             -- receive fifo empty flag
      rxd_i       : in     std_logic_vector (RX_FIFO_DATA_WIDTH-1 downto 0);      -- receive data byte 
      cmd_ack_i   : in     std_logic;                                             -- command acknowledge

      cmd_code_o  : out    std_logic_vector (CMD_CODE_BUS_WIDTH-1 downto 0);      -- command code  
      card_id_o   : out    std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);     -- card id
      param_id_o  : out    std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);        -- parameter id
      num_data_o  : out    std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);     -- number of valid 32 bit data words
      cmd_data_o  : out    std_logic_vector (DATA_BUS_WIDTH-1 downto 0);          -- 32bit valid data word
      cksum_err_o : out    std_logic;                                             -- checksum error flag
      cmd_rdy_o   : out    std_logic;                                             -- command ready flag (checksum passed)
      data_clk_o  : out    std_logic;                                             -- data clock
      rx_fr_o     : out    std_logic                                              -- receive fifo read request
   );
   end component;

--------------------------------------
-- fibre_rx_control
---------------------------------------

   component fibre_rx_control
      port( 
         nRx_rdy_i : in     std_logic;
         rsc_nRd_i : in     std_logic;
         rso_i     : in     std_logic;
         rvs_i     : in     std_logic;
         rx_ff_i   : in     std_logic;
         rx_fw_o   : out    std_logic
   );
   end component;


end fibre_rx_pack;
