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
-- tb_eeprom_wbs.vhd
--
-- Project:	  SCUBA-2
-- Author:        Mandana Amiri
-- Organisation:  UBC
--
-- Description:
-- Testbench for the eeprom wishbone interface:
-- emulates signals from eeprom_admin block as welll as dispatch block
-- not self-checking at the moment!
--
-- Revision history:
-- <date $Date$>    - <initials $Author$>
-- $Log$
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.eeprom_ctrl_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;

entity tb_eeprom_wbs is

end tb_eeprom_wbs;

architecture test of tb_eeprom_wbs is

   -- testbench constant and signal declarations

   constant CLK_PERIOD      : time                            := 20 ns;   -- 50 MHz system clock period (max.)
   constant EDGE_DEPENDENCY         : time := 2 ns;                       --shows clk edge dependency
   constant RESET_WINDOW            : time := 8*CLK_PERIOD;
   constant FREE_RUN                : time := 19*CLK_PERIOD;

   shared variable endsim   : boolean                         := false;   -- simulation window

   -- global input signals
   signal   clk_i           : std_logic                       := '0';     -- 50MHz system clock
   signal   rst_i           : std_logic                       := '0';     -- system-wide reset

   -- output signals to eeprom_admin   
   signal   read_req        : std_logic                       := '0';     -- trigger a read from eeprom
   signal   write_req       : std_logic                       := '0';     -- trigger a write from eeprom
   signal   hold_cs         : std_logic                       := '0';     -- whether to hold cs low after operation is done
   signal   w_dat           : std_logic_vector(EEPROM_DATA_WIDTH-1 downto 0);-- parallel write data
   signal   w_dat_stb       : std_logic                       := '0';     -- strobe for the write data
   signal   start_addr      : std_logic_vector(EEPROM_ADDR_WIDTH-1 downto 0);-- eeprom read/write start address
      
   -- input signals from eeprom_admin
   signal   ee_busy         : std_logic                       := '0';     -- eeprom ack  
   signal   ee_dat_i        : std_logic_vector(7 downto 0)    := x"00";   -- parallel read data from eeprom
   signal   ee_dat_stb_i    : std_logic                       := '0';     -- strobe for the read data from eeprom                            
   
   -- wishbone signals from dispatch
   signal   addr_i          : std_logic_vector(WB_ADDR_WIDTH-1 downto 0); -- wishbone incoming address
   signal   dat_i           : std_logic_vector(WB_DATA_WIDTH-1 downto 0); -- wishbone incoming data
   signal   tga_i           : std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);-- wishbone incoming tga
   signal   stb_i           : std_logic;                                  -- wishbone strobe
   signal   cyc_i           : std_logic;                                  -- wishbone cyc
   signal   we_i            : std_logic;                                  -- wishbone we
   
   
   -- wishbone signals to dispatch
   signal   dat_o           : std_logic_vector(WB_DATA_WIDTH-1 downto 0); -- wishbone incoming data
   signal   ack_o           : std_logic;                                  -- wishbone ack

   -- check signals to track different tests   
   signal reset_window_done      : boolean                    := false;
   signal finish_write_start_addr: boolean                    := false;
   signal finish_write1_eeprom   : boolean                    := false;
   signal finish_write2_eeprom   : boolean                    := false;
   signal finish_read1_eeprom    : boolean                    := false;
   signal finish_read2_eeprom    : boolean                    := false;
 
   -- automated check signals
   -- to be defined
   
begin
  
   -- Generate the system clock (40 ns period)
   clk_gen : process
   begin
      if not (endsim) then
         clk_i <= not clk_i;
         wait for CLK_PERIOD/2;
      end if;
   end process clk_gen;
   
   -----------------------------------------------------------------------------
   -- read and write from eeprom
   -----------------------------------------------------------------------------
   i_eeprom_read_write: process 
   begin 
      -- Start Writing
      dat_i  <= (others => '0');
      addr_i <= (others => '0');
      tga_i  <= (others => '0');
      we_i   <= '0';
      stb_i  <= '0';
      cyc_i  <= '0';
      
      wait for RESET_WINDOW;
      wait for FREE_RUN;
      wait for EDGE_DEPENDENCY;   
      
      ---------------------------------------------------------------------------
      -- Write Start Address
      addr_i <= EEPROM_SRT_ADDR;
      stb_i  <= '1';
      cyc_i  <= '1';
      we_i   <= '1';
    
      dat_i  <= x"0000000F";
      wait for EDGE_DEPENDENCY;
      wait for CLK_PERIOD;     
      finish_write_start_addr <= true;
      stb_i <= '0';
      cyc_i <= '0';
      we_i  <= '0';
      tga_i    <= (others => '0');

      wait for FREE_RUN;
      wait for EDGE_DEPENDENCY;   
   
      ---------------------------------------------------------------------------
      -- Write 7 bytes (<64B)to eeprom
      addr_i <= EEPROM_ADDR;
      stb_i  <= '1';
      cyc_i  <= '1';
      we_i   <= '1';
      for i in 0 to 7 loop
         dat_i  <= dat_i +7;
         wait until ack_o = '1';
         wait for CLK_PERIOD;
         wait for EDGE_DEPENDENCY;
         -- assert a wait cycle by master
--         if i=5 then
            stb_i <= '0';
            wait for CLK_PERIOD;
            stb_i <= '1';
  --       end if;
         tga_i  <= tga_i+1;
      end loop;  -- i
              
      finish_write1_eeprom <= true;
      stb_i <= '0';
      cyc_i <= '0';
      we_i  <= '0';
      tga_i    <= (others => '0');

      wait for FREE_RUN;
      wait for EDGE_DEPENDENCY;   

      ---------------------------------------------------------------------------
      -- Write 66 bytes (>64B) to eeprom
      addr_i <= EEPROM_ADDR;
      stb_i  <= '1';
      cyc_i  <= '1';
      we_i   <= '1';
      for i in 0 to 66 loop
         dat_i  <= dat_i +7;
         wait until ack_o = '1';
         wait for CLK_PERIOD;
         wait for EDGE_DEPENDENCY;
         -- assert a wait cycle by master
--         if i=5 then
            stb_i <= '0';
            wait for 6*CLK_PERIOD;
            stb_i <= '1';
--         end if;
         tga_i  <= tga_i+1;
      end loop;  -- i
              
      finish_write2_eeprom <= true;
      stb_i <= '0';
      cyc_i <= '0';
      we_i  <= '0';
      tga_i    <= (others => '0');

      wait for FREE_RUN;
      wait for EDGE_DEPENDENCY;   

      ---------------------------------------------------------------------------
      -- Read 7 bytes (<64B) from eeprom
      addr_i <= EEPROM_ADDR;
      stb_i  <= '1';
      cyc_i  <= '1';
      we_i   <= '0';
      for i in 0 to 7 loop
         wait until ack_o = '1';
         wait for CLK_PERIOD;
         -- assert a wait cycle by master
--         if i=3 then
           stb_i <= '0';
           wait for 19*CLK_PERIOD;
           stb_i <= '1';
--         end if;
         tga_i  <= tga_i+1;
      end loop;  -- i
              
      finish_read1_eeprom <= true;
      stb_i <= '0';
      cyc_i <= '0';
      we_i  <= '0';
      tga_i    <= (others => '0');

      wait for FREE_RUN;
      wait for EDGE_DEPENDENCY;   

      ---------------------------------------------------------------------------
      -- Read 66 byes (>64B) from eeprom
      addr_i <= EEPROM_ADDR;
      stb_i  <= '1';
      cyc_i  <= '1';
      we_i   <= '0';
      for i in 0 to 66 loop
         wait until ack_o = '1';
         wait for CLK_PERIOD;
         -- assert a wait cycle by master
--         if i=3 then
           stb_i <= '0';
           wait for 19*CLK_PERIOD;
           stb_i <= '1';
--         end if;
         tga_i  <= tga_i+1;
      end loop;  -- i
              
      finish_read2_eeprom <= true;
      stb_i <= '0';
      cyc_i <= '0';
      we_i  <= '0';
      tga_i    <= (others => '0');

      wait for FREE_RUN;
      wait for EDGE_DEPENDENCY;   

   
   end process i_eeprom_read_write;
      
--   sim_time : process
--   begin
--      wait for 4000*CLK_PERIOD;
--      endsim := true;
--      report "Simulation Finished....."
--      severity NOTE;
--   end process sim_time;
   emulate_ee_busy: process
   begin
      wait until tga_i = 64; 
      wait for CLK_PERIOD;
      if (we_i = '1') then
         ee_busy <= '1';
      end if;
      wait for 10*CLK_PERIOD;
      ee_busy <= '0';
   end process emulate_ee_busy;   
   
   emulate_ee_data: process -- emulate data read from eeprom
   begin
--      ee_dat_i     <= (others => '0');
      wait until read_req = '1' ; 
      wait for 6*CLK_PERIOD;
      ee_dat_i     <= ee_dat_i + 1;
      ee_dat_stb_i <= '1';
      wait for CLK_PERIOD;      
      ee_dat_stb_i <= '0';
   end process emulate_ee_data;   
         
   -- Instantiate the Unit Under Test
   -----------------------------------------------------------------------------
   -- Perform Test
   -----------------------------------------------------------------------------
   i_test: process

    ---------------------------------------------------------------------------
    -- Procedure to initialize all the inputs
     
    procedure do_initialize is
    begin
      reset_window_done      <= false;
      rst_i                  <= '1';
                            
      wait for 100 ns;
      rst_i <= '0';
      wait for RESET_WINDOW - 100 ns;   -- alligne with clk

      reset_window_done <= true;
    end do_initialize;
    
    ---------------------------------------------------------------------------
    begin  -- process i_test
 
       do_initialize;

       wait until finish_write_start_addr;
       wait until finish_write1_eeprom;
       wait until finish_write2_eeprom;
       wait until finish_read1_eeprom;
       wait until finish_read2_eeprom;
       
       -- End of Simulation
       endsim := true;
       report "Simulation Finished....."
       severity NOTE;
       
    end process i_test;

    
    UUT : eeprom_wbs
      port map 
         (rst_i          => rst_i,
          clk_50_i       => clk_i,
          read_req_o     => read_req,
          write_req_o    => write_req,
          hold_cs_o      => hold_cs,
          ee_dat_o       => w_dat,
          ee_dat_stb_o   => w_dat_stb,
          start_addr_o   => start_addr,
          ee_busy_i      => ee_busy,
          ee_dat_i       => ee_dat_i,
          ee_dat_stb_i   => ee_dat_stb_i,
          dat_i          => dat_i,
          addr_i	 => addr_i,
          tga_i		 => tga_i,
          we_i		 => we_i,
          stb_i		 => stb_i,
          cyc_i		 => cyc_i,
          dat_o		 => dat_o,
          ack_o		 => ack_o
          );		 
      			 
end test;

   