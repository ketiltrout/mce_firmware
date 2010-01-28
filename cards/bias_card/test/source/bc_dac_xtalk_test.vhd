---------------------------------------------------------------------
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
-- Project:       SCUBA-2
-- Author:        Mandana Amiri
-- 
-- Organisation:  UBC
--
-- Description:
-- bc_dac_xtalk_test wrapper file: puts a square wave on the even number channels while
-- odd number channels are quiet.
--
-- Revision history:
-- $Log: bc_dac_xtalk_test.vhd,v $
-- Revision 1.10  2010/01/22 01:17:10  mandana
-- Rev. 3.0 to accomodate 12 low-noise bias lines introduced in Bias Card Rev. E
-- Note that xtalk test is not supported for ln-bias lines YET!
--
-- Revision 1.9  2006/09/01 17:52:59  mandana
-- lowered the square wave frequency
--
-- Revision 1.8  2006/08/30 21:20:46  mandana
-- rewritten to a large degree: there are 3 clock domains. SPI runs off clk_4_i or 12.5MHz  and square wave is set to 3.25kHz. clock-domain crossing routines are utilized to resolve timing issues that existed in previous versions.
--
-----------------------------------------------------------------------------

library ieee, sys_param, components, work;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use sys_param.wishbone_pack.all;
use sys_param.data_types_pack.all;

use components.component_pack.all;
use work.bc_test_pack.all;

-----------------------------------------------------------------------------
                     
entity bc_dac_xtalk_test_wrapper is
   port (
      -- basic signals
      rst_i     : in std_logic;    -- reset input
      clk_i     : in std_logic;    -- clock input
      clk_4_i   : in std_logic;    -- clock div 4 input
      en_i      : in std_logic;    -- enable signal
      mode_i    : in std_logic;    -- mode signal (0 indicates square wave on odd channels, 1 indicates square wave on even channels)
      done_o    : out std_logic;   -- done ouput signal
      
      -- transmitter signals removed!
                
      -- extended signals
      dac_dat_o : out std_logic_vector (NUM_FLUX_FB_DACS-1 downto 0); 
      dac_ncs_o : out std_logic_vector (NUM_FLUX_FB_DACS-1 downto 0); 
      dac_clk_o : out std_logic_vector (NUM_FLUX_FB_DACS-1 downto 0);
     
      lvds_dac_dat_o: out std_logic;
      lvds_dac_ncs_o: out std_logic_vector(NUM_LN_BIAS_DACS-1 downto 0);
      lvds_dac_clk_o: out std_logic;
      
      spi_start_o: out std_logic
      
   );   
end;  

---------------------------------------------------------------------

architecture rtl of bc_dac_xtalk_test_wrapper is

constant TOGGLE_FREQ_FACTOR    : integer := 15;
constant TOGLLE2SPI_FREQ_RATIO : integer := 2**(TOGGLE_FREQ_FACTOR - 2);

-- DAC CTRL:
-- State encoding and state variables:

-- controller states:
type states is (IDLE, PUSH_DATA, SPI_START, DONE); 
signal present_state         : states;
signal next_state            : states;

type   w_array3 is array (2 downto 0) of word16; 
signal data     : w_array3;

signal idx      : integer range 0 to 2;
signal data1    : word16;
signal data2    : word16;
signal idac     : integer range 0 to 16;
signal clk_2    : std_logic;
signal clk_count: std_logic_vector(TOGGLE_FREQ_FACTOR downto 0);

signal send_dac32_start   : std_logic;
signal send_dac_lvds_start: std_logic;
signal send_dac32_start_tuned   : std_logic;
signal send_dac_lvds_start_tuned: std_logic;

signal dac_done : std_logic_vector (32 downto 0);
signal dac_done_1dly : std_logic;
signal dac_done_rise : std_logic;

signal mode_reg : std_logic;
signal xtalk    : std_logic;
signal xtalk_reg: std_logic;
signal lvds_dac_ncs_temp : std_logic_vector(0 downto 0);

-- parallel data signals for DAC
-- subtype word is std_logic_vector (15 downto 0); 
type   w_array32 is array (32 downto 0) of word16; 
signal dac_data_p      : w_array32;

begin

   spi_start_o <= send_dac32_start;

   process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         clk_count <= (others =>'0');
      elsif(clk_i'event and clk_i = '1') then
         clk_count <= clk_count + 1;
      end if;
   end process;

   clk_2 <= clk_count(TOGGLE_FREQ_FACTOR - 1);

  -- values tried on DAC Tests with fixed values                               
   data(0) <= "0000000000000000";--x0000     zero range
   data(1) <= "1111111111111111";--xffff     full range
   data(2) <= "1000000000000000";--x8000     half range

   -- capture rising edge of dac_done(0)
   process (rst_i, clk_i, dac_done_rise, dac_done(0))
   begin
     if (rst_i = '1') then
       idx <= 0;
       dac_done_1dly <= '0';
     elsif(clk_i'event and clk_i = '1') then
       dac_done_1dly <= dac_done (0);
       if (dac_done_rise = '1') then
         if (idx = 1) then
           idx <= 0;
         else
           idx <= idx + 1;
         end if;
       end if;
     end if;  
   end process;   
   dac_done_rise <= (dac_done(0) xor dac_done_1dly) and dac_done(0);   

--   process (rst_i, dac_done(0))
--   begin
--      if(rst_i = '1') then
--         idx <= 0;
--      elsif(dac_done(0)'event and dac_done(0) = '1') then
--         if (idx = 1) then 
--           idx <= 0;
--         else  
--           idx <= idx + 1;
--         end if;  
--      end if;
--   end process;
      
------------------------------------------------------------------------
--
-- Instantiate spi interface blocks, they all share the same start signal
-- and therefore they are all fired at once.
--
------------------------------------------------------------------------

   gen_spi32: for k in 0 to NUM_FLUX_FB_DACS-1 generate
   
      dac_write_spi :write_spi_with_cs
      generic map(DATA_LENGTH => 16)
      port map(--inputs
         spi_clk_i        => clk_4_i,
         rst_i            => rst_i,
         start_i          => send_dac32_start_tuned,
         parallel_data_i  => dac_data_p(k),
       
         --outputs
         spi_clk_o        => dac_clk_o (k),
         done_o           => dac_done (k),
         spi_ncs_o        => dac_ncs_o (k),
         serial_wr_data_o => dac_dat_o(k)
      );
   end generate gen_spi32;      
 ----------------------------------------------------------------------
 --
 -- Instantiate the spi for dac_lvds interface seperately
 -- (lvds dac is indexed by 32)
 --
 ----------------------------------------------------------------------
   dac_write_lvds_spi :write_spi_with_cs

   generic map(DATA_LENGTH => 16)

   port map(--inputs
      spi_clk_i        => clk_4_i,
      rst_i            => rst_i,
      start_i          => send_dac_lvds_start_tuned,
      parallel_data_i  => dac_data_p(NUM_FLUX_FB_DACS),
    
      --outputs
      spi_clk_o        => lvds_dac_clk_o,
      done_o           => dac_done  (NUM_FLUX_FB_DACS),
      spi_ncs_o        => lvds_dac_ncs_temp(0) ,
      serial_wr_data_o => lvds_dac_dat_o
   );
   lvds_dac_ncs_o <= (others => lvds_dac_ncs_temp(0)); -- ext(lvds_dac_ncs_temp, lvds_dac_ncs_o'length);
      
  -- state register:
   state_FF: process(clk_2, rst_i)
   begin
      if(rst_i = '1') then 
         present_state <= IDLE;
      elsif(clk_2'event and clk_2 = '1') then
         present_state <= next_state;
      end if;
   end process state_FF;
---------------------------------------------------------------   
   state_NS: process(present_state, xtalk_reg,data)
   begin
      next_state <= present_state;
      case present_state is
         when IDLE =>     
            if(xtalk_reg = '1') then
               next_state <= PUSH_DATA;
            else
               next_state <= IDLE;
            end if;
                
         when PUSH_DATA =>  
            next_state  <= SPI_START; -- 2ns settling time for data (ts)
            
         when SPI_START =>
            next_state  <= DONE;
         
         when DONE =>
            next_state  <= IDLE;
         
         when others => 
            next_state  <= IDLE;
                        
      end case;
   end process state_NS;
-----------------------------------------------------------------   
   state_out: process(present_state,data, idx, mode_reg)
   begin
      -- default values
      send_dac32_start    <= '0';
      send_dac_lvds_start <= '0';

      case present_state is
         when IDLE =>     
            for idac in 0 to NUM_FLUX_FB_DACS loop
               dac_data_p(idac) <= (others => '0');
            end loop;            
         
         when PUSH_DATA =>    
            if (mode_reg = '1') then 
               for idac in 0 to 15 loop
                  dac_data_p(idac*2)   <= data(idx);
                  dac_data_p(idac*2+1) <= data(2);
               end loop;   
               dac_data_p (32) <= data(idx);
            else   
               for idac in 0 to 15 loop
                  dac_data_p(idac*2)   <= data(2);
                  dac_data_p(idac*2+1) <= data(idx);
               end loop;
               dac_data_p (32) <= data(2);
            end if;                        
                          
         when SPI_START =>     
            if (mode_reg = '1') then 
               for idac in 0 to 15 loop
                  dac_data_p(idac*2)   <= data(idx);
                  dac_data_p(idac*2+1) <= data(2);
               end loop;   
               dac_data_p (32) <= data(idx);
            else   
               for idac in 0 to 15 loop
                  dac_data_p(idac*2)   <= data(2);
                  dac_data_p(idac*2+1) <= data(idx);
               end loop;
               dac_data_p (32) <= data(2);
            end if;            
            
            send_dac32_start    <= '1';
            send_dac_lvds_start <= '1';

         when DONE =>    
            if (mode_reg = '1') then 
               for idac in 0 to 15 loop
                  dac_data_p(idac*2)   <= data(idx);
                  dac_data_p(idac*2+1) <= data(2);
               end loop;   
               dac_data_p (32) <= data(idx);
            else   
               for idac in 0 to 15 loop
                  dac_data_p(idac*2)   <= data(2);
                  dac_data_p(idac*2+1) <= data(idx);
               end loop;
               dac_data_p (32) <= data(2);
            end if;            
            
         when others =>
            for idac in 0 to 32 loop
               dac_data_p(idac) <= (others => '0');
            end loop;            
            
      end case;
   end process state_out;
   
    -- capture the slow spi start in the 12.5MHz clock domain
   start_tune:slow2fast_clk_domain_crosser
      generic map (NUM_TIMES_FASTER => TOGLLE2SPI_FREQ_RATIO)
      port map(       
         -- global signals
         rst_i      => rst_i,
         clk_slow   => clk_2,
         clk_fast   => clk_4_i,
         -- input/output 
         input_slow => send_dac32_start,
         output_fast=> send_dac32_start_tuned      
      );

   -- capture the slow spi start in the 12.5MHz clock domain
   lvds_start_tune:slow2fast_clk_domain_crosser
      generic map (NUM_TIMES_FASTER => TOGLLE2SPI_FREQ_RATIO)
      port map(       
         -- global signals
         rst_i      => rst_i,
         clk_slow   => clk_2,
         clk_fast   => clk_4_i,
         -- input/output 
         input_slow => send_dac_lvds_start,
         output_fast=> send_dac_lvds_start_tuned      
      );
   
   on_off_control: process(en_i, rst_i, clk_i)
   begin
      if (rst_i = '1') then
         xtalk     <= '0';
         xtalk_reg <= '0';
      elsif(clk_i'event and clk_i = '1') then
         if (en_i = '1') then
            xtalk <= not xtalk;
            xtalk_reg <= xtalk;
         end if;   
      end if;
   end process;
   
   
   issue_done: process(clk_i, rst_i)
   begin
      if (rst_i = '1') then
         done_o <= '0';
         mode_reg <= '0';
      elsif(clk_i'event and clk_i = '1') then
         done_o <= en_i;
         if (en_i = '1') then
            mode_reg <= mode_i;
         end if;   
      end if;
   end process;
   
 end;
 

