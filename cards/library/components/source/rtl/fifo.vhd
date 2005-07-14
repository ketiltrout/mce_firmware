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
-- Revision 1.5  2005/01/13 01:50:16  mandana
-- pointer management bug fixed for the simultaneous read/write case
--
-- Revision 1.4  2004/12/24 21:06:44  erniel
-- removed read enable from memory core (it didn't work)
--
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
port(clk_i   : in std_logic;
     rst_i   : in std_logic;

     data_i  : in std_logic_vector(DATA_WIDTH-1 downto 0);
     data_o  : out std_logic_vector(DATA_WIDTH-1 downto 0);

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
   generic(OPERATION_MODE         : string;
           WIDTH_A                : natural; 
           WIDTHAD_A              : natural;
           WIDTH_B                : natural;
           WIDTHAD_B              : natural;
           LPM_TYPE               : string;
           WIDTH_BYTEENA_A        : natural;
           OUTDATA_REG_B          : string;
           INDATA_ACLR_A          : string;
           WRCONTROL_ACLR_A       : string;
           ADDRESS_ACLR_A         : string;
           ADDRESS_REG_B          : string;
           ADDRESS_ACLR_B         : string;
           OUTDATA_ACLR_B         : string;
           INTENDED_DEVICE_FAMILY : string);
   port(clock0    : in std_logic;
        clock1    : in std_logic;
        wren_a    : in std_logic;
        address_a : in std_logic_vector(WIDTHAD_A-1 downto 0);
        data_a    : in std_logic_vector(WIDTH_A-1 downto 0);
        address_b : in std_logic_vector(WIDTHAD_B-1 downto 0);
        q_b       : out std_logic_vector(WIDTH_B-1 downto 0));
end component;

component lpm_counter
   generic(LPM_WIDTH     : natural;
           LPM_TYPE      : string;
           LPM_DIRECTION : string);
   port(clock  : in std_logic;
        cnt_en : in std_logic;
        sclr   : in std_logic;
        aclr   : in std_logic;
        q      : out std_logic_vector(LPM_WIDTH-1 downto 0));
end component;

signal n_clk : std_logic;

-- storage controls:
signal write_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
signal read_addr  : std_logic_vector(ADDR_WIDTH-1 downto 0);
signal data_out   : std_logic_vector(DATA_WIDTH-1 downto 0);
signal write_ena  : std_logic;
signal read_ena   : std_logic;

-- item counter controls:
signal items_ena : std_logic;
signal items     : integer;

-- FIFO flags:
signal fifo_full   : std_logic;
signal fifo_empty  : std_logic;
signal write_nread : std_logic;

begin

   -- NOTES: 1. On FIFO clear, RAM storage is not reinitialized.  Pointers are reset and 
   --        item counter is reset and the FIFO empty flag is asserted.  You cannot read 
   --        from an empty FIFO, so there is no danger of reading invalid data.
   --
   --        2. I am using the altsyncram in flow-through mode.  In this mode, the read
   --        enable and read address registers are clocked using the negative clock edge.
   --        The data is available at the end of the clock cycle when the read address 
   --        is asserted.  See Altera Stratix device handbook vol. 2, page 2-23.
   
   fifo_storage : altsyncram
   generic map(OPERATION_MODE         => "DUAL_PORT",
               WIDTH_A                => DATA_WIDTH,
               WIDTHAD_A              => ADDR_WIDTH,
               WIDTH_B                => DATA_WIDTH,
               WIDTHAD_B              => ADDR_WIDTH,
               LPM_TYPE               => "altsyncram",
               WIDTH_BYTEENA_A        => 1,
               OUTDATA_REG_B          => "UNREGISTERED",
               INDATA_ACLR_A          => "NONE",
               WRCONTROL_ACLR_A       => "NONE",
               ADDRESS_ACLR_A         => "NONE",
               ADDRESS_REG_B          => "CLOCK1",
               ADDRESS_ACLR_B         => "NONE",
               OUTDATA_ACLR_B         => "NONE",
               INTENDED_DEVICE_FAMILY => "Stratix")
   port map(clock0    => clk_i,
            clock1    => n_clk,
            wren_a    => write_ena,
            address_a => write_addr,
            data_a    => data_i,
            address_b => read_addr,
            q_b       => data_out);

   n_clk <= not clk_i;
   
   write_pointer: lpm_counter
   generic map(LPM_WIDTH => ADDR_WIDTH,
               LPM_TYPE  => "LPM_COUNTER",
               LPM_DIRECTION => "UP")
   port map(clock  => clk_i,
            cnt_en => write_ena,
            sclr   => clear_i,                                    -- if FIFO clear requested, zero write pointer.
            aclr   => rst_i,
            q      => write_addr);

   read_pointer: lpm_counter
   generic map(LPM_WIDTH => ADDR_WIDTH,
               LPM_TYPE  => "LPM_COUNTER",
               LPM_DIRECTION => "UP")
   port map(clock  => clk_i,
            cnt_en => read_ena,
            sclr   => clear_i,                                    -- if FIFO clear requested, zero read pointer.
            aclr   => rst_i,
            q      => read_addr);     

   write_ena <= write_i and not fifo_full;
   
   read_ena  <= read_i and not fifo_empty;
   
   
   -- This process implements the item counter.
   item_counter: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         items <= 0;
      elsif(clk_i'event and clk_i = '1') then
         if(clear_i = '1') then
            items <= 0;
         elsif(items_ena = '1') then
            if(write_ena = '1') then
               items <= items + 1;
            else
               items <= items - 1;
            end if;
         end if;
      end if;
   end process;
   
   items_ena <= write_ena xor read_ena;
   

   -- This flag indicates whether a write and no read has just occured.  The flag is used in
   -- determining whether the FIFO is full or empty in the case where both pointers are equal. 
   write_no_read_flag: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         write_nread <= '0';
      elsif(clk_i'event and clk_i = '1') then
         if(clear_i = '1') then
            write_nread <= '0';
         elsif(write_i = '1' or read_i = '1') then
            write_nread <= write_i and not read_i;
         end if;
      end if;
   end process write_no_read_flag;

   fifo_empty <= '1' when write_addr = read_addr and write_nread = '0' else '0';
      
   fifo_full  <= '1' when write_addr = read_addr and write_nread = '1' else '0';
   
   
   -- This process implements a mux that controls the data output.  Data_o is "00...0" when 
   -- the FIFO is empty, even though the data_out from the FIFO storage is not (since the 
   -- memory is not cleared on assertion of clear_i).
   data_output: process(data_out, fifo_empty)
   begin
      if(fifo_empty = '1') then
         data_o <= (others => '0');
      else
         data_o <= data_out;
      end if;
   end process data_output;      
      
   empty_o <= fifo_empty;
      
   full_o  <= fifo_full;
   
   error_o <= (read_i and fifo_empty) or (write_i and fifo_full);
   
   used_o  <= items;

end rtl;