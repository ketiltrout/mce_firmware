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
-- <revision control keyword substitutions e.g. $Id: async_fifo.vhd,v 1.5 2004/07/08 10:46:37 dca Exp $>
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
-- <date $Date: 2004/07/08 10:46:37 $>	-		<text>		- <initials $Author: dca $>
--
-- <$log$>
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity async_fifo is
   generic( 
      addr_size : Positive
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


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


architecture rtl of async_fifo is

   -- Architecture Declarations
  
   
   subtype word is std_logic_vector(7 downto 0);                     -- define the size of a fifo word
   type mem is array (0 to 2**addr_size-1) of word;                  -- define the size of the fifo ram
   signal memory        : mem;                                       -- assign the ram to signal 'memory'

   signal write_addr    : std_logic_vector(addr_size-1 downto 0);    --  ram write address
   signal read_addr     : std_logic_vector(addr_size-1 downto 0);    --  ram read address 
   
   subtype fifo_deep is integer range 0 to 2**addr_size-1;
   signal fifo_count    : fifo_deep;                                 -- number of words in fifo still to be read
   signal last_count    : fifo_deep;                                 -- number of words in fifo before last read/write
   
   signal empty         : std_logic;                                 -- empty flag
   signal full          : std_logic;                                 -- full flag


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
         write_addr <= (others => '0');
         for i in 0 to (2**addr_size-1) loop
            memory(i) <= (others => '0');
         end loop;
      elsif (write_i'EVENT and write_i = '1') then
         memory(to_integer(unsigned(write_addr))) <= d_i; 
            if ((to_integer(unsigned(write_addr))) = 2**addr_size-1) then          -- if at last address
               write_addr <= (others => '0');                                      -- reset to 0
            else                                                                   -- else increment by 1
               write_addr <= std_logic_vector(to_unsigned((to_integer(unsigned(write_addr)) + 1), addr_size));
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
         read_addr <= (others => '0');
         q_o <= (others => '0');
      elsif (read_i'EVENT and read_i = '1') then
         q_o <=  memory(to_integer(unsigned(read_addr)));
         if (to_integer(unsigned(read_addr)) = 2**addr_size-1) then        -- if at last address 
            read_addr <= (others => '0');                                  -- reset to 0
         else                                                              -- else increament by 1
            read_addr <= std_logic_vector(to_unsigned((to_integer(unsigned(read_addr)) + 1), addr_size));
         end if;
      end if; 
    end process fifo_read_ram;


   -----------------------------------------------------
   save_last_count: process(read_addr(0), write_addr(0))
   -----------------------------------------------------
   -- process to save last value of fifo_count if 
   -- read_addr or write_addr are incremented.
   -- used to establish if fifo is full or empty
   ------------------------------------------------------
   begin
      last_count <= fifo_count;      -- save last fifo_count                 
   end process;

   ----------------------------------------------------------------------------
   fifo_state : process(read_addr, write_addr)
   ----------------------------------------------------------------------------
   -- process to establish how many words are currently in the fifo
   ----------------------------------------------------------------------------
   
   begin  
      
      -- calculate current fifo count
      if (to_integer(unsigned(write_addr))) < (to_integer(unsigned(read_addr))) then 
         fifo_count <= (2**addr_size) + (to_integer(unsigned(write_addr))) - (to_integer(unsigned(read_addr)));
      else 
         fifo_count <= (to_integer(unsigned(write_addr))) - (to_integer(unsigned(read_addr))); 
      end if;   
   end process fifo_state;
        
   ----------------------------------------------------------------------------
   flag_fifo : process(fifo_count, last_count)
   ----------------------------------------------------------------------------
   -- process which sets the full and empty flags depending on fifo_count
   -- when write_addr and read_addr are equal (fifo_count = 0) then the 
   -- fifo is either full or empty.  Value of last_count determines which.
   ----------------------------------------------------------------------------
      begin
         if (fifo_count = 0) then
            if (last_count = 2**addr_size - 1) then   -- i.e. if last operation was a write
               empty <= '0';
               full <= '1';
            else 
               empty <= '1';
               full <= '0';
            end if;
         else
            empty <= '0';
            full <= '0';
         end if;
      end process flag_fifo;
end rtl;
