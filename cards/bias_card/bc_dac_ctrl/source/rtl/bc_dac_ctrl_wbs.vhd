-- 2003 SCUBA-2 Project
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
-- $Id: bc_dac_ctrl_wbs.vhd,v 1.19 2014/12/18 23:21:42 mandana Exp $
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- Wishbone interface to handle read-write of bias-card parameters: 
--   flux_fb, flux_fb_upper, bias, fb_col0 to fb_col31, enbl_mux
-- It primarily interacts with bc_dac_ctrl block.
-- This block includes storage for all parameters:
--   fix_flux_fb_reg: to store upto 32 flux_fb values for non-multiplexing mode (flux_fb, flux_fb_upper)
--   ln_bias_ram: to store upto 12 bias values (bias)
--   flux_fb_mux_ram: to store upto 41 values per column (fb_col0 to fb_col31)
--   enbl_mux_reg: to store multiplexing flag per column (whether mux is on or off)
--
-- Revision history:
-- $Log: bc_dac_ctrl_wbs.vhd,v $
-- Revision 1.19  2014/12/18 23:21:42  mandana
-- 5.3.5 added num_idle_rows
--
-- Revision 1.18  2012-12-20 20:59:14  mandana
-- sxt instead of ext for a single-value mod_val change to assert all LN_BIAS changes when enbl_ln_bias_mod=1
-- add one clk latency to access enbl_ln_bias_mod register
--
-- Revision 1.17  2012-04-13 18:08:05  mandana
-- mod_val takes 1 value now
--
-- Revision 1.16  2012-03-26 21:55:15  mandana
-- added enbl_bias_mod, enbl_flux_fb_mod, mod_val
--
-- Revision 1.15  2011-11-29 01:08:26  mandana
-- ln_bias RAM handled correctly now
--
-- Revision 1.14  2011-10-26 18:38:46  mandana
-- ln_bias_changed is asserted when any of ln_bias values are re-written
--
-- Revision 1.13  2010/06/01 23:45:21  mandana
-- individual flux_fb_change flags as oppose to a single one for all channels
--
-- Revision 1.12  2010/05/14 22:43:30  mandana
-- adds support for fb_col0 to fb_col31 and enbl_mux commands
-- fix_flux_fb values are stored in registers as oppose to RAM
--
-- Revision 1.11  2010/01/20 23:16:38  mandana
-- ram storage is now 16-bit wide (as wide as DAC itself) and data is extended to 32b to match wishbone width
-- changed bias to ln_bias to accomodate multiple bias lines
--
-- Revision 1.10  2008/07/15 17:48:04  bburger
-- BB: added tga_i to the state_out FSM's sensitivity list
--
-- Revision 1.9  2007/12/20 00:40:04  mandana
-- added flux_fb_upper
--
-- Revision 1.8  2006/10/02 18:42:52  bburger
-- Bryce:  Gave the WBS the ability to update either the bias or flux_fb, without having to do the other.
--
-- Revision 1.7  2006/08/03 19:00:52  mandana
-- removed reference to ac_dac_ctrl_pack file
-- moved ram component declaraion to bc_dac_ctrl_pack
--
-- Revision 1.6  2006/08/01 18:23:33  bburger
-- Bryce:  removed component declarations from header files and moved them to source files
--
-- Revision 1.5  2005/03/05 01:37:20  mandana
-- fixed the problem with first data being read twice
--
-- Revision 1.4  2005/01/17 23:01:04  mandana
-- removed mem_clk_i
-- read from RAM is performed in 2 clk_i cycles, added an extra state for read
--
-- Revision 1.3  2005/01/07 01:32:03  bench2
-- Mandana: watch for debug ports
--
-- Revision 1.2  2005/01/04 19:19:47  bburger
-- Mandana: changed mictor assignment to 0 to 31 and swapped odd and even pods
--
-- Revision 1.1  2004/11/25 03:05:08  bburger
-- Bryce:  Modified the Bias Card DAC control slaves.
--
-- Revision 1.1  2004/11/11 01:46:56  bburger
-- Bryce:  new
--
--
--
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;  -- for ext function
use ieee.std_logic_unsigned.all;


library sys_param;
use sys_param.wishbone_pack.all;

library work;
use work.bias_card_pack.all;
use work.bc_dac_ctrl_pack.all;
use work.frame_timing_pack.all; -- for NUM_OF_ROWS

entity bc_dac_ctrl_wbs is
   port
   (
      -- bc_dac_ctrl interface:
      flux_fb_addr_i    : in std_logic_vector(FLUX_FB_DAC_ADDR_WIDTH-1 downto 0);   -- address index to read DAC data from RAM
      flux_fb_data_o    : out flux_fb_dac_array;  -- data read from RAM to be consumed by bc_dac_ctrl_core      
      flux_fb_changed_o : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
      ln_bias_addr_i    : in std_logic_vector(LN_BIAS_DAC_ADDR_WIDTH-1 downto 0);
      ln_bias_data_o    : out std_logic_vector(LN_BIAS_DAC_DATA_WIDTH-1 downto 0);
      ln_bias_changed_o : out std_logic_vector(NUM_LN_BIAS_DACS-1 downto 0);
      
      mux_flux_fb_data_o: out flux_fb_dac_array;
      enbl_mux_data_o   : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);

      -- row_addr_i to access the right flux_fb bank when in multiplexing mode (enbl_mux = 1)
      row_addr_i        : in std_logic_vector(ROW_ADDR_WIDTH-1 downto 0);
      
      -- frame_timing interface
      row_switch_i      : in std_logic;

      -- wishbone interface:
      dat_i             : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i            : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i             : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i              : in std_logic;
      stb_i             : in std_logic;
      cyc_i             : in std_logic;
      dat_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o             : out std_logic;

      -- global interface
      clk_i             : in std_logic;
      rst_i             : in std_logic;
      debug             : inout std_logic_vector(31 downto 0)
   );
end bc_dac_ctrl_wbs;

architecture rtl of bc_dac_ctrl_wbs is

  -- convert std_logic to std_logic_vector(0 downto 0)
  function vectorize(s: std_logic) return std_logic_vector is
  variable v: std_logic_vector(0 downto 0);
  begin
      v(0) := s;
      return v;
  end;

   -- RAM/Register signals
   signal flux_fb_wren     : std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
   signal fix_flux_fb_data : flux_fb_dac_array; 
   signal mux_flux_fb_data : flux_fb_dac_array;
   signal mod_val_data     : std_logic_vector(FLUX_FB_DAC_DATA_WIDTH-1 downto 0);
   signal wb_mux_flux_fb_data : flux_fb_dac_array;

   signal ln_bias_wren     : std_logic;
   signal ln_bias_data     : std_logic_vector(LN_BIAS_DAC_DATA_WIDTH-1 downto 0);
   signal ln_bias_data_temp: std_logic_vector(LN_BIAS_DAC_DATA_WIDTH-1 downto 0);
   
   signal enbl_mux_wren    : std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0); 
   signal enbl_mux_data    : std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);

   signal mod_val_wren     : std_logic;

   signal enbl_flux_fb_mod_wren: std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0); 
   signal enbl_flux_fb_mod_data: std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);

   signal enbl_ln_bias_mod_wren: std_logic_vector(NUM_LN_BIAS_DACS-1 downto 0); 
   signal enbl_ln_bias_mod_data: std_logic_vector(2**LN_BIAS_DAC_ADDR_WIDTH-1 downto 0) := (others => '0');

   -- index of the ram_16x16 block used to store non-multiplexed values for flux_fb
   signal ram_addr         : std_logic_vector(FLUX_FB_DAC_ADDR_WIDTH-1 downto 0);
   signal addr             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0);   

   -- index of the ram_16x64 blocks dedicated to store flux_fb values for the particular column
   signal mux_ram_addr     : std_logic_vector(FLUX_FB_DAC_ADDR_WIDTH-1 downto 0);  
   signal row_flux_fb_wren : std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
   
   signal mux_ram_addr_int : integer range 0 to NUM_FLUX_FB_DACS-1 := 0;   
   signal ram_addr_int     : integer range 0 to NUM_FLUX_FB_DACS-1 := 0;
   signal ln_bias_ram_addr_int: integer range 0 to 2**LN_BIAS_DAC_ADDR_WIDTH-1 := 0;
   signal ln_bias_ram_raddr_int: integer range 0 to 2**LN_BIAS_DAC_ADDR_WIDTH-1 := 0;
   signal ln_bias_addr_1d  : std_logic_vector(LN_BIAS_DAC_ADDR_WIDTH-1 downto 0);
   
   -- used for generating wishbone ack 
   signal addr_qualifier   : std_logic;
   signal ack_read         : std_logic;
   signal ack_write        : std_logic;
   
   -- temp wire
   signal ln_bias_changed  : std_logic_vector(2**LN_BIAS_DAC_ADDR_WIDTH-1 downto 0);
   
begin
   -----------------------------------------------------------------
   -- RAM blocks for storing distinct values for each row (up to 41)
   -- FB_COL0 to FB_COL31  
   -- flux-fb storage when multiplexing is on
   -----------------------------------------------------------------
   ram_bank: for i in 0 to NUM_FLUX_FB_DACS-1 generate
      -- port a is used for updating DACs and port b for wishbone read
      flux_fb_mux_ram : ram_16x64
      port map
         (
            clock             => clk_i,
            data              => dat_i(FLUX_FB_DAC_DATA_WIDTH-1 downto 0),
            wren              => row_flux_fb_wren(i),
            wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0),
            rdaddress_a       => row_addr_i, --flux_fb_addr_i,
            rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0),
            qa                => mux_flux_fb_data(i),
            qb                => wb_mux_flux_fb_data(i)
         );
                  
   end generate ram_bank;
   mux_flux_fb_data_o <= mux_flux_fb_data;
   
   -----------------------------------------------------------------
   -- flux-fb storage when multiplexing is off (enbl_mux = 0)
   -----------------------------------------------------------------   
   reg_bank: for i in 0 to NUM_FLUX_FB_DACS-1 generate
      -- port a is used for updating DACs and port b for wishbone read
     fix_flux_fb_reg: process(clk_i, rst_i)
     begin
       if(rst_i = '1') then
         fix_flux_fb_data(i) <= (others => '0');            
       elsif(clk_i'event and clk_i = '1') then
         if(flux_fb_wren(i) = '1') then
           fix_flux_fb_data(i) <= dat_i(FLUX_FB_DAC_DATA_WIDTH-1 downto 0);
         else
           fix_flux_fb_data(i) <= fix_flux_fb_data(i);
         end if;
       end if;
     end process fix_flux_fb_reg;                  
     
     flux_fb_data_o(i) <= fix_flux_fb_data(i) + mod_val_data when enbl_flux_fb_mod_data(i) = '1' else fix_flux_fb_data(i);        
   end generate reg_bank;
   -- flux_fb_data_o <= fix_flux_fb_data;   
   
   -----------------------------------------------------------------
   -- RAM storage for up-to 16 ln_bias values
   -----------------------------------------------------------------
   -- port a is used for updating DACs (bc_dac_ctrl_core interface) and
   -- port b is for wishbone read
   ln_bias_ram : ram_16x16
   port map
      (
         clock             => clk_i,
         data              => dat_i(LN_BIAS_DAC_DATA_WIDTH-1 downto 0),
         wren              => ln_bias_wren,
         wraddress         => ram_addr(LN_BIAS_DAC_ADDR_WIDTH-1 downto 0),
         rdaddress_a       => ln_bias_addr_i,
         rdaddress_b       => ram_addr(LN_BIAS_DAC_ADDR_WIDTH-1 downto 0),
         qa                => ln_bias_data_temp,
         qb                => ln_bias_data
      );   
   ln_bias_data_o <= ln_bias_data_temp + mod_val_data when enbl_ln_bias_mod_data(ln_bias_ram_raddr_int) = '1' else ln_bias_data_temp;        
  
   -----------------------------------------------------------------
   -- mod_val storage when multiplexing is off (enbl_mux = 0)
   -----------------------------------------------------------------   
   mod_val_reg: process(clk_i, rst_i)
   begin
     if(rst_i = '1') then
       mod_val_data <= (others => '0');            
     elsif(clk_i'event and clk_i = '1') then
       if(mod_val_wren = '1') then
         mod_val_data <= dat_i(FLUX_FB_DAC_DATA_WIDTH-1 downto 0);
       else
         mod_val_data <= mod_val_data;
       end if;
     end if;
   end process mod_val_reg;                  
   
   -----------------------------------------------------------------   
   -- register multiplex mode enabled or not per column
   -----------------------------------------------------------------
   enbl_mux_data_o <= enbl_mux_data;
   enbl_mux_bank: for i in 0 to NUM_FLUX_FB_DACS-1 generate
     enbl_mux_reg: process (clk_i, rst_i)
     begin 
       if(rst_i = '1') then
         enbl_mux_data(i) <= '0'; --(others => '0');
       elsif(clk_i'event and clk_i = '1') then
         if(enbl_mux_wren(i) = '1') then
            enbl_mux_data(i) <= dat_i(0);
         end if;
       end if;  
     end process enbl_mux_reg;
   end generate enbl_mux_bank;   

   -----------------------------------------------------------------   
   -- register flux-fb-modulation enabled or not per column
   -----------------------------------------------------------------   
   enbl_flux_fb_mod_bank: for i in 0 to NUM_FLUX_FB_DACS-1 generate
     enbl_flux_fb_mod_reg: process (clk_i, rst_i)
     begin 
       if(rst_i = '1') then
         enbl_flux_fb_mod_data(i) <= '0'; 
       elsif(clk_i'event and clk_i = '1') then
         if(enbl_flux_fb_mod_wren(i) = '1') then
            enbl_flux_fb_mod_data(i) <= dat_i(0);
         end if;
       end if;  
     end process enbl_flux_fb_mod_reg;
   end generate enbl_flux_fb_mod_bank;   

   -----------------------------------------------------------------   
   -- register bias-modulation enabled or not per column
   -----------------------------------------------------------------   
   enbl_ln_bias_mod_bank: for i in 0 to NUM_LN_BIAS_DACS-1 generate
     enbl_ln_bias_mod_reg: process (clk_i, rst_i)
     begin 
       if(rst_i = '1') then
         enbl_ln_bias_mod_data(i) <= '0'; 
       elsif(clk_i'event and clk_i = '1') then
         if(enbl_ln_bias_mod_wren(i) = '1') then
            enbl_ln_bias_mod_data(i) <= dat_i(0);
         end if;
       end if;  
     end process enbl_ln_bias_mod_reg;
   end generate enbl_ln_bias_mod_bank;   
   
   ------------------------------------------------------------
   -- generate wren signals
   ------------------------------------------------------------
   i_gen_wren_signals: process (addr_i, we_i, ram_addr_int, mux_ram_addr_int, ln_bias_ram_addr_int)
   begin  -- process i_gen_wren_signals
   
     flux_fb_wren <= (others => '0');
     row_flux_fb_wren <= (others => '0');
     mod_val_wren <= '0';
         
     for i in 0 to NUM_FLUX_FB_DACS-1 loop
       enbl_mux_wren(i) <= '0';
       enbl_flux_fb_mod_wren(i) <= '0';
     end loop;  -- i
     for i in 0 to NUM_LN_BIAS_DACS-1 loop
       enbl_ln_bias_mod_wren(i) <= '0';
     end loop;  -- i
     
     case addr_i is
       when FLUX_FB_ADDR | FLUX_FB_UPPER_ADDR =>
         flux_fb_wren(ram_addr_int) <= we_i;

       when ENBL_MUX_ADDR =>
         enbl_mux_wren(ram_addr_int) <= we_i;
     
       when MOD_VAL_ADDR =>
         mod_val_wren <= we_i;

       when ENBL_FLUX_FB_MOD_ADDR =>
         enbl_flux_fb_mod_wren(ram_addr_int) <= we_i;
         
       when ENBL_BIAS_MOD_ADDR =>
         enbl_ln_bias_mod_wren(ln_bias_ram_addr_int) <= we_i;
         
       when FB_COL0_ADDR | FB_COL1_ADDR | FB_COL2_ADDR | FB_COL3_ADDR | FB_COL4_ADDR | FB_COL5_ADDR | FB_COL6_ADDR | FB_COL7_ADDR |
            FB_COL8_ADDR | FB_COL9_ADDR | FB_COL10_ADDR | FB_COL11_ADDR | FB_COL12_ADDR | FB_COL13_ADDR | FB_COL14_ADDR | FB_COL15_ADDR |
            FB_COL16_ADDR | FB_COL17_ADDR | FB_COL18_ADDR | FB_COL19_ADDR | FB_COL20_ADDR | FB_COL21_ADDR | FB_COL22_ADDR | FB_COL23_ADDR |
            FB_COL24_ADDR | FB_COL25_ADDR | FB_COL26_ADDR | FB_COL27_ADDR | FB_COL28_ADDR | FB_COL29_ADDR | FB_COL30_ADDR | FB_COL31_ADDR =>
         row_flux_fb_wren(mux_ram_addr_int) <= we_i;
             
       when others => null;
                      
     end case;    
   end process i_gen_wren_signals;
   
   ln_bias_wren <= we_i when addr_i = BIAS_ADDR else '0';
   ------------------------------------------------------------
   -- generate ram addresses
   ------------------------------------------------------------
   i_gen_addr_signals: process (addr_i, tga_i)
   begin -- process i_gen_addr_signals
     ram_addr <= tga_i(FLUX_FB_DAC_ADDR_WIDTH-1 downto 0);
     case addr_i is
        when FLUX_FB_UPPER_ADDR =>
           ram_addr <= tga_i(FLUX_FB_DAC_ADDR_WIDTH-1 downto 0) + 16;
           
        when others => null;     
     end case;
   end process i_gen_addr_signals;  
   
   mux_ram_addr <= addr_i(FLUX_FB_DAC_ADDR_WIDTH-1 downto 0);
      
   mux_ram_addr_int <= conv_integer(mux_ram_addr);
   ram_addr_int <= conv_integer(ram_addr);
   
   -- Note that one is the wishbone read/write address and the other is the read address for refreshing DACs
   ln_bias_ram_addr_int <= conv_integer(ram_addr(LN_BIAS_DAC_ADDR_WIDTH-1 downto 0)); 
   ln_bias_addr_reg: process(clk_i, rst_i)
   begin
     if(rst_i = '1') then
       ln_bias_addr_1d <= (others => '0');            
     elsif(clk_i'event and clk_i = '1') then
         ln_bias_addr_1d <= ln_bias_addr_i;
     end if;
   end process ln_bias_addr_reg;                  
   ln_bias_ram_raddr_int <= conv_integer(ln_bias_addr_1d);
   
   ------------------------------------------------------------
   -- generate flux_fb_changed_o and ln_bias_changed_o
   ------------------------------------------------------------
   i_gen_bias_changed: process(addr_i, ln_bias_ram_addr_int, we_i)
   begin
      ln_bias_changed <= (others => '0');         
     case addr_i is
       when BIAS_ADDR =>
         ln_bias_changed(ln_bias_ram_addr_int) <= we_i;
       when others => null;           
     end case;
   end process i_gen_bias_changed;
   ln_bias_changed_o <= ln_bias_changed(ln_bias_changed_o'length-1 downto 0) or 
                        (sxt(vectorize(mod_val_wren), ln_bias_changed_o'length) and enbl_ln_bias_mod_data(ln_bias_changed_o'length-1 downto 0)) or
                        (enbl_ln_bias_mod_wren(ln_bias_changed_o'length-1 downto 0) and enbl_ln_bias_mod_data(ln_bias_changed_o'length-1 downto 0));   
   flux_fb_changed_o <= flux_fb_wren or 
                        (sxt(vectorize(mod_val_wren), flux_fb_changed_o'length) and enbl_flux_fb_mod_data) or
                        (enbl_flux_fb_mod_wren and enbl_flux_fb_mod_data); 
                        --'1' when ((addr_i = FLUX_FB_ADDR or addr_i = FLUX_FB_UPPER_ADDR) and cyc_i = '1' and we_i = '1') else '0';
 
   ------------------------------------------------------------
   --  Wishbone interface
   ------------------------------------------------------------
   dat_o <= 
      ext(fix_flux_fb_data(ram_addr_int), WB_DATA_WIDTH)  when ((addr_i = FLUX_FB_ADDR) or (addr_i = FLUX_FB_UPPER_ADDR)) else
      ext(ln_bias_data, WB_DATA_WIDTH) when (addr_i =  BIAS_ADDR) else      
      ext("0",WB_DATA_WIDTH-1) & enbl_mux_data(ram_addr_int) when (addr_i =  ENBL_MUX_ADDR) else      
      ext("0",WB_DATA_WIDTH-1) & enbl_flux_fb_mod_data(ram_addr_int) when (addr_i =  ENBL_FLUX_FB_MOD_ADDR) else      
      ext("0",WB_DATA_WIDTH-1) & enbl_ln_bias_mod_data(ram_addr_int) when (addr_i =  ENBL_BIAS_MOD_ADDR) else       
      ext(mod_val_data, WB_DATA_WIDTH)     when (addr_i = MOD_VAL_ADDR) else
      ext(wb_mux_flux_fb_data(mux_ram_addr_int), WB_DATA_WIDTH) when (( addr_i >= FB_COL0_ADDR) and (addr_i <= FB_COL31_ADDR)) else
      (others => '0');

   with addr_i select
      addr_qualifier <= '1' when FLUX_FB_ADDR | BIAS_ADDR | FLUX_FB_UPPER_ADDR | ENBL_MUX_ADDR | ENBL_FLUX_FB_MOD_ADDR | ENBL_BIAS_MOD_ADDR | MOD_VAL_ADDR |
                                 FB_COL0_ADDR | FB_COL1_ADDR | FB_COL2_ADDR | FB_COL3_ADDR | FB_COL4_ADDR | FB_COL5_ADDR | FB_COL6_ADDR | FB_COL7_ADDR |
                                 FB_COL8_ADDR | FB_COL9_ADDR | FB_COL10_ADDR | FB_COL11_ADDR | FB_COL12_ADDR | FB_COL13_ADDR | FB_COL14_ADDR | FB_COL15_ADDR |
                                 FB_COL16_ADDR | FB_COL17_ADDR | FB_COL18_ADDR | FB_COL19_ADDR | FB_COL20_ADDR | FB_COL21_ADDR | FB_COL22_ADDR | FB_COL23_ADDR |
                                 FB_COL24_ADDR | FB_COL25_ADDR | FB_COL26_ADDR | FB_COL27_ADDR | FB_COL28_ADDR | FB_COL29_ADDR | FB_COL30_ADDR | FB_COL31_ADDR,
      '0'                   when others; 
      
   -- Wishbone Acknowlege signals
   i_gen_ack: process (clk_i, rst_i)    
     variable count : integer :=0;       -- counts number of clock cycles passed
     
   begin  -- process i_gen_ack
     if rst_i = '1' then                
        ack_read  <= '0';
        ack_write <= '0';
        count:=0;
             
     elsif clk_i'event and clk_i = '1' then  
       -- Write Acknowledge
       if (we_i = '1') and (addr_qualifier = '1') then
          if (stb_i = '1') and (ack_write = '0') then
             ack_write <= '1';
          else
             ack_write <= '0';
          end if;
       else
          ack_write <= '0';
       end if;
       
       -- Read Acknowledge
       if (we_i = '0') and ( addr_qualifier = '1') then        
          if (stb_i = '1') and (ack_read = '0') then
             count:=count+1;
             if count=2 then
                ack_read <= '1';
                count:=0;
             else 
                ack_read <= '0';
             end if;
          else
             ack_read <= '0';
          end if;              
       else
          ack_read <= '0';        
       end if;      
     end if;
   end process i_gen_ack;  
   ack_o <= ack_read or ack_write;
   
end rtl;