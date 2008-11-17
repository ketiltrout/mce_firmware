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
-- fsfb_io_controller.vhd
--
-- Project:   SCUBA-2
-- Author:        Anthony Ko
-- Organisation:  UBC
--
-- Description:
-- First stage feedback calculation i/o controller firmware
--
-- 
--
-- This block maintains control over all the i/o connections to the fsfb_queues.
-- Most importantly, it ensures read and write address inputs are modified correctly at
-- the right time. By doing this, correct data would then be read/written from/to the 
-- queues. 
--
-- Revision history:
-- 
-- $Log: fsfb_io_controller.vhd,v $
-- Revision 1.7  2008/10/03 00:32:57  mandana
-- BB: Adjusted the indentation in fsfb_io_controller.vhd to make the file more readable.
--
-- Revision 1.6  2005/12/12 23:53:29  mandana
-- added filter-related interface
-- changed fsfb_flux_cnt_queue to flux_cnt_queue for consistancy
--
-- Revision 1.5  2005/10/07 21:38:07  bburger
-- Bryce:  Added a port between fsfb_io_controller and wbs_frame_data to readout flux_counts
--
-- Revision 1.4  2005/09/14 23:48:39  bburger
-- bburger:
-- Integrated flux-jumping into flux_loop
--
-- Revision 1.3  2004/12/07 19:41:42  mohsen
-- Anthony & Mohsen: Restructured constant declaration.  Moved shared constants from lower level package files to the upper level ones.  This was done to resolve compilation error resulting from shared constants defined in multiple package files.
--
-- Revision 1.2  2004/11/26 18:26:45  mohsen
-- Anthony & Mohsen: Restructured constant declaration.  Moved shared constants from lower level package files to the upper level ones.  This was done to resolve compilation error resulting from shared constants defined in multiple package files.
--
-- Revision 1.1  2004/10/22 22:18:36  anthonyk
-- Initial release
--
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.fsfb_calc_pack.all;
use work.flux_loop_pack.all;
use work.readout_card_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;

entity fsfb_io_controller is
   generic (
      start_val                           : integer := 0                                                -- value read from the queue when initialize_window_i is asserted
      );

   port( 
      -- global signals
      rst_i                           : in     std_logic;                                           -- global reset
      clk_50_i                        : in     std_logic;                                           -- gobal clock
     
      -- control signals from frame timing block
      restart_frame_aligned_i         : in     std_logic;                                           -- start of frame signal 
      restart_frame_1row_post_i       : in     std_logic;                                           -- start of frame signal (one row behind of actual frame start)
      row_switch_i                    : in     std_logic;                                           -- row switch signal to indicate next clock cycle is the beginning of new row
      initialize_window_i             : in     std_logic;                                           -- frame window at which all values read equal to fixed preset parameter
      
      -- configuration signals 
      num_ramp_frame_cycles_i         : in     std_logic_vector(RAMP_CYC_WIDTH-1 downto 0);         -- number of frame cycle ramp remained level
      
      -- signals from first stage feedback correction block
      num_flux_quanta_pres_rdy_i      : in     std_logic;                                           -- flux quanta present count ready
      num_flux_quanta_pres_i          : in     std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);  -- flux quanta present count    
       
      -- signals from first stage feedback processor block (filter related)
      fsfb_proc_fltr_update_i         : in     std_logic;                   -- indicates when fsfb_proc_fltr_data_o is valid
      fsfb_proc_fltr_dat_i            : in     std_logic_vector(FLTR_QUEUE_DATA_WIDTH-1 downto 0);  -- fsfb filter result to be written to filter queue

      -- signals from first stage feedback processor block
      fsfb_proc_update_i              : in     std_logic;                                           -- current fsfb queue update
      fsfb_proc_dat_i                 : in     std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);    -- new current fsfb queue data result

      -- wishbone slave interface (dedicated read ports to fsfb_queue/flux_cnt_queue/fltr_queue)
      fsfb_ws_fltr_addr_i             : in     std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);  -- wishbone slave address input
      fsfb_ws_fltr_dat_o              : out    std_logic_vector(WB_DATA_WIDTH-1 downto 0);          -- wishbone slave data output
      fsfb_ws_addr_i                  : in     std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);  -- wishbone slave address input
      fsfb_ws_dat_o                   : out    std_logic_vector(WB_DATA_WIDTH-1 downto 0);          -- wishbone slave data output
      flux_cnt_ws_dat_o               : out    std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
     
      -- signals to first stage feedback filter block
      fsfb_fltr_dat_rdy_o             : out    std_logic;                                           -- fs feedback queue current data ready to filter
      fsfb_fltr_dat_o                 : out    std_logic_vector(FLTR_QUEUE_DATA_WIDTH-1 downto 0);  -- fs feedback queue current data to filter
      
      -- signals to first stage feedback control/correction block
      fsfb_ctrl_dat_rdy_o             : out    std_logic;                                           -- fs feedback queue previous data ready to control (now correction block)
      fsfb_ctrl_dat_o                 : out    std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);  -- fs feedback queue previous data to control (now correction block)
      num_flux_quanta_prev_o          : out    std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);  -- flux quanta previous count data to correction block       
      
      -- PID coefficient queue interface
      p_addr_o                        : out    std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0); -- coefficient queue address inputs
      i_addr_o                        : out    std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0); 
      d_addr_o                        : out    std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0); 
     
      -- filter wn interface
      wn_addr_o                       : out    std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);  -- wn register address to store intermediate filter results
      
      -- flux quanta queue interface      
      flux_quanta_addr_o              : out    std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0); 
        
      -- control signal to first stage feedback processor block
      ramp_update_new_o               : out     std_logic;                                          -- enable to latch new ramp result
      initialize_window_ext_o         : out     std_logic;                                          -- ramp mode processor output would be zeroed during this window
      
      -- First stage feedback queue interface (used by fsfb_proc_ramp block to determine the next value in a ramp)
      previous_fsfb_dat_o             : out    std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);    -- previous data read from the previous fsfb_queue
      previous_fsfb_dat_rdy_o         : out    std_logic;                                           -- previous data ready    

      -- fsbfb_fltr (filter) interface
      fsfb_fltr_wr_data_o             : out    std_logic_vector(FLTR_QUEUE_DATA_WIDTH-1 downto 0);  -- write data to the filter queue
      fsfb_fltr_wr_addr_o             : out    std_logic_vector(FLTR_QUEUE_ADDR_WIDTH-1 downto 0);  -- write address to the filter queue
      fsfb_fltr_rd_addr_o             : out    std_logic_vector(FLTR_QUEUE_ADDR_WIDTH-1 downto 0);  -- read address to the filter queue
      fsfb_fltr_wr_en_o               : out    std_logic;                                           -- write enable to the fsfb filter queue
      fsfb_fltr_rd_data_i             : in     std_logic_vector(FLTR_QUEUE_DATA_WIDTH-1 downto 0);  -- read data from the filter queue

      -- fsfb Q interface
      fsfb_queue_wr_data_o            : out    std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);    -- write data to the fsfb data queue (bank 0, 1)
      fsfb_queue_wr_addr_o            : out    std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);  -- write address to the fsfb data queue (bank 0, 1)
      fsfb_queue_rd_addra_o           : out    std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);  -- read address (port a) to the fsfb data queue (bank 0, 1)
      fsfb_queue_rd_addrb_o           : out    std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);  -- read address (port b) to the fsfb data queue (bank 0, 1)
      fsfb_queue_wr_en_bank0_o        : out    std_logic;                                           -- write enable to the fsfb data queue (bank 0)
      fsfb_queue_wr_en_bank1_o        : out    std_logic;                                           -- write enable to the fsfb data queue (bank 1)
      fsfb_queue_rd_dataa_bank0_i     : in     std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);    -- read data (port a) from the fsfb data queue (bank 0)
      fsfb_queue_rd_dataa_bank1_i     : in     std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);    -- read data (port a) from the fsfb data queue (bank 1)
      fsfb_queue_rd_datab_bank0_i     : in     std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);    -- read data (port b) from the fsfb data queue (bank 0)
      fsfb_queue_rd_datab_bank1_i     : in     std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);    -- read data (port b) from the fsfb data queue (bank 1)

      -- First stage feedback flux count queue interface       
      flux_cnt_queue_wr_data_o        : out    std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- write data to the fsfb quanta cnt queue (bank 0, 1)
      flux_cnt_queue_wr_addr_o        : out    std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0); -- write address to the fsfb quanta cnt queue (bank 0, 1)
      flux_cnt_queue_rd_addra_o       : out    std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0); -- read address (port a) to the fsfb quanta cnt queue (bank 0, 1)            
      flux_cnt_queue_rd_addrb_o       : out    std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0); -- read address (port b) to the fsfb quanta cnt queue (bank 0, 1)
      flux_cnt_queue_wr_en_bank0_o    : out    std_logic;                                          -- write enable to the fsfb quanta cnt queue (bank 0)
      flux_cnt_queue_wr_en_bank1_o    : out    std_logic;                                          -- write enable to the fsfb quanta cnt queue (bank 1)
      flux_cnt_queue_rd_dataa_bank0_i : in     std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- read data (port a) from the fsfb quanta cnt queue (bank 0)
      flux_cnt_queue_rd_dataa_bank1_i : in     std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- read data (port a) from the fsfb quanta cnt queue (bank 1)
      flux_cnt_queue_rd_datab_bank0_i : in     std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- read data (port b) from the fsfb quanta cnt queue (bank 0)
      flux_cnt_queue_rd_datab_bank1_i : in     std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0)  -- read data (port b) from the fsfb quanta cnt queue (bank 1)        
  );

end fsfb_io_controller;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.fsfb_calc_pack.all;
use work.flux_loop_pack.all;
use work.readout_card_pack.all;

architecture rtl of fsfb_io_controller is

   -- constant declarations
   constant NUM_CYC_PER_READ          : integer := 3;                                        -- number of clock cycles per read
   constant NUM_READ                  : integer := 2;                                        -- number of read (1 for ctrl + 1 for system)
   constant READ_SHIFTER_WIDTH        : integer := NUM_CYC_PER_READ + NUM_READ - 1;          -- total number clock cycles required for all reads

   -- internal signal declarations

   signal count                       : std_logic_vector(RAMP_CYC_WIDTH-1 downto 0);         -- internal counter to determine when to inc/dec ramp level
   
   signal initialize_window_1row_post : std_logic;
   
   signal even_odd                    : std_logic;                                           -- bank select control for fsfb_corr read
   signal even_odd_inv                : std_logic;                                           -- bank select control for fsfb_corr write
   signal even_odd_delayed            : std_logic;                                           -- bank select control for system read (ramp mode use)
   signal even_odd_delayed_inv        : std_logic;                                           -- bank select control for system write (all modes use)
    
   signal wr_addr                     : std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);  -- write address to the fsfb data queue (bank 0, 1)

   signal ctrl_rd_addr                : std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);  -- read address (port b) by the ctrl (bank 0, 1)
   signal sys_rd_addr                 : std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);  -- read address (port b) by the system processor (bank 0, 1)
   
   signal read_shifter                : std_logic_vector(READ_SHIFTER_WIDTH-1 downto 0);     -- shifter used for the system read operations

   signal ctrl_dat_rdy                : std_logic;                                           -- ready pulse to indicate read data is valid for ctrl use
   signal sys_dat_rdy                 : std_logic;                                           -- ready pulse to indicate read data is valid for system use
   
   signal ctrl_dat_selected           : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);  -- ctrl data read from either bank 0 (even) or 1 (odd)
   signal sys_dat_selected            : std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);    -- system data read from either bank 0 (even) or 1 (odd)
   signal flux_dat_selected           : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);  -- flux cnt data read from either bank 0 (even) or 1 (odd)
   
   
   signal ctrl_dat                    : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);  -- registered ctrl data read 
   signal sys_dat                     : std_logic_vector(FSFB_QUEUE_DATA_WIDTH downto 0);    -- registered system data read
   signal flux_dat                    : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);  -- registered flux data read
   
   signal ctrl_dat_rdy_1d             : std_logic;                                           -- ready pulse to indicate registered read data is valid for ctrl use
   signal sys_dat_rdy_1d              : std_logic;                                           -- ready pulse to indicate registered read data is valid for system use
   
   signal fsfb_ws_dat                 : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);

--   signal flux_cnt_ws_dat_o           : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
begin
   
   -- This window indicates when to latch the new ramp result from add/sub operation
   -- If not active, the data written to the current queue remains unchanged.
   fixed_ramp : process (rst_i, clk_50_i)
   begin 
      if (rst_i = '1') then
         ramp_update_new_o  <= '0';
         count <= (others => '0');
      elsif (clk_50_i'event and clk_50_i = '1') then
         -- if (restart_frame_aligned_i = '1')  then
        
         if (initialize_window_i = '1') then
            count <= num_ramp_frame_cycles_i-1;
            ramp_update_new_o <= '0';
         
         elsif (restart_frame_1row_post_i = '1') then
            if (count = 0) then
               ramp_update_new_o <= '1';       
               count <= num_ramp_frame_cycles_i - 1;
            else     
               ramp_update_new_o <= '0';
               count <= count - 1;
            end if;
         end if;
      end if;
   end process fixed_ramp;
      
   -- Create a 1row_post version of the initialize_window input
   init_1row_post : process(rst_i, clk_50_i)
   begin
      if (rst_i = '1') then
         initialize_window_1row_post <= '0';
      elsif (clk_50_i'event and clk_50_i = '1') then
         if (initialize_window_i = '1') then
            initialize_window_1row_post <= '1';
         elsif (restart_frame_1row_post_i = '1') then
            initialize_window_1row_post <= '0';
         end if;
      end if;
   end process init_1row_post;
      
   -- Extend the initialize window input to the 1row_post boundary
   initialize_window_ext_o <= initialize_window_1row_post or initialize_window_i;
      
   -- even_odd bank select (even = 0. odd = 1)
   -- Four versions are required
   -- 1) read control for fsfb_corr (even_odd)
   -- 2.1) read control for wishbone (even_odd_delayed for fsfb queue, should be opposite to write control)
   -- 2.2) read control for wishbone (even_odd for fsfb flux cnt queue, for the same reason)   
   -- 3) read control for ramp calculation (even_odd_delayed)
   -- 4) write control to fsfb queue (even_odd_delayed_inv)
   -- 5) write control to fsfb flux cnt queue (even_odd_inv)
   even_odd_ctrl : process (rst_i, clk_50_i)
   begin
      if (rst_i = '1') then
         even_odd <= '0';
         even_odd_delayed <= '0';
      elsif (clk_50_i'event and clk_50_i = '1') then
         if (restart_frame_aligned_i = '1') then
            even_odd <= not(even_odd);
         end if;
         
         if (restart_frame_1row_post_i = '1') then
            even_odd_delayed <= not(even_odd_delayed);
         end if;
      end if;
   end process even_odd_ctrl;
   
   even_odd_inv         <= not(even_odd);
   even_odd_delayed_inv <= not(even_odd_delayed);
   
   -- Write address counter
   -- Upon restart_frame_aligned_i pulse, the write address is set to 40
   -- This is required since processing is always one row behind 
   wr_addr_counter : process (rst_i, clk_50_i)
   begin
      if (rst_i = '1') then
         wr_addr <= (others => '0');
      elsif (clk_50_i'event and clk_50_i = '1') then
            
         if (restart_frame_1row_post_i = '1') then
            wr_addr <= (others => '0');           
         elsif (row_switch_i = '1') then
            wr_addr <= wr_addr + 1;
         end if;
      end if;
   end process wr_addr_counter;
      
   fsfb_queue_wr_addr_o <= wr_addr;
   fsfb_fltr_wr_addr_o  <= wr_addr;
   
   -- The write address output of the flux cnt queue is same as that of the fsfb_ctrl; this is because
   -- the written data (newly updated flux cnt) corresponds to the same row the fsfb_ctrl currently processes
   flux_cnt_queue_wr_addr_o <= ctrl_rd_addr;   
   
   -- Write data control
   -- Directly connect to the data input of queue
   -- The selection mux based on servo mode is embedded inside processor block
   
   -- Corner case:  Because wr_addr always starts from row[40] (let's say odd bank)
   -- if we do a write then r[40]b[1] would be written with 0+step, r[0]b[0] <= 0+step,
   -- up to r[39]b[0] <= 0+step; To avoid this, the processor output is locked to zero
   -- during this time frame when operating in ramp mode.
   fsfb_queue_wr_data_o     <= fsfb_proc_dat_i;
   flux_cnt_queue_wr_data_o <= num_flux_quanta_pres_i;
   
   -- Write enable control
   -- even_odd_delayed_inv bank will determine whether the fsfb_queue_wr_data_o will written to bank 0 or 1
   fsfb_queue_wr_en_bank0_o <= fsfb_proc_update_i when even_odd_delayed_inv = '0' else '0';
   fsfb_queue_wr_en_bank1_o <= fsfb_proc_update_i when even_odd_delayed_inv = '1' else '0'; 
   
   -- even_odd_inv bank will determine whether the flux_cnt_queue_wr_data_o will written to bank 0 or 1   
   flux_cnt_queue_wr_en_bank0_o <= num_flux_quanta_pres_rdy_i when even_odd_inv = '0' else '0';
   flux_cnt_queue_wr_en_bank1_o <= num_flux_quanta_pres_rdy_i when even_odd_inv = '1' else '0';
      
   
   -- fsfb queue current data from processor to filter (essentially the same as fsfb_queue_wr_data_o)
   fsfb_fltr_dat_o     <= fsfb_proc_fltr_dat_i(FLTR_QUEUE_DATA_WIDTH-1 downto 0);
   fsfb_fltr_dat_rdy_o <= fsfb_proc_fltr_update_i;
   
   -- this is the data to be written to filter storage ram (queue)
   fsfb_fltr_wr_en_o   <= fsfb_proc_fltr_update_i;
   fsfb_fltr_wr_data_o <= fsfb_proc_fltr_dat_i; 
 
   -- Read address control (bank 0 and 1, port a)
   -- Dedicated to wishbone slave read operation

   -- Directly connect to the rdaddress_a input of fsfb/flux_cnt/fltr queues
   fsfb_queue_rd_addra_o     <= fsfb_ws_addr_i;
   fsfb_fltr_rd_addr_o       <= fsfb_ws_fltr_addr_i;   
   flux_cnt_queue_rd_addra_o <= fsfb_ws_addr_i;
   
   -- Read data control (bank 0 and 1, port a)
   fsfb_ws_dat_o <= 
      fsfb_queue_rd_dataa_bank1_i(WB_DATA_WIDTH-1 downto 0) when even_odd_delayed = '1' else 
      fsfb_queue_rd_dataa_bank0_i(WB_DATA_WIDTH-1 downto 0);
    
   fsfb_ws_fltr_dat_o <= fsfb_fltr_rd_data_i;     
   -- ???? sign extend later
   -- fsfb_ws_fltr_dat_o (WB_DATA_WIDTH-1 downto FSFB_QUEUE_DATA_WIDTH) <= (others =>fsfb_fltr_rd_data_i(FSFB_QUEUE_DATA_WIDTH-1));
   
   -- Read data control (bank 0 and 1, port a)
   flux_cnt_ws_dat_o <= 
      flux_cnt_queue_rd_dataa_bank1_i when even_odd = '1' else
      flux_cnt_queue_rd_dataa_bank0_i;
                    
   -- Read address control (bank 0 and 1, port b)
   -- Port b is dedicated to control and system read access 
      
   -- On port b, system will perform two sequential read operations after each row switch
   -- First read operation is to provide previous frame data of current system row to the 
   -- downstream fsfb control block.
   -- Second read operation is to provide previous frame data of current system row-1 to the
   -- for ramp mode calculation.

   -- Read address counters
   -- There are really two of these:  1 for fsfb_ctrl block and 1 for system processor
   -- But the one for system processor is same as the wr_addr counter
   ctrl_rd_addr_counter : process (rst_i, clk_50_i)
   begin
      if (rst_i = '1') then
         ctrl_rd_addr <= (others => '0');
      elsif (clk_50_i'event and clk_50_i = '1') then
         if (restart_frame_aligned_i = '1') then
            ctrl_rd_addr <= conv_std_logic_vector(0, FSFB_QUEUE_ADDR_WIDTH);
         elsif (row_switch_i = '1') then
            ctrl_rd_addr <= ctrl_rd_addr + 1;
         end if;
      end if;
   end process ctrl_rd_addr_counter;
   
   sys_rd_addr <= wr_addr;
   
   -- Note that each READ from RAM takes 3 cycles to complete
   -- Cycle 0: Write ctrl address to RAM read addr inputs
   -- Cycle 1: Internal RAM processing; Write sys address to RAM read addr inputs
   -- Cycle 2: RAM data is valid for ctrl
   -- Cycle 3: RAM data is valid for sys
   -- All of the above happen after each row switch
   --
   -- Shift register for the READ operation
   read_shifter_proc : process (rst_i, clk_50_i)
   begin
      if (rst_i = '1') then
         read_shifter <= (others => '0');
      elsif (clk_50_i'event and clk_50_i = '1') then
         read_shifter(READ_SHIFTER_WIDTH-1 downto 1) <= read_shifter(READ_SHIFTER_WIDTH-2 downto 0);
         read_shifter(0) <= row_switch_i;
      end if;
   end process read_shifter_proc;
   
   -- Select the correct address for port b of both banks
   -- Selection can be based on delayed row switch input since first read operation belongs to ctrl
   fsfb_queue_rd_addrb_o <= ctrl_rd_addr when read_shifter(0) = '1' else sys_rd_addr;
   
   -- No selection is necessary as the read port is dedicated
   flux_cnt_queue_rd_addrb_o <= ctrl_rd_addr;
      
   -- Tap off the ready signals to control and system from the shifter
   ctrl_dat_rdy <= read_shifter(2);
   sys_dat_rdy  <= read_shifter(3);
    
   -- select the read data from bank 1 or 0 based on even_odd switch
   -- Note that this data bus has had its MSB clipped off by specifying "FSFB_QUEUE_DATA_WIDTH-1" = 38
   ctrl_dat_selected <= 
      fsfb_queue_rd_datab_bank1_i(FSFB_QUEUE_DATA_WIDTH-1 downto 0) when even_odd = '1' else 
      fsfb_queue_rd_datab_bank0_i(FSFB_QUEUE_DATA_WIDTH-1 downto 0); 
   
   -- used by fsfb_proc_ramp block to determine the next value in a ramp 
   sys_dat_selected  <= 
      fsfb_queue_rd_datab_bank1_i(FSFB_QUEUE_DATA_WIDTH downto 0) when even_odd_delayed = '1' else 
      fsfb_queue_rd_datab_bank0_i(FSFB_QUEUE_DATA_WIDTH downto 0);
   
   flux_dat_selected <= 
      flux_cnt_queue_rd_datab_bank1_i when even_odd = '1' else
      flux_cnt_queue_rd_datab_bank0_i;
   
   -- Latch the selected read data to control once RAM data is valid
   data_ltches : process (rst_i, clk_50_i)
   begin
      if (rst_i = '1') then
         ctrl_dat <= (others => '0');
         sys_dat <= (others => '0');
         flux_dat <= (others => '0');
         
      elsif (clk_50_i'event and clk_50_i = '1') then
         if (ctrl_dat_rdy = '1') then
            ctrl_dat <= ctrl_dat_selected;
            flux_dat <= flux_dat_selected;
         end if;
         
         if (sys_dat_rdy = '1') then
            sys_dat <= sys_dat_selected;
         end if;            
      end if;
   end process data_ltches;
   
   -- Delay the ctrl/sys_dat_rdy by 1 clk to line up with the latch outputs
   data_rdy_delayed : process (rst_i, clk_50_i)
   begin
      if (rst_i = '1') then
         ctrl_dat_rdy_1d <= '0';
         sys_dat_rdy_1d <= '0';
      elsif (clk_50_i'event and clk_50_i = '1') then
         ctrl_dat_rdy_1d <= ctrl_dat_rdy;
         sys_dat_rdy_1d <= sys_dat_rdy;
      end if;
   end process data_rdy_delayed;
   
   -- Outputs to pid coefficient queue address inputs
   p_addr_o <= wr_addr;
   i_addr_o <= wr_addr;
   d_addr_o <= wr_addr;
   wn_addr_o <= wr_addr;
   
   -- Output to z coefficient queue (now flux_quanta unit) address input is now set to ctrl_rd_addr
   -- This is such that flux quanta data output to fsfb_corr (formerly fsfb_ctrl) will be aligned with the
   -- fsfb_queue data output.
   flux_quanta_addr_o <= ctrl_rd_addr;

   -- Outputs to downstream fsfb_ctrl (now fsfb_corr) block
   -- Note that the z_dat_i storing flux quanta unit is ready one clk cycle before the ctrl_dat and flux_cnt as 
   -- it does not involve bank selection
   fsfb_ctrl_dat_o         <= ctrl_dat when initialize_window_i = '0' else conv_std_logic_vector(start_val, FSFB_QUEUE_DATA_WIDTH);
   num_flux_quanta_prev_o  <= flux_dat when initialize_window_i = '0' else (others => '0');
   fsfb_ctrl_dat_rdy_o     <= ctrl_dat_rdy_1d;   
   
   -- Outputs to fsfb_processor block for ramp mode calculation
   --previous_fsfb_dat_o     <= sys_dat when initialize_window_i = '0' else '0' & conv_std_logic_vector(start_val, FSFB_QUEUE_DATA_WIDTH);
   previous_fsfb_dat_o     <= sys_dat;
   previous_fsfb_dat_rdy_o <= sys_dat_rdy_1d;
   
end rtl;
