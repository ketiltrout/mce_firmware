library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.general_pack.all;
use sys_param.command_pack.all;
use sys_param.frame_timing_pack.all;

library work;
use work.sync_gen_pack.all;

entity tb_sync_gen is
end tb_sync_gen;

architecture beh of tb_sync_gen is

   signal clk_i      : std_logic := '1';   
   signal rst_i      : std_logic;
   signal dv_i       : std_logic;
   signal dv_en_i    : std_logic;
   signal sync_o     : std_logic;
   signal sync_num_o : std_logic_vector(SYNC_NUM_BUS_WIDTH-1 downto 0);
   signal clk_count_o     : integer;
   signal clk_error_o     : std_logic_vector(31 downto 0);


------------------------------------------------------------------------
--
-- Instantiate the design
--
------------------------------------------------------------------------

begin

   dut : sync_gen
      port map(
         clk_i      => clk_i,
         rst_i      => rst_i,
         dv_i       => dv_i,
         dv_en_i    => dv_en_i,
         sync_o     => sync_o,
         sync_num_o => sync_num_o
      );
      
   dut2 : frame_timing
      port map(
         clk_i => clk_i,
         sync_i => sync_o,
         frame_rst_i => rst_i,
         clk_count_o => clk_count_o,
         clk_error_o => clk_error_o
      );

   -- Create a test clock
   clk_i <= not clk_i after CLOCK_PERIOD/2;

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
      dv_i    <= dv_i;
      dv_en_i <= dv_en_i;      
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
      assert false report " sync" severity NOTE;
   end do_reset;

   -- Start the test
   begin
      do_reset;
      do_no_dv;

      L2: for count_value in 0 to 3*END_OF_FRAME loop
         do_nop;
      end loop L2;

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