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
-- <revision control keyword substitutions e.g. $Id$>
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
-- <date $Date$>	-		<text>		- <initials $Author$>
--
--
-----------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY async_fifo IS
   GENERIC( 
      fifo_size : Positive
   );
   PORT( 
      rst_i     : IN     std_logic;
      read_i    : IN     std_logic;
      write_i   : IN     std_logic;
      d_i       : IN     std_logic_vector (7 DOWNTO 0);
      empty_o   : OUT    std_logic;
      full_o    : OUT    std_logic;
      q_o       : OUT    std_logic_vector (7 DOWNTO 0)
   );

END async_fifo ;


ARCHITECTURE rtl OF async_fifo IS

   -- Architecture Declarations
   
   subtype fifo_deep is integer range 0 to fifo_size-1;

   signal write_pointer : fifo_deep := 0;
   signal read_pointer  : fifo_deep := 0;
   signal fifo_fill     : integer := 0;


BEGIN
   ----------------------------------------------------------------------------
   fifo_ram : PROCESS(rst_i, write_i, read_i)
   ----------------------------------------------------------------------------
   -- process to read, write and clear fifo as appropriate
   ----------------------------------------------------------------------------

      subtype word is std_logic_vector(7 downto 0);
      type mem is array (0 to fifo_size-1) of word;
      variable memory: mem;
   
   BEGIN
      if (rst_i = '1') then
         write_pointer <= 0;
         read_pointer <= 0;
      else 
         if (write_i'EVENT AND write_i = '1') then
            memory(write_pointer) := d_i; 
               if (write_pointer = fifo_size-1) then
                  write_pointer <= 0;
               else
                  write_pointer <= write_pointer + 1;
               end if; 
         end if;
   
         if (read_i'EVENT AND read_i = '1') then
            q_o <=  memory(read_pointer);
               if (read_pointer = fifo_size-1) then
                  read_pointer <= 0;
               else
                  read_pointer <= read_pointer + 1;
               end if;
         end if;
      end if; 
    END PROCESS fifo_ram;


   ----------------------------------------------------------------------------
   fifo_state : PROCESS(read_pointer, write_pointer)
   ----------------------------------------------------------------------------
   -- process to establish how many words are currently in the fifo
   ----------------------------------------------------------------------------
   
   BEGIN
      
      if write_pointer < read_pointer then             -- when write pointer has wrapped round 
                                                       -- but read pointer hasn't yet.
         fifo_fill <= 8 - read_pointer + write_pointer;
      else
         fifo_fill <= write_pointer - read_pointer; 
      end if;   
   END PROCESS fifo_state;
      
   ----------------------------------------------------------------------------
   flag_fifo : PROCESS(fifo_fill)
   ----------------------------------------------------------------------------
   -- process which sets the full and empty flags depending on # words in fifo
   ----------------------------------------------------------------------------
      BEGIN
         if fifo_fill = 0 then
            empty_o <= '1';
            full_o <= '0';
         elsif fifo_fill = fifo_size then
            full_o <= '1';
            empty_o <= '0';
         else
            empty_o <= '0';
            full_o <= '0';
         end if;
      END PROCESS flag_fifo;

END rtl;
