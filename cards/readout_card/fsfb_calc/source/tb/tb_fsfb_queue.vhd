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
-- tb_fsfb_queue.vhd
--
-- Project:	  SCUBA-2
-- Author:        Anthony Ko
-- Organisation:  UBC
--
-- Description:
-- Testbench for the first stage feedback queue storage
--
-- This bench investigates the behaviour of the first stage feedback queue storage generated
-- by the ALTERA megafunction alt3pram component.
--
--
-- Revision history:
-- 
-- $Log$
--
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.fsfb_calc_pack.all;


entity tb_fsfb_queue is


end tb_fsfb_queue;




architecture test of tb_fsfb_queue is

   -- constant/signal declarations

   constant clk_period              :              time      := 20 ns;   -- 50 MHz clock period
   shared variable endsim           :              boolean   := false;   -- simulation window

   signal rst                       :              std_logic := '1';     -- global reset

   -- ram interface
   signal queue_data_i :                           std_logic_vector(32 downto 0);
   signal queue_wraddr_i :                         std_logic_vector(5 downto 0);
   signal queue_rdaddr_i :                         std_logic_vector(5 downto 0);
   signal queue_rdaddra_i :                        std_logic_vector(5 downto 0);
   signal queue_rdaddrb_i :                        std_logic_vector(5 downto 0);
   signal queue_wren_i :                           std_logic;
   signal queue_clk_i :                            std_logic := '0';
   signal queue_qa_o :                             std_logic_vector(32 downto 0);
   signal queue_qb_o :                             std_logic_vector(32 downto 0);
   signal rden_a : std_logic;
   signal rden_b : std_logic;
   
   -- done signals
   signal wr_done : std_logic;
   signal rd_done : std_logic;



begin

   rst <= '0' after 1000 * clk_period;

   -- Generate a 50MHz clock (ie 20 ns period)
   clk_gen : process
   begin
      if endsim = false then
         queue_clk_i <= not queue_clk_i;
         wait for clk_period/2;
      else
         wait;
      end if;
   end process clk_gen;


   -- Write enable
   -- Assert it until all 41 locations are written
   wren_gen : process(queue_clk_i, rst)
   begin
      if rst = '1' then
         queue_wren_i <= '0';
      elsif (queue_clk_i'event and queue_clk_i = '1') then
         if wr_done =  '0' then
            queue_wren_i <= '1';
         else
            queue_wren_i <= '0';
         end if;
      end if;
   end process wren_gen;
   

   -- Write read operation control
   -- The RAM content is always 2,4,6,8, and so on
   write_read_op : process(queue_clk_i, rst)
   begin
      if rst = '1' then
         queue_wraddr_i <= (others => '1');
         queue_rdaddr_i <= (0 => '0', others => '1');
         queue_data_i   <= (others => '0');
            
      elsif (queue_clk_i'event and queue_clk_i = '1') then
         queue_wraddr_i <= queue_wraddr_i + 1;
         queue_rdaddr_i <= queue_rdaddr_i + 1;
         queue_data_i   <= queue_data_i + 2;
      
      end if;
   end process write_read_op;
   

   -- Mux the read address to port A and then B and so on
   queue_rdaddra_i <= queue_rdaddr_i when rden_a = '1' else (others => '1');
   queue_rdaddrb_i <= queue_rdaddr_i when rden_b = '1' else (others => '1');

   read_a_or_b : process
   begin
       rden_a <= '1';
       rden_b <= '0';
       wait for clk_period;
       rden_a <= '0';
       rden_b <= '1';
       wait for clk_period;
   end process read_a_or_b;
   

   -- Write/Read completion indicator
   write_read_done : process(queue_wraddr_i, queue_rdaddr_i, rst)
   begin
      if rst = '1' then
         wr_done <= '0';
         rd_done <= '0';
      else
         if (queue_wraddr_i = 41) then  -- only check the first 41 locations
            wr_done <= '1';
         end if;
      
         if (queue_rdaddr_i = 44) then  -- read data is valid 3 cycles behind write, hence 41+3=44
            rd_done <= '1';
         end if;
      end if;
   end process write_read_done;
   

   -- Simulation ends as soon as all reads are finished
   process (rd_done)
   begin
      if rd_done = '1' then
        endsim := true;
      end if;
   end process;
      
      
   -- unit under test:  first stage feedback queue
   UUT : fsfb_queue 
      port map (
         data                     => queue_data_i,
         wraddress                => queue_wraddr_i,
         rdaddress_a              => queue_rdaddra_i,
         rdaddress_b              => queue_rdaddrb_i,
         wren                     => queue_wren_i,
         clock                    => queue_clk_i,
         qa                       => queue_qa_o,
         qb                       => queue_qb_o
      );
   

end test;

