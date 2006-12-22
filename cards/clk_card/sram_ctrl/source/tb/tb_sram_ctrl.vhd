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

-- tb_sram_ctrl.vhd
--
-- Project:       SCUBA-2
-- Author:         Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Testbench for SRAM controller
--
-- Revision history:
-- <date $Date: 2004/04/21 19:58:39 $> -     <text>      - <initials $Author: bburger $>
-- <$Log$>
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.wishbone_pack.all;
use sys_param.general_pack.all;

entity TB_SRAM_CTRL is
end TB_SRAM_CTRL;

architecture BEH of TB_SRAM_CTRL is

   component sram_ctrl
   port(-- SRAM signals:
        addr_o  : out std_logic_vector(19 downto 0);
        data_bi : inout std_logic_vector(31 downto 0);
        n_ble_o : out std_logic;
        n_bhe_o : out std_logic;
        n_oe_o  : out std_logic;
        n_ce1_o : out std_logic;
        ce2_o   : out std_logic;
        n_we_o  : out std_logic;
     
        -- wishbone signals:
        clk_i   : in std_logic;
        rst_i   : in std_logic;     
        dat_i   : in std_logic_vector (WB_DATA_WIDTH-1 downto 0);
        addr_i  : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
        tga_i   : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
        we_i    : in std_logic;
        stb_i   : in std_logic;
        cyc_i   : in std_logic;
        dat_o   : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
        ack_o   : out std_logic);     
   end component;

   -- testbench timing parameters
   constant PERIOD                : time := 20 ns;
   constant EDGE_DEPENDENCY       : time := 2 ns;  --shows clk edge dependency
   constant RESET_WINDOW          : time := 8*PERIOD;
   constant FREE_RUN              : time := 19*PERIOD;

   -- SRAM address and data in
   constant ADDRESS0 : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
   constant ADDRESS1 : std_logic_vector(31 downto 0) := "00000000000000000000000000000001";
   constant ADDRESS2 : std_logic_vector(31 downto 0) := "00000000000000000000000000000010";
   constant ADDRESS3 : std_logic_vector(31 downto 0) := "00000000000000000000000000000011";
   constant ADDRESS16 : std_logic_vector(31 downto 0) := "00000000000000000000000000010000";


   constant DATA0 : std_logic_vector(31 downto 0) := "00010010001101000101011001111000"; -- 0x12345678
   constant DATA1 : std_logic_vector(31 downto 0) := "10011011101011011100101010110000"; -- 0x9BADCAB0
   constant DATA2 : std_logic_vector(31 downto 0) := "11001010111111100000111110111100"; -- 0xCAFE0FBC
   constant DATA3 : std_logic_vector(31 downto 0) := "11011110101011011011101010111110"; -- 0xDEADBABE
   constant DATA4 : std_logic_vector(31 downto 0) := "11011110101011011100101011111110"; -- 0xDEADCAFE
   constant DATA5 : std_logic_vector(31 downto 0) := "10101011110011010001001000110100"; -- 0xABCD1234
   constant DATA6 : std_logic_vector(31 downto 0) := "10101011101011011100101011111110"; -- 0xABADCAFE
   constant DATA7 : std_logic_vector(31 downto 0) := "00001111001111000101101010100101"; -- 0x0F3C5AA5
           

   signal addr_o    : std_logic_vector ( 19 downto 0 );
   signal data_bi   : std_logic_vector ( 31 downto 0 );
   signal n_ble_o   : std_logic ;
   signal n_bhe_o   : std_logic ;
   signal n_oe_o    : std_logic ;
   signal n_ce1_o   : std_logic ;
   signal ce2_o     : std_logic ;
   signal n_we_o    : std_logic ;
   signal clk_i     : std_logic := '1';
   signal rst_i     : std_logic ;
   signal dat_i     : std_logic_vector (31 downto 0 );
   signal addr_i    : std_logic_vector (WB_ADDR_WIDTH-1 downto 0 );
   signal tga_i     : std_logic_vector (31 downto 0 );
   signal we_i      : std_logic ;
   signal stb_i     : std_logic ;
   signal cyc_i     : std_logic ;
   signal dat_o     : std_logic_vector (31 downto 0 );
   signal ack_o     : std_logic ;
   
   signal reset_window_done         : boolean := false;
   signal finish_write_base_addr    : boolean := false;  -- asserted to end tb
   signal finish_write_sram         : boolean := false;
   signal finish_read_base_addr     : boolean := false;
   signal finish_read_sram          : boolean := false;
   signal finish_tb1                : boolean := false;
  
begin

   DUT : sram_ctrl
      port map(addr_o    => addr_o,
               data_bi   => data_bi,
               n_ble_o   => n_ble_o,
               n_bhe_o   => n_bhe_o,
               n_oe_o    => n_oe_o,
               n_ce1_o   => n_ce1_o,
               ce2_o     => ce2_o,
               n_we_o    => n_we_o,
               clk_i     => clk_i,
               rst_i     => rst_i,
               dat_i     => dat_i,
               addr_i    => addr_i,
               tga_i     => tga_i,
               we_i      => we_i,
               stb_i     => stb_i,
               cyc_i     => cyc_i,
               dat_o     => dat_o,
               ack_o     => ack_o);

   -----------------------------------------------------------------------------
   -- Clocking
   -----------------------------------------------------------------------------

   gen_clk_i: process
   begin  

      clk_i <= '1';
      wait for PERIOD/2;
    
      while (not finish_tb1) loop
         clk_i <= not clk_i;
         wait for PERIOD/2;
      end loop;

      wait;
    
   end process gen_clk_i;


   -----------------------------------------------------------------------------
   -- Write into then Read from Banks 
   -----------------------------------------------------------------------------
   i_write_read_mem: process 
   begin  
--      data_bi <= (others => 'Z');
      ---------------------------------------------------------------------------
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
      -- Write SRAM base address
      addr_i <= SRAM_ADDR_ADDR;
      stb_i  <= '1';
      cyc_i  <= '1';
      we_i   <= '1';
     
      dat_i  <= ADDRESS16;
      wait for PERIOD;
   --   wait until falling_edge(ack_o);
      wait for EDGE_DEPENDENCY;
      --wait for PERIOD;
      
      finish_write_base_addr <= true;
      stb_i <= '0';
      cyc_i <= '0';
      we_i  <= '0';
      tga_i <= (others => '0');

      ---------------------------------------------------------------------------
      -- Write SRAM content
      wait for 5*PERIOD;
      addr_i <= SRAM_DATA_ADDR;
      stb_i  <= '1';
      cyc_i  <= '1';
      we_i   <= '1';
     
      for i in 0 to 40 loop
        dat_i  <= dat_i +7;
        wait until falling_edge(ack_o);
        wait for EDGE_DEPENDENCY;
        -- assert a wait cycle by master
        if i=25 then
          stb_i <= '0';
          wait for 11*PERIOD;
          stb_i <= '1';
        end if;
        tga_i  <= tga_i+1;
      end loop;  -- i
      
      finish_write_sram <= true;
      stb_i <= '0';
      cyc_i <= '0';
      we_i  <= '0';
      tga_i <= (others => '0');


      ---------------------------------------------------------------------------
      -- Start Reading
      wait for 17*PERIOD;
     
      ---------------------------------------------------------------------------
      -- Read SRAM base addr
      addr_i <= SRAM_ADDR_ADDR;
      stb_i  <= '1';
      cyc_i  <= '1';
      we_i   <= '0';
     
      wait until falling_edge(ack_o);
      wait for EDGE_DEPENDENCY;
      finish_read_base_addr <= true;
      stb_i <= '0';
      cyc_i <= '0';
      we_i  <= '0';
      tga_i    <= (others => '0');

      ---------------------------------------------------------------------------
      -- Read SRAM content
      addr_i <= SRAM_DATA_ADDR;
      stb_i  <= '1';
      cyc_i  <= '1';
      we_i   <= '0';
     
      for i in 0 to 40 loop
        wait until falling_edge(ack_o);
        wait for EDGE_DEPENDENCY;
        -- assert a wait cycle by master
        if i=17 then
          stb_i <= '0';
          wait for 23*PERIOD;
          stb_i <= '1';
        end if;
        tga_i  <= tga_i+1;
      end loop;  -- i
      
      finish_read_sram <= true;
      stb_i <= '0';
      cyc_i <= '0';
      we_i  <= '0';
      tga_i    <= (others => '0');
      
      wait;
   end process i_write_read_mem ;

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
                          
      wait for 113 ns;
      rst_i <= '0';
      wait for RESET_WINDOW - 113 ns;   -- alligne with clk

      reset_window_done <= true;
    end do_initialize;

    ---------------------------------------------------------------------------
    -- 


  begin  -- process i_test
 
    do_initialize;
    
    data_bi <= (others=> 'Z');
    -- write base addr
    wait until finish_write_base_addr;
    --wait for EDGE_DEPENDENCY;
        
    -- write to sram    
    wait until finish_write_sram;
    wait for PERIOD;
    --wait for EDGE_DEPENDENCY;
    
    wait for FREE_RUN;
    for i in 0 to 40 loop
      data_bi <= data_bi + 1;
      wait for PERIOD;
    end loop;  -- i

    wait until finish_read_sram;
    finish_tb1 <= true;

    report "END OF TEST";
    wait;
    
  end process i_test;

  
  -----------------------------------------------------------------------------
  -- 
  -----------------------------------------------------------------------------

end BEH;
