-- Copyright (c) 2003 SCUBA-2 Project
--                  All Rights Reserved

--  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
--  The copyright notice above does not evidence any
--  actual or intended publication of such source code.

--  SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
--  REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
--  MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
--  PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
--  THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.

-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.

-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1

-- 
--
-- <revision control keyword substitutions e.g. $Id: async_fifo.vhd,v 1.2 2004/04/28 15:57:51 dca Exp $>
--
-- Project:	      SCUBA-2
-- Author:	      David Atkinson
--               
-- Organisation:  UK ATC
--
-- Description: Generic byte wide asynchronous FIFO
-- instantiated by blocks rx_fifo and tx_fifo
--
-- Includes full and empty flags. 
--
--
-- Revision history:
-- 29th March 2004   - Initial version      - DA
-- 
-- <date $Date: 2004/04/28 15:57:51 $>	-		<text>		- <initials $Author: dca $>
--
-- <$log$>
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity async_fifo is
   generic( 
      fifo_size : Positive
   );
   port( 
      rst_i     : in     std_logic;
      read_i    : in     std_logic;
      write_i   : in     std_logic;
      d_i       : in     std_logic_vector (7 downto 0);
      empty_o   : out    std_logic;
      full_o    : out    std_logic;
      q_o       : out    std_logic_vector (7 downto 0)
   );

end async_fifo ;


architecture rtl of async_fifo is

   -- Architecture Declarations
   
   subtype fifo_deep is integer range 0 to fifo_size-1;
   subtype fifo_fill is integer range 0 to fifo_size;

   subtype word is std_logic_vector(7 downto 0);
   type mem is array (0 to fifo_size-1) of word;
   signal memory: mem;

   signal write_pointer : fifo_deep;
   signal read_pointer  : fifo_deep;
   signal fifo_count    : fifo_fill;
   signal empty         : std_logic;
   signal full          : std_logic;


begin

   empty_o <= empty;
   full_o <= full;
   
   ----------------------------------------------------------------------------
   fifo_write_ram : process(rst_i, write_i)
   ----------------------------------------------------------------------------
   -- process to write to fifo ram 
   ----------------------------------------------------------------------------
  
   begin
      if (rst_i = '1') then
         write_pointer <= 0;
      else 
         if (write_i'EVENT and write_i = '1') then
            memory(write_pointer) <= d_i; 
               if (write_pointer = fifo_size-1) then
                  write_pointer <= 0;
               else
                  write_pointer <= write_pointer + 1;
               end if; 
         end if;
      end if; 
    end process fifo_write_ram;

  ----------------------------------------------------------------------------
   fifo_read_ram : process(rst_i, read_i)
   ----------------------------------------------------------------------------
   -- process to read from fifo ram
   ----------------------------------------------------------------------------
  
   begin
      if (rst_i = '1') then
         read_pointer <= 0;
      elsif (read_i'EVENT and read_i = '1') then
         q_o <=  memory(read_pointer);
         if (read_pointer = fifo_size-1) then
            read_pointer <= 0;
         else
            read_pointer <= read_pointer + 1;
         end if;
      end if; 
    end process fifo_read_ram;

   ----------------------------------------------------------------------------
   fifo_state : process(read_pointer, write_pointer)
   ----------------------------------------------------------------------------
   -- process to establish how many words are currently in the fifo
   ----------------------------------------------------------------------------
   
   begin
   
      if write_pointer < read_pointer then 
         fifo_count <= fifo_size + write_pointer - read_pointer;
      else 
         fifo_count <= write_pointer - read_pointer; 
      end if;   
   end process fifo_state;
        
   ----------------------------------------------------------------------------
   flag_fifo : process(fifo_count)
   ----------------------------------------------------------------------------
   -- process which sets the full and empty flags depending on # words in fifo
   ----------------------------------------------------------------------------
      begin
         if fifo_count = 0 then
            empty <= '1';
            full <= '0';
         elsif fifo_count = fifo_size-1 then      -- this actually full - 1
            full <= '1';                          -- will update later 
            empty <= '0';
         else
            empty <= '0';
            full <= '0';
         end if;
      end process flag_fifo;


end rtl;
