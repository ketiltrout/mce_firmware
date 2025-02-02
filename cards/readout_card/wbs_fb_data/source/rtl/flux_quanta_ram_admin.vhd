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
-- flux_quanta_ram_admin.vhd
--
-- Project:       SCUBA-2
-- Author:        Mohsen Nahvi, Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- 
-- This block instantiates the P/I/D memory RAMs for each of the 8 channels of the
-- flux_loop_ctrl.  The memory banks are registered both at the inputs and the
-- outputs.  Therefore, a write cycle is complete on the next rising edge
-- of the clock after the address is valid.  However, a read cycle is only
-- complete after two clock cycles after the address is valid. (NOTE: that the
-- data can be read on the third clock rising edge)
--
-- Two control signals are also generated.
-- 1. The first one is the write enable signal for each memory bank.  These
-- signals are simply the we_i when the addr_i is equal to the address of that
-- memory bank.
-- 2. The second control signal is the ack_o.  This signal is generated
-- separtely for each of the write or read cycle.  A behavioural code is used
-- for simplicity where the idea is to generate the ack_o every other clock
-- cycles during a write and every two other clock cycles during a read.
--
-- Ports:
-- #clk_50_i: Golbal signal
-- #rst_i: Global signal
-- #p_dat_ch0_o: P Data for flux_loop_ctrl channel0
-- #p_addr_ch0_i: Read address from flux_loop_ctrl channle0
-- #### Similarly for ch1 to ch7
-- #dat_i: Data in from Dispatch
-- #addr_i: Address from Dispatch showing the address of memory banks. This is
-- kept constant during a read or write cycle.
-- #tga_i: Address Tag from Dispatch.  This is incremented during a read or
-- write cycle.  Therefore, it is used as an index to the location in the
-- memory bank
-- #we_i: Write Enable input from Dispatch
-- #stb_i: Strobe signal from Dispatch.  Indicates if an address is valid or
-- not. See Wishbone manul page 54 and 57.  
-- #cyc_i: Input from Dispatch indicating a read or write cycle is in progress
-- #qa_p_bank_o: A MUX output of all the qa output of the memory banks for P 
-- #ack_p_bank_o: A logical OR function of acknowledge signals for read or
-- write cycles of each memory bank
--
--
-- Revision history:
-- $Log: flux_quanta_ram_admin.vhd,v $
-- Revision 1.5  2010/02/13 00:36:39  bburger
-- BB: Merged 1.4.2.1 into the main line.
--
-- Revision 1.4  2009/08/28 17:56:46  bburger
-- BB:  fixed a bug in the flx_quanta that signed extended an unsigned value.
--
-- Revision 1.3  2008/07/08 21:59:13  mandana
-- incomplete if statement for ack_read_bank is fixed.
-- count is set to 0 as a start value.
--
-- Revision 1.2  2008/06/27 21:04:44  mandana
-- merged with flux_quanta_admin_reduced_width
-- removed conv_int calls, only process FLUX_QUANTA_DATA_WIDTH bits out of Wishbone data. use sign-extend functions
--
-- Revision 1.1.2.1  2007/03/21 18:11:58  mandana
-- removed conv_int calls, only process FLUX_QUANTA_DATA_WIDTH bits out of Wishbone data. use sign-extend functions
--
-- Revision 1.1  2005/09/15 00:03:59  bburger
-- bburger:
-- Integrated flux-jumping into flux_loop
--
--
--
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library work;

-- Call Parent Library
use work.wbs_fb_data_pack.all;
use work.flux_loop_pack.all;



entity flux_quanta_ram_admin is
  port (

    -- Global signals
    clk_50_i              : in std_logic;
    rst_i                 : in std_logic;
    
    -- Flux_Loop_Ctrl Channel Interface
    dat_ch0_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);   
    addr_ch0_i            : in  std_logic_vector(FLUX_QUANTA_ADDR_WIDTH-1 downto 0);   
    dat_ch1_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);   
    addr_ch1_i            : in  std_logic_vector(FLUX_QUANTA_ADDR_WIDTH-1 downto 0);   
    dat_ch2_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);   
    addr_ch2_i            : in  std_logic_vector(FLUX_QUANTA_ADDR_WIDTH-1 downto 0);   
    dat_ch3_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);   
    addr_ch3_i            : in  std_logic_vector(FLUX_QUANTA_ADDR_WIDTH-1 downto 0);   
    dat_ch4_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);   
    addr_ch4_i            : in  std_logic_vector(FLUX_QUANTA_ADDR_WIDTH-1 downto 0);   
    dat_ch5_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);   
    addr_ch5_i            : in  std_logic_vector(FLUX_QUANTA_ADDR_WIDTH-1 downto 0);   
    dat_ch6_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);   
    addr_ch6_i            : in  std_logic_vector(FLUX_QUANTA_ADDR_WIDTH-1 downto 0);   
    dat_ch7_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);   
    addr_ch7_i            : in  std_logic_vector(FLUX_QUANTA_ADDR_WIDTH-1 downto 0);    

    -- Signals to/from dispatch  (wishbone interface)
    dat_i                 : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);       -- wishbone data in
    addr_i                : in  std_logic_vector(WB_ADDR_WIDTH-1 downto 0);       -- wishbone address in
    tga_i                 : in  std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);   -- Address Tag
    we_i                  : in  std_logic;                                        -- write//read enable
    stb_i                 : in  std_logic;                                        -- strobe 
    cyc_i                 : in  std_logic;                                        -- cycle
    
    -- Interface intended for dispatch
    qa_bank_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    ack_bank_o            : out std_logic);  

end flux_quanta_ram_admin;


architecture rtl of flux_quanta_ram_admin is

  -----------------------------------------------------------------------------
  -- Signals from P Banks
  -----------------------------------------------------------------------------
  signal qa0 : std_logic_vector(FLUX_QUANTA_DATA_WIDTH-1 downto 0);
  signal qa1 : std_logic_vector(FLUX_QUANTA_DATA_WIDTH-1 downto 0);
  signal qa2 : std_logic_vector(FLUX_QUANTA_DATA_WIDTH-1 downto 0);
  signal qa3 : std_logic_vector(FLUX_QUANTA_DATA_WIDTH-1 downto 0);
  signal qa4 : std_logic_vector(FLUX_QUANTA_DATA_WIDTH-1 downto 0);
  signal qa5 : std_logic_vector(FLUX_QUANTA_DATA_WIDTH-1 downto 0);
  signal qa6 : std_logic_vector(FLUX_QUANTA_DATA_WIDTH-1 downto 0);
  signal qa7 : std_logic_vector(FLUX_QUANTA_DATA_WIDTH-1 downto 0);

  signal qb0 : std_logic_vector(FLUX_QUANTA_DATA_WIDTH-1 downto 0);   
  signal qb1 : std_logic_vector(FLUX_QUANTA_DATA_WIDTH-1 downto 0);   
  signal qb2 : std_logic_vector(FLUX_QUANTA_DATA_WIDTH-1 downto 0);   
  signal qb3 : std_logic_vector(FLUX_QUANTA_DATA_WIDTH-1 downto 0);   
  signal qb4 : std_logic_vector(FLUX_QUANTA_DATA_WIDTH-1 downto 0);   
  signal qb5 : std_logic_vector(FLUX_QUANTA_DATA_WIDTH-1 downto 0);   
  signal qb6 : std_logic_vector(FLUX_QUANTA_DATA_WIDTH-1 downto 0);   
  signal qb7 : std_logic_vector(FLUX_QUANTA_DATA_WIDTH-1 downto 0);   
  
  -----------------------------------------------------------------------------
  -- Signals from P Controller
  -----------------------------------------------------------------------------
  signal wren0 : std_logic;
  signal wren1 : std_logic;
  signal wren2 : std_logic;
  signal wren3 : std_logic;
  signal wren4 : std_logic;
  signal wren5 : std_logic;
  signal wren6 : std_logic;
  signal wren7 : std_logic;
  signal ack_read_bank  : std_logic;
  signal ack_write_bank : std_logic;
  
  signal dat : std_logic_vector(FLUX_QUANTA_DATA_WIDTH-1 downto 0);
  
begin  -- rtl


  -----------------------------------------------------------------------------
  -- Instantiation of P Banks
  -----------------------------------------------------------------------------

  dat <= dat_i(FLUX_QUANTA_DATA_WIDTH-1 downto 0);
  
  dat_ch0_o <= ext( qb0, dat_ch0_o'length); 
  dat_ch1_o <= ext( qb1, dat_ch1_o'length);
  dat_ch2_o <= ext( qb2, dat_ch2_o'length);
  dat_ch3_o <= ext( qb3, dat_ch3_o'length);
  dat_ch4_o <= ext( qb4, dat_ch4_o'length);
  dat_ch5_o <= ext( qb5, dat_ch5_o'length);
  dat_ch6_o <= ext( qb6, dat_ch6_o'length);
  dat_ch7_o <= ext( qb7, dat_ch7_o'length);
  
  i_bank_ch0 : ram_14x64
    port map (
    data        => dat,                             -- from dispatch
    wraddress   => tga_i(FLUX_QUANTA_ADDR_WIDTH-1 downto 0), -- from dispatch
    rdaddress_a => tga_i(FLUX_QUANTA_ADDR_WIDTH-1 downto 0), -- from dispatch
    rdaddress_b => addr_ch0_i,                      -- from flux_loop_ctrl ch0
    wren        => wren0,                   -- from controller
    clock       => clk_50_i,                          -- global input
    qa          => qa0,                              -- not used anymore
--    qa          => open,                              -- not used anymore
    qb          => qb0);                        -- to flux_loop_ctrl ch0

--  qa0 <= (others => '0');     -- Decided not to have access through
                                        -- dispatch. However, still use 3-port
                                        -- ram to limit changes.


  i_bank_ch1 : ram_14x64
    port map (
    data        => dat,                             -- from dispatch
    wraddress   => tga_i(FLUX_QUANTA_ADDR_WIDTH-1 downto 0), -- from dispatch
    rdaddress_a => tga_i(FLUX_QUANTA_ADDR_WIDTH-1 downto 0), -- from dispatch
    rdaddress_b => addr_ch1_i,                      -- from flux_loop_ctrl ch1
    wren        => wren1,                   -- from controller
    clock       => clk_50_i,                          -- global input
    qa          => qa1,                              -- not used anymore
--    qa          => open,                              -- not used anymore
    qb          => qb1);                      -- to flux_loop_ctrl ch1


--  qa1 <= (others => '0');     -- Decided not to have access through
                                        -- dispatch. However, still use 3-port
                                        -- ram to limit changes.

  
  i_bank_ch2 : ram_14x64
    port map (
    data        => dat,                             -- from dispatch
    wraddress   => tga_i(FLUX_QUANTA_ADDR_WIDTH-1 downto 0), -- from dispatch
    rdaddress_a => tga_i(FLUX_QUANTA_ADDR_WIDTH-1 downto 0), -- from dispatch
    rdaddress_b => addr_ch2_i,                      -- from flux_loop_ctrl ch2
    wren        => wren2,                   -- from controller
    clock       => clk_50_i,                          -- global input
    qa          => qa2,                              -- not used anymore
--    qa          => open,                              -- not used anymore
    qb          => qb2);                      -- to flux_loop_ctrl ch2


--  qa2 <= (others => '0');     -- Decided not to have access through
                                        -- dispatch. However, still use 3-port
                                        -- ram to limit changes.


  i_bank_ch3 : ram_14x64
    port map (
    data        => dat,                             -- from dispatch
    wraddress   => tga_i(FLUX_QUANTA_ADDR_WIDTH-1 downto 0), -- from dispatch
    rdaddress_a => tga_i(FLUX_QUANTA_ADDR_WIDTH-1 downto 0), -- from dispatch
    rdaddress_b => addr_ch3_i,                      -- from flux_loop_ctrl ch3
    wren        => wren3,                   -- from controller
    clock       => clk_50_i,                          -- global input
    qa          => qa3,                              -- not used anymore
--    qa          => open,                              -- not used anymore
    qb          => qb3);                      -- to flux_loop_ctrl ch3


--  qa3 <= (others => '0');     -- Decided not to have access through
                                        -- dispatch. However, still use 3-port
                                        -- ram to limit changes.


  i_bank_ch4 : ram_14x64
    port map (
    data        => dat,                             -- from dispatch
    wraddress   => tga_i(FLUX_QUANTA_ADDR_WIDTH-1 downto 0), -- from dispatch
    rdaddress_a => tga_i(FLUX_QUANTA_ADDR_WIDTH-1 downto 0), -- from dispatch
    rdaddress_b => addr_ch4_i,                      -- from flux_loop_ctrl ch4
    wren        => wren4,                   -- from controller
    clock       => clk_50_i,                          -- global input
    qa          => qa4,                              -- not used anymore
--    qa          => open,                              -- not used anymore
    qb          => qb4);                      -- to flux_loop_ctrl ch4


--  qa4 <= (others => '0');     -- Decided not to have access through
                                        -- dispatch. However, still use 3-port
                                        -- ram to limit changes.


  i_bank_ch5 : ram_14x64
    port map (
    data        => dat,                             -- from dispatch
    wraddress   => tga_i(FLUX_QUANTA_ADDR_WIDTH-1 downto 0), -- from dispatch
    rdaddress_a => tga_i(FLUX_QUANTA_ADDR_WIDTH-1 downto 0), -- from dispatch
    rdaddress_b => addr_ch5_i,                      -- from flux_loop_ctrl ch5
    wren        => wren5,                   -- from controller
    clock       => clk_50_i,                          -- global input
    qa          => qa5,                              -- not used anymore
--    qa          => open,                              -- not used anymore
    qb          => qb5);                      -- to flux_loop_ctrl ch5
 

--  qa5 <= (others => '0');     -- Decided not to have access through
                                        -- dispatch. However, still use 3-port
                                        -- ram to limit changes.


  i_bank_ch6 : ram_14x64
    port map (
    data        => dat,                             -- from dispatch
    wraddress   => tga_i(FLUX_QUANTA_ADDR_WIDTH-1 downto 0), -- from dispatch
    rdaddress_a => tga_i(FLUX_QUANTA_ADDR_WIDTH-1 downto 0), -- from dispatch
    rdaddress_b => addr_ch6_i,                      -- from flux_loop_ctrl ch6
    wren        => wren6,                   -- from controller
    clock       => clk_50_i,                          -- global input
    qa          => qa6,                              -- not used anymore
--    qa          => open,                              -- not used anymore
    qb          => qb6);                      -- to flux_loop_ctrl ch6


--  qa6 <= (others => '0');     -- Decided not to have access through
                                        -- dispatch. However, still use 3-port
                                        -- ram to limit changes.


  i_bank_ch7 : ram_14x64
    port map (
    data        => dat,                             -- from dispatch
    wraddress   => tga_i(FLUX_QUANTA_ADDR_WIDTH-1 downto 0), -- from dispatch
    rdaddress_a => tga_i(FLUX_QUANTA_ADDR_WIDTH-1 downto 0), -- from dispatch
    rdaddress_b => addr_ch7_i,                      -- from flux_loop_ctrl ch7
    wren        => wren7,                   -- from controller
    clock       => clk_50_i,                          -- global input
    qa          => qa7,                              -- not used anymore
--    qa          => open,                              -- not used anymore
    qb          => qb7);                      -- to flux_loop_ctrl ch7


--  qa7 <= (others => '0');     -- Decided not to have access through
                                        -- dispatch. However, still use 3-port
                                        -- ram to limit changes.


  
  -----------------------------------------------------------------------------
  -- Controller for P Banks:
  -- 
  -- 1. Write Enable signals for each bank is equal to the dispatch we_i when
  -- the address from dispatch, addr_i, is equla to that bank's address
  --
  -- 2. Acknowledge signals are different for Write or Read cycle.
  -- 
  -- 2.1 Write Cycle:
  -- The acknowlege signal is asserted for one clock cycle on the first clock
  -- rising edge after seeing the stb_i, and repeats every other clock as long
  -- as stb_i is high.  Note that stb_i remains high if slave is asserting wait
  -- states, like our case here.  However, if the master is inserting a wait
  -- state, stb_i goes low on seeing acknowlege signal and comes back high when
  -- the master is ready.  We implement the Write acknowlege using a
  -- behavioural code.
  --
  -- 2.2 Read Cycle:
  -- The acknowlege signal is asserted for one clock cycle on the second clcok
  -- rising edge after seeing the stb_i, and repeats every 2 clock cycles as
  -- long as stb_i is high.  This is necessary as we use memory with registered
  -- outputs, and, thus, there are two clock cycles delay for the output to be
  -- ready on each read value.  We implement the Read acknowlege using a
  -- behavioural code.
  -----------------------------------------------------------------------------

  
  -----------------------------------------------------------------------------
  -- Write Enable Signals
  wren0 <= we_i when addr_i = FLX_QUANTA0_ADDR else '0';
  wren1 <= we_i when addr_i = FLX_QUANTA1_ADDR else '0';
  wren2 <= we_i when addr_i = FLX_QUANTA2_ADDR else '0';
  wren3 <= we_i when addr_i = FLX_QUANTA3_ADDR else '0';
  wren4 <= we_i when addr_i = FLX_QUANTA4_ADDR else '0';
  wren5 <= we_i when addr_i = FLX_QUANTA5_ADDR else '0';
  wren6 <= we_i when addr_i = FLX_QUANTA6_ADDR else '0';
  wren7 <= we_i when addr_i = FLX_QUANTA7_ADDR else '0';
  
  -----------------------------------------------------------------------------
  -- Acknowlege signals
  i_gen_ack: process (clk_50_i, rst_i)
    
    variable count : integer := 0;           -- counts number of clock cycles passed
    
  begin  -- process i_gen_ack
    if rst_i = '1' then                 -- asynchronous reset (active high)
       ack_read_bank  <= '0';
       ack_write_bank <= '0';
       count:=0;
      
      
    elsif clk_50_i'event and clk_50_i = '1' then  -- rising clock edge
      
      -- Write Acknowledge
      if (we_i='1') and (
         (addr_i = FLX_QUANTA0_ADDR) or
         (addr_i = FLX_QUANTA1_ADDR) or
         (addr_i = FLX_QUANTA2_ADDR) or
         (addr_i = FLX_QUANTA3_ADDR) or
         (addr_i = FLX_QUANTA4_ADDR) or
         (addr_i = FLX_QUANTA5_ADDR) or
         (addr_i = FLX_QUANTA6_ADDR) or
         (addr_i = FLX_QUANTA7_ADDR)) then
        
         if (stb_i='1') and (ack_write_bank='0') then
            ack_write_bank <= '1';
         else
            ack_write_bank <= '0';
         end if;
      else
         ack_write_bank <= '0';
      end if;
      
      -- Read Acknowledge
      if (we_i='0') and (
         (addr_i = FLX_QUANTA0_ADDR) or
         (addr_i = FLX_QUANTA1_ADDR) or
         (addr_i = FLX_QUANTA2_ADDR) or
         (addr_i = FLX_QUANTA3_ADDR) or
         (addr_i = FLX_QUANTA4_ADDR) or
         (addr_i = FLX_QUANTA5_ADDR) or
         (addr_i = FLX_QUANTA6_ADDR) or
         (addr_i = FLX_QUANTA7_ADDR)) then
        
         if (stb_i='1') and (ack_read_bank='0') then
            count:=count+1;
            if count=3 then
               ack_read_bank <= '1';
               count:=0;
            else 
               ack_read_bank <= '0';
            end if;
            
         else
            ack_read_bank <= '0';
         end if;
        
        
      else
         ack_read_bank <= '0';        
      end if;

      
    end if;
  end process i_gen_ack;



  
  -----------------------------------------------------------------------------
  -- Output MUX to Dispatch:
  -- 
  -- 1. addr_i selects which bank is sending its output to the dispatch.  The
  -- defulat connection is to ch0.
  --
  -- 2. Acknowlege is ORing of the write and read cycle
  -----------------------------------------------------------------------------

  ack_bank_o <= ack_write_bank or ack_read_bank;
  
  qa_bank_o <=
     ext(qa0, qa_bank_o'length) when addr_i = FLX_QUANTA0_ADDR else
     ext(qa1, qa_bank_o'length) when addr_i = FLX_QUANTA1_ADDR else
     ext(qa2, qa_bank_o'length) when addr_i = FLX_QUANTA2_ADDR else
     ext(qa3, qa_bank_o'length) when addr_i = FLX_QUANTA3_ADDR else
     ext(qa4, qa_bank_o'length) when addr_i = FLX_QUANTA4_ADDR else
     ext(qa5, qa_bank_o'length) when addr_i = FLX_QUANTA5_ADDR else
     ext(qa6, qa_bank_o'length) when addr_i = FLX_QUANTA6_ADDR else
     ext(qa7, qa_bank_o'length) when addr_i = FLX_QUANTA7_ADDR else
     ext(qa0, qa_bank_o'length); -- default to ch0
    
end rtl;
