-- Copyright (c) 2003 SCUBA-2 Project
--                  All Rights Reserved
--
--  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
--  The copyright notice above does not evidence any
--  actual or intended publication of such source code.
--
--  SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
--  REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
--  MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
--  PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
--  THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
--
-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.
--
-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1
--
-- $Id: clk_card.vhd,v 1.17 2005/03/04 18:26:27 bburger Exp $
--
-- Project:       SCUBA-2
-- Author:        Greg Dennis
-- Organization:  UBC
--
-- Description:
-- Clock card top-level file
--
-- Revision history:
-- $Log: clk_card.vhd,v $
-- Revision 1.17  2005/03/04 18:26:27  bburger
-- Bryce:  incremented the build number
--
-- Revision 1.16  2005/03/04 03:45:58  bburger
-- Bryce:  fixed bugs associated with ret_dat_s and ret_dat
--
-- Revision 1.15  2005/02/21 22:27:53  mandana
-- added firmware revision CC_REVISION (fw_rev)
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;
use sys_param.data_types_pack.all;

library work;
use work.dispatch_pack.all;
use work.leds_pack.all;
use work.fw_rev_pack.all;
use work.sync_gen_pack.all;
use work.frame_timing_pack.all;
use work.issue_reply_pack.all;
use work.cc_reset_pack.all;
use work.ret_dat_wbs_pack.all;


entity clk_card is
   port(
      -- PLL input:
      inclk      : in std_logic;
      rst_n      : in std_logic;
      
      -- LVDS interface:
      lvds_cmd   : out std_logic;
      lvds_sync  : out std_logic;
      lvds_spare : out std_logic;
      lvds_clk   : out std_logic;
      lvds_reply_ac_a  : in std_logic;  
      lvds_reply_ac_b  : in std_logic;
      lvds_reply_bc1_a  : in std_logic;
      lvds_reply_bc1_b  : in std_logic;
      lvds_reply_bc2_a  : in std_logic;
      lvds_reply_bc2_b  : in std_logic;
      lvds_reply_bc3_a  : in std_logic;
      lvds_reply_bc3_b  : in std_logic;
      lvds_reply_rc1_a  : in std_logic;
      lvds_reply_rc1_b  : in std_logic;
      lvds_reply_rc2_a  : in std_logic;
      lvds_reply_rc2_b  : in std_logic;
      lvds_reply_rc3_a  : in std_logic; 
      lvds_reply_rc3_b  : in std_logic;  
      lvds_reply_rc4_a  : in std_logic; 
      lvds_reply_rc4_b  : in std_logic;
      
      -- DV interface:
      dv_pulse_fibre  : in std_logic;
      dv_pulse_bnc    : in std_logic;
      
      -- TTL interface:
      ttl_nrx1   : in std_logic;
      ttl_tx1    : out std_logic;
      ttl_txena1 : out std_logic;
      
      ttl_nrx2   : in std_logic;
      ttl_tx2    : out std_logic;
      ttl_txena2 : out std_logic;

      ttl_nrx3   : in std_logic;
      ttl_tx3    : out std_logic;
      ttl_txena3 : out std_logic;

      -- eeprom interface:
      eeprom_si  : in std_logic;
      eeprom_so  : out std_logic;
      eeprom_sck : out std_logic;
      eeprom_cs  : out std_logic;
      
      -- miscellaneous ports:
      red_led    : out std_logic;
      ylw_led    : out std_logic;
      grn_led    : out std_logic;
      dip_sw3    : in std_logic;
      dip_sw4    : in std_logic;
      wdog       : out std_logic;
      slot_id    : in std_logic_vector(3 downto 0);
      
      -- debug ports:
      mictor_o    : out std_logic_vector(15 downto 1);
      mictorclk_o : out std_logic;
      mictor_e    : out std_logic_vector(15 downto 1);
      mictorclk_e : out std_logic;
      rs232_rx    : in std_logic;
      rs232_tx    : out std_logic;
      
      -- interface to HOTLINK fibre receiver      
      fibre_rx_clk       : out std_logic;
      fibre_rx_data      : in std_logic_vector (7 downto 0);  
      fibre_rx_rdy       : in std_logic;                      
      fibre_rx_rvs       : in std_logic;                      
      fibre_rx_status    : in std_logic;                      
      fibre_rx_sc_nd     : in std_logic;                      
      fibre_rx_ckr       : in std_logic;                      
      
      -- interface to hotlink fibre transmitter      
      fibre_tx_clk       : out std_logic;
      fibre_tx_data      : out std_logic_vector (7 downto 0);
      fibre_tx_ena       : out std_logic;  
      fibre_tx_sc_nd     : out std_logic
   );     
end clk_card;

architecture top of clk_card is

-- The REVISION format is RRrrBBBB where 
--               RR is the major revision number
--               rr is the minor revision number
--               BBBB is the build number
constant CC_REVISION: std_logic_vector (31 downto 0) := X"01010001";

-- reset
signal rst           : std_logic;
signal sc_rst      : std_logic;    -- reset signal generated by Linux PC issuing a 'special character' byte down the fibre

-- clocks
signal clk           : std_logic;
signal mem_clk       : std_logic;
signal comm_clk      : std_logic;
signal fibre_clk     : std_logic;

-- sync_gen interface
signal sync_num   : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);

-- ret_dat_wbs interface
signal start_seq_num : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal stop_seq_num  : std_logic_vector(WB_DATA_WIDTH-1 downto 0);

-- wishbone bus (from master)
signal data : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal addr : std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
signal tga  : std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
signal we   : std_logic;
signal stb  : std_logic;
signal cyc  : std_logic;

-- wishbone bus (from slaves)
signal slave_data          : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal slave_ack           : std_logic;
signal led_data            : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal led_ack             : std_logic;
signal sync_gen_data       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal sync_gen_ack        : std_logic;
signal frame_timing_data   : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal frame_timing_ack    : std_logic;
signal slave_err           : std_logic;
signal fw_rev_data         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal fw_rev_ack          : std_logic;
signal ret_dat_data        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal ret_dat_ack         : std_logic;
      
-- lvds_tx interface
signal sync       : std_logic;
signal cmd        : std_logic;

-- lvds_rx interface
signal lvds_reply_cc_a     : std_logic;

-- For testing
signal debug             : std_logic_vector(31 downto 0);
signal fib_tx_data       : std_logic_vector (7 downto 0);
signal fib_tx_ena        : std_logic;

component cc_pll
   port(
      inclk0 : in std_logic;
      e2     : out std_logic;
      c0     : out std_logic;
      c1     : out std_logic;
      c2     : out std_logic;
      c3     : out std_logic;
      e0     : out std_logic;
      e1     : out std_logic 
   );
end component;

begin

   mictor_o(8 downto 1) <= fibre_rx_data;
   mictor_o(9) <= fibre_rx_rdy;
   
   mictor_e(8 downto 1) <= fib_tx_data;
   mictor_e(9) <= fib_tx_ena;
   
   fibre_tx_data <= fib_tx_data;
   fibre_tx_ena <= fib_tx_ena;
   
   -- This is an active-low enable signal for the TTL transmitter.  This line is used as a BClr.
   ttl_txena1 <= '0';
   -- ttl_tx1 is an active-low reset transmitted accross the bus backplane to clear FPGA registers (BClr)
   ttl_tx1    <= not sc_rst;
   
   rst        <= (not rst_n) or sc_rst;

   with addr select
      slave_data <=
         fw_rev_data       when FW_REV_ADDR,              
         led_data          when LED_ADDR,
         sync_gen_data     when USE_DV_ADDR | ROW_LEN_ADDR | NUM_ROWS_ADDR,
         ret_dat_data      when RET_DAT_S_ADDR,
         (others => '0')   when others;
         
   with addr select
      slave_ack <= 
         fw_rev_ack        when FW_REV_ADDR,
         led_ack           when LED_ADDR,
         sync_gen_ack      when USE_DV_ADDR | ROW_LEN_ADDR | NUM_ROWS_ADDR,
         ret_dat_ack       when RET_DAT_S_ADDR,
         '0'               when others;
         
   with addr select
      slave_err <= 
         '0'              when FW_REV_ADDR | LED_ADDR | USE_DV_ADDR | ROW_LEN_ADDR | NUM_ROWS_ADDR | RET_DAT_S_ADDR, --| SAMPLE_DLY_ADDR | SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR | RESYNC_ADDR | FLX_LP_INIT_ADDR,
         '1'              when others;

   pll0: cc_pll
      port map(
         inclk0 => inclk,
         c0     => clk,
         c1     => mem_clk,
         c2     => comm_clk,
         c3     => fibre_clk,
         e0     => fibre_tx_clk, 
         e1     => fibre_rx_clk,   
         e2     => lvds_clk 
      );
            
   lvds_cmd <= cmd;
   cmd0: dispatch
      port map(
         lvds_cmd_i   => cmd,
         lvds_reply_o => lvds_reply_cc_a,
         
         --  Global signals
         clk_i      => clk,
         comm_clk_i => comm_clk,
         rst_i      => rst,
            
         -- Wishbone interface
         dat_o  => data,
         addr_o => addr,
         tga_o  => tga,
         we_o   => we,
         stb_o  => stb,
         cyc_o  => cyc,
         dat_i  => slave_data,   
         ack_i  => slave_ack,
         err_i  => slave_err, 
     
         wdt_rst_o => wdog,
         slot_i    => slot_id
      );
            
   led0: leds
      port map(   
         --  Global signals
         clk_i => clk,
         rst_i => rst,
            
         -- Wishbone interface
         dat_i  => data,
         addr_i => addr,
         tga_i  => tga,
         we_i   => we,
         stb_i  => stb,
         cyc_i  => cyc,
         dat_o  => led_data,
         ack_o  => led_ack,
      
         power  => grn_led,
         status => ylw_led,
         fault  => red_led
      );

   fw_rev_slave: fw_rev
      generic map( REVISION => CC_REVISION)
      port map(
         clk_i  => clk,
         rst_i  => rst,

         dat_i  => data,
         addr_i => addr,
         tga_i  => tga,
         we_i   => we,
         stb_i  => stb,
         cyc_i  => cyc,
         dat_o  => fw_rev_data,
         ack_o  => fw_rev_ack
    );
   
   lvds_sync <= sync;
   sync_gen0: sync_gen
      port map( 
         -- Inputs/Outputs
         dv_i       => dv_pulse_fibre,
         sync_o     => sync,
         sync_num_o => sync_num,
      
         -- Wishbone interface
         dat_i       => data,         
         addr_i      => addr,           
         tga_i       => tga,
         we_i        => we,          
         stb_i       => stb,            
         cyc_i       => cyc,       
         dat_o       => sync_gen_data,          
         ack_o       => sync_gen_ack,
      
         --  Global signals
         clk_i       => clk,
         mem_clk_i   => mem_clk,
         rst_i       => rst
      );

   issue_reply0: issue_reply
      port map(   
         -- For testing
         debug_o    => debug,
   
         -- global signals
         rst_i             => rst,
         clk_i             => clk,
         comm_clk_i        => comm_clk,
         mem_clk_i         => mem_clk,
         
         -- bus backplane interface
         lvds_reply_ac_a   => lvds_reply_ac_a,   
         lvds_reply_bc1_a  => lvds_reply_bc1_a,
         lvds_reply_bc2_a  => lvds_reply_bc2_a,
         lvds_reply_bc3_a  => lvds_reply_bc3_a,
         lvds_reply_rc1_a  => lvds_reply_rc1_a,
         lvds_reply_rc2_a  => lvds_reply_rc2_a,
         lvds_reply_rc3_a  => lvds_reply_rc3_a, 
         lvds_reply_rc4_a  => lvds_reply_rc4_a,
         lvds_reply_cc_a   => lvds_reply_cc_a,

         -- fibre receiver interface 
         fibre_clkr_i      => fibre_rx_ckr,  
         rx_data_i         => fibre_rx_data,
         nRx_rdy_i         => fibre_rx_rdy,
         rvs_i             => fibre_rx_rvs,
         rso_i             => fibre_rx_status,
         rsc_nRd_i         => fibre_rx_sc_nd,
         cksum_err_o       => open,
    
         -- fibre transmitter interface
         tx_data_o         => fib_tx_data,     -- byte of data to be transmitted
         tsc_nTd_o         => fibre_tx_sc_nd,    -- hotlink tx special char/ data sel
         nFena_o           => fib_tx_ena,      -- hotlink tx enable
   
         -- 25MHz clock for fibre_tx_control
         fibre_clkw_i      => fibre_clk,
        
         -- lvds_tx interface
         lvds_cmd_o        => cmd,

         -- ret_dat_wbs interface:
         start_seq_num_i   => start_seq_num,
         stop_seq_num_i    => stop_seq_num,
         
         -- sync_gen interface
         sync_pulse_i      => sync,
         sync_number_i     => sync_num
      );
      
      
   cc_reset0: cc_reset
      port map ( 
      nRx_rdy_i  =>  fibre_rx_rdy,
      rsc_nRd_i  =>  fibre_rx_sc_nd,
      rso_i      =>  fibre_rx_status,
      rvs_i      =>  fibre_rx_rvs,
      rx_data_i  =>  fibre_rx_data,
      reset_o    =>  sc_rst     
   );

   ret_dat_param: ret_dat_wbs       
      port map
      (
         -- cmd_translator interface:
         start_seq_num_o => start_seq_num,
         stop_seq_num_o  => stop_seq_num,

         -- global interface
         clk_i           => clk,
         rst_i           => rst, 
         
         -- wishbone interface:
         dat_i           => data,         
         addr_i          => addr,         
         tga_i           => tga,
         we_i            => we,          
         stb_i           => stb,          
         cyc_i           => cyc,       
         dat_o           => ret_dat_data,
         ack_o           => ret_dat_ack
      );
      
end top;