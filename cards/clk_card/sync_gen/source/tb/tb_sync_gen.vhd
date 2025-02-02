library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.general_pack.all;
use sys_param.command_pack.all;

library work;
use work.sync_gen_core_pack.all;
use work.frame_timing_core_pack.all;
use work.sync_gen_pack.all;
use work.frame_timing_pack.all;

entity tb_sync_gen is
end tb_sync_gen;

architecture beh of tb_sync_gen is

   -- sync_gen
   signal clk_i                     : std_logic := '1';
   signal mem_clk_i                 : std_logic := '1';
   signal rst_i                     : std_logic := '0';
   signal dv_i                      : std_logic := '0';
   signal dv_en_i                   : std_logic := '0';
   signal sync                      : std_logic;
   signal sync_num_o                : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
   
   -- frame_timing
   signal init_window_req           : std_logic := '0';
   signal sample_num                : integer := 42;
   signal sample_delay              : integer := 6;
   signal feedback_delay            : integer := 4;
   signal address_on_delay          : integer := 2;
   
   signal update_bias               : std_logic;
   signal dac_dat_en                : std_logic;
   signal adc_coadd_en              : std_logic;
   signal restart_frame_1row_prev   : std_logic;
   signal restart_frame_aligned     : std_logic;
   signal restart_frame_1row_post   : std_logic;
   signal row_switch                : std_logic;
   signal row_en                    : std_logic;
   signal initialize_window         : std_logic;
   signal row_len                   : integer; -- not used yet
   signal num_rows                  : integer; -- not used yet
   signal resync_req                : std_logic;
   signal resync_ack                : std_logic; -- not used yet
   signal init_window_ack           : std_logic; -- not used yet
   


------------------------------------------------------------------------
--
-- Instantiate the design
--
------------------------------------------------------------------------

begin

   dut : sync_gen_core
      port map(
         -- Wishbone Interface
         dv_en_i     => dv_en_i,
         
         -- Inputs/Outputs
         dv_i        => dv_i,
         sync_o      => sync,
         sync_num_o  => sync_num_o,


         -- Global Signals
         clk_i       => clk_i,
         mem_clk_i   => mem_clk_i,
         rst_i       => rst_i
      );
      
   dut2 : frame_timing_core
      port map(
         -- Readout Card interface
         dac_dat_en_o               => dac_dat_en,
         adc_coadd_en_o             => adc_coadd_en,
         restart_frame_1row_prev_o  => restart_frame_1row_prev,
         restart_frame_aligned_o    => restart_frame_aligned,
         restart_frame_1row_post_o  => restart_frame_1row_post,
         initialize_window_o        => initialize_window,
         
         -- Address Card interface
         row_switch_o               => row_switch,
         row_en_o                   => row_en,
            
         -- Bias Card interface
         update_bias_o              => update_bias,
         
         -- Wishbone interface
         row_len_i                  => row_len,
         num_rows_i                 => num_rows,
         sample_delay_i             => sample_delay,
         sample_num_i               => sample_num,
         feedback_delay_i           => feedback_delay,
         address_on_delay_i         => address_on_delay,
         resync_req_i               => resync_req,
         resync_ack_o               => resync_ack,
         init_window_req_i          => init_window_req,
         init_window_ack_o          => init_window_ack,
         
         -- Global signals
         clk_i                      => clk_i,
         mem_clk_i                  => mem_clk_i,
         rst_i                      => rst_i,
         sync_i                     => sync
      );

   -- Create a test clock
   clk_i <= not clk_i after CLOCK_PERIOD/2;
   mem_clk_i <= not mem_clk_i after CLOCK_PERIOD/8;
   
   -- Create stimulus
   stimuli : process

   -- Proceedures for creating stimulus
   procedure do_no_dv is
   begin
      rst_i   <= '0';
      dv_i    <= '0';
      dv_en_i <= '0';      
      wait for CLOCK_PERIOD;
      assert false report " no dv" severity NOTE;
   end do_no_dv;

   procedure do_nop is
   begin
      rst_i   <= '0';
--      dv_i    <= dv_i;
--      dv_en_i <= dv_en_i;      
      wait for CLOCK_PERIOD;
      assert false report " nop" severity NOTE;
   end do_nop;

   procedure do_dv is
   begin
      rst_i   <= '0';
      dv_i    <= '1';
      dv_en_i <= '1';
      wait for CLOCK_PERIOD;
      assert false report " do dv" severity NOTE;
   end do_dv;

   procedure do_reset is
   begin
      rst_i   <= '1';
      dv_i    <= '0';
      dv_en_i <= '0';
      wait for CLOCK_PERIOD;
      assert false report " reset" severity NOTE;
   end do_reset;

   procedure do_init_window is
   begin
      init_window_req <= '1';
      wait for CLOCK_PERIOD;
      init_window_req <= '0';
      assert false report " init window" severity NOTE;
   end do_init_window;

   -- Start the test
   begin
      do_reset;
      do_no_dv;
      do_nop;
      do_nop;
      do_nop;
      do_nop;
      do_nop;
      do_nop;
      do_nop;
      do_nop;
      do_nop;
      do_nop;
      do_reset;
      do_nop;

      L2: for count_value in 0 to 3*END_OF_FRAME loop
         do_nop;
      end loop L2;
      
      do_init_window;
      
      L3: for count_value in 0 to 3*END_OF_FRAME loop
         do_nop;
      end loop L3;

      assert false report " Simulation done." severity FAILURE;
   end process stimuli;
end beh;

------------------------------------------------------------------------
--
-- Configuration
--
------------------------------------------------------------------------

configuration tb_sync_gen_conf of tb_sync_gen is
   for beh
   end for;
end tb_sync_gen_conf;