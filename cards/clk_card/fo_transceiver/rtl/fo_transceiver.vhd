
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.rx_fifo_pack.all;
use work.tx_fifo_pack.all;
use work.rx_control_pack.all;
use work.tx_control_pack.all;
use work.rx_protocol_fsm_pack.all;
use work.simple_reply_fsm_pack.all;


entity fo_transceiver is
   port( 
      rst_i        : in     std_logic;
      clk_i        : in     std_logic;
      
      rx_data_i   : in     std_logic_vector (7 DOWNTO 0);
      nRx_rdy_i   : in     std_logic;
      rvs_i       : in     std_logic;
      rso_i       : in     std_logic;
      rsc_nRd_i   : in     std_logic;  
      
      nTrp_i      : in     std_logic;
      ft_clkw_i   : in     std_logic; 
      
      cmd_ack_i   : in     std_logic;
      
      tx_data_o   : out    std_logic_vector (7 DOWNTO 0);      
      tsc_nTd_o   : out    std_logic;
      nFena_o     : out    std_logic
  
    );


end fo_transceiver;



-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.rx_control_pack.all;
use work.tx_control_pack.all;
use work.rx_fifo_pack.all;
use work.tx_fifo_pack.all;
use work.rx_protocol_fsm_pack.all;

architecture behav of fo_transceiver is

   -- Internal signal declarations
   
   signal rx_fr       : std_logic;
   signal rx_fw       : std_logic;
   signal rx_fe       : std_logic;
   signal rx_ff       : std_logic;
   signal rxd         : std_logic_vector(7 downto 0);
   signal rx_data     : std_logic_vector(7 downto 0);
  
   signal tx_fw       : std_logic;
   signal tx_fr       : std_logic; 
   signal tx_fe       : std_logic;
   signal tx_ff       : std_logic;
   signal txd         : std_logic_vector (7 downto 0);            
   signal tx_data     : std_logic_vector (7 downto 0);
 
     
   signal nRx_rdy     : std_logic;
   signal rsc_nRd     : std_logic;
   signal rso         : std_logic;
   signal rvs         : std_logic;
   
   signal ft_clkw     : std_logic;
   signal nTrp        : std_logic;
   signal tsc_nTd     : std_logic;
   signal nFena       : std_logic;
  
   
   signal cksum_err   : std_logic;
   signal cmd_rdy     : std_logic;


   signal card_id     : std_logic_vector (15 downto 0);
   signal param_id    : std_logic_vector (15 downto 0);
   signal cmd_code    : std_logic_vector (15 downto 0);
   signal cmd_data    : std_logic_vector (31 downto 0);
   signal data_clk    : std_logic;
   signal num_data    : std_logic_vector (7 downto 0);
 
   signal cmd_ack     : std_logic;
      
begin

   rx_data   <= rx_data_i;
   nRx_rdy   <= nRx_rdy_i;
   rvs       <= rvs_i;
   rso       <= rso_i;
   rsc_nRd   <= rsc_nRd_i; 
   cmd_ack   <= cmd_ack_i; 
      
   nTrp      <= nTrp_i;
   ft_clkW   <= ft_clkw_i;   
  
   tx_data_o <= tx_data;      
   tsc_nTd_o <= tsc_nTd;
   nFena_o   <= nFena;
   
    

   -- Instance port mappings.
   I0 : rx_fifo
      generic map (
         fifo_size => 256
      )
      port map (
         rst_i       => rst_i,
         rx_fr_i     => rx_fr,
         rx_fw_i     => rx_fw,
         rx_data_i   => rx_data,
         rx_fe_o     => rx_fe,
         rx_ff_o     => rx_ff,
         rxd_o       => rxd
   );

   I1: rx_control 
      port map ( 
         nRx_rdy_i  =>   nRx_rdy,
         rsc_nRd_i  =>   rsc_nRd,
         rso_i      =>   rso,
         rvs_i      =>   rvs,
         rx_ff_i    =>   rx_ff,
         rx_fw_o    =>   rx_fw
   );
 
 
   I2: rx_protocol_fsm
      port map ( 
         rst_i       =>   rst_i,
         clk_i       =>   clk_i,
         rx_fe_i     =>   rx_fe,
         rxd_i       =>   rxd,
         cmd_ack_i   =>   cmd_ack,
         
         cmd_code_o  =>   cmd_code,
         card_id_o   =>   card_id,
         param_id_o  =>   param_id,
         num_data_o  =>   num_data,
         cmd_data_o  =>   cmd_data,
         cksum_err_o =>   cksum_err,
         cmd_rdy_o   =>   cmd_rdy,
         data_clk_o  =>   data_clk,
         rx_fr_o     =>   rx_fr
      );
      
     I4 : simple_reply_fsm
       port map (
          rst_i       => rst_i,
          clk_i       => clk_i,
          cmd_code_i  => cmd_code,
          cksum_err_i => cksum_err,
          cmd_rdy_i   => cmd_rdy,
          tx_ff_i     => tx_ff,
          txd_o       => txd,
          tx_fw_o     => tx_fw
      );
           
    I5 : tx_control 
       port map( 
          ft_clkw_i   => ft_clkw,  
          nTrp_i      => nTrp,
          tx_fe_i     => tx_fe,
          tsc_nTd_o   => tsc_nTd,
          nFena_o     => nFena,
          tx_fr_o     => tx_fr
     );


    I6 : tx_fifo 
       generic map( 
           fifo_size => 32
       )
       port map( 
          rst_i       => rst_i,
          tx_fr_i     => tx_fr,
          tx_fw_i     => tx_fw,
          txd_i       => txd,
          tx_fe_o     => tx_fe,
          tx_ff_o     => tx_ff,
          tx_data_o   => tx_data
   );

END behav;