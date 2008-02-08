-- Copyright (c) 2003 SCUBA-2 Project
--               All Rights Reserved
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
-- all_cards.vhd
--
-- Project:      SCUBA2
-- Author:       Mandana Amiri
-- Organisation: UBC
--
-- Description: This module defines series of registers that are common to all cards
--              For now: fw_rev, card_type, scratch 0 to 7, slot_id
------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library sys_param;
use sys_param.wishbone_pack.all;
use sys_param.command_pack.all;

library work;
use work.all_cards_pack.all;

entity all_cards is
generic(REVISION        :std_logic_vector (WB_DATA_WIDTH-1 downto 0) := X"01010001"; 
        CARD_TYPE       :std_logic_vector (CARD_TYPE_WIDTH-1 downto 0) := b"111"
        );
   port(clk_i           : in std_logic;
        rst_i           : in std_logic;

        -- Wishbone signals
        dat_i           : in std_logic_vector (WB_DATA_WIDTH-1 downto 0);
        addr_i          : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
        tga_i           : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
        we_i            : in std_logic;
        stb_i           : in std_logic;
        cyc_i           : in std_logic;
        slot_id_i       : in std_logic_vector (SLOT_ID_BITS-1 downto 0);
        err_all_cards_o : out std_logic;
        qa_all_cards_o  : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
        ack_all_cards_o : out std_logic
      );
end all_cards;

architecture rtl of all_cards is
  constant ALL_CARDS_BANK_MAX_WIDTH    : integer := WB_DATA_WIDTH;
  constant FW_REV_INDEX_OFFSET         : integer := 0;   -- Index of firmware revision
  constant CARD_TYPE_INDEX_OFFSET      : integer := 1;   -- Index of card_type
  constant SLOT_ID_INDEX_OFFSET        : integer := 2;
  constant SCRATCH_INDEX_OFFSET        : integer := 3;   -- A Read/write wakeup register that is reset to 0 everytime the firmware is reset.
  constant ALL_CARDS_BANK_MAX_RANGE    : integer := 11;   -- Maximum number of parameters in the Miscellanous bank
 
  constant MAX_SCRATCH_INDEX           : integer := 8;
  constant MAX_SCRATCH_INDEX_BITS      : integer := 3;
 
  -----------------------------------------------------------------------------
  -- Registers for each value
  -- Note: we have used 32-bit registers across the board, as the wishbone
  -- interface is 32 bits.  Clearly, some of these don't have to be 32b
  -----------------------------------------------------------------------------

  type all_cards_bank is array (0 to ALL_CARDS_BANK_MAX_RANGE-1) of std_logic_vector(ALL_CARDS_BANK_MAX_WIDTH-1 downto 0);
  signal reg : all_cards_bank;
  
  type wren_banks is array (0 to ALL_CARDS_BANK_MAX_RANGE-1) of std_logic;
  signal wren : wren_banks;
 
  signal scratch            : std_logic_vector(ALL_CARDS_BANK_MAX_WIDTH-1 downto 0);
  
  signal ack_all_cards_bank : std_logic;
  
  begin --rtl
-----------------------------------------------------------------------------
-- Instantiation of All Registers
----------------------------------------------------------------------------- 

  i_all_cards_bank: for i in 0 to ALL_CARDS_BANK_MAX_RANGE-1 generate
    i_reg: process (clk_i, rst_i)
    begin  -- process i_reg
      if rst_i = '1' then               -- asynchronous reset (active high)
        if i = FW_REV_INDEX_OFFSET then
          reg(i) <= REVISION;
        elsif i= CARD_TYPE_INDEX_OFFSET then
          reg(i) <= ext(CARD_TYPE, reg(i)'length);          
        elsif i= SLOT_ID_INDEX_OFFSET then
          reg(i) <= ext(slot_id_i, WB_DATA_WIDTH);
        else
          reg(i) <= (others => '0');
        end if;
      elsif clk_i'event and clk_i = '1' then  -- rising clock edge
        if wren(i)='1' then
          reg(i) <= dat_i;
        end if;
      end if;
    end process i_reg;
  end generate i_all_cards_bank;
  
  -----------------------------------------------------------------------------
  -- Controller for All Registers:
  -- 
  -- 1. Write Enable signals for each bank is equal to the dispatch we_i when
  -- the address from dispatch, addr_i, is equals to that bank's address
  --
  -- 2. Acknowledge signals are the same for Write or Read cycle. It is simply
  -- the logical AND of stb_i and cyc_i when addr_i is equal to the address of
  -- the parameters used in this block.
  -- 
  -----------------------------------------------------------------------------

  -- Write Enable Signals
  i_gen_wren_signals: process (addr_i, we_i, tga_i)
  begin  -- process i_gen_wren_signals
  
    for i in 0 to ALL_CARDS_BANK_MAX_RANGE-1 loop
      wren(i) <= '0';
    end loop;  -- i
     
    case addr_i is
    
      when SCRATCH_ADDR =>
        case tga_i(MAX_SCRATCH_INDEX_BITS-1 downto 0) is
          when "000" => wren(SCRATCH_INDEX_OFFSET+0) <= we_i;
          when "001" => wren(SCRATCH_INDEX_OFFSET+1) <= we_i;
          when "010" => wren(SCRATCH_INDEX_OFFSET+2) <= we_i;
          when "011" => wren(SCRATCH_INDEX_OFFSET+3) <= we_i;
          when "100" => wren(SCRATCH_INDEX_OFFSET+4) <= we_i;
          when "101" => wren(SCRATCH_INDEX_OFFSET+5) <= we_i;
          when "110" => wren(SCRATCH_INDEX_OFFSET+6) <= we_i;
          when "111" => wren(SCRATCH_INDEX_OFFSET+7) <= we_i;
          when others => null;
        end case;        
      
      when others => null;
                     
    end case;
  end process i_gen_wren_signals;

  -- Acknowlege signal
  with addr_i select
    ack_all_cards_o <=
    (stb_i and cyc_i and (not we_i)) when FW_REV_ADDR | CARD_TYPE_ADDR | SLOT_ID_ADDR,
    (stb_i and cyc_i) when SCRATCH_ADDR,
    '0'               when others;

  -- Wishbone Error signal
  with addr_i select 
    err_all_cards_o <= 
       we_i when FW_REV_ADDR | CARD_TYPE_ADDR | SLOT_ID_ADDR,
       '0'      when others; 
       
  -----------------------------------------------------------------------------
  -- Output MUX to Dispatch:
  -- 
  -- The addr_i selects which bank is sending its output to the dispatch.  The
  -- defulat connection is to fw_rev.
  -- We use two levels of muxes to do the selection.  The first level selects
  -- based on the tga_i for those registers that hold multiple values of same
  -- parameter, e.g., scratch, etc. The second level of muxes selects
  -- based on the address present on addr_i.
  -----------------------------------------------------------------------------

  with tga_i(MAX_SCRATCH_INDEX_BITS-1 downto 0) select
    scratch <=
    reg(SCRATCH_INDEX_OFFSET+0) when "000",
    reg(SCRATCH_INDEX_OFFSET+1) when "001",
    reg(SCRATCH_INDEX_OFFSET+2) when "010",
    reg(SCRATCH_INDEX_OFFSET+3) when "011",
    reg(SCRATCH_INDEX_OFFSET+4) when "100",
    reg(SCRATCH_INDEX_OFFSET+5) when "101",
    reg(SCRATCH_INDEX_OFFSET+6) when "110",
    reg(SCRATCH_INDEX_OFFSET+7) when "111",
    reg(SCRATCH_INDEX_OFFSET+0) when others;

  with addr_i select
    qa_all_cards_o <=
    
    reg(FW_REV_INDEX_OFFSET)      when FW_REV_ADDR,
    reg(CARD_TYPE_INDEX_OFFSET)   when CARD_TYPE_ADDR,
    reg(SLOT_ID_INDEX_OFFSET)     when SLOT_ID_ADDR,
    scratch                       when SCRATCH_ADDR,
    reg(FW_REV_INDEX_OFFSET)      when others;           -- default to first value in bank

end rtl;