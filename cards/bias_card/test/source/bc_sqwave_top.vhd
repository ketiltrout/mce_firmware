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
-- $Id: bc_sqwave_top.vhd,v 1.1 2005/05/02 16:18:52 mandana Exp $
--
-- Project:       SCUBA-2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- bc_sqwave top level based on Bias Card top-level file
--
-- Revision history:
-- 
-- $Log: bc_sqwave_top.vhd,v $
-- Revision 1.1  2005/05/02 16:18:52  mandana
-- *** empty log message ***
--
-- Revision 1.15  2005/04/20 20:54:51  mandana
-- build revision 0005, frame_timing updated
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;
use sys_param.data_types_pack.all;

library work;
use work.bias_card_pack.all;
use work.all_cards_pack.all;
use work.bc_dac_ctrl_pack.all;

entity bias_card_test is
   port(
 
      -- PLL input:
      inclk      : in std_logic;
      rst_n      : in std_logic;
      
      -- LVDS interface:
      lvds_cmd   : in std_logic;
      lvds_sync  : in std_logic;
      lvds_spare : in std_logic;
      lvds_txa   : out std_logic;
      lvds_txb   : out std_logic;
      
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
                  
      -- dac interface:
      dac_ncs       : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
      dac_sclk      : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
      dac_data      : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);      
      lvds_dac_ncs  : out std_logic;
      lvds_dac_sclk : out std_logic;
      lvds_dac_data : out std_logic;
      dac_nclr      : out std_logic; -- add to tcl file
      
      -- miscellaneous ports:
      red_led    : out std_logic;
      ylw_led    : out std_logic;
      grn_led    : out std_logic;
      dip_sw3    : in std_logic;
      dip_sw4    : in std_logic;
      wdog       : out std_logic;
      slot_id    : in std_logic_vector(3 downto 0);
      
      -- debug ports:
      test       : inout std_logic_vector(16 downto 3);
      mictor     : out std_logic_vector(31 downto 0);
      mictorclk  : out std_logic_vector(2 downto 1);
      rs232_rx   : in std_logic;
      rs232_tx   : out std_logic
   );
end bias_card_test;

architecture top of bias_card_test is

-- The REVISION format is RRrrBBBB where 
--               RR is the major revision number
--               rr is the minor revision number
--               BBBB is the build number
constant BC_REVISION: std_logic_vector (31 downto 0) := X"01010005";

signal dac_ncs_temp : std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
signal dac_sclk_temp: std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
signal dac_data_temp: std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);      

-- clocks
signal clk      : std_logic;
signal clk_n    : std_logic;
signal comm_clk : std_logic;

signal rst      : std_logic;

-- wishbone bus (from master)
signal data : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal addr : std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
signal tga  : std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
signal we   : std_logic;
signal stb  : std_logic;
signal cyc  : std_logic;

-- wishbone bus (from slaves)
signal slave_data        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal slave_ack         : std_logic;
signal led_data          : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal led_ack           : std_logic;
signal bc_dac_data       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal bc_dac_ack        : std_logic;
signal frame_timing_data : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal frame_timing_ack  : std_logic;
signal slave_err         : std_logic;
signal fw_rev_data          : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal fw_rev_ack           : std_logic;

-- frame_timing interface
signal update_bias : std_logic; 

signal debug       : std_logic_vector (31 downto 0);


-- spi if
signal spi_write_start           : std_logic;             -- trigger signal to start writing data over the spi interface
signal spi_write_start_slow      : std_logic;
signal spi_pdat                  : std_logic_vector(15 downto 0);   
signal spi_clk                   : std_logic;
signal spi_clk_slow              : std_logic;
signal sync_cnt                  : integer;
signal sync_cnt_prev             : integer;

component bc_pll
port(inclk0 : in std_logic;
     c0 : out std_logic;
     c1 : out std_logic;
     c2 : out std_logic;
     c3 : out std_logic);
end component;

component bc_sqwave_spi_if is
      port (
         rst_i                       : in      std_logic;    
         clk_i                       : in      std_logic;  
         spi_start_i                 : in      std_logic;
         spi_pdat_i                  : in      std_logic_vector(15 downto 0);
         spi_csb_o                   : out     std_logic;
         spi_sclk_o                  : out     std_logic;
         spi_sdat_o                  : out     std_logic         
      );
   end component bc_sqwave_spi_if;

  ---------------------------------------------------------------------------------
   -- Clock domain crossing component
   ---------------------------------------------------------------------------------   
   
   component bc_sqwave_domain_crosser is
      generic (
         NUM_TIMES_FASTER            : integer := 2
      );
         
      port (
         rst_i                       : in      std_logic;
	 clk_slow                    : in      std_logic;
	 clk_fast                    : in      std_logic;
	 input_fast                  : in      std_logic;
	 output_slow                 : out     std_logic
      );  
   end component bc_sqwave_domain_crosser;

begin
   
   -- Active low enable signal for the transmitter on the card.  With '1' it is disabled.
   -- The transmitter is disabled because the Clock Card is driving this line.
   ttl_txena1 <= '1';
   -- The ttl_nrx1 signal is inverted on the Card, thus the FPGA sees an active-high signal.
   rst <= (not rst_n) or (ttl_nrx1);
   
   mictor   <= debug;
   test (4) <= dac_ncs_temp(0);
   test (6) <= dac_data_temp(0);
   test (8) <= dac_sclk_temp(0);
      
   --dac_ncs <= dac_ncs_temp;
   --dac_data <= dac_data_temp;
   --dac_sclk <= dac_sclk_temp;
   
   pll0: bc_pll
   port map(
      inclk0 => inclk,
      c0 => clk,
      c1 => comm_clk,
      c2 => clk_n,
      c3 => spi_clk
   );
            
   cmd0: dispatch
      port map(
         clk_i                      => clk,
         comm_clk_i                 => comm_clk,
         rst_i                      => rst,         
         
         lvds_cmd_i                 => lvds_cmd,
         lvds_replya_o              => lvds_txa,
     
         dat_o                      => data,
         addr_o                     => addr,
         tga_o                      => tga,
         we_o                       => we,
         stb_o                      => stb,
         cyc_o                      => cyc,
         dat_i                      => slave_data,
         ack_i                      => slave_ack,
         err_i                      => slave_err,      
         wdt_rst_o                  => wdog,
         slot_i                     => slot_id,
         dip_sw3                    => dip_sw3,
         dip_sw4                    => dip_sw4
      );
            
   leds_slave: leds
      port map(
         clk_i                      => clk,
         rst_i                      => rst,

         dat_i                      => data,
         addr_i                     => addr,
         tga_i                      => tga,
         we_i                       => we,
         stb_i                      => stb,
         cyc_i                      => cyc,
         dat_o                      => led_data,
         ack_o                      => led_ack,
         
         power                      => grn_led,
         status                     => ylw_led,
         fault                      => red_led
      );
   
            
   bc_dac_ctrl_slave: bc_dac_ctrl
      port map(
         -- DAC hardware interface:
         -- There are 32 DAC channels, thus 32 serial data/cs/clk lines.
         flux_fb_data_o             => dac_data_temp,      
         flux_fb_ncs_o              => dac_ncs_temp,     
         flux_fb_clk_o              => dac_sclk_temp,     
                                       
         bias_data_o                => lvds_dac_data,
         bias_ncs_o                 => lvds_dac_ncs,
         bias_clk_o                 => lvds_dac_sclk,
         
         dac_nclr_o                 => dac_nclr,
         
         -- wishbone interface:
         dat_i                      => data,
         addr_i                     => addr,
         tga_i                      => tga, 
         we_i                       => we,  
         stb_i                      => stb, 
         cyc_i                      => cyc, 
         dat_o                      => bc_dac_data,
         ack_o                      => bc_dac_ack,
         
         -- frame_timing signals
         update_bias_i              => update_bias,
         
         -- Global Signals      
         clk_i                      => clk,
         rst_i                      => rst,
         debug                      => debug
      );                         
                                 
   frame_timing_slave: frame_timing
      port map(
         dac_dat_en_o               => open,
         adc_coadd_en_o             => open,
         restart_frame_1row_prev_o  => open,
         restart_frame_aligned_o    => open,
         restart_frame_1row_post_o  => open,
         initialize_window_o        => open,
         
         row_switch_o               => open,
         row_en_o                   => open,
            
         update_bias_o              => update_bias,
         
         dat_i                      => data,
         addr_i                     => addr,
         tga_i                      => tga,
         we_i                       => we,
         stb_i                      => stb,
         cyc_i                      => cyc,
         dat_o                      => frame_timing_data,
         ack_o                      => frame_timing_ack,        
         clk_i                      => clk,
         clk_n_i                    => clk_n,
         rst_i                      => rst,
         sync_i                     => lvds_sync
      );
   
   with addr select
      slave_data <=
         fw_rev_data       when FW_REV_ADDR,     
         led_data          when LED_ADDR,
         bc_dac_data       when FLUX_FB_ADDR | BIAS_ADDR,
         frame_timing_data when ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR | SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR | RESYNC_ADDR | FLX_LP_INIT_ADDR,
         (others => '0')   when others;

   with addr select
      slave_ack <= 
         fw_rev_ack       when FW_REV_ADDR,
         led_ack          when LED_ADDR,
         bc_dac_ack       when FLUX_FB_ADDR | BIAS_ADDR,
         frame_timing_ack when ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR | SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR | RESYNC_ADDR | FLX_LP_INIT_ADDR,
         '0'              when others;
         
   with addr select
      slave_err <= 
         '0'              when FW_REV_ADDR | LED_ADDR | FLUX_FB_ADDR | BIAS_ADDR | ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR | SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR | RESYNC_ADDR | FLX_LP_INIT_ADDR,
         '1'              when others;        
   
   gen_spi32: for k in 0 to 31 generate
      i_bc_sqwave_spi_if : bc_sqwave_spi_if
         port map (
            rst_i                       => rst,
            clk_i                       => spi_clk_slow,
            spi_start_i                 => spi_write_start_slow,
            spi_pdat_i                  => spi_pdat,
            spi_csb_o                   => dac_ncs(k),
            spi_sclk_o                  => dac_sclk(k),
            spi_sdat_o                  => dac_data(k)
         );
  end generate gen_spi32;          
     
   i_bc_sqwave_domain_crosser : bc_sqwave_domain_crosser
      generic map (
         NUM_TIMES_FASTER            => 4
      )
         
      port map (
         rst_i                       => rst,
         clk_slow                    => spi_clk_slow,
         clk_fast                    => clk,
         input_fast                  => spi_write_start,
         output_slow                 => spi_write_start_slow
      );     
   


   process(rst, clk)
   begin
      if rst = '1' then
        spi_clk <= '0';
        spi_clk_slow <= '0';
      elsif clk'event and clk = '1' then
        spi_clk <= not spi_clk;
        if spi_clk = '1' then
          spi_clk_slow <= not spi_clk_slow;
        end if;
      end if;
   end process;
   
   
  
   process(rst, clk)
   begin
     if rst = '1' then
       sync_cnt <= 0;
       sync_cnt_prev <= 0;
       spi_pdat <= (others => '0');
       spi_write_start <= '0';
     elsif clk'event and clk = '1' then
       
       sync_cnt_prev <= sync_cnt;

       if (sync_cnt = 20 and sync_cnt_prev = 19) or 
          (sync_cnt = 40 and sync_cnt_prev = 39) then
         spi_write_start <= '1';
       else
         spi_write_start <= '0';
       end if;      

       
       if (lvds_sync = '1') then 
         
         if (sync_cnt <= 20) then
           spi_pdat <= conv_std_logic_vector(10000, 16);
           sync_cnt <= sync_cnt + 1;
         elsif (sync_cnt <= 40) then
           spi_pdat <= conv_std_logic_vector(10100, 16);
           sync_cnt <= sync_cnt + 1;
         else
           sync_cnt <= 0;
         end if;
                   
       end if;
       
     end if;
   end process;
           
           
   
   
end top;