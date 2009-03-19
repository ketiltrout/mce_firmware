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
--
-- readout_card.vhd
--
-- Project:       SCUBA-2
-- Author:        David Atkinson
-- Organisation:  ATC
--
-- Description:
-- Readout Card top-level file
--
-- Revision history:
-- 
-- $Log: readout_card_stratix_iii.vhd,v $
-- Revision 1.1  2009/01/23 23:49:36  bburger
-- BB:  Adding new files for Readout Card rev. C.  Also regenerated the following RAM blocks for the new revision:  pid_ram, ram_14x64, wbs_fb_storage.
--
--
-----------------------------------------------------------------------------
-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

--library altera;
--use altera.altera_europa_support_lib.all;

--library altera_mf;
--use altera_mf.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library work;
use work.readout_card_pack.all;
use work.all_cards_pack.all;
use work.adc_sample_coadd_pack.all;

entity readout_card_stratix_iii is
generic(
   CARD            : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := READOUT_CARD_1);
port(
   -- Global Interface
   rst_n           : in std_logic;

   -- PLL Interface
   inclk           : in std_logic;
   inclk_ddr       : in std_logic;
   
   -- ADC Interface for Readout Card Rev. C 
   -- How do I instantiate and LVDS receiver?
   adc0_lvds_p : in std_logic; 
   adc1_lvds_p : in std_logic; 
   adc2_lvds_p : in std_logic; 
   adc3_lvds_p : in std_logic; 
   adc4_lvds_p : in std_logic; 
   adc5_lvds_p : in std_logic; 
   adc6_lvds_p : in std_logic; 
   adc7_lvds_p : in std_logic; 
   adc_fco_p   : in std_logic;
   adc_clk_p   : out std_logic; 
   adc_sclk    : out std_logic;
   adc_sdio    : inout std_logic; 
   adc_csb_n   : out std_logic; 
   adc_pdwn    : out std_logic;
   adc_dco_p   : in std_logic;

   -- DAC Interface
   dac_FB1_dat     : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   dac_FB2_dat     : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   dac_FB3_dat     : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   dac_FB4_dat     : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   dac_FB5_dat     : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   dac_FB6_dat     : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   dac_FB7_dat     : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   dac_FB8_dat     : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   dac_FB_clk      : out std_logic_vector(7 downto 0);  -- Note number of channels are hard coded
   
   -- Sa_bias and Offset_ctrl Interface
   dac_clk         : out std_logic_vector(7 downto 0);  -- Note number of channels are hard coded
   dac_dat         : out std_logic_vector(7 downto 0);  -- Note number of channels are hard coded
   bias_dac_ncs    : out std_logic_vector(7 downto 0);  -- Note number of channels are hard coded
   offset_dac_ncs  : out std_logic_vector(7 downto 0);  -- Note number of channels are hard coded
   
   -- LVDS interface:
   lvds_cmd        : in std_logic;
   lvds_sync       : in std_logic;
   lvds_spare      : in std_logic;
   lvds_txa        : out std_logic;
   lvds_txb        : out std_logic;

   -- TTL interface:
   ttl_dir1        : out std_logic;
   ttl_in1         : in std_logic;
   ttl_out1        : out std_logic;
   
   ttl_dir2        : out std_logic;
   ttl_in2         : in std_logic;
   ttl_out2        : out std_logic;
   
   ttl_dir3        : out std_logic;
   ttl_in3         : in std_logic;
   ttl_out3        : out std_logic;

   -- LED Interface
   red_led         : out std_logic;
   ylw_led         : out std_logic;
   grn_led         : out std_logic;
   
   -- miscellaneous ports
   dip_sw3         : in std_logic;
   dip_sw4         : in std_logic;
   wdog            : out std_logic;

   -- slot_id interface  
   slot_id         : in std_logic_vector(3 downto 0);

   -- silicon_id/temperature interface
   card_id         : inout std_logic;
   
   -- fpga_thermo serial interface
   smb_clk         : out std_logic;
   smb_nalert      : in std_logic;
   smb_data        : inout std_logic;      

   -- DDR2 interface
   -- outputs:
   mem_addr : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
   mem_ba : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
   mem_cas_n : OUT STD_LOGIC;
   mem_cke : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
   mem_clk : INOUT STD_LOGIC_VECTOR (0 DOWNTO 0);
   mem_clk_n : INOUT STD_LOGIC_VECTOR (0 DOWNTO 0);
   mem_cs_n : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
   mem_dm : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
   mem_dq : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
   mem_dqs : INOUT STD_LOGIC_VECTOR (1 DOWNTO 0);
   mem_dqsn : INOUT STD_LOGIC_VECTOR (1 DOWNTO 0);
   mem_odt : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
   mem_ras_n : OUT STD_LOGIC;
   mem_we_n : OUT STD_LOGIC;
   pnf : OUT STD_LOGIC;
   pnf_per_byte : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
   test_complete : OUT STD_LOGIC;
   test_status : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)

);  
end readout_card_stratix_iii;

architecture top of readout_card_stratix_iii is

   -- The REVISION format is RRrrBBBB where 
   --               RR is the major revision number
   --               rr is the minor revision number
   --               BBBB is the build number
   
   constant RC_REVISION : std_logic_vector (31 downto 0) := X"05000001"; -- 12b pid pars , sa_bias/offset updated only when modified
                                                                        -- fixed gainpid/adc_offset/flx_quanta-read failure upon power-up (prior to reset)
                                                                        -- removed quartus.ini from synth directory
   -- Global signals
   signal clk                     : std_logic; -- system clk
   signal comm_clk                : std_logic; -- communication clk
   signal spi_clk                 : std_logic; -- spi clk
   signal rst                     : std_logic;
   signal clk_n                   : std_logic;
   signal samp_clk                : std_logic; -- ADC sampling clock
   signal serial_clk              : std_logic;
   signal sync_clk1               : std_logic;
   signal sync_clk2               : std_logic;
   signal sync_clk3               : std_logic;

   -- Readout Card Rev. C ADC Signals
   signal clk0        : std_logic;
   signal clk1        : std_logic;
   signal clk2        : std_logic;
   signal clk3        : std_logic;
   signal clk4        : std_logic;
   signal locked      : std_logic;
   
   signal adc_dat     : std_logic_vector(7 downto 0);
   signal serdes_dat0 : std_logic_vector(55 downto 0);
   signal serdes_dat1 : std_logic_vector(55 downto 0);
   signal serdes_dat2 : std_logic_vector(55 downto 0);
   signal serdes_dat3 : std_logic_vector(111 downto 0);
   signal serdes_dat4 : std_logic_vector(111 downto 0);
   signal serdes_dat5 : std_logic_vector(111 downto 0);
   signal serdes_dat6 : std_logic_vector(111 downto 0);
   
   signal adc_dat0    : std_logic_vector(13 downto 0);
   signal adc_dat1    : std_logic_vector(13 downto 0);
   signal adc_dat2    : std_logic_vector(13 downto 0);
   signal adc_dat3    : std_logic_vector(13 downto 0);
   signal adc_dat4    : std_logic_vector(13 downto 0);
   signal adc_dat5    : std_logic_vector(13 downto 0);
   signal adc_dat6    : std_logic_vector(13 downto 0);
   signal adc_dat7    : std_logic_vector(13 downto 0);
  
   -- Dispatch interface signals 
   signal dispatch_dat_out        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal dispatch_addr_out       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
   signal dispatch_tga_out        : std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
   signal dispatch_we_out         : std_logic;
   signal dispatch_stb_out        : std_logic;
   signal dispatch_cyc_out        : std_logic;
   signal dispatch_err_in         : std_logic;
   signal dispatch_lvds_txa       : std_logic;
   
   -- WBS MUX output siganls
   signal dispatch_dat_in         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal dispatch_ack_in         : std_logic;
   
   -- frame_timing output signals
   signal dac_dat_en              : std_logic;
   signal adc_coadd_en            : std_logic;
   signal restart_frame_1row_prev : std_logic;
   signal restart_frame_aligned   : std_logic;
   signal restart_frame_1row_post : std_logic;
   signal initialize_window       : std_logic;
   signal fltr_rst                : std_logic;
   signal row_switch              : std_logic;
   signal dat_ft                  : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal ack_ft                  : std_logic;
   
   -- flux_loop output signals
   signal dat_frame               : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal dat_fb                  : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal ack_frame               : std_logic;
   signal ack_fb                  : std_logic;
   signal sa_bias_dac_spi_ch0     : std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
   signal sa_bias_dac_spi_ch1     : std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
   signal sa_bias_dac_spi_ch2     : std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
   signal sa_bias_dac_spi_ch3     : std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
   signal sa_bias_dac_spi_ch4     : std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
   signal sa_bias_dac_spi_ch5     : std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
   signal sa_bias_dac_spi_ch6     : std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
   signal sa_bias_dac_spi_ch7     : std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
   signal offset_dac_spi_ch0      : std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
   signal offset_dac_spi_ch1      : std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
   signal offset_dac_spi_ch2      : std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
   signal offset_dac_spi_ch3      : std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
   signal offset_dac_spi_ch4      : std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
   signal offset_dac_spi_ch5      : std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
   signal offset_dac_spi_ch6      : std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
   signal offset_dac_spi_ch7      : std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
   
   -- LED output signals
   signal ack_led                 : std_logic;
   signal dat_led                 : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   
   -- all_cards regs (including fw_rev, card_type, slot_id, scratch) signals
   signal all_cards_data          : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal all_cards_ack           : std_logic;
   signal all_cards_err           : std_logic;
   
   -- id_thermo signals
   signal id_thermo_data          : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal id_thermo_ack           : std_logic;
   signal id_thermo_err           : std_logic;
   
   -- fpga_thermo signals
   signal fpga_thermo_data        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal fpga_thermo_ack         : std_logic;
   signal fpga_thermo_err         : std_logic;
   
   -- frame_timing : wbs_frame_data interface
   signal num_rows                : integer;
   signal num_rows_reported       : integer;
   signal num_cols_reported       : integer;
   
   -- DDR2 signals as copied from micro_ctrl_example_top.vhd generated from MegaWizard DDR2 SDRAM CTRL HP 8.1
   signal internal_mem_addr :  STD_LOGIC_VECTOR (12 DOWNTO 0);
   signal internal_mem_ba :  STD_LOGIC_VECTOR (1 DOWNTO 0);
   signal internal_mem_cas_n :  STD_LOGIC;
   signal internal_mem_cke :  STD_LOGIC_VECTOR (0 DOWNTO 0);
   signal internal_mem_cs_n :  STD_LOGIC_VECTOR (0 DOWNTO 0);
   signal internal_mem_dm :  STD_LOGIC_VECTOR (1 DOWNTO 0);
   signal internal_mem_odt :  STD_LOGIC_VECTOR (0 DOWNTO 0);
   signal internal_mem_ras_n :  STD_LOGIC;
   signal internal_mem_we_n :  STD_LOGIC;
   signal internal_pnf :  STD_LOGIC;
   signal internal_pnf_per_byte :  STD_LOGIC_VECTOR (7 DOWNTO 0);
   signal internal_test_complete :  STD_LOGIC;
   signal internal_test_status :  STD_LOGIC_VECTOR (7 DOWNTO 0);
   signal mem_aux_full_rate_clk :  STD_LOGIC;
   signal mem_aux_half_rate_clk :  STD_LOGIC;
   signal mem_local_addr :  STD_LOGIC_VECTOR (22 DOWNTO 0);
   signal mem_local_be :  STD_LOGIC_VECTOR (7 DOWNTO 0);
   signal mem_local_col_addr :  STD_LOGIC_VECTOR (9 DOWNTO 0);
   signal mem_local_cs_addr :  STD_LOGIC;
   signal mem_local_rdata :  STD_LOGIC_VECTOR (63 DOWNTO 0);
   signal mem_local_rdata_valid :  STD_LOGIC;
   signal mem_local_read_req :  STD_LOGIC;
   signal mem_local_ready :  STD_LOGIC;
   signal mem_local_size :  STD_LOGIC;
   signal mem_local_wdata :  STD_LOGIC_VECTOR (63 DOWNTO 0);
   signal mem_local_write_req :  STD_LOGIC;
   signal oct_ctl_rs_value :  STD_LOGIC_VECTOR (13 DOWNTO 0);
   signal oct_ctl_rt_value :  STD_LOGIC_VECTOR (13 DOWNTO 0);
   signal phy_clk :  STD_LOGIC;
   signal reset_phy_clk_n :  STD_LOGIC;
   signal tie_high :  STD_LOGIC;
   signal tie_low :  STD_LOGIC;

begin

   -- Default assignments for ADC control pins
   adc_sclk  <= '0';  --: out std_logic;
   adc_sdio  <= '0';  --: inout std_logic; 
   adc_csb_n <= '0';  --: out std_logic; 
   adc_pdwn  <= '0';  --: out std_logic;   
   
   -- Default assignments to get rid of synthesis warnings.
   ttl_out1 <= '0';
   ttl_dir2 <= '0';
   ttl_out2 <= '0';
   ttl_dir3 <= '0';
   ttl_out3 <= '0';
   
   -- Active low enable signal for the transmitter on the card.  With '1' it is disabled.
   -- The transmitter is disabled because the Clock Card is driving this line.
   ttl_dir1 <= '1';
   -- The ttl_in1 signal is inverted on the Card, thus the FPGA sees an active-high signal.
   rst <= (not rst_n) or (ttl_in1);
 
   -- This line will be used by clock card to check card presence
   --lvds_txb <= '0';

   ----------------------------------------------------------------------------
   -- PLL Instantiation
   ----------------------------------------------------------------------------
   i_rc_pll: rc_pll_stratix_iii
   port map (
      inclk0 => inclk,
      c0     => clk,
      c1     => open,
      c2     => comm_clk,
      c3     => spi_clk,
      c4     => clk_n,
      c5     => adc_clk_p
   );
   
   ----------------------------------------------------------------------------
   -- ADC Receiver Instantiation.  
   ----------------------------------------------------------------------------
   -- This ADC receiver logic has a 2-cycle latency in it's throughput (i.e. Two 50-MHz clock cycles).
   -- That is, it takes 2 clock cycles from the start of the first bit received to the expression of the whole 14-bit word on adc_dat0..7
   -- For information on this logic, see:  http://www.altera.com/support/examples/functionality/pll-clocking-stratix3.html
   -- In addition to this, the ADC has an inherant latency of 8 clock cycles + t_fco (~2.3ns) + t_board (~ 0.5ns)
   -- For information on this, see p. of http://www.analog.com/static/imported-files/data_sheets/AD9252.pdf
   -- Thus, the total latency from ADC to servo input is = 2 + 8 + 2.3ns/20ns + 0.5/20ns = 10.14 clock cycles
   -- Therefore we must wait 11 clock cycles from the beginning of the frame period to be sampling data from that frame period.
   -- This has to be built into the firmware in the same manner that the 4-cycle delay is built in for Rev A/B.
   i_adc_pll: adc_pll_stratix_iii
   port map (
      -- adc_fco_p is the framing signal from the ADC
      inclk0 => adc_fco_p,
      -- clk0: 700.00 MHz, phase shift = -180.00 degrees, duty cycle = 50.00%, fully compensated
      c0     => clk0,
      -- clk1: 100.00 MHz, phase shift = +128.57 degrees, duty cycle = 21.42%
      c1     => clk1,
      -- clk2: 050.00 MHz, phase shift = +295.71 degrees, duty cycle = 50.00%  [Note: phase shift = (9/28)*360]
      c2     => clk2,
      -- clk3: 050.00 MHz, phase shift = +115.71 degrees, duty cycle = 50.00%  [Note: phase shift = ([9+14]/28)*360]
      c3     => clk3,
      -- clk4: 050.00 MHz, phase shift = +141.42 degrees, duty cycle = 50.00%  [Note: phase shift = (11/28)*360]
      c4     => clk4,
      locked => locked
   );

   adc_dat <= adc7_lvds_p & adc6_lvds_p & adc5_lvds_p & adc4_lvds_p & adc3_lvds_p & adc2_lvds_p & adc1_lvds_p & adc0_lvds_p;
   i_adc_serdes: adc_serdes 
   port map (
      rx_enable  => clk1, -- This is always enabled to see what the running output of the deserializer is.
      rx_in      => adc_dat,    
      rx_inclock => clk0,    
      rx_out     => serdes_dat0   
   );
  
   i_adc_serdes_flipflop1: flipflop_56
   port map (
      clock      => clk2,
      data       => serdes_dat0,
      q          => serdes_dat1
   );
   
   i_adc_serdes_flipflop2: flipflop_56
   port map (
      clock      => clk3,
      data       => serdes_dat0,
      q          => serdes_dat2
   );   
   
   serdes_dat3 <= 
      serdes_dat1(55 downto 49) & serdes_dat2(55 downto 49) &
      serdes_dat1(48 downto 42) & serdes_dat2(48 downto 42) &
      serdes_dat1(41 downto 35) & serdes_dat2(41 downto 35) &
      serdes_dat1(34 downto 28) & serdes_dat2(34 downto 28) &
      serdes_dat1(27 downto 21) & serdes_dat2(27 downto 21) &
      serdes_dat1(20 downto 14) & serdes_dat2(20 downto 14) &
      serdes_dat1(13 downto  7) & serdes_dat2(13 downto  7) &
      serdes_dat1(6  downto  0) & serdes_dat2(6  downto  0);

   i_adc_serdes_flipflop3: flipflop_112
   port map (
      clock      => clk4,
      data       => serdes_dat3,
      q          => serdes_dat4
   );   
   
   ---------------------------------------------------------
   -- Double Synchronizer for ADC Data
   ---------------------------------------------------------
   process(rst, clk_n)
   begin
      if(rst = '1') then
         serdes_dat5 <= (others => '0');
      elsif(clk_n'event and clk_n = '1') then
         serdes_dat5 <= serdes_dat4;
      end if;
   end process;

   process(rst, clk)
   begin
      if(rst = '1') then
         serdes_dat6 <= (others => '0');
      elsif(clk'event and clk = '1') then
         serdes_dat6 <= serdes_dat5;
      end if;
   end process;
   
   adc_dat0 <=  serdes_dat6(13  downto 0);
   adc_dat1 <=  serdes_dat6(27  downto 14);
   adc_dat2 <=  serdes_dat6(41  downto 28);
   adc_dat3 <=  serdes_dat6(55  downto 42);
   adc_dat4 <=  serdes_dat6(69  downto 56);
   adc_dat5 <=  serdes_dat6(83  downto 70);
   adc_dat6 <=  serdes_dat6(97  downto 84);
   adc_dat7 <=  serdes_dat6(111 downto 98);

   ----------------------------------------------------------------------------
   -- Dispatch Instantiation
   ----------------------------------------------------------------------------
   i_dispatch: dispatch
   port map (
      clk_i        => clk,
      comm_clk_i   => comm_clk,
      rst_i        => rst,
      lvds_cmd_i   => lvds_cmd,
      lvds_replya_o => lvds_txa,
      lvds_replyb_o => lvds_txb,
      dat_o        => dispatch_dat_out,
      addr_o       => dispatch_addr_out,
      tga_o        => dispatch_tga_out,
      we_o         => dispatch_we_out,
      stb_o        => dispatch_stb_out,
      cyc_o        => dispatch_cyc_out,
      dat_i        => dispatch_dat_in,
      ack_i        => dispatch_ack_in,
      err_i        => dispatch_err_in,
      wdt_rst_o    => wdog,
      slot_i       => slot_id,
      dip_sw3      => '1',
      dip_sw4      => '1'
   );


  --lvds_txa <= dispatch_lvds_txa;-- when dip_sw3 = '1' else '1';  -- multiplexer for disabling the RC output during test of issue_reply
  
  -----------------------------------------------------------------------------
  -- Output MUX to Dispatch:
  -- 
  -- 1. dispatch_addr_out selects which wbs is sending its output to the
  -- dispatch.  The defulat connection is to data=0.
  --
  -- 2. Acknowlege is ORing of the acknowledge signals from all Admins.
  --
  -- 3. Generate dispatch_err_in signal based on dispatch_addr_out.
  -----------------------------------------------------------------------------
   with dispatch_addr_out select dispatch_dat_in <=
      dat_fb           when GAINP0_ADDR | GAINP1_ADDR | GAINP2_ADDR |
                            GAINP3_ADDR | GAINP4_ADDR | GAINP5_ADDR |
                            GAINP6_ADDR | GAINP7_ADDR |
                            GAINI0_ADDR | GAINI1_ADDR | GAINI2_ADDR |
                            GAINI3_ADDR | GAINI4_ADDR | GAINI5_ADDR |
                            GAINI6_ADDR | GAINI7_ADDR |
                            GAIND0_ADDR | GAIND1_ADDR | GAIND2_ADDR |
                            GAIND3_ADDR | GAIND4_ADDR | GAIND5_ADDR |
                            GAIND6_ADDR | GAIND7_ADDR |
                            FLX_QUANTA0_ADDR | FLX_QUANTA1_ADDR | FLX_QUANTA2_ADDR | FLX_QUANTA3_ADDR |
                            FLX_QUANTA4_ADDR | FLX_QUANTA5_ADDR | FLX_QUANTA6_ADDR | FLX_QUANTA7_ADDR |
                            ADC_OFFSET0_ADDR | ADC_OFFSET1_ADDR |
                            ADC_OFFSET2_ADDR | ADC_OFFSET3_ADDR |
                            ADC_OFFSET4_ADDR | ADC_OFFSET5_ADDR |
                            ADC_OFFSET6_ADDR | ADC_OFFSET7_ADDR |
                            FILT_COEF_ADDR | SERVO_MODE_ADDR | RAMP_STEP_ADDR |
                            RAMP_AMP_ADDR  | FB_CONST_ADDR   | RAMP_DLY_ADDR  |
                            SA_BIAS_ADDR   | OFFSET_ADDR     | EN_FB_JUMP_ADDR,
      dat_frame        when DATA_MODE_ADDR | RET_DAT_ADDR | CAPTR_RAW_ADDR | READOUT_ROW_INDEX_ADDR |
                            READOUT_COL_INDEX_ADDR | READOUT_PRIORITY_ADDR,
      dat_led          when LED_ADDR,
      dat_ft           when ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR |
                            SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR |
                            RESYNC_ADDR | FLX_LP_INIT_ADDR | FLTR_RST_ADDR | NUM_COLS_REPORTED_ADDR | NUM_ROWS_REPORTED_ADDR,
      all_cards_data   when FW_REV_ADDR |CARD_TYPE_ADDR | SCRATCH_ADDR | SLOT_ID_ADDR,     
      id_thermo_data   when CARD_ID_ADDR | CARD_TEMP_ADDR,                      
      fpga_thermo_data when FPGA_TEMP_ADDR,
      (others => '0')  when others;        -- default to zero

--   dispatch_ack_in <= ack_fb or ack_frame or ack_led or ack_ft or all_cards_ack; --or id_thermo_ack or fpga_thermo_ack;
   with dispatch_addr_out select dispatch_ack_in <=
      ack_fb          when GAINP0_ADDR | GAINP1_ADDR | GAINP2_ADDR |
                           GAINP3_ADDR | GAINP4_ADDR | GAINP5_ADDR |
                           GAINP6_ADDR | GAINP7_ADDR |
                           GAINI0_ADDR | GAINI1_ADDR | GAINI2_ADDR |
                           GAINI3_ADDR | GAINI4_ADDR | GAINI5_ADDR |
                           GAINI6_ADDR | GAINI7_ADDR |
                           GAIND0_ADDR | GAIND1_ADDR | GAIND2_ADDR |
                           GAIND3_ADDR | GAIND4_ADDR | GAIND5_ADDR |
                           GAIND6_ADDR | GAIND7_ADDR |
                           FLX_QUANTA0_ADDR | FLX_QUANTA1_ADDR | FLX_QUANTA2_ADDR | FLX_QUANTA3_ADDR |
                           FLX_QUANTA4_ADDR | FLX_QUANTA5_ADDR | FLX_QUANTA6_ADDR | FLX_QUANTA7_ADDR |
                           ADC_OFFSET0_ADDR | ADC_OFFSET1_ADDR |
                           ADC_OFFSET2_ADDR | ADC_OFFSET3_ADDR |
                           ADC_OFFSET4_ADDR | ADC_OFFSET5_ADDR |
                           ADC_OFFSET6_ADDR | ADC_OFFSET7_ADDR |
                           FILT_COEF_ADDR | SERVO_MODE_ADDR | RAMP_STEP_ADDR |
                           RAMP_AMP_ADDR  | FB_CONST_ADDR   | RAMP_DLY_ADDR  |
                           SA_BIAS_ADDR   | OFFSET_ADDR     | EN_FB_JUMP_ADDR,
      ack_frame       when DATA_MODE_ADDR | RET_DAT_ADDR | CAPTR_RAW_ADDR | READOUT_ROW_INDEX_ADDR |
                           READOUT_COL_INDEX_ADDR | READOUT_PRIORITY_ADDR,
      ack_led         when LED_ADDR,
      ack_ft          when ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR |
                           SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR |
                           RESYNC_ADDR | FLX_LP_INIT_ADDR | FLTR_RST_ADDR | NUM_COLS_REPORTED_ADDR | NUM_ROWS_REPORTED_ADDR,
      all_cards_ack   when FW_REV_ADDR |CARD_TYPE_ADDR | SCRATCH_ADDR | SLOT_ID_ADDR,
      id_thermo_ack   when CARD_ID_ADDR | CARD_TEMP_ADDR,
      fpga_thermo_ack when FPGA_TEMP_ADDR,
      '0'             when others;        -- default to zero

   with dispatch_addr_out select dispatch_err_in <=
      '0'             when GAINP0_ADDR | GAINP1_ADDR | GAINP2_ADDR |
                           GAINP3_ADDR | GAINP4_ADDR | GAINP5_ADDR |
                           GAINP6_ADDR | GAINP7_ADDR |
                           GAINI0_ADDR | GAINI1_ADDR | GAINI2_ADDR |
                           GAINI3_ADDR | GAINI4_ADDR | GAINI5_ADDR |
                           GAINI6_ADDR | GAINI7_ADDR |
                           GAIND0_ADDR | GAIND1_ADDR | GAIND2_ADDR |
                           GAIND3_ADDR | GAIND4_ADDR | GAIND5_ADDR |
                           GAIND6_ADDR | GAIND7_ADDR |
                           FLX_QUANTA0_ADDR | FLX_QUANTA1_ADDR | FLX_QUANTA2_ADDR | FLX_QUANTA3_ADDR |
                           FLX_QUANTA4_ADDR | FLX_QUANTA5_ADDR | FLX_QUANTA6_ADDR | FLX_QUANTA7_ADDR |
                           ADC_OFFSET0_ADDR | ADC_OFFSET1_ADDR |
                           ADC_OFFSET2_ADDR | ADC_OFFSET3_ADDR |
                           ADC_OFFSET4_ADDR | ADC_OFFSET5_ADDR |
                           ADC_OFFSET6_ADDR | ADC_OFFSET7_ADDR |
                           FILT_COEF_ADDR | SERVO_MODE_ADDR | RAMP_STEP_ADDR |
                           RAMP_AMP_ADDR  | FB_CONST_ADDR   | RAMP_DLY_ADDR  |
                           SA_BIAS_ADDR   | OFFSET_ADDR     | EN_FB_JUMP_ADDR |
                           DATA_MODE_ADDR | RET_DAT_ADDR | CAPTR_RAW_ADDR | READOUT_ROW_INDEX_ADDR |
                           READOUT_COL_INDEX_ADDR | READOUT_PRIORITY_ADDR |
                           LED_ADDR |
                           ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR |
                           SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR |
                           RESYNC_ADDR | FLX_LP_INIT_ADDR | FLTR_RST_ADDR | NUM_COLS_REPORTED_ADDR | NUM_ROWS_REPORTED_ADDR,
      all_cards_err   when FW_REV_ADDR |CARD_TYPE_ADDR | SCRATCH_ADDR | SLOT_ID_ADDR,
      id_thermo_err   when CARD_ID_ADDR | CARD_TEMP_ADDR,
      fpga_thermo_err when FPGA_TEMP_ADDR,
      '1'             when others;        
   
   ----------------------------------------------------------------------------
   -- Frame_timing Instantiation
   ----------------------------------------------------------------------------
   i_frame_timing: frame_timing
   port map (
      dac_dat_en_o              => dac_dat_en,
      adc_coadd_en_o            => adc_coadd_en,
      restart_frame_1row_prev_o => restart_frame_1row_prev,
      restart_frame_aligned_o   => restart_frame_aligned,
      restart_frame_1row_post_o => restart_frame_1row_post,
      initialize_window_o       => initialize_window,
      fltr_rst_o                => fltr_rst,
      num_rows_o                => num_rows,
      num_rows_reported_o       => num_rows_reported,
      num_cols_reported_o       => num_cols_reported,
      
      row_switch_o              => row_switch,
      row_en_o                  => open,
      
      update_bias_o             => open,
      
      dat_i                     => dispatch_dat_out,
      addr_i                    => dispatch_addr_out,
      tga_i                     => dispatch_tga_out,
      we_i                      => dispatch_we_out,
      stb_i                     => dispatch_stb_out,
      cyc_i                     => dispatch_cyc_out,
      dat_o                     => dat_ft,
      ack_o                     => ack_ft,
      clk_i                     => clk,
      clk_n_i                   => clk_n,
      rst_i                     => rst,
      sync_i                    => lvds_sync
   );
   
   
   ----------------------------------------------------------------------------
   -- Flux_loop Instantiation
   ----------------------------------------------------------------------------
   i_flux_loop: flux_loop
   generic map (ADC_LATENCY => ADC_LATENCY_REVC)
   port map (
      clk_50_i                  => clk,
      clk_25_i                  => spi_clk,
      rst_i                     => rst,
      num_rows_i                => num_rows,
      num_rows_reported_i       => num_rows_reported,
      num_cols_reported_i       => num_cols_reported,
      adc_coadd_en_i            => adc_coadd_en,
      restart_frame_1row_prev_i => restart_frame_1row_prev,
      restart_frame_aligned_i   => restart_frame_aligned,
      restart_frame_1row_post_i => restart_frame_1row_post,
      row_switch_i              => row_switch,
      initialize_window_i       => initialize_window,
      fltr_rst_i                => fltr_rst,
      num_rows_sub1_i           => (others => '0'),
      dac_dat_en_i              => dac_dat_en,
      dat_i                     => dispatch_dat_out,
      addr_i                    => dispatch_addr_out,
      tga_i                     => dispatch_tga_out,
      we_i                      => dispatch_we_out,
      stb_i                     => dispatch_stb_out,
      cyc_i                     => dispatch_cyc_out,
      dat_frame_o               => dat_frame,
      ack_frame_o               => ack_frame,
      dat_fb_o                  => dat_fb,
      ack_fb_o                  => ack_fb,
      
      ------------------------------------
      -- Readout Card Rev. A/AA/B
      ------------------------------------
      adc_dat_ch0_i             => adc_dat0,
      adc_dat_ch1_i             => adc_dat1,
      adc_dat_ch2_i             => adc_dat2,
      adc_dat_ch3_i             => adc_dat3,
      adc_dat_ch4_i             => adc_dat4,
      adc_dat_ch5_i             => adc_dat5,
      adc_dat_ch6_i             => adc_dat6,
      adc_dat_ch7_i             => adc_dat7,
--      adc_ovr_ch0_i             => '0',
--      adc_ovr_ch1_i             => '0',
--      adc_ovr_ch2_i             => '0',
--      adc_ovr_ch3_i             => '0',
--      adc_ovr_ch4_i             => '0',
--      adc_ovr_ch5_i             => '0',
--      adc_ovr_ch6_i             => '0',
--      adc_ovr_ch7_i             => '0',
--      adc_rdy_ch0_i             => '0',
--      adc_rdy_ch1_i             => '0',
--      adc_rdy_ch2_i             => '0',
--      adc_rdy_ch3_i             => '0',
--      adc_rdy_ch4_i             => '0',
--      adc_rdy_ch5_i             => '0',
--      adc_rdy_ch6_i             => '0',
--      adc_rdy_ch7_i             => '0',
--
--      ------------------------------------
--      -- For Readout Card Rev. C
--      ------------------------------------
--      -- Must be fully compensated, and 180 degrees out of phase with samp_clk
--      adc_dat0_i                => adc_dat0,   
--      adc_dat1_i                => adc_dat1,   
--      adc_dat2_i                => adc_dat2,   
--      adc_dat3_i                => adc_dat3,   
--      adc_dat4_i                => adc_dat4,   
--      adc_dat5_i                => adc_dat5,   
--      adc_dat6_i                => adc_dat6,   
--      adc_dat7_i                => adc_dat7,   
--      
--      samp_clk_i  => samp_clk,
--      adc_frame_i => adc_dco_p,
--      adc0_lvds_i => adc0_lvds_p,  
--      adc1_lvds_i => adc1_lvds_p,  
--      adc2_lvds_i => adc2_lvds_p,  
--      adc3_lvds_i => adc3_lvds_p,  
--      adc4_lvds_i => adc4_lvds_p,  
--      adc5_lvds_i => adc5_lvds_p,  
--      adc6_lvds_i => adc6_lvds_p,  
--      adc7_lvds_i => adc7_lvds_p,
--      ------------------------------------
      
      dac_dat_ch0_o             => dac_FB1_dat,
      dac_dat_ch1_o             => dac_FB2_dat,
      dac_dat_ch2_o             => dac_FB3_dat,
      dac_dat_ch3_o             => dac_FB4_dat,
      dac_dat_ch4_o             => dac_FB5_dat,
      dac_dat_ch5_o             => dac_FB6_dat,
      dac_dat_ch6_o             => dac_FB7_dat,
      dac_dat_ch7_o             => dac_FB8_dat,
      dac_clk_ch0_o             => dac_FB_clk(0),
      dac_clk_ch1_o             => dac_FB_clk(1),
      dac_clk_ch2_o             => dac_FB_clk(2),
      dac_clk_ch3_o             => dac_FB_clk(3),
      dac_clk_ch4_o             => dac_FB_clk(4),
      dac_clk_ch5_o             => dac_FB_clk(5),
      dac_clk_ch6_o             => dac_FB_clk(6),
      dac_clk_ch7_o             => dac_FB_clk(7),
      sa_bias_dac_spi_ch0_o     => sa_bias_dac_spi_ch0,
      sa_bias_dac_spi_ch1_o     => sa_bias_dac_spi_ch1,
      sa_bias_dac_spi_ch2_o     => sa_bias_dac_spi_ch2,
      sa_bias_dac_spi_ch3_o     => sa_bias_dac_spi_ch3,
      sa_bias_dac_spi_ch4_o     => sa_bias_dac_spi_ch4,
      sa_bias_dac_spi_ch5_o     => sa_bias_dac_spi_ch5,
      sa_bias_dac_spi_ch6_o     => sa_bias_dac_spi_ch6,
      sa_bias_dac_spi_ch7_o     => sa_bias_dac_spi_ch7,
      offset_dac_spi_ch0_o      => offset_dac_spi_ch0,
      offset_dac_spi_ch1_o      => offset_dac_spi_ch1,
      offset_dac_spi_ch2_o      => offset_dac_spi_ch2,
      offset_dac_spi_ch3_o      => offset_dac_spi_ch3,
      offset_dac_spi_ch4_o      => offset_dac_spi_ch4,
      offset_dac_spi_ch5_o      => offset_dac_spi_ch5,
      offset_dac_spi_ch6_o      => offset_dac_spi_ch6,
      offset_dac_spi_ch7_o      => offset_dac_spi_ch7
   );               
   
   -- Chip select signal assignment
   bias_dac_ncs(0) <= sa_bias_dac_spi_ch0(2);
   bias_dac_ncs(1) <= sa_bias_dac_spi_ch1(2);
   bias_dac_ncs(2) <= sa_bias_dac_spi_ch2(2);
   bias_dac_ncs(3) <= sa_bias_dac_spi_ch3(2);
   bias_dac_ncs(4) <= sa_bias_dac_spi_ch4(2);
   bias_dac_ncs(5) <= sa_bias_dac_spi_ch5(2);
   bias_dac_ncs(6) <= sa_bias_dac_spi_ch6(2);
   bias_dac_ncs(7) <= sa_bias_dac_spi_ch7(2);

   -- Chip select signal assignment
   offset_dac_ncs(0)  <= offset_dac_spi_ch0(2);
   offset_dac_ncs(1)  <= offset_dac_spi_ch1(2);
   offset_dac_ncs(2)  <= offset_dac_spi_ch2(2);
   offset_dac_ncs(3)  <= offset_dac_spi_ch3(2);
   offset_dac_ncs(4)  <= offset_dac_spi_ch4(2);
   offset_dac_ncs(5)  <= offset_dac_spi_ch5(2);
   offset_dac_ncs(6)  <= offset_dac_spi_ch6(2);
   offset_dac_ncs(7)  <= offset_dac_spi_ch7(2);
   
   -- MUX for slecting dac_dat or dac_clk from offset or sa_bias based on the
   -- chip select from sa_bias.  Note that we are assuming mutually exclusive
   -- chip select for sa_bias and offset.
   i_MUX_dac: process ( 
      sa_bias_dac_spi_ch0, sa_bias_dac_spi_ch1,
      sa_bias_dac_spi_ch2, sa_bias_dac_spi_ch3,
      sa_bias_dac_spi_ch4, sa_bias_dac_spi_ch5,
      sa_bias_dac_spi_ch6, sa_bias_dac_spi_ch7,
      offset_dac_spi_ch0, offset_dac_spi_ch1,
      offset_dac_spi_ch2, offset_dac_spi_ch3,
      offset_dac_spi_ch4, offset_dac_spi_ch5,
      offset_dac_spi_ch6, offset_dac_spi_ch7)    
   begin  -- process i_MUX_dac_dat    
      case sa_bias_dac_spi_ch0(2) is
         when '0' =>
            dac_dat(0) <= sa_bias_dac_spi_ch0(0);
            dac_clk(0) <= sa_bias_dac_spi_ch0(1);
         when others =>
            dac_dat(0) <= offset_dac_spi_ch0(0);
            dac_clk(0) <= offset_dac_spi_ch0(1);
      end case;

      case sa_bias_dac_spi_ch1(2) is
         when '0' =>
            dac_dat(1) <= sa_bias_dac_spi_ch1(0);
            dac_clk(1) <= sa_bias_dac_spi_ch1(1);
         when others =>
            dac_dat(1) <= offset_dac_spi_ch1(0);
            dac_clk(1) <= offset_dac_spi_ch1(1);
      end case;

      case sa_bias_dac_spi_ch2(2) is
         when '0' =>
            dac_dat(2) <= sa_bias_dac_spi_ch2(0);
            dac_clk(2) <= sa_bias_dac_spi_ch2(1);
         when others =>
            dac_dat(2) <= offset_dac_spi_ch2(0);
            dac_clk(2) <= offset_dac_spi_ch2(1);
      end case;
    
      case sa_bias_dac_spi_ch3(2) is
         when '0' =>
            dac_dat(3) <= sa_bias_dac_spi_ch3(0);
            dac_clk(3) <= sa_bias_dac_spi_ch3(1);
         when others =>
            dac_dat(3) <= offset_dac_spi_ch3(0);
            dac_clk(3) <= offset_dac_spi_ch3(1);
      end case;

      case sa_bias_dac_spi_ch4(2) is
         when '0' =>
            dac_dat(4) <= sa_bias_dac_spi_ch4(0);
            dac_clk(4) <= sa_bias_dac_spi_ch4(1);
         when others =>
            dac_dat(4) <= offset_dac_spi_ch4(0);
            dac_clk(4) <= offset_dac_spi_ch4(1);
      end case;

      case sa_bias_dac_spi_ch5(2) is
         when '0' =>
            dac_dat(5) <= sa_bias_dac_spi_ch5(0);
            dac_clk(5) <= sa_bias_dac_spi_ch5(1);
         when others =>
            dac_dat(5) <= offset_dac_spi_ch5(0);
            dac_clk(5) <= offset_dac_spi_ch5(1);
      end case;

      case sa_bias_dac_spi_ch6(2) is
         when '0' =>
            dac_dat(6) <= sa_bias_dac_spi_ch6(0);
            dac_clk(6) <= sa_bias_dac_spi_ch6(1);
         when others =>
            dac_dat(6) <= offset_dac_spi_ch6(0);
            dac_clk(6) <= offset_dac_spi_ch6(1);
      end case;

      case sa_bias_dac_spi_ch7(2) is
         when '0' =>
            dac_dat(7) <= sa_bias_dac_spi_ch7(0);
            dac_clk(7) <= sa_bias_dac_spi_ch7(1);
         when others =>
            dac_dat(7) <= offset_dac_spi_ch7(0);
            dac_clk(7) <= offset_dac_spi_ch7(1);
      end case;
   end process i_MUX_dac;
                
   ----------------------------------------------------------------------------
   -- LED Instantition
   ----------------------------------------------------------------------------
   i_LED: leds
   port map (
      clk_i  => clk,
      rst_i  => rst,
      dat_i  => dispatch_dat_out,
      addr_i => dispatch_addr_out,
      tga_i  => dispatch_tga_out,
      we_i   => dispatch_we_out,
      stb_i  => dispatch_stb_out,
      cyc_i  => dispatch_cyc_out,
      dat_o  => dat_led,
      ack_o  => ack_led,
      power  => grn_led,
      status => ylw_led,
      fault  => red_led
   );

   ----------------------------------------------------------------------------
   -- all_cards registers Instantition
   ----------------------------------------------------------------------------
   i_all_cards: all_cards
   generic map ( 
      REVISION => RC_REVISION,
      CARD_TYPE=> RC_CARD_TYPE)
   port map (
      clk_i  => clk,
      rst_i  => rst,
      dat_i  => dispatch_dat_out,
      addr_i => dispatch_addr_out,
      tga_i  => dispatch_tga_out,
      we_i   => dispatch_we_out,
      stb_i  => dispatch_stb_out,
      cyc_i  => dispatch_cyc_out,
      slot_id_i => slot_id,
      err_o     => all_cards_err,
      dat_o     => all_cards_data,
      ack_o     => all_cards_ack
   );
   
   ----------------------------------------------------------------------------
   -- id_thermo Instantition
   ----------------------------------------------------------------------------
   i_id_thermo: id_thermo
   port map(
      clk_i   => clk,
      rst_i   => rst,  
      
      -- Wishbone signals
      dat_i   => dispatch_dat_out, 
      addr_i  => dispatch_addr_out,
      tga_i   => dispatch_tga_out,
      we_i    => dispatch_we_out,
      stb_i   => dispatch_stb_out,
      cyc_i   => dispatch_cyc_out,
      err_o   => id_thermo_err,
      dat_o   => id_thermo_data,
      ack_o   => id_thermo_ack,
         
      -- silicon id/temperature chip signals
      data_io => card_id
   );
   
   ----------------------------------------------------------------------------
   -- fpga_thermo Instantition
   ----------------------------------------------------------------------------
   i_fpga_thermo: fpga_thermo
   port map(
      clk_i   => clk,
      rst_i   => rst,  
      
      -- Wishbone signals
      dat_i   => dispatch_dat_out, 
      addr_i  => dispatch_addr_out,
      tga_i   => dispatch_tga_out,
      we_i    => dispatch_we_out,
      stb_i   => dispatch_stb_out,
      cyc_i   => dispatch_cyc_out,
      err_o   => fpga_thermo_err,
      dat_o   => fpga_thermo_data,
      ack_o   => fpga_thermo_ack,
         
      -- FPGA temperature chip signals
      smbclk_o  => smb_clk,
      smbalert_i => smb_nalert,
      smbdat_io => smb_data
   );
   ----------------------------------------------------------------------------
   -- DDR2-related Instantitions and connections copied from micron_ctrl_example_top.vhd
   ----------------------------------------------------------------------------
  -- replaced global_reset_n with rst and replaced clk_source with inclk_ddr
  tie_low <= std_logic'('0');
  oct_ctl_rs_value <= std_logic_vector'("00000000000000");
  oct_ctl_rt_value <= std_logic_vector'("00000000000000");
  tie_high <= std_logic'('1');
  --<< START MEGAWIZARD INSERT WRAPPER_NAME
  micron_ctrl_inst : micron_ctrl
  port map(
     aux_full_rate_clk => mem_aux_full_rate_clk,
     aux_half_rate_clk => mem_aux_half_rate_clk,
     global_reset_n => rst_n,
     local_address => mem_local_addr,
     local_be => mem_local_be,
     local_burstbegin => tie_low,
     local_init_done => open,
     local_rdata => mem_local_rdata,
     local_rdata_valid => mem_local_rdata_valid,
     local_read_req => mem_local_read_req,
     local_ready => mem_local_ready,
     local_refresh_ack => open,
     local_size => mem_local_size,
     local_wdata => mem_local_wdata,
     local_wdata_req => open,
     local_write_req => mem_local_write_req,
     mem_addr => internal_mem_addr,
     mem_ba => internal_mem_ba,
     mem_cas_n => internal_mem_cas_n,
     mem_cke(0) => internal_mem_cke(0),
     mem_clk(0) => mem_clk(0),
     mem_clk_n(0) => mem_clk_n(0),
     mem_cs_n(0) => internal_mem_cs_n(0),
     mem_dm => internal_mem_dm(1 DOWNTO 0),
     mem_dq => mem_dq,
     mem_dqs => mem_dqs(1 DOWNTO 0),
     mem_dqsn => mem_dqsn(1 DOWNTO 0),
     mem_odt(0) => internal_mem_odt(0),
     mem_ras_n => internal_mem_ras_n,
     mem_we_n => internal_mem_we_n,
     oct_ctl_rs_value => oct_ctl_rs_value,
     oct_ctl_rt_value => oct_ctl_rt_value,
     phy_clk => phy_clk,
     pll_ref_clk => inclk_ddr,
     reset_phy_clk_n => reset_phy_clk_n,
     reset_request_n => open,
     soft_reset_n => tie_high
  );

  --<< END MEGAWIZARD INSERT WRAPPER_NAME

  --<< START MEGAWIZARD INSERT CS_ADDR_MAP
  --connect up the column address bits, dropping 2 bits from example driver output because of 4:1 data rate
  mem_local_addr(7 DOWNTO 0) <= mem_local_col_addr(9 DOWNTO 2);
  --<< END MEGAWIZARD INSERT CS_ADDR_MAP

  --<< START MEGAWIZARD INSERT EXAMPLE_DRIVER
  --Self-test, synthesisable code to exercise the DDR SDRAM Controller
  driver : micron_ctrl_example_driver
  port map(
     clk => phy_clk,
     local_bank_addr => mem_local_addr(22 DOWNTO 21),
     local_be => mem_local_be,
     local_col_addr => mem_local_col_addr,
     local_cs_addr => mem_local_cs_addr,
     local_rdata => mem_local_rdata,
     local_rdata_valid => mem_local_rdata_valid,
     local_read_req => mem_local_read_req,
     local_ready => mem_local_ready,
     local_row_addr => mem_local_addr(20 DOWNTO 8),
     local_size => mem_local_size,
     local_wdata => mem_local_wdata,
     local_write_req => mem_local_write_req,
     pnf_per_byte => internal_pnf_per_byte(7 DOWNTO 0),
     pnf_persist => internal_pnf,
     reset_n => reset_phy_clk_n,
     test_complete => internal_test_complete,
     test_status => internal_test_status
  );

  --<< END MEGAWIZARD INSERT EXAMPLE_DRIVER

  --<< START MEGAWIZARD INSERT DLL

  --<< END MEGAWIZARD INSERT DLL

  --<< start europa
  --vhdl renameroo for output signals
  mem_addr <= internal_mem_addr;
  --vhdl renameroo for output signals
  mem_ba <= internal_mem_ba;
  --vhdl renameroo for output signals
  mem_cas_n <= internal_mem_cas_n;
  --vhdl renameroo for output signals
  mem_cke <= internal_mem_cke;
  --vhdl renameroo for output signals
  mem_cs_n <= internal_mem_cs_n;
  --vhdl renameroo for output signals
  mem_dm <= internal_mem_dm;
  --vhdl renameroo for output signals
  mem_odt <= internal_mem_odt;
  --vhdl renameroo for output signals
  mem_ras_n <= internal_mem_ras_n;
  --vhdl renameroo for output signals
  mem_we_n <= internal_mem_we_n;
  --vhdl renameroo for output signals
  pnf <= internal_pnf;
  --vhdl renameroo for output signals
  pnf_per_byte <= internal_pnf_per_byte;
  --vhdl renameroo for output signals
  test_complete <= internal_test_complete;
  --vhdl renameroo for output signals
  test_status <= internal_test_status;

   ----------------------------------------------------------------------------
   -- Mictor Connection
   ----------------------------------------------------------------------------
   
--   mictor(0)  <= clk;
--   mictor(1)  <= dac_dat_en;
--   mictor(2)  <= adc_coadd_en;
--   mictor(3)  <= restart_frame_1row_prev;
--   mictor(4)  <= restart_frame_aligned;
--   mictor(5)  <= restart_frame_1row_post;
--   mictor(6)  <= row_switch;
--   mictor(7)  <= initialize_window;
--   mictor(8)  <= lvds_sync;
--   mictor(9)  <= lvds_cmd;
--   mictor(10) <= dispatch_lvds_txa;
--   mictor(11) <= dispatch_err_in;
--   mictor(12) <= dispatch_tga_out(0);
--   mictor(13) <= dispatch_tga_out(1);
--   mictor(14) <= dispatch_tga_out(2);
--   mictor(15) <= dispatch_we_out;
--   mictor(16) <= dispatch_stb_out;
--   mictor(17) <= dispatch_cyc_out;
--   mictor(18) <= dispatch_addr_out(0);
--   mictor(19) <= dispatch_addr_out(1);
--   mictor(20) <= dispatch_addr_out(2);
--   mictor(21) <= dispatch_addr_out(3);
--   mictor(22) <= dispatch_addr_out(4);
--   mictor(23) <= dispatch_addr_out(5);
--   mictor(24) <= dispatch_addr_out(6);
--   mictor(25) <= dispatch_addr_out(7);
--   mictor(26) <= ack_fb;
--   mictor(27) <= ack_frame;
--   mictor(28) <= ack_ft;
--   mictor(29) <= ack_led;
--   mictor(30) <= fw_rev_ack;
--   mictor(31) <= rst;
   
end top;
