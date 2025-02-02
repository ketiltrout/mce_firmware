-- Copyright (c) 2003 SCUBA-2 Project
--               All Rights Reserved
--
-- THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
-- The copyright notice above does not evidence any
-- actual or intended publication of such source code.
--
-- SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
-- REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
-- MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
-- PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
-- THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
--
-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.
--
-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1
--
-- $Id: tb_fsfb_corr.vhd,v 1.4 2005/06/23 21:40:02 bburger Exp $
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
--
-- Revision History:
-- $Log: tb_fsfb_corr.vhd,v $
-- Revision 1.4  2005/06/23 21:40:02  bburger
-- Bryce:  interm update
--
-- Revision 1.3  2005/04/22 23:22:57  bburger
-- Bryce:  Fixed some bugs.  Now in working order.
--
--
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.general_pack.all;

library work;
use work.flux_loop_ctrl_pack.all;
use work.flux_loop_pack.all;
use work.readout_card_pack.all;
use work.fsfb_corr_pack.all;

entity tb_fsfb_corr is
end tb_fsfb_corr;

architecture BEH of tb_fsfb_corr is

   -- fsfb_calc interface
   signal flux_jumping_en_i          : std_logic := '1';
   signal fsfb_ctrl_lock_en_i        : std_logic := '1';
   
   signal flux_quanta0_i             : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- Z
   signal flux_quanta1_i             : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- Z
   signal flux_quanta2_i             : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- Z
   signal flux_quanta3_i             : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- Z
   signal flux_quanta4_i             : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- Z
   signal flux_quanta5_i             : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- Z
   signal flux_quanta6_i             : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- Z
   signal flux_quanta7_i             : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- Z
   
   signal num_flux_quanta_prev0_i    : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0) := (others => '0'); -- m_prev
   signal num_flux_quanta_prev1_i    : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0) := (others => '0'); -- m_prev
   signal num_flux_quanta_prev2_i    : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0) := (others => '0'); -- m_prev
   signal num_flux_quanta_prev3_i    : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0) := (others => '0'); -- m_prev
   signal num_flux_quanta_prev4_i    : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0) := (others => '0'); -- m_prev
   signal num_flux_quanta_prev5_i    : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0) := (others => '0'); -- m_prev
   signal num_flux_quanta_prev6_i    : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0) := (others => '0'); -- m_prev
   signal num_flux_quanta_prev7_i    : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0) := (others => '0'); -- m_prev
   
   signal fsfb_ctrl_dat0_i           : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- pid_prev
   signal fsfb_ctrl_dat1_i           : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- pid_prev
   signal fsfb_ctrl_dat2_i           : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- pid_prev
   signal fsfb_ctrl_dat3_i           : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- pid_prev
   signal fsfb_ctrl_dat4_i           : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- pid_prev
   signal fsfb_ctrl_dat5_i           : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- pid_prev
   signal fsfb_ctrl_dat6_i           : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- pid_prev
   signal fsfb_ctrl_dat7_i           : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- pid_prev
   
   signal fsfb_ctrl_dat_rdy0_i       : std_logic := '0';
   signal fsfb_ctrl_dat_rdy1_i       : std_logic := '0';
   signal fsfb_ctrl_dat_rdy2_i       : std_logic := '0';
   signal fsfb_ctrl_dat_rdy3_i       : std_logic := '0';
   signal fsfb_ctrl_dat_rdy4_i       : std_logic := '0';
   signal fsfb_ctrl_dat_rdy5_i       : std_logic := '0';
   signal fsfb_ctrl_dat_rdy6_i       : std_logic := '0';
   signal fsfb_ctrl_dat_rdy7_i       : std_logic := '0';
   
   signal num_flux_quanta_pres0_o    : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_pres
   signal num_flux_quanta_pres1_o    : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_pres
   signal num_flux_quanta_pres2_o    : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_pres
   signal num_flux_quanta_pres3_o    : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_pres
   signal num_flux_quanta_pres4_o    : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_pres
   signal num_flux_quanta_pres5_o    : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_pres
   signal num_flux_quanta_pres6_o    : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_pres
   signal num_flux_quanta_pres7_o    : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_pres
   
   signal num_flux_quanta_pres_rdy_o : std_logic;
   
   -- fsfb_ctrl interface
   signal fsfb_ctrl_dat0_o           : std_logic_vector(DAC_DAT_WIDTH-1 downto 0); -- pid_corr_prev
   signal fsfb_ctrl_dat1_o           : std_logic_vector(DAC_DAT_WIDTH-1 downto 0); -- pid_corr_prev
   signal fsfb_ctrl_dat2_o           : std_logic_vector(DAC_DAT_WIDTH-1 downto 0); -- pid_corr_prev
   signal fsfb_ctrl_dat3_o           : std_logic_vector(DAC_DAT_WIDTH-1 downto 0); -- pid_corr_prev
   signal fsfb_ctrl_dat4_o           : std_logic_vector(DAC_DAT_WIDTH-1 downto 0); -- pid_corr_prev
   signal fsfb_ctrl_dat5_o           : std_logic_vector(DAC_DAT_WIDTH-1 downto 0); -- pid_corr_prev
   signal fsfb_ctrl_dat6_o           : std_logic_vector(DAC_DAT_WIDTH-1 downto 0); -- pid_corr_prev
   signal fsfb_ctrl_dat7_o           : std_logic_vector(DAC_DAT_WIDTH-1 downto 0); -- pid_corr_prev
   signal fsfb_ctrl_dat_rdy_o        : std_logic;
   
   -- Parallel signals
   signal fsfb_ctrl_dat_rdy          : std_logic;
   signal fsfb_ctrl_dat              : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- pid_prev
   signal flux_quanta                : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- Z
   signal num_flux_quanta_prev       : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0) := (others => '0'); -- m_prev
   
   -- Global Signals      
   signal clk_i                      : std_logic := '0';
   signal rst_i                      : std_logic := '0';
   
   

------------------------------------------------------------------------
--
-- Instantiate the design
--
------------------------------------------------------------------------

begin
   dut : fsfb_corr
      port map(
         -- fsfb_calc interface
         flux_jumping_en_i          => flux_jumping_en_i,
         fsfb_ctrl_lock_en_i        => fsfb_ctrl_lock_en_i,       
         
         flux_quanta0_i             => flux_quanta,            
         flux_quanta1_i             => flux_quanta,            
         flux_quanta2_i             => flux_quanta,            
         flux_quanta3_i             => flux_quanta,            
         flux_quanta4_i             => flux_quanta,            
         flux_quanta5_i             => flux_quanta,            
         flux_quanta6_i             => flux_quanta,            
         flux_quanta7_i             => flux_quanta,            
         
         num_flux_quanta_prev0_i    => num_flux_quanta_prev,   
         num_flux_quanta_prev1_i    => num_flux_quanta_prev,   
         num_flux_quanta_prev2_i    => num_flux_quanta_prev,   
         num_flux_quanta_prev3_i    => num_flux_quanta_prev,   
         num_flux_quanta_prev4_i    => num_flux_quanta_prev,   
         num_flux_quanta_prev5_i    => num_flux_quanta_prev,   
         num_flux_quanta_prev6_i    => num_flux_quanta_prev,   
         num_flux_quanta_prev7_i    => num_flux_quanta_prev,   
         
         fsfb_ctrl_dat0_i           => fsfb_ctrl_dat,          
         fsfb_ctrl_dat1_i           => fsfb_ctrl_dat,          
         fsfb_ctrl_dat2_i           => fsfb_ctrl_dat,          
         fsfb_ctrl_dat3_i           => fsfb_ctrl_dat,          
         fsfb_ctrl_dat4_i           => fsfb_ctrl_dat,          
         fsfb_ctrl_dat5_i           => fsfb_ctrl_dat,          
         fsfb_ctrl_dat6_i           => fsfb_ctrl_dat,          
         fsfb_ctrl_dat7_i           => fsfb_ctrl_dat,          
         
         fsfb_ctrl_dat_rdy0_i       => fsfb_ctrl_dat_rdy,      
         fsfb_ctrl_dat_rdy1_i       => fsfb_ctrl_dat_rdy,      
         fsfb_ctrl_dat_rdy2_i       => fsfb_ctrl_dat_rdy,      
         fsfb_ctrl_dat_rdy3_i       => fsfb_ctrl_dat_rdy,      
         fsfb_ctrl_dat_rdy4_i       => fsfb_ctrl_dat_rdy,      
         fsfb_ctrl_dat_rdy5_i       => fsfb_ctrl_dat_rdy,      
         fsfb_ctrl_dat_rdy6_i       => fsfb_ctrl_dat_rdy,      
         fsfb_ctrl_dat_rdy7_i       => fsfb_ctrl_dat_rdy,      
         
         num_flux_quanta_pres0_o    => num_flux_quanta_pres0_o,   
         num_flux_quanta_pres1_o    => num_flux_quanta_pres1_o,   
         num_flux_quanta_pres2_o    => num_flux_quanta_pres2_o,   
         num_flux_quanta_pres3_o    => num_flux_quanta_pres3_o,   
         num_flux_quanta_pres4_o    => num_flux_quanta_pres4_o,   
         num_flux_quanta_pres5_o    => num_flux_quanta_pres5_o,   
         num_flux_quanta_pres6_o    => num_flux_quanta_pres6_o,   
         num_flux_quanta_pres7_o    => num_flux_quanta_pres7_o,   
         
         num_flux_quanta_pres_rdy_o => num_flux_quanta_pres_rdy_o,
         
         -- fsfb_ctrl interface        -- fsfb_ctrl interface
         fsfb_ctrl_dat0_o           => fsfb_ctrl_dat0_o,          
         fsfb_ctrl_dat1_o           => fsfb_ctrl_dat1_o,          
         fsfb_ctrl_dat2_o           => fsfb_ctrl_dat2_o,          
         fsfb_ctrl_dat3_o           => fsfb_ctrl_dat3_o,          
         fsfb_ctrl_dat4_o           => fsfb_ctrl_dat4_o,          
         fsfb_ctrl_dat5_o           => fsfb_ctrl_dat5_o,          
         fsfb_ctrl_dat6_o           => fsfb_ctrl_dat6_o,          
         fsfb_ctrl_dat7_o           => fsfb_ctrl_dat7_o,          
         fsfb_ctrl_dat_rdy_o        => fsfb_ctrl_dat_rdy_o,      
         
         -- Global Signals             -- Global Signals      
         clk_i                      => clk_i,                     
         rst_i                      => rst_i                     
      );
      

   -- Continuous assignements (clocks, etc.)
   clk_i <= not clk_i after CLOCK_PERIOD/2; -- 50 MHz

   -- Create stimulus
   STIMULI : process

      procedure do_init is
      begin
         rst_i         <= '1';
         wait for CLOCK_PERIOD;
         rst_i         <= '0';
         wait for CLOCK_PERIOD;
         assert false report " init" severity NOTE;
      end do_init;

      procedure do_nop is
      begin
         wait for CLOCK_PERIOD;
         assert false report " nop" severity NOTE;
      end do_nop;

      procedure do_corr_a is
      begin
         flux_quanta          <= x"00002800";
         num_flux_quanta_prev <= "00000000";
         fsfb_ctrl_dat        <= (others => '0');
         wait for CLOCK_PERIOD;
         
         L3: for i in 1023 downto 0 loop

            fsfb_ctrl_dat_rdy    <= '1'; --: std_logic := '0';

            wait for CLOCK_PERIOD;
            fsfb_ctrl_dat_rdy    <= '0'; --: std_logic := '0';

            L1: while num_flux_quanta_pres_rdy_o = '0' loop
               wait for CLOCK_PERIOD;
            end loop;
            
            num_flux_quanta_prev <= num_flux_quanta_pres0_o;
            
            L2: while fsfb_ctrl_dat_rdy_o = '0' loop
               wait for CLOCK_PERIOD;
            end loop;
            
            fsfb_ctrl_dat <= fsfb_ctrl_dat + "000000000000010000000000000000000000000";
            wait for CLOCK_PERIOD;
            wait for CLOCK_PERIOD;
            wait for CLOCK_PERIOD;
            wait for CLOCK_PERIOD;
            wait for CLOCK_PERIOD;
            wait for CLOCK_PERIOD;

         end loop;

         assert false report " return data" severity NOTE;
      end do_corr_a;

      procedure do_corr_b is
      begin
         flux_quanta0_i          <= x"00000800"; -- (1/4)*(2**13)
         flux_quanta1_i          <= x"00000800"; 
         flux_quanta2_i          <= x"00000800"; 
         flux_quanta3_i          <= x"00000800"; 
         flux_quanta4_i          <= x"00000800"; 
         flux_quanta5_i          <= x"00000800"; 
         flux_quanta6_i          <= x"00000800"; 
         flux_quanta7_i          <= x"00000800"; 
         
         -- num_flux_quanta_prev0_i <= "1111111100"; -- -3
         num_flux_quanta_prev0_i <= "00000101"; -- -3
         num_flux_quanta_prev1_i <= "00000101"; -- -2
         num_flux_quanta_prev2_i <= "00000101"; -- -1
         num_flux_quanta_prev3_i <= "11111011"; --  0
         num_flux_quanta_prev4_i <= "00000101"; --  1
         num_flux_quanta_prev5_i <= "00000101"; --  2
         num_flux_quanta_prev6_i <= "00000101"; --  3
         num_flux_quanta_prev7_i <= "00000101"; --  4
         
         -- fsfb_ctrl_dat0_i        <= x"FFFFC000"; --: std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- pid_prev
         fsfb_ctrl_dat0_i        <= "000000000000000" & x"004000"; --: std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- pid_prev 00
         fsfb_ctrl_dat1_i        <= "000000000000000" & x"004000"; --: std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- pid_prev 00
         fsfb_ctrl_dat2_i        <= "000000000000000" & x"004000"; --: std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- pid_prev 00
         fsfb_ctrl_dat3_i        <= "111111111111111" & x"FFC000"; --: std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- pid_prev FF
         fsfb_ctrl_dat4_i        <= "000000000000000" & x"004000"; --: std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- pid_prev 00
         fsfb_ctrl_dat5_i        <= "000000000000000" & x"004000"; --: std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- pid_prev 00
         fsfb_ctrl_dat6_i        <= "000000000000000" & x"004000"; --: std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- pid_prev 00
         fsfb_ctrl_dat7_i        <= "000000000000000" & x"004000"; --: std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- pid_prev 00   
         
         wait for CLOCK_PERIOD;

         fsfb_ctrl_dat_rdy0_i    <= '1'; --: std_logic := '0';

         wait for CLOCK_PERIOD;
         fsfb_ctrl_dat_rdy0_i    <= '0'; --: std_logic := '0';

         fsfb_ctrl_dat_rdy1_i    <= '1'; --: std_logic := '0';
         fsfb_ctrl_dat_rdy2_i    <= '1'; --: std_logic := '0';
         fsfb_ctrl_dat_rdy3_i    <= '1'; --: std_logic := '0';
         
         wait for CLOCK_PERIOD;
         fsfb_ctrl_dat_rdy1_i    <= '0'; --: std_logic := '0';
         fsfb_ctrl_dat_rdy2_i    <= '0'; --: std_logic := '0';
         fsfb_ctrl_dat_rdy3_i    <= '0'; --: std_logic := '0';

         fsfb_ctrl_dat_rdy4_i    <= '1'; --: std_logic := '0';
         fsfb_ctrl_dat_rdy5_i    <= '1'; --: std_logic := '0';
         fsfb_ctrl_dat_rdy6_i    <= '1'; --: std_logic := '0';
         fsfb_ctrl_dat_rdy7_i    <= '1'; --: std_logic := '0';
         
         wait for CLOCK_PERIOD;
         fsfb_ctrl_dat_rdy4_i    <= '0'; --: std_logic := '0';
         fsfb_ctrl_dat_rdy5_i    <= '0'; --: std_logic := '0';
         fsfb_ctrl_dat_rdy6_i    <= '0'; --: std_logic := '0';
         fsfb_ctrl_dat_rdy7_i    <= '0'; --: std_logic := '0';

         L1: while num_flux_quanta_pres_rdy_o = '0' loop
            wait for CLOCK_PERIOD;
         end loop;
         
         L2: while fsfb_ctrl_dat_rdy_o = '0' loop
            wait for CLOCK_PERIOD;
         end loop;

         assert false report " return data" severity NOTE;
      end do_corr_b;
      
      procedure do_corr_c is
      begin
         flux_quanta0_i          <= x"00000800"; -- (1/4)*(2**13)
         flux_quanta1_i          <= x"00000800"; 
         flux_quanta2_i          <= x"00000800"; 
         flux_quanta3_i          <= x"00000800"; 
         flux_quanta4_i          <= x"00000800"; 
         flux_quanta5_i          <= x"00000800"; 
         flux_quanta6_i          <= x"00000800"; 
         flux_quanta7_i          <= x"00000800"; 
         
         -- num_flux_quanta_prev0_i <= "1111111100"; -- -3
         num_flux_quanta_prev0_i <= "00000101"; -- -3
         num_flux_quanta_prev1_i <= "00000101"; -- -2
         num_flux_quanta_prev2_i <= "00000101"; -- -1
         num_flux_quanta_prev3_i <= "11111011"; --  0
         num_flux_quanta_prev4_i <= "00000101"; --  1
         num_flux_quanta_prev5_i <= "00000101"; --  2
         num_flux_quanta_prev6_i <= "00000101"; --  3
         num_flux_quanta_prev7_i <= "00000101"; --  4
         
         -- fsfb_ctrl_dat0_i        <= x"FFFFC000"; --: std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- pid_prev
         fsfb_ctrl_dat0_i        <= "000000000000000" & x"004000"; --: std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- pid_prev  00
         fsfb_ctrl_dat1_i        <= "000000000000000" & x"004000"; --: std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- pid_prev  00
         fsfb_ctrl_dat2_i        <= "000000000000000" & x"004000"; --: std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- pid_prev  00
         fsfb_ctrl_dat3_i        <= "111111111111111" & x"FFC000"; --: std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- pid_prev  FF
         fsfb_ctrl_dat4_i        <= "000000000000000" & x"004000"; --: std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- pid_prev  00
         fsfb_ctrl_dat5_i        <= "000000000000000" & x"004000"; --: std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- pid_prev  00
         fsfb_ctrl_dat6_i        <= "000000000000000" & x"004000"; --: std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- pid_prev  00
         fsfb_ctrl_dat7_i        <= "000000000000000" & x"004000"; --: std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0'); -- pid_prev  00  
         
         wait for CLOCK_PERIOD;

         fsfb_ctrl_dat_rdy0_i    <= '1'; --: std_logic := '0';

         wait for CLOCK_PERIOD;
         fsfb_ctrl_dat_rdy0_i    <= '0'; --: std_logic := '0';

         fsfb_ctrl_dat_rdy1_i    <= '1'; --: std_logic := '0';
         fsfb_ctrl_dat_rdy2_i    <= '1'; --: std_logic := '0';
         fsfb_ctrl_dat_rdy3_i    <= '1'; --: std_logic := '0';
         
         wait for CLOCK_PERIOD;
         fsfb_ctrl_dat_rdy1_i    <= '0'; --: std_logic := '0';
         fsfb_ctrl_dat_rdy2_i    <= '0'; --: std_logic := '0';
         fsfb_ctrl_dat_rdy3_i    <= '0'; --: std_logic := '0';

         fsfb_ctrl_dat_rdy4_i    <= '1'; --: std_logic := '0';
         fsfb_ctrl_dat_rdy5_i    <= '1'; --: std_logic := '0';
         fsfb_ctrl_dat_rdy6_i    <= '1'; --: std_logic := '0';
         fsfb_ctrl_dat_rdy7_i    <= '1'; --: std_logic := '0';
         
         wait for CLOCK_PERIOD;
         fsfb_ctrl_dat_rdy4_i    <= '0'; --: std_logic := '0';
         fsfb_ctrl_dat_rdy5_i    <= '0'; --: std_logic := '0';
         fsfb_ctrl_dat_rdy6_i    <= '0'; --: std_logic := '0';
         fsfb_ctrl_dat_rdy7_i    <= '0'; --: std_logic := '0';

         L1: while num_flux_quanta_pres_rdy_o = '0' loop
            wait for CLOCK_PERIOD;
         end loop;
         
         L2: while fsfb_ctrl_dat_rdy_o = '0' loop
            wait for CLOCK_PERIOD;
         end loop;

         assert false report " return data" severity NOTE;
      end do_corr_c;

   -- Start the test
   begin
      do_nop;
      -- This delay is to synchronize the inputs controlled by this TB with the state transitions of the cmd_queue FSMs
      --wait for CLOCK_PERIOD/2;
      do_init;
      do_nop;
      
      fsfb_ctrl_lock_en_i <= '1';
      do_corr_a;
      
--      do_nop;
--      do_nop;
--      do_nop;
--      do_nop;
--      do_nop;
--      do_nop;
--
--      fsfb_ctrl_lock_en_i <= '1';
--      do_corr_b;
--
--      do_nop;
--      do_nop;
--      do_nop;
--      do_nop;
--      do_nop;
--      do_nop;
--
--      fsfb_ctrl_lock_en_i <= '1';
--      do_corr_c;
--
--      do_nop;
--      do_nop;
--      do_nop;
--      do_nop;
--      do_nop;
--      do_nop;

      assert false report " Simulation done." severity FAILURE;
   end process STIMULI;
end BEH;

------------------------------------------------------------------------
--
-- Configuration
--
------------------------------------------------------------------------

configuration tb_fsfb_corr_conf of tb_fsfb_corr is
   for BEH
   end for;
end tb_fsfb_corr_conf;
