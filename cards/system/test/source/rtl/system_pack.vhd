library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.bias_card_pack.all;
use work.readout_card_pack.all;

package system_pack is

   component clk_card
   port(
      -- Crystal Clock PLL input:
      inclk14           : in std_logic; -- Crystal Clock Input
      rst_n             : in std_logic;

      -- Manchester Clock PLL inputs:
      inclk15           : in std_logic;
      inclk1            : in std_logic;
      inclk5            : in std_logic;

      -- LVDS interface:
      lvds_cmd          : out std_logic;
      lvds_sync         : out std_logic;
      lvds_spare        : out std_logic;
      lvds_clk          : out std_logic;
      lvds_reply_ac_a   : in std_logic;
      lvds_reply_ac_b   : in std_logic;
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
      dv_pulse_fibre    : in std_logic;
      manchester_data   : in std_logic;
      manchester_sigdet : in std_logic;

      -- TTL interface:
      ttl_nrx1          : in std_logic;
      ttl_tx1           : out std_logic;
      ttl_txena1        : out std_logic;

      ttl_nrx2          : in std_logic;
      ttl_tx2           : out std_logic;
      ttl_txena2        : out std_logic;

      ttl_nrx3          : in std_logic;
      ttl_tx3           : out std_logic;
      ttl_txena3        : out std_logic;

      -- eeprom interface:
      eeprom_si         : in std_logic;
      eeprom_so         : out std_logic;
      eeprom_sck        : out std_logic;
      eeprom_cs         : out std_logic;

      mosii             : in std_logic;
      sclki             : in std_logic;
      ccssi             : in std_logic;
      misoo             : out std_logic;
      sreqo             : out std_logic;

      -- SRAM bank 0 interface
      sram0_addr : out std_logic_vector(19 downto 0);
      sram0_data : inout std_logic_vector(15 downto 0);
      sram0_nbhe : out std_logic;
      sram0_nble : out std_logic;
      sram0_noe  : out std_logic;
      sram0_nwe  : out std_logic;
      sram0_nce1 : out std_logic;
      sram0_ce2  : out std_logic;

      -- SRAM bank 1 interface
      sram1_addr : out std_logic_vector(19 downto 0);
      sram1_data : inout std_logic_vector(15 downto 0);
      sram1_nbhe : out std_logic;
      sram1_nble : out std_logic;
      sram1_noe  : out std_logic;
      sram1_nwe  : out std_logic;
      sram1_nce1 : out std_logic;
      sram1_ce2  : out std_logic;

      -- miscellaneous ports:
      red_led           : out std_logic;
      ylw_led           : out std_logic;
      grn_led           : out std_logic;
      dip_sw3           : in std_logic;
      dip_sw4           : in std_logic;
      wdog              : out std_logic;
      slot_id           : in std_logic_vector(3 downto 0);
      array_id          : in std_logic_vector(2 downto 0);
      card_id           : inout std_logic;
      smb_clk           : out std_logic;
      smb_data          : inout std_logic;
      smb_nalert        : out std_logic;

      box_id_in         : in std_logic;
      box_id_out        : out std_logic;
      box_id_ena_n      : out std_logic;

      extend_n          : in std_logic;

      -- debug ports:
      mictor0_o         : out std_logic_vector(15 downto 0);
      mictor0clk_o      : out std_logic;
      mictor0_e         : in std_logic_vector(15 downto 0);
      mictor0clk_e      : in std_logic;
      mictor1_o         : out std_logic_vector(15 downto 0);
      mictor1clk_o      : out std_logic;
--      mictor1_e         : out std_logic_vector(15 downto 0);
--      mictor1clk_e      : out std_logic;

      rx                : in std_logic;
      tx                : out std_logic;

      -- interface to HOTLINK fibre receiver
      fibre_rx_data     : in std_logic_vector (7 downto 0);
      fibre_rx_rdy      : in std_logic;
      fibre_rx_rvs      : in std_logic;
      fibre_rx_status   : in std_logic;
      fibre_rx_sc_nd    : in std_logic;
      fibre_rx_clkr     : in std_logic;
      fibre_rx_refclk   : out std_logic;
      fibre_rx_a_nb     : out std_logic;
      fibre_rx_bisten   : out std_logic;
      fibre_rx_rf       : out std_logic;

      -- interface to hotlink fibre transmitter
      fibre_tx_clkw     : out std_logic;
      fibre_tx_data     : out std_logic_vector (7 downto 0);
      fibre_tx_ena      : out std_logic;
      fibre_tx_sc_nd    : out std_logic;
      fibre_tx_enn      : out std_logic;
      fibre_tx_bisten   : out std_logic;
      fibre_tx_foto     : out std_logic;

      -- JTAG
      fpga_tdo          : out std_logic; -- TDI (into JTAG chain)
      fpga_tck          : out std_logic; -- TCK
      fpga_tms          : out std_logic; -- TMS
      epc_tdo           : in std_logic;  -- TDO (out of JTAG chain)
      jtag_sel          : out std_logic; -- JTAG source: '0'=Header, '1'=FGPA
      nbb_jtag          : in std_logic;  -- JTAG source:  readback (jtag_sel)

      nreconf           : out std_logic;
      nepc_sel          : out std_logic
   );
   end component;

   component readout_card
      port (
         rst_n          : in  std_logic;
         inclk          : in  std_logic;
         adc1_dat       : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
         adc2_dat       : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
         adc3_dat       : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
         adc4_dat       : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
         adc5_dat       : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
         adc6_dat       : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
         adc7_dat       : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
         adc8_dat       : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
         adc1_ovr       : in  std_logic;
         adc2_ovr       : in  std_logic;
         adc3_ovr       : in  std_logic;
         adc4_ovr       : in  std_logic;
         adc5_ovr       : in  std_logic;
         adc6_ovr       : in  std_logic;
         adc7_ovr       : in  std_logic;
         adc8_ovr       : in  std_logic;
         adc1_rdy       : in  std_logic;
         adc2_rdy       : in  std_logic;
         adc3_rdy       : in  std_logic;
         adc4_rdy       : in  std_logic;
         adc5_rdy       : in  std_logic;
         adc6_rdy       : in  std_logic;
         adc7_rdy       : in  std_logic;
         adc8_rdy       : in  std_logic;
         adc1_clk       : out std_logic;
         adc2_clk       : out std_logic;
         adc3_clk       : out std_logic;
         adc4_clk       : out std_logic;
         adc5_clk       : out std_logic;
         adc6_clk       : out std_logic;
         adc7_clk       : out std_logic;
         adc8_clk       : out std_logic;
         dac_FB1_dat    : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
         dac_FB2_dat    : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
         dac_FB3_dat    : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
         dac_FB4_dat    : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
         dac_FB5_dat    : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
         dac_FB6_dat    : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
         dac_FB7_dat    : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
         dac_FB8_dat    : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
         dac_FB_clk     : out std_logic_vector(7 downto 0);
         dac_clk        : out std_logic_vector(7 downto 0);
         dac_dat        : out std_logic_vector(7 downto 0);
         bias_dac_ncs   : out std_logic_vector(7 downto 0);
         offset_dac_ncs : out std_logic_vector(7 downto 0);
         lvds_cmd       : in  std_logic;
         lvds_sync      : in  std_logic;
         lvds_spare     : in  std_logic;
         lvds_txa       : out std_logic;
         lvds_txb       : out std_logic;

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

         smb_clk         : out std_logic;
         smb_nalert      : out std_logic;
         smb_data        : inout std_logic;

         red_led        : out std_logic;
         ylw_led        : out std_logic;
         grn_led        : out std_logic;
         dip_sw3        : in  std_logic;
         dip_sw4        : in  std_logic;
         wdog           : out std_logic;
         slot_id        : in  std_logic_vector(3 downto 0);
         card_id        : inout  std_logic;
         mictor         : out std_logic_vector(31 downto 0)
      );
   end component;


   component readout_card_stratix_iii
      port(
         -- Global Interface
         dev_clr_n           : in std_logic;

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
         adc_sclk    : out std_logic;
         adc_sdio    : inout std_logic; 
         adc_csb_n   : out std_logic; 
         adc_pdwn    : out std_logic;
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
         dip_sw0            : in std_logic;
         dip_sw1            : in std_logic;
         dip_sw2            : in std_logic;
         dip_sw3            : in std_logic;
         wdog             : out std_logic;
         rs232_tx        : out std_logic;
         rs232_rx        : in std_logic;
         eeprom_si       : in std_logic; -- Implement this
         eeprom_so       : out std_logic; -- Implement this
         eeprom_sck      : out std_logic; -- Implement this
         eeprom_cs_n     : out std_logic; -- Implement this
         crc_error_in    : in std_logic; -- Implement this
         critical_error  : in std_logic; -- Implement this
         extend_n        : in std_logic; -- Implement this   

         -- slot id interface  
         slot_id         : in std_logic_vector(3 downto 0);

         -- silicon_id/temperature interface
         card_id         : inout std_logic;
         
         -- fpga_thermo serial interface
         smb_clk         : out std_logic;
         smb_nalert      : out std_logic;
         smb_data        : inout std_logic;      

         -- DDR2 interface
         -- outputs:
         mem_addr       : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
         mem_ba         : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
         mem_cas_n      : OUT STD_LOGIC;
         mem_cke        : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
         mem_clk        : INOUT STD_LOGIC_VECTOR (0 DOWNTO 0);
         mem_clk_n      : INOUT STD_LOGIC_VECTOR (0 DOWNTO 0);
         mem_cs_n       : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
         mem_dm         : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
         mem_dq         : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
         mem_dqs        : INOUT STD_LOGIC_VECTOR (1 DOWNTO 0);
         mem_dqsn       : INOUT STD_LOGIC_VECTOR (1 DOWNTO 0);
         mem_odt        : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
         mem_ras_n      : OUT STD_LOGIC;
         mem_we_n       : OUT STD_LOGIC;
         pnf            : OUT STD_LOGIC;
         pnf_per_byte   : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
         test_complete  : OUT STD_LOGIC;
         test_status    : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
         mictor_clk     : out std_logic -- Implement this!!!
      );  
   end component;


   component bias_card
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

      -- dac interface:
      dac_ncs       : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
      dac_sclk      : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
      dac_data      : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
      lvds_dac_ncs  : out std_logic_vector(NUM_LN_BIAS_DACS-1 downto 0);
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
      card_id    : inout std_logic;
      pcb_rev    : in std_logic_vector(3 downto 0);
      smb_clk    : out std_logic;
      smb_data   : inout std_logic;
      smb_nalert : out std_logic;

      -- debug ports:
      test       : inout std_logic_vector(16 downto 3);
      mictor     : out std_logic_vector(31 downto 0);
      mictorclk  : out std_logic_vector(2 downto 1);
      rx   : in std_logic;
      tx   : out std_logic
   );
   end component;

   component addr_card
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
      dac_data0  : out std_logic_vector(13 downto 0);
      dac_data1  : out std_logic_vector(13 downto 0);
      dac_data2  : out std_logic_vector(13 downto 0);
      dac_data3  : out std_logic_vector(13 downto 0);
      dac_data4  : out std_logic_vector(13 downto 0);
      dac_data5  : out std_logic_vector(13 downto 0);
      dac_data6  : out std_logic_vector(13 downto 0);
      dac_data7  : out std_logic_vector(13 downto 0);
      dac_data8  : out std_logic_vector(13 downto 0);
      dac_data9  : out std_logic_vector(13 downto 0);
      dac_data10 : out std_logic_vector(13 downto 0);
      dac_clk    : out std_logic_vector(40 downto 0);

      -- miscellaneous ports:
      red_led    : out std_logic;
      ylw_led    : out std_logic;
      grn_led    : out std_logic;
      dip_sw3    : in std_logic;
      dip_sw4    : in std_logic;
      wdog       : out std_logic;
      slot_id    : in std_logic_vector(3 downto 0);
      card_id    : inout std_logic;
--      pcb_rev    : in std_logic_vector(3 downto 0);
      smb_clk    : out std_logic;
      smb_nalert : out std_logic;
      smb_data   : inout std_logic;

      -- debug ports:
      test       : inout std_logic_vector(16 downto 3);
      mictor     : out std_logic_vector(32 downto 1);
      mictorclk  : out std_logic_vector(2 downto 1);
      rx         : in std_logic;
      tx         : out std_logic
   );
   end component;
end system_pack;