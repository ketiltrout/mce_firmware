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
-- tb_fsfb_io_controller.vhd
--
-- Project:	  SCUBA-2
-- Author:        Anthony Ko
-- Organisation:  UBC
--
-- Description:
-- Testbench for the first stage feedback io controller block
--
-- This bench investigates the behaviour of the first stage feedback io controller.  It primarily
-- looks into the data ready and address outputs
--
-- Revision history:
-- 
-- $Log: tb_fsfb_io_controller.vhd,v $
-- Revision 1.3  2004/12/07 19:41:42  mohsen
-- Anthony & Mohsen: Restructured constant declaration.  Moved shared constants from lower level package files to the upper level ones.  This was done to resolve compilation error resulting from shared constants defined in multiple package files.
--
-- Revision 1.2  2004/11/26 18:26:45  mohsen
-- Anthony & Mohsen: Restructured constant declaration.  Moved shared constants from lower level package files to the upper level ones.  This was done to resolve compilation error resulting from shared constants defined in multiple package files.
--
-- Revision 1.1  2004/10/22 22:19:41  anthonyk
-- Initial release
--
--
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.wishbone_pack.all;

library work;
use work.fsfb_calc_pack.all;

use work.flux_loop_pack.all;
use work.readout_card_pack.all;

entity tb_fsfb_io_controller is


end tb_fsfb_io_controller;




architecture test of tb_fsfb_io_controller is

   -- constant/signal declarations

   constant clk_period                :     time      := 20 ns;   -- 50 MHz clock period
   constant num_clk_row               :     integer   := 10;      -- number of clock cycles per row
   constant num_row_frame             :     integer   := 41;      -- number of rows per frame
   constant coadd_done_cyc            :     integer   := 5;       -- cycle number at which coadd_done occurs
   constant num_ramp_frame_cycles     :     integer   := 2;       -- num of frame_cycles for fixed ramp output
   
     
   shared variable endsim             :     boolean   := false;   -- simulation window

   signal rst_i                       :     std_logic := '1';     -- global reset
   signal io_clk_i                    :     std_logic := '0';     -- global clock
   
   -- testbench signals
   -- timing references
   signal row_counter                 :     std_logic_vector(5 downto 0);
   signal row_switch_i                :     std_logic;
   signal frame_counter               :     std_logic_vector(5 downto 0);
   signal restart_frame_aligned_i     :     std_logic;
   signal restart_frame_1row_post_i   :     std_logic;
   signal delay_en                    :     std_logic;
   
   -- shift register for processor update
   signal fsfb_proc_update_shift    :     std_logic_vector(num_clk_row-1 downto 0);
   
   -- uut interface 
   signal initialize_window_i         :     std_logic;   
   signal num_ramp_frame_cycles_i     :     std_logic_vector(RAMP_CYC_WIDTH-1 downto 0);
   signal fsfb_proc_update_i          :     std_logic;
   signal fsfb_proc_dat_i             :     std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);
   signal fsfb_ws_addr_i              :     std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);
   signal fsfb_ws_dat_o               :     std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal fsfb_fltr_dat_rdy_o         :     std_logic;
   signal fsfb_fltr_dat_o             :     std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);
   signal fsfb_ctrl_dat_rdy_o         :     std_logic;
   signal fsfb_ctrl_dat_o             :     std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);
   signal p_addr_o                    :     std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);
   signal i_addr_o                    :     std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);
   signal d_addr_o                    :     std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);
   signal z_addr_o                    :     std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);
   signal ramp_update_new_o           :     std_logic;
   signal initialize_window_ext_o     :     std_logic;
   signal previous_fsfb_dat_rdy_o     :     std_logic;
   signal previous_fsfb_dat_o         :     std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0); 
   signal fsfb_queue_wr_data_o        :     std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);       
   signal fsfb_queue_wr_addr_o        :     std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);     
   signal fsfb_queue_rd_addra_o       :     std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);                 
   signal fsfb_queue_rd_addrb_o       :     std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);     
   signal fsfb_queue_wr_en_bank0_o    :     std_logic;                                              
   signal fsfb_queue_wr_en_bank1_o    :     std_logic;                                              
   signal fsfb_queue_rd_dataa_bank0_i :     std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);       
   signal fsfb_queue_rd_dataa_bank1_i :     std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);       
   signal fsfb_queue_rd_datab_bank0_i :     std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);       
   signal fsfb_queue_rd_datab_bank1_i :     std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);       
      
   -- data to be written to the queue for the write operation
   signal dat                         :     std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);
   
 
 -- procedure for generating initialize_window_i input
   procedure init_window(
      signal restart_frame_aligned_i : in std_logic;
      signal init_window_o : out std_logic
      ) is
   begin
      wait until restart_frame_aligned_i = '1';
      wait for 1.1*clk_period;
      init_window_o <= '1';
      wait until restart_frame_aligned_i = '1';
      wait for 1.1*clk_period;
      init_window_o <= '0';
   end procedure init_window;
   
begin

   rst_i <= '0' after 1000 * clk_period;
   
      
   -- end simulation after 50000*clk_period
   end_sim : process
   begin 
      wait for 50000* clk_period;
      endsim := true;
   end process end_sim;

   -- Generate a 50MHz clock (ie 20 ns period)
   clk_gen : process
   begin
      if endsim = false then
         io_clk_i <= not io_clk_i;
         wait for clk_period/2;
      else
         report "Simulation Finished....."
         severity FAILURE;
      end if;     
   end process clk_gen;
 
 
   -- Generate a row, frame reference for various inputs used by the processor
   row_ref : process (rst_i, io_clk_i)
   begin
      if rst_i = '1' then
         row_counter  <= conv_std_logic_vector(num_clk_row-1, 6);    -- 64 Max
         row_switch_i <= '0';
      
      elsif (io_clk_i'event and io_clk_i = '1') then
         if (row_counter = 0) then
            row_counter  <= conv_std_logic_vector(num_clk_row-1, 6);
            row_switch_i <= '1';
         else
            row_counter  <= row_counter - 1;
            row_switch_i <= '0';
         end if;
      end if;
   end process row_ref;
         
   frame_ref : process (rst_i, io_clk_i)
   begin
      if rst_i = '1' then
         frame_counter           <= (others => '0');
         restart_frame_aligned_i <= '0';
         
      elsif (io_clk_i'event and io_clk_i = '1') then
         if (row_counter = 0 and frame_counter = 0) then
            restart_frame_aligned_i <= '1';
         else
            restart_frame_aligned_i <= '0';
         end if;
         
         if (row_switch_i = '1') then
            if (frame_counter = 0) then      
               frame_counter <= conv_std_logic_vector(num_row_frame-1, 6);   -- 41 Max   
            else
               frame_counter <= frame_counter - 1;
            end if;
         end if;
      end if;
   end process frame_ref;
   
   fsfb_ws_addr_i <= frame_counter;
   
   
   delay_en_proc : process (io_clk_i, rst_i)   
   begin
      if (rst_i = '1') then
         delay_en <= '0';
      elsif (io_clk_i'event and io_clk_i = '1') then
         -- indication of start of first row in frame N
         if (restart_frame_aligned_i = '1' and row_switch_i = '1') then
            delay_en <= '1';
         -- indication of start of second row in frame N+1   
         elsif (row_switch_i = '1') then
            delay_en <= '0';
         end if;
      end if;
   end process delay_en_proc;
   
   -- delayed restart_frame_aligned_i control signal output
   -- the output is now delayed to the 1st row instead of the last one
   
   restart_frame_1row_post_i <= row_switch_i when delay_en ='1' else '0';   
   
   
   -- Generate the fsfb_proc_update_i input
   fsfb_proc_update_gen : process (rst_i, io_clk_i)
   begin
      if rst_i = '1' then
         fsfb_proc_update_shift <= (others => '0');
      elsif (io_clk_i'event and io_clk_i = '1') then
         fsfb_proc_update_shift(num_clk_row-1 downto 1) <= fsfb_proc_update_shift(num_clk_row-2 downto 0);
         fsfb_proc_update_shift(0)                      <= row_switch_i;
      end if;
   end process fsfb_proc_update_gen;
   
   fsfb_proc_update_i <= fsfb_proc_update_shift(3);   
   
   
   -- Generate the fsfb_proc_dat_i inputs
   dat_counter : process (rst_i, io_clk_i)
   begin
      if rst_i = '1' then
         dat <= (others => '0');
      elsif (io_clk_i'event and io_clk_i = '1') then
         dat <= dat + 1;
      end if;
   end process dat_counter;
   
   fsfb_proc_dat_gen : process (fsfb_proc_update_i)
   begin
      if fsfb_proc_update_i = '1' then
         fsfb_proc_dat_i <= dat;
      end if;
   end process fsfb_proc_dat_gen;
   
   -- Change the num_ramp cycles to observe the impact on changing the 
   -- num_ramp_frame_cycles input on the fly without asserting
   -- initalize_window
   num_ramp_cycles : process
   begin
      num_ramp_frame_cycles_i <= conv_std_logic_vector(10, RAMP_CYC_WIDTH);
      wait for 8200* 49 ns;
      num_ramp_frame_cycles_i <= conv_std_logic_vector(2, RAMP_CYC_WIDTH);
      wait;
   end process num_ramp_cycles;
   
   
   -- unit under test:  first stage feedback io controller
   UUT : fsfb_io_controller
      generic map (
         start_val                    => 0
         )
      port map (
         rst_i                        => rst_i,
         clk_50_i                     => io_clk_i,
         restart_frame_aligned_i      => restart_frame_aligned_i,
         restart_frame_1row_post_i    => restart_frame_1row_post_i,
         row_switch_i                 => row_switch_i,
         initialize_window_i          => initialize_window_i,
         num_ramp_frame_cycles_i      => num_ramp_frame_cycles_i,
         fsfb_proc_update_i           => fsfb_proc_update_i,
	 fsfb_proc_dat_i              => fsfb_proc_dat_i,
         fsfb_ws_addr_i               => fsfb_ws_addr_i,
         fsfb_ws_dat_o                => fsfb_ws_dat_o,
         fsfb_fltr_dat_rdy_o          => fsfb_fltr_dat_rdy_o,
         fsfb_fltr_dat_o              => fsfb_fltr_dat_o,
         fsfb_ctrl_dat_rdy_o          => fsfb_ctrl_dat_rdy_o,
         fsfb_ctrl_dat_o              => fsfb_ctrl_dat_o,
         p_addr_o                     => p_addr_o,
         i_addr_o                     => i_addr_o,
         d_addr_o                     => d_addr_o,
         z_addr_o                     => z_addr_o,
         ramp_update_new_o            => ramp_update_new_o,
         initialize_window_ext_o      => initialize_window_ext_o,
         previous_fsfb_dat_rdy_o      => previous_fsfb_dat_rdy_o,
         previous_fsfb_dat_o          => previous_fsfb_dat_o,
         fsfb_queue_wr_data_o         => fsfb_queue_wr_data_o,
         fsfb_queue_wr_addr_o         => fsfb_queue_wr_addr_o,
         fsfb_queue_rd_addra_o        => fsfb_queue_rd_addra_o,            
         fsfb_queue_rd_addrb_o        => fsfb_queue_rd_addrb_o,
         fsfb_queue_wr_en_bank0_o     => fsfb_queue_wr_en_bank0_o,
         fsfb_queue_wr_en_bank1_o     => fsfb_queue_wr_en_bank1_o,
         fsfb_queue_rd_dataa_bank0_i  => fsfb_queue_rd_dataa_bank0_i, 
         fsfb_queue_rd_dataa_bank1_i  => fsfb_queue_rd_dataa_bank1_i,
         fsfb_queue_rd_datab_bank0_i  => fsfb_queue_rd_datab_bank0_i,
         fsfb_queue_rd_datab_bank1_i  => fsfb_queue_rd_datab_bank1_i         
      );
   
   
   -- first stage feedback queues
   -- Bank 0 (even)
   -- Queue is 33-bit wide:  32 (ramp +/-); 31:0 (actual fsfb data)
   i_fsfb_queue_bank0 : fsfb_queue
      port map (
         data                         => fsfb_queue_wr_data_o,
         wraddress                    => fsfb_queue_wr_addr_o,
         rdaddress_a                  => fsfb_queue_rd_addra_o,
         rdaddress_b                  => fsfb_queue_rd_addrb_o,
         wren                         => fsfb_queue_wr_en_bank0_o,
         clock                        => io_clk_i,
         qa                           => fsfb_queue_rd_dataa_bank0_i,
         qb                           => fsfb_queue_rd_datab_bank0_i
      );   
    
   -- Bank 1 (odd)
   -- Queue is 33-bit wide:  32 (ramp +/-); 31:0 (actual fsfb data)   
   i_fsfb_queue_bank1 : fsfb_queue
      port map (
         data                         => fsfb_queue_wr_data_o,
         wraddress                    => fsfb_queue_wr_addr_o,
         rdaddress_a                  => fsfb_queue_rd_addra_o,
         rdaddress_b                  => fsfb_queue_rd_addrb_o,
         wren                         => fsfb_queue_wr_en_bank1_o,
         clock                        => io_clk_i,
         qa                           => fsfb_queue_rd_dataa_bank1_i,
         qb                           => fsfb_queue_rd_datab_bank1_i
      );     
   
   
     
   run_test : process 
   begin
      
      initialize_window_i <= '0';
      wait for 200000*clk_period;
      init_window(restart_frame_aligned_i, initialize_window_i);
      wait;

   end process run_test;
        
   
end test;

