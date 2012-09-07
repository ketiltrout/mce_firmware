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
-- Revision 1.23  2012-01-24 22:35:31  mandana
-- 5.1.a programmable pterm_decay_bits and default is 0
--
-- Revision 1.22  2012-01-23 21:00:03  mandana
-- rev. 5.1.9
-- support added for par_id x64 or qterm_decay_bits, for now hardcoded to n=3!
--
-- Revision 1.21  2012-01-13 20:30:46  mandana
-- 5.1.8 sq1fb is applied with fb_dly=7 when flux-jump is off, with fb_dly=18 when flux-jump is on
--
-- Revision 1.20  2011-11-18 00:46:42  mandana
-- v5.1.7: bugfix for duplicate data in high-data-rate rectangle_mode readout.
-- rd_addr_offset in wbs_frame_data.vhd
--
-- Revision 1.19  2011-10-27 19:01:48  mandana
-- 5.1.6 bugfix for correct handling of ADC latency of Rev. C cards with adjusting coadd_done_o to be tied to ADC_latency parameter
--
-- Revision 1.18  2011-09-16 23:08:26  mandana
-- fix ADC_latency compensation bug in coadd window (is parameterized now)
--
-- Revision 1.17  2011-01-21 01:40:10  mandana
-- 5.1.2, bugfix for filtered data being 2 row behind
--
-- Revision 1.16  2010-11-13 00:40:55  mandana
-- filter_coeff added
-- revision 5.1.0
-- comments added for more structured revision numbering
--
-- Revision 1.15  2010/10/22 21:34:23  mandana
-- 5.0.f with integral_clamp fixed, tcl file fixed
--
-- Revision 1.14  2010/10/07 23:43:59  mandana
-- added pcb_rev interface for Rev. E cards
-- added clamp and fltr_rst commands to bring forward to 5.0.e version
-- cleaned up unused libraries
--
-- Revision 1.13  2010/01/11 23:00:55  bburger
-- BB: re-integrated the DDR2 RAM interface, temporarily removed the CRC_ERROR interface, updated comments regarding ADC sampling-clock phases.
--
-- Revision 1.12  2009/12/10 00:13:36  bburger
-- BB: Added CRC_ERROR entities and test functionality.
--
-- Revision 1.11  2009/11/24 23:52:01  bburger
-- BB: Made a top-level modification that does not affect old cards with the MAX1618, but enables the LM95235 on new cards.
--
-- Revision 1.10  2009/10/06 06:04:57  bburger
-- BB:  Added a new PLL for adc_clk and replaced a couple of descrete flip-flops with Quartus-generated ones
--
-- Revision 1.9  2009/09/15 22:30:13  mandana
-- Updated top-level signal names to align top-level and tcl and qsf file. There were discrepencies in the previous revision that implied some portions to be synthesized out and some constraints not to be considered.
--
-- Revision 1.8  2009/08/21 21:56:22  bburger
-- BB:
-- - changed default level of adc_sclk to '1'
-- - dac_clr_n was changed from an output to an input.
-- - added 'locked' interface to rc_pll_stratix_iii
-- - renamed the adc_pll clock signals to more explanitory names
-- - added the FPGA_DEVICE_FAMILY generic to the dispatch interace for synthesis of the dc_fifo in lvds_rx
-- - uncommented DDR interface to force the syntesizer to use correct left and right PLLs (in conjunction with ADC and DDR PLLs)
-- - added test signals to test_status to see clocks on the scope.
--
-- Revision 1.7  2009/07/11 00:14:59  bburger
-- BB: implemented discrete flip-flops rather than megafunction wizard entities
--
-- Revision 1.6  2009/07/03 23:44:00  bburger
-- BB: This file has been comitted in a transitionary state for the sake of sharing the progress that is being made on the Readout Card ADC interface.
--
-- Revision 1.5  2009/07/03 18:46:00  bburger
-- BB: Changed DDR signal names back to MEM.  Re-introduced the SERDES for continued testing.
--
-- Revision 1.4  2009/06/18 23:01:19  bburger
-- BB:  I had to replace the serdes block in the top level of readout_card_stratix_iii becuase of a hardware mistake which routes adc_fco (LVDS) to a 3.3V Bank (6C).  It should be a Left_Right_PLL (fast PLL) if it is going to feed a ALT_LVDS (serdes) block.  The only spare clock input is not to fast PLL.
--
-- Revision 1.3  2009/06/17 16:14:55  bburger
-- BB: Merging data_size output changes for rectangle mode over to RC vC code
--
-- Revision 1.2  2009/03/19 22:13:38  bburger
-- BB: Added the logic for the ADC deserializer, and removed the ADC signals that are no longer used.
--
-- Revision 1.1  2009/01/23 23:49:36  bburger
-- BB:  Adding new files for Readout Card rev. C.  Also regenerated the following RAM blocks for the new revision:  pid_ram, ram_14x64, wbs_fb_storage.
--
--
-----------------------------------------------------------------------------
-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

LIBRARY altera_mf;
USE altera_mf.all;


library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;


library work;
use work.readout_card_pack.all;
use work.all_cards_pack.all;
use work.adc_sample_coadd_pack.all;

entity readout_card_stratix_iii is
port(
   -- Global Interface
   dev_clr_n         : in std_logic;
   dev_clr_fpga_out_n: out std_logic;

   -- PLL Interface
   inclk           : in std_logic;
   inclk6          : in std_logic;
   inclk_ddr       : in std_logic;
   
   -- ADC Interface for Readout Card Rev. C 
   -- How do I instantiate and LVDS receiver?
   adc0_lvds : in std_logic; 
   adc1_lvds : in std_logic; 
   adc2_lvds : in std_logic; 
   adc3_lvds : in std_logic; 
   adc4_lvds : in std_logic; 
   adc5_lvds : in std_logic; 
   adc6_lvds : in std_logic; 
   adc7_lvds : in std_logic; 
   adc_fco   : in std_logic;
   adc_clk   : out std_logic; 
   adc_sclk  : out std_logic;
   adc_sdio  : inout std_logic; 
   adc_csb_n : out std_logic; 
   adc_pdwn  : out std_logic;
   adc_dco   : in std_logic;

   -- DAC Interface
   dac_clr_n        : in std_logic; -- Implement this!!
   dac0_dfb_dat     : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   dac1_dfb_dat     : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   dac2_dfb_dat     : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   dac3_dfb_dat     : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   dac4_dfb_dat     : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   dac5_dfb_dat     : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   dac6_dfb_dat     : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   dac7_dfb_dat     : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   dac_dfb_clk      : out std_logic_vector(7 downto 0);  -- Note number of channels are hard coded
   
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
   dip_sw0         : in std_logic;
   dip_sw1         : in std_logic;
   dip_sw2         : in std_logic;
   dip_sw3         : in std_logic;
   wdog            : out std_logic;
   rs232_tx        : out std_logic;
   rs232_rx        : in std_logic;
   eeprom_si       : in std_logic; -- Implement this
   eeprom_so       : out std_logic; -- Implement this
   eeprom_sck      : out std_logic; -- Implement this
   eeprom_cs_n     : out std_logic; -- Implement this
   crc_error_out   : inout std_logic;
   crc_error_in    : in std_logic; -- Implement this
   critical_error  : in std_logic; -- Implement this
   extend_n        : in std_logic; -- Implement this   

   -- slot_id interface  
   slot_id         : in std_logic_vector(3 downto 0);

   -- silicon_id/temperature interface
   card_id         : inout std_logic;
   
   -- fpga_thermo serial interface
   smb_clk         : out std_logic;
   smb_nalert      : out std_logic;
   smb_data        : inout std_logic;      
   
   -- pcb revision identification pins
   pcb_rev         : in std_logic_vector(PCB_REV_BITS-1 downto 0);
   
   -- DDR2 interface
   mem_cs_n : OUT STD_LOGIC_VECTOR (0 DOWNTO 0)
 
);  
end readout_card_stratix_iii;

architecture top of readout_card_stratix_iii is

   -- The REVISION format is RRrrBBBB where 
   --               RR is the major revision number, incremented when major new features are added and possibly incompatible with previous versions
   --               rr is the minor revision number, incremented when new features added
   --               BBBB is the build number, incremented for bug fixes
   constant RC_REVISION  : std_logic_vector (31 downto 0) := X"0501000c";
   constant FPGA_DEVICE_FAMILY : string := "Stratix III";
   
   -- Global signals
   signal clk                     : std_logic; -- system clk
   signal comm_clk                : std_logic; -- communication clk
   signal spi_clk                 : std_logic; -- spi clk
   signal rst                     : std_logic;
   signal clk_n                   : std_logic;
   signal samp_clk                : std_logic; -- ADC sampling clock
   signal serial_clk              : std_logic;   
   
   signal crc_error               : std_logic;
   signal crc_error_ff            : std_logic;

   -- Readout Card Rev. C ADC Signals
   signal rx_sclk      : std_logic;            -- high-speed serial clock for ADC-stream deserializer (700MHz) 
   signal rx_enable_clk: std_logic;            -- load-enable signal of the altlvds receiver
   signal clk_upper    : std_logic;            -- 50MHz to latch upper half of the ADC sample
   signal clk_lower    : std_logic;            -- 50MHz to latch lower half of the ADC sample
   signal clk_word     : std_logic;            -- 50MHz to latch the full word (upper + lower)
   signal rc_pll_locked       : std_logic;
   signal adc_pll_locked      : std_logic;
   signal adc_clk_pll_locked  : std_logic;
   
   signal adc_dat     : std_logic_vector(7 downto 0);
   signal serdes_dat0 : std_logic_vector(55 downto 0);
   signal serdes_dat1 : std_logic_vector(55 downto 0);
   signal serdes_dat2 : std_logic_vector(55 downto 0);
   signal serdes_dat3 : std_logic_vector(111 downto 0);
   signal serdes_dat4 : std_logic_vector(111 downto 0);
   signal serdes_dat5 : std_logic_vector(111 downto 0);
   signal serdes_dat6 : std_logic_vector(111 downto 0);
   
   signal adc_des_a0    : std_logic_vector(ADC_DAT_WIDTH-1 downto 0);
   signal adc_des_a1    : std_logic_vector(ADC_DAT_WIDTH-1 downto 0);
   signal adc_des_a2    : std_logic_vector(ADC_DAT_WIDTH-1 downto 0);
   signal adc_des_a3    : std_logic_vector(ADC_DAT_WIDTH-1 downto 0);
   signal adc_des_a4    : std_logic_vector(ADC_DAT_WIDTH-1 downto 0);
   signal adc_des_a5    : std_logic_vector(ADC_DAT_WIDTH-1 downto 0);
   signal adc_des_a6    : std_logic_vector(ADC_DAT_WIDTH-1 downto 0);
   signal adc_des_a7    : std_logic_vector(ADC_DAT_WIDTH-1 downto 0);

   signal adc_des_b0    : std_logic_vector(ADC_DAT_WIDTH-1 downto 0);
   signal adc_des_b1    : std_logic_vector(ADC_DAT_WIDTH-1 downto 0);
   signal adc_des_b2    : std_logic_vector(ADC_DAT_WIDTH-1 downto 0);
   signal adc_des_b3    : std_logic_vector(ADC_DAT_WIDTH-1 downto 0);
   signal adc_des_b4    : std_logic_vector(ADC_DAT_WIDTH-1 downto 0);
   signal adc_des_b5    : std_logic_vector(ADC_DAT_WIDTH-1 downto 0);
   signal adc_des_b6    : std_logic_vector(ADC_DAT_WIDTH-1 downto 0);
   signal adc_des_b7    : std_logic_vector(ADC_DAT_WIDTH-1 downto 0);

   signal adc_dat0    : std_logic_vector(ADC_DAT_WIDTH-1 downto 0);
   signal adc_dat1    : std_logic_vector(ADC_DAT_WIDTH-1 downto 0);
   signal adc_dat2    : std_logic_vector(ADC_DAT_WIDTH-1 downto 0);
   signal adc_dat3    : std_logic_vector(ADC_DAT_WIDTH-1 downto 0);
   signal adc_dat4    : std_logic_vector(ADC_DAT_WIDTH-1 downto 0);
   signal adc_dat5    : std_logic_vector(ADC_DAT_WIDTH-1 downto 0);
   signal adc_dat6    : std_logic_vector(ADC_DAT_WIDTH-1 downto 0);
   signal adc_dat7    : std_logic_vector(ADC_DAT_WIDTH-1 downto 0);
   signal adc_dat_tst : std_logic_vector(ADC_DAT_WIDTH-1 downto 0);
  
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
   signal data_size               : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
   
   
begin   
   
   -- Default assignments for ADC control pins
   -- A predetermined digital test pattern is outputed when sclk and csb_n pins are both held high at power up.
   -- the ADC channel outputs shift out the following pattern: 10 0000 0000 0000
   -- We are seeing the test pattern despite the fact that adc_scb_n is not held high here
   -- This is because the ADC powers up before the FPGA configures and asserts this values.
   adc_sclk  <= '1';  --: out std_logic; 
   adc_csb_n <= '0';  --: out std_logic; 

   adc_sdio  <= '0';  --: inout std_logic; 
   adc_pdwn  <= '0';  --: out std_logic;   
   
   -- Default assignments to get rid of synthesis warnings.
   ttl_out1 <= '0';
   ttl_dir2 <= '0';
   ttl_out2 <= '0';
   ttl_dir3 <= '0';
   ttl_out3 <= '0';
   
   --dac_clr_n <= '1';
   rs232_tx  <= '0';
   eeprom_so <= '0';
   eeprom_sck <= '0';
   eeprom_cs_n <= '0';
   --mictor_clk <= '0';
   
   -- Active low enable signal for the transmitter on the card.  With '1' it is disabled.
   -- The transmitter is disabled because the Clock Card is driving this line.
   ttl_dir1 <= '1';
   -- The ttl_in1 signal is inverted on the Card, thus the FPGA sees an active-high signal.
   rst <= (not dev_clr_n) or (ttl_in1);
   -- Active-low signal will issue a dev_clr_n and reset the FPGA
   dev_clr_fpga_out_n <= '1'; 
 
   ----------------------------------------------------------------------------
   -- CRC_ERROR WYSIWYG Atom Instantiation
   ----------------------------------------------------------------------------
   i_stratixiii_crcblock : stratixiii_crcblock
   port map(
      clk => clk,
      shiftnld => '0',
      crcerror => crc_error_out,
      regout => open
   );

   -- According an539.pdf, p. 7:
   -- To route the crcerror port to user I/O, you must insert a D flipflop (DFF) in between the crcerror port and the I/O.
   i_d_flipflop : d_flipflop
   PORT map(
      clock => clk,
      data  => crc_error_out,  
      q     => crc_error_ff  
   );
   
--   process(rst, clk)
--   begin
--      if(rst = '1') then
--         ylw_led <= '0';
--      elsif(clk'event and clk = '1') then
--         if(crc_error_ff = '1') then
--            ylw_led <= '1';
--         end if;
--      end if;
--   end process;
   ----------------------------------------------------------------------------

--   ylw_led <= crc_error_ff;

--   crc_error_out <= '1';

--   crc_error <= crc_error_in;
--   ylw_led   <= crc_error;

--   -- According an539.pdf, p. 7:
--   -- To route the crcerror port to user I/O, you must insert a D flipflop (DFF) in between the crcerror port and the I/O.
--   process(clk)
--   begin
--      if(clk'event and clk = '1') then
--         crc_error_ff <= crc_error;
--      end if;
--   end process;

--   process(rst, crc_error)
--   begin
--      if(rst = '1') then
--         crc_error_ff <= '0';
--      elsif(crc_error'event and crc_error = '1') then
--         crc_error_ff <= '1';
--      end if;
--   end process;
   
   
   ----------------------------------------------------------------------------
   -- PLL Instantiation
   ----------------------------------------------------------------------------
   i_rc_pll: rc_pll_stratix_iii
   port map (
      inclk0 => inclk,
      c0     => clk,
      c2     => comm_clk,
      c3     => spi_clk,
      c4     => clk_n,
      c5     => open,
      locked => rc_pll_locked
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


----------------------------------------------
-- Start of "fco hardware error"
----------------------------------------------
-- This was replaced with the code above because of a mistake in the Rev. C hardware that didn't route the adc_fco signal to a fast PLL LVDS input
-- We may choose to re-instate this serdes when the hardware error is fixed -- or we may not, since a lot of the complexity is handled in the adc_pll, above
-- From http://www.altera.com/support/examples/functionality/pll-clocking-stratix3.html
--# Clk0: High-speed serial clock connected to the rx_inclock or tx_inclock port of the altlvds megafunction
--    * Output frequency: Data rate
--    * Phase shift: -180 degrees
--    * Duty cycle: 50%
--# Clk1: Load-enable signal connected to the rx_enable or tx_enable input port of the altlvds megafunction
--    * Output frequency: Data rate/deserialization factor
--    * Phase shift: [(deserialization factor – 2)/deserialization factor] * 360 degrees
--    * Duty cycle: (100/deserialization factor)%
--# Clk2: Clocks the synchronization register
--    * Output frequency: Data rate/deserialization factor
--    * Phase shift: (-180/deserialization factor) degrees
--    * Duty cycle: 50%
--# If dynamic phase alignment (DPA) is used for the receiver, set  the following in the wrapper file generated for the altlvds megafunction:
--    * dpa_multiply_by and dpa_divide_by = same multiplication/division factor as Clk0 (i.e., DPA clock frequency is same as data rate)
   i_adc_clk_pll : adc_clk_pll_stratix_iii
   port map (
      inclk0      => inclk6,
      c0          => adc_clk,
      locked      => adc_clk_pll_locked
   );
   
   i_adc_pll: adc_pll_stratix_iii
   port map (
      areset => rst,
      inclk0 => adc_fco,    -- adc_fco_p is the framing signal from the ADC, source synchronous clock
      c0     => rx_sclk,      -- 700.00MHz, phase shift = -135.00 degrees, duty cycle = 50.00%, fully compensated
      c1     => rx_enable_clk,-- 100.00MHz, phase shift = +102.86 degrees, duty cycle = 7.14% changed to 21.42% (Three 700 MHz clock cycles).  [Note: phase shift = (8/28)*360 or 4 clock edges @700 MHz]
      -- c2, c3 can be latched out at any point during the time they are valid, i.e. 100 MHz -- 10 ns.
      -- However, they have been phase shifted so that their rising edges fall exactly between SERDES data edges.
      -- c2 = MSB latch clock      -- c3 = LSB latch clock      -- c4 = Full word latch clock
      c2     => clk_upper,    -- clk2: 050.00 MHz, phase shift = -025.71 deg [(- 2/28)*360 deg], duty cycle = 18.00% [2.5 700MHz cycles]
      c3     => clk_lower,    -- clk3: 050.00 MHz, phase shift = +154.28 deg [(+12/28)*360 deg], duty cycle = 18.00% [2.5 700MHz cycles]
      c4     => clk_word,     -- clk4: 050.00 MHz, phase shift = +218.57 deg [(+17/28)*360 deg], duty cycle = 18.00% [2.5 700MHz cycles]
      locked => adc_pll_locked
   );

   adc_dat <= adc7_lvds & adc6_lvds & adc5_lvds & adc4_lvds & adc3_lvds & adc2_lvds & adc1_lvds & adc0_lvds;
   
   -- The native SERDES width is at most 12 bits.
   -- To receive a 14-bit word, the SERDES data must be latched twice per data period
   i_adc_serdes: adc_serdes 
   port map (
      rx_enable  => rx_enable_clk, -- This is the latching signal.  Data is latched twice per 14-bit data point.  The phase delay of +102.86 degrees accounts for propagation through the SERDES.
      rx_in      => adc_dat,    
      rx_inclock => rx_sclk,    
      rx_out     => serdes_dat0   
   );

   -- This register captures the 7 MSB of every data point
   process(clk_upper, rst)
   begin
      if(rst = '1') then
         serdes_dat1 <= (others => '0');
      elsif(clk_upper'event and clk_upper = '1') then
         serdes_dat1 <= serdes_dat0;
      end if;
   end process;
  
   -- This register captures the 7 LSB of every data point
   process(clk_lower, rst)
   begin
      if(rst = '1') then
         serdes_dat2 <= (others => '0');
      elsif(clk_lower'event and clk_lower = '1') then
         serdes_dat2 <= serdes_dat0;
      end if;
   end process;

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
      clock      => clk_word,
      data       => serdes_dat3,
      q          => serdes_dat4
   );   
----------------------------------------------
-- End of "fco hardware error"
----------------------------------------------
   
   ---------------------------------------------------------
   -- Double Synchronizer for ADC Data
   ---------------------------------------------------------
   i_adc_serdes_flipflop4: flipflop_112
   port map (
      clock      => clk_n,
      data       => serdes_dat4,
      q          => serdes_dat5
   );   

   i_adc_serdes_flipflop5: flipflop_112
   port map (
      clock      => clk,
      data       => serdes_dat5,
      q          => serdes_dat6
   );   

   -- This cludge is due to the fact that the AD9252 data output format is "offset binary" by default.
   -- See Table 8 on p. 22 of the datasheet.
   adc_dat0 <= not serdes_dat6( 13) & serdes_dat6( 12 downto  0);
   adc_dat1 <= not serdes_dat6( 27) & serdes_dat6( 26 downto 14);
   adc_dat2 <= not serdes_dat6( 41) & serdes_dat6( 40 downto 28);
   adc_dat3 <= not serdes_dat6( 55) & serdes_dat6( 54 downto 42);
   adc_dat4 <= not serdes_dat6( 69) & serdes_dat6( 68 downto 56);
   adc_dat5 <= not serdes_dat6( 83) & serdes_dat6( 82 downto 70);
   adc_dat6 <= not serdes_dat6( 97) & serdes_dat6( 96 downto 84);
   adc_dat7 <= not serdes_dat6(111) & serdes_dat6(110 downto 98);

--   adc_dat_tst <= adc_dat0 or adc_dat1 or adc_dat2 or adc_dat3 or adc_dat4 or adc_dat5 or adc_dat6 or adc_dat7;

   ----------------------------------------------------------------------------
   -- Dispatch Instantiation
   ----------------------------------------------------------------------------
   
   -- Test signal for debugging the ADC interface.
   --dispatch_dat_in <= "0000" & adc_dat1 & adc_dat0;
   
   i_dispatch: dispatch
   generic map (
     FPGA_DEVICE_FAMILY => FPGA_DEVICE_FAMILY)
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
      data_size_o  => data_size,
      dip_sw3      => '1',
      dip_sw4      => '1'
   );
 
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
                            SA_BIAS_ADDR   | OFFSET_ADDR     | EN_FB_JUMP_ADDR |
                            I_CLAMP_VAL_ADDR | FLTR_TYPE_ADDR | QTERM_DECAY_ADDR,
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
                           SA_BIAS_ADDR   | OFFSET_ADDR     | EN_FB_JUMP_ADDR |
                           I_CLAMP_VAL_ADDR | FLTR_TYPE_ADDR | QTERM_DECAY_ADDR,
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
                           RESYNC_ADDR | FLX_LP_INIT_ADDR | FLTR_RST_ADDR | NUM_COLS_REPORTED_ADDR | NUM_ROWS_REPORTED_ADDR |
                           I_CLAMP_VAL_ADDR | FLTR_TYPE_ADDR | QTERM_DECAY_ADDR,
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
      data_size_i               => data_size,
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
      
      dac_dat_ch0_o             => dac0_dfb_dat,
      dac_dat_ch1_o             => dac1_dfb_dat,
      dac_dat_ch2_o             => dac2_dfb_dat,
      dac_dat_ch3_o             => dac3_dfb_dat,
      dac_dat_ch4_o             => dac4_dfb_dat,
      dac_dat_ch5_o             => dac5_dfb_dat,
      dac_dat_ch6_o             => dac6_dfb_dat,
      dac_dat_ch7_o             => dac7_dfb_dat,
      
      dac_clk_ch0_o             => dac_dfb_clk(0),
      dac_clk_ch1_o             => dac_dfb_clk(1),
      dac_clk_ch2_o             => dac_dfb_clk(2),
      dac_clk_ch3_o             => dac_dfb_clk(3),
      dac_clk_ch4_o             => dac_dfb_clk(4),
      dac_clk_ch5_o             => dac_dfb_clk(5),
      dac_clk_ch6_o             => dac_dfb_clk(6),
      dac_clk_ch7_o             => dac_dfb_clk(7),
      
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
      pcb_rev_i => pcb_rev,
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
   smb_nalert <= '0';
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
      smbalert_i => '1',
      smbdat_io => smb_data
   );
   
   ----------------------------------------------------------------------------
   -- DDR2-related Instantitions and connections copied from micron_ctrl_example_top.vhd
   ----------------------------------------------------------------------------
  -- replaced global_reset_n with rst and replaced clk_source with inclk_ddr
  -- all ddr2 code removed, because enabling on-chip termination may have power 
  mem_cs_n(0) <= '1';
  
end top;
