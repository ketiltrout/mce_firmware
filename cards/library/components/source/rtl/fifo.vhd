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
-- fifo.vhd
--
-- Project:	      SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Implementation of a parameterized show-ahead FIFO.
--
-- Revision history:
-- 
-- $Log: fifo.vhd,v $
-- Revision 1.3  2004/12/24 20:12:47  erniel
-- changed memory core to operate in flow-through mode
-- added read enable to memory core
-- removed mem_clk_i port (not necessary in flow-through mode)
--
-- Revision 1.2  2004/10/25 23:39:17  erniel
-- really minor cosmetic changes (spacing, word alignment, etc)
--
-- Revision 1.1  2004/10/25 18:58:49  erniel
-- initial version
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

library lpm;
use lpm.lpm_components.all;

entity fifo is
generic(DATA_WIDTH : integer := 32;
        ADDR_WIDTH : integer := 8);
port(clk_i     : in std_logic;
     rst_i     : in std_logic;

     data_i : in std_logic_vector(DATA_WIDTH-1 downto 0);
     data_o : out std_logic_vector(DATA_WIDTH-1 downto 0);

     read_i  : in std_logic;
     write_i : in std_logic;
     clear_i : in std_logic;
     
     empty_o : out std_logic;
     full_o  : out std_logic;
     error_o : out std_logic;
     used_o  : out integer);
end fifo;

architecture rtl of fifo is

component altsyncram
   generic(operation_mode         : string;
           width_a                : natural; 
           widthad_a              : natural;
           width_b                : natural;
           widthad_b              : natural;
           lpm_type               : string;
           width_byteena_a        : natural;
           outdata_reg_b          : string;
           indata_aclr_a          : string;
           wrcontrol_aclr_a       : string;
           address_aclr_a         : string;
           address_reg_b          : string;
           address_aclr_b         : string;
           outdata_aclr_b         : string;
           intended_device_family : string);
   port(clock0    : in std_logic;
        clock1    : in std_logic;
        wren_a    : in std_logic;
        address_a : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        data_a    : in std_logic_vector(DATA_WIDTH-1 downto 0);
        address_b : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        q_b       : out std_logic_vector(DATA_WIDTH-1 downto 0));
end component;

component lpm_counter
   generic(lpm_width     : NATURAL;
           lpm_type      : STRING;
           lpm_direction : STRING);
   port(clock  : in std_logic;
        cnt_en : in std_logic;
        sclr   : in std_logic;
        aclr   : in std_logic;
        q      : out std_logic_vector(ADDR_WIDTH-1 downto 0));
end component;

signal n_clk : std_logic;

-- storage controls:
signal write_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
signal read_addr  : std_logic_vector(ADDR_WIDTH-1 downto 0);
signal data_out   : std_logic_vector(DATA_WIDTH-1 downto 0);
signal write_ena  : std_logic;
signal read_ena   : std_logic;

-- item counter:
signal num_items : integer;

-- controller states:
type states is (EMPTY, SOME, FULL);
signal pres_state : states;
signal next_state : states;

begin
   -------------------------------------------------
   -- FIFO Datapath:
   -------------------------------------------------


   -- NOTES: 1. On FIFO clear, RAM storage is not reinitialized.  Pointers are reset and 
   --        item counter is reset and state machine assumes EMPTY.  You cannot read 
   --        from an empty FIFO, so there is no danger of reading invalid data.
   --
   --        2. I am using the altsyncram in flow-through mode.  In this mode, the read
   --        enable and read address registers are clocked using the negative clock edge.
   --        The data is available at the end of the clock cycle when the read address 
   --        is asserted.  See Altera Stratix device handbook vol. 2, page 2-23.
   
   fifo_storage : altsyncram
   generic map(operation_mode         => "DUAL_PORT",
               width_a                => DATA_WIDTH,
               widthad_a              => ADDR_WIDTH,
               width_b                => DATA_WIDTH,
               widthad_b              => ADDR_WIDTH,
               lpm_type               => "altsyncram",
               width_byteena_a        => 1,
               outdata_reg_b          => "UNREGISTERED",
               indata_aclr_a          => "NONE",
               wrcontrol_aclr_a       => "NONE",
               address_aclr_a         => "NONE",
               address_reg_b          => "CLOCK1",               
               address_aclr_b         => "NONE",
               outdata_aclr_b         => "NONE",
               intended_device_family => "Stratix")
   port map(clock0    => clk_i,
            clock1    => n_clk,
            wren_a    => write_ena,
            address_a => write_addr,
            data_a    => data_i,
            address_b => read_addr,
            q_b       => data_out);

   n_clk <= not clk_i;
   
   write_pointer: lpm_counter
   generic map(lpm_width     => ADDR_WIDTH,
               lpm_type      => "LPM_COUNTER",
               lpm_direction => "UP")
   port map(clock  => clk_i,
            cnt_en => write_ena,
            sclr   => clear_i,                                    -- if FIFO clear requested, zero write pointer.
            aclr   => rst_i,
            q      => write_addr);

   read_pointer: lpm_counter
   generic map(lpm_width     => ADDR_WIDTH,
               lpm_type      => "LPM_COUNTER",
               lpm_direction => "UP")
   port map(clock  => clk_i,
            cnt_en => read_ena,
            sclr   => clear_i,                                    -- if FIFO clear requested, zero read pointer.
            aclr   => rst_i,
            q      => read_addr);

   item_counter: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         num_items <= 0;
      elsif(clk_i'event and clk_i = '1') then
         if(clear_i = '1') then                                   -- if FIFO clear requested, clear item counter.
            num_items <= 0;
         elsif(read_i = '1' and num_items > 0) then               -- decrement on FIFO read when FIFO is not empty.
            num_items <= num_items - 1;
         elsif(write_i = '1' and num_items < 2**ADDR_WIDTH) then  -- increment on FIFO write when FIFO is not full.
            num_items <= num_items + 1;
         end if;
      end if;
   end process item_counter;

   used_o <= num_items;


   -------------------------------------------------
   -- FIFO Controller:
   -------------------------------------------------

   state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         pres_state <= EMPTY;
      elsif(clk_i'event and clk_i = '1') then
         if(clear_i = '1') then                                   -- if FIFO clear requested, move to EMPTY state.
            pres_state <= EMPTY;
         else
            pres_state <= next_state;
         end if;
      end if;
   end process state_FF;

   state_NS: process(pres_state, write_i, read_i, num_items)
   begin
      -- in EMPTY state:
      --    if FIFO write requested, move to SOME state.
      
      -- in SOME state:
      --    if FIFO read requested when FIFO is almost empty, move to EMPTY state.
      --    if FIFO write requested when FIFO is almost full, move to FULL state.
      
      -- in FULL state:
      --    if FIFO read requested, move to SOME state.
      
      case pres_state is
         when EMPTY =>  if(write_i = '1') then
                           next_state <= SOME;
                        else
                           next_state <= EMPTY;
                        end if;

         when SOME =>   if(read_i = '1' and num_items = 1) then
                           next_state <= EMPTY;
                        elsif(write_i = '1' and num_items = 2**ADDR_WIDTH-1) then
                           next_state <= FULL;
                        else
                           next_state <= SOME;
                        end if;

         when FULL =>   if(read_i = '1') then
                           next_state <= SOME;
                        else
                           next_state <= FULL;
                        end if;

         when others => next_state <= EMPTY;
      end case;
   end process state_NS;

   state_Out: process(pres_state, write_i, read_i, data_out)
   begin
      -- in EMPTY state:
      --    1. enable FIFO write when requested, disable FIFO read.
      --    2. assert empty flag.
      --    3. if FIFO read requested, assert error.

      -- in SOME state:
      --    1. both FIFO read and write are enabled when requested.
      --    2. output data at FIFO head.
                        
      -- in FULL state:
      --    1. disable FIFO write, enable FIFO read when requested.
      --    2. assert full flag.
      --    3. if FIFO write requested, assert error.
      --    4. output data at FIFO head.
                          
      case pres_state is
         when EMPTY =>  write_ena <= write_i;
                        read_ena  <= '0';
                        empty_o   <= '1';
                        full_o    <= '0';
                        error_o   <= read_i;
                        data_o    <= (others => '0');

         when SOME =>   write_ena <= write_i;
                        read_ena  <= read_i;
                        empty_o   <= '0';
                        full_o    <= '0';
                        error_o   <= '0';
                        data_o    <= data_out;

         when FULL =>   write_ena <= '0';
                        read_ena  <= read_i;
                        empty_o   <= '0';
                        full_o    <= '1';
                        error_o   <= write_i;
                        data_o    <= data_out;

         when others => null;
      end case;
   end process state_Out;

end rtl;