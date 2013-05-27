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
-- coadd_manager_data_path.vhd
--
-- Project:	  SCUBA-2
-- Author:        Mohsen Nahvi
-- Organisation:  UBC
--
-- Description:
-- 
-- This block is the data path in the coadd manager unit.  Coadd manager is a
-- component of the adc_sample_coadd block.
-- 
-- The actions taken in this block are:
--
-- 1. Sampled data from ADC is corrected with the value of the offset.  The
-- offset value, adc_offset_dat_i, is read from wbs_fb_data.  To access this
-- value,adc_offset_adr_o is asserted.  The address is the same as the address
-- index that this block is using to write data to memory banks.  In essense,
-- for the same row number we use one address index to read ADC offset value
-- and then write to the same memeory location with the same address index.
-- As an example,for row 0, the address index count=0.  adc_offset_adr_o=0, so
-- we read adc_offset_dat_i from location 0.  Also, we write the coadded data
-- into location 0 in the current memeory bank.  The same is true for writing
-- integral value.  Note that address index generated in this block is
-- universally used in adc_sample_coadd block, except in the raw acquisition
-- block. In other words, dynamic_manager_data_path also uses the same address
-- index generated here.
-- 
-- 2. During the active window for adc_coadd_en_i, the sampled data from ADC is
-- added to the previous values and saved into a register (samples_coadd_reg).
-- In order to take into account the latency of the ADC, the adc_coadd_en_i is
-- fed into a shift register and the appropriate tap (4 delays) is used as the
-- active window for addition.
-- 
-- 3. Data is saved in the "current_bank" at the end of the active window. The
-- address index for write channel of these banks uses an up counter.  This
-- counter is running using an enable signal from the contoller.  When the
-- data is saved, necessary control signals are issued to clear the address
-- counter and the "samples_coadd_reg" reg.
--
-- Ports:
-- #rst_i: global reset active high
-- #clk_i: global clock
-- #adc_dat_i: Input to adc_sample_coadd block from ADC
-- #adc_offset_dat_i: Input from wbs_fb_data.  Per row we need to get this
-- value. Only the least significant 14 bits used in correcting the value of
-- adc_dat_i.
-- #adc_offset_adr_o: Output to wbs_fb_data.  This is the address index to
-- retrieve the adc_offset_dat_i from the dedicated memory in wbs_fb_data. Note
-- that the address index for coadd_write_addr_o is used for this purpose as
-- the address indices are equal.
-- #adc_coadd_en_i: Input to adc_sample_coadd block from frame_timing block.
-- This signal is high for nudetermind length during each row cycle time
-- #adc_coadd_en_5delay_o: out to coadd_dynamic_manager_ctrl block.  This
-- signals is the 5th clock delay of adc_coadd_en_i.
-- #adc_coadd_en_4delay_o: same as adc_coadd_en_5delay_o, but the 4th clock
-- delay
-- #clr_samples_coadd_reg_i: Input signal from coadd_dynamic_manager_ctrl and
-- is assrted high (true) for entire duration of coadding plus two colck
-- cycles. 
-- In the 1st clock cycle the data is written into the memory bank, and in the
-- 2nd cycle the register is cleared.  This signal clears the register holding
-- the coadd value
-- #samples_coadd_reg_o: output to coadd_dat_bank0/1 and
-- dynamic_dat_manage_data_path.  It holds the coadded value at any time during
-- coadding and holds its last value when not coadding and before getting
-- cleared for the next coadding.
-- #address_count_en_i: Input from coadd_dynamic_manager_ctrl.  This signal is
-- high for only one clock cycle after the coadded value is writen into the
-- memory bank.  It enables the index counter to the next memory location.
-- Note that the address index points to the present row during coadding.
-- #clr_address_count_i: Input from coadd_dynamic_manager_ctrl.  This signal is
-- asserted high for one clock cycle and only once per frame.  It is asserted
-- after the coaddition of the last row in a frame is done.  It clears the
-- address index that points to the location where in the memory bank the
-- coadded data is stored.
-- #coadd_write_addr_o: Index address output to wraddress input of
-- coadd_dat_bank0/1 and wraddress input of intgrl_dat_bank0/1.  This output
-- points to the location in the respective memory banks where the coadd and
-- integral data are saved for the current row.
--
-- signals:
-- #adc_dat: This is the output of the correction block that subtracts the adc
-- offeset from the ADC inputs.
-- #shifted_adc_coadd_en: A shift register to shift adc_coadd_en_i.
-- #samples_coadd_reg: internal representation of samples_coadd_reg_o.
-- count: address index to the memory location where coadd data and integral
-- data are saved.  Also, represents the current row cycle during coadding.
-- Also,represnts the address index to retrieve adc_offset_dat_i.  In other
-- workds,count is the same as adc_offset_adr_o.
-- 
--
-- Revision history:
-- 
-- $Log: coadd_manager_data_path.vhd,v $
-- Revision 1.6  2011-09-15 23:46:44  mandana
-- coadd window now is adjusted for ADC latency as oppose to hard-coded value of 4
--
-- Revision 1.5  2009/04/09 19:10:44  bburger
-- BB: Removed the default assignement of ADC_LATENCY which is a constant that doesn't exist anymore.
--
-- Revision 1.4  2004/12/13 21:50:22  mohsen
-- To avoid synthesis complication, changed the construct to generate shift register.
--
-- Revision 1.3  2004/11/26 18:25:54  mohsen
-- Anthony & Mohsen: Restructured constant declaration.  Moved shared constants from lower level package files to the upper level ones.  This was done to resolve compilation error resulting from shared constants defined in multiple package files.
--
-- Revision 1.2  2004/10/29 01:53:50  mohsen
-- Sorted out library use and use parameters
--
-- Revision 1.1  2004/10/22 00:14:37  mohsen
-- Created
--
--
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

library work;
use work.adc_sample_coadd_pack.all;

-- Call Parent Library
use work.flux_loop_ctrl_pack.all;
use work.flux_loop_pack.all;
use work.readout_card_pack.all;


entity coadd_manager_data_path is

  generic (
    MAX_COUNT                 : integer := TOTAL_ROW_NO;
    MAX_SHIFT                 : integer); -- = Delay stages for coadd enable (to compensate for ADC latency)
                                          
                                                            
  port (
    rst_i                     : in  std_logic;
    clk_i                     : in  std_logic;
    adc_dat_i                 : in  std_logic_vector(ADC_DAT_WIDTH-1 downto 0);
    adc_offset_dat_i          : in  std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
    adc_offset_adr_o          : out std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
    adc_coadd_en_i            : in  std_logic;
    adc_coadd_en_5delay_o     : out std_logic;
    adc_coadd_en_4delay_o     : out std_logic;
    clr_samples_coadd_reg_i   : in  std_logic;
    samples_coadd_reg_o       : out std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
    address_count_en_i        : in  std_logic;
    clr_address_count_i       : in  std_logic;
    coadd_write_addr_o        : out std_logic_vector(COADD_ADDR_WIDTH-1 downto 0);
    servo_rst_addr_o          : out std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0));
    

end coadd_manager_data_path;



architecture beh of coadd_manager_data_path is


  -- Signal needed in the correction block
  signal adc_dat : std_logic_vector(ADC_DAT_WIDTH-1 downto 0);
  

  -- Signals needed for the shift register
  signal shifted_adc_coadd_en : std_logic_vector(MAX_SHIFT-1 downto 0);
  alias  adc_coadd_en_5delay  : std_logic is shifted_adc_coadd_en(MAX_SHIFT-1);
  alias  adc_coadd_en_4delay  : std_logic is shifted_adc_coadd_en(MAX_SHIFT-2);
  
  
  -- Signals needed in the Registered Adder
  signal samples_coadd_reg    : std_logic_vector (COADD_DAT_WIDTH-1 downto 0); 

  
  -- Signals needed in Address Index Counter
  signal count                : integer range 0 to MAX_COUNT;
  

 

begin  -- beh


  -----------------------------------------------------------------------------
  -- Correction Block:
  -- This block subtracts the ADC offset value from the ADC input value. Note
  -- that the address is the same as the write address for the coadded data as
  -- it is the address index shown by count that represents the row we are
  -- working at.
  -----------------------------------------------------------------------------

  adc_dat <= adc_dat_i - adc_offset_dat_i(ADC_DAT_WIDTH-1 downto 0);  
                                                                        
  
  -----------------------------------------------------------------------------
  -- Shift Register:
  -- Delays adc_coadd_en_i by MAX_SHIFT.  There are taps for each shift in the
  -- form of aliases signals.
  -----------------------------------------------------------------------------

  i_delay_adc_coadd_en: process (clk_i, rst_i)
       
  begin  -- process i_delay_adc_coadd_en
    if rst_i = '1' then                 -- asynchronous reset (active high)
      shifted_adc_coadd_en <= (others => '0');
      
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
      
      shifted_adc_coadd_en(MAX_SHIFT-1 downto 1) <= shifted_adc_coadd_en(MAX_SHIFT-2 downto 0);
      shifted_adc_coadd_en(0)                    <= adc_coadd_en_i;

    end if;
  end process i_delay_adc_coadd_en;

  adc_coadd_en_5delay_o <= adc_coadd_en_5delay;
  adc_coadd_en_4delay_o <= adc_coadd_en_4delay;


  
  -----------------------------------------------------------------------------
  -- Registered Adder:
  -- This unit synchronously addes the "corrected" new sample data from ADC
  -- (adc_dat) to the sum of its previous values.  The addition is a signed
  -- addition, so the sign bit of the adc_dat is extended.  The addition is
  -- performed during the active window, i.e., during the adc_coadd_en_4delay.
  -- The 4th clock delay of the adc_coadd_en_i is used, as the latency in the
  -- ADC is 4 clock cycles.  Moreover, the unit clears the register during the
  -- inactive window only if clr_samples_coadd_reg_i is asserted.  In effect,
  -- this clear signal is logical OR of adc_coadd_en_4delay and
  -- adc_coadd_en_5delay signals.  In other words the falling edge of
  -- adc_coadd_en_5delay activates the clear signal and the risign edge of the
  -- adc_coadd_en_4delay disactivates it.  This extra clock cycle is need to
  -- write the contents of the register into the memory bank.
  -----------------------------------------------------------------------------


  i_coadd: process (clk_i, rst_i)
  begin  -- process i_coadd
    if rst_i = '1' then                 -- asynchronous reset (active high)
      samples_coadd_reg <= (others => '0');
      
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
     
      if adc_coadd_en_4delay = '1' then
        samples_coadd_reg <= samples_coadd_reg + adc_dat;
      elsif clr_samples_coadd_reg_i = '1' then
        samples_coadd_reg <= (others => '0');
      else
        samples_coadd_reg <= samples_coadd_reg;
      end if;
      
    end if;
  end process i_coadd;

  samples_coadd_reg_o <= samples_coadd_reg;

  

  -----------------------------------------------------------------------------
  -- Address  Index Counter:
  -- This block counts up the address index for write port of the coadd data
  -- banks.  The index is also used to write to the integral memeory bank too.
  -- It is also used as a read index in other parts of adc_sample_coadd block.
  -- The counter is only active during a small window (one clk cycle)
  -- long.  It gets cleared during the beginning of a frame sequence.  Note
  -- that the number of rows in a frame could change, so the only information
  -- available to the number of rows in a frame is from the clr_address_count_i
  -- This signal in turn is derived from last_row_5delay that in turn is
  -- dervied from restart_frame_1row_prev_i.
  -----------------------------------------------------------------------------
   
  i_address_index_count: process (clk_i, rst_i)
  begin  -- process i_address_index_count
    if rst_i = '1' then                 -- asynchronous reset (active hig)
      count <= 0;
      
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge

      if (clr_address_count_i = '1') then
        count <=0;
      elsif (address_count_en_i = '1') then
        if (count = MAX_COUNT-1) then
          count <= 0;
        else
          count <= count +1;
        end if;
      end if;
            
    end if;
  end process i_address_index_count;

  coadd_write_addr_o <=conv_std_logic_vector(count, coadd_write_addr_o'length);
  adc_offset_adr_o   <=conv_std_logic_vector(count, adc_offset_adr_o'length); 
  servo_rst_addr_o   <=conv_std_logic_vector(count, servo_rst_addr_o'length);
  
end beh;
