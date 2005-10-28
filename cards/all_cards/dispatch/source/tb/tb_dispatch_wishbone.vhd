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
-- tb_dispatch_wishbone.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Testbench for dispatch Wishbone master
--
-- Revision history:
-- 
-- $Log: tb_dispatch_wishbone.vhd,v $
-- Revision 1.1  2004/08/25 20:22:11  erniel
-- initial version
--
--
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library components;
use components.component_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;
use sys_param.command_pack.all;

entity TB_DISPATCH_WISHBONE is
end TB_DISPATCH_WISHBONE;

architecture BEH of TB_DISPATCH_WISHBONE is

   component DISPATCH_WISHBONE
      port(CLK_I        : in std_logic ;
           RST_I        : in std_logic ;
           HEADER0_I    : in std_logic_vector ( 31 downto 0 );
           HEADER1_I    : in std_logic_vector ( 31 downto 0 );
           BUF_DATA_I   : in std_logic_vector ( 31 downto 0 );
           BUF_DATA_O   : out std_logic_vector ( 31 downto 0 );
           BUF_ADDR_O   : out std_logic_vector ( BB_DATA_SIZE_WIDTH - 1 downto 0 );
           BUF_WREN_O   : out std_logic ;
           CMD_RDY_I    : in std_logic ;
           WB_RDY_O     : out std_logic ;
           WB_ERR_O     : out std_logic ;
           DAT_O        : out std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 );
           ADDR_O       : out std_logic_vector ( WB_ADDR_WIDTH - 1 downto 0 );
           TGA_O        : out std_logic_vector ( WB_TAG_ADDR_WIDTH - 1 downto 0 );
           WE_O         : out std_logic ;
           STB_O        : out std_logic ;
           CYC_O        : out std_logic ;
           DAT_I        : in std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 );
           ACK_I        : in std_logic ;
           ERR_I        : in std_logic ;
           WDT_RST_O    : out std_logic );

   end component;


   constant PERIOD : time := 20000 ps;
   
   signal W_CLK_I        : std_logic := '1';
   signal W_RST_I        : std_logic ;
   signal W_HEADER0_I    : std_logic_vector ( 31 downto 0 );
   signal W_HEADER1_I    : std_logic_vector ( 31 downto 0 );
   signal W_BUF_DATA_I   : std_logic_vector ( 31 downto 0 );
   signal W_BUF_DATA_O   : std_logic_vector ( 31 downto 0 );
   signal W_BUF_ADDR_O   : std_logic_vector ( BB_DATA_SIZE_WIDTH - 1 downto 0 );
   signal W_BUF_WREN_O   : std_logic ;
   signal W_CMD_RDY_I    : std_logic ;
   signal W_WB_RDY_O     : std_logic ;
   signal W_WB_ERR_O     : std_logic ;
   signal W_DAT_O        : std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 );
   signal W_ADDR_O       : std_logic_vector ( WB_ADDR_WIDTH - 1 downto 0 );
   signal W_TGA_O        : std_logic_vector ( WB_TAG_ADDR_WIDTH - 1 downto 0 );
   signal W_WE_O         : std_logic ;
   signal W_STB_O        : std_logic ;
   signal W_CYC_O        : std_logic ;
   signal W_DAT_I        : std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 );
   signal W_ACK_I        : std_logic ;
   signal W_ERR_I        : std_logic ;
   signal W_WDT_RST_O    : std_logic ;

   signal random0    : std_logic_vector(2 downto 0);
   signal random1    : std_logic_vector(3 downto 0);
   signal slave_rdy  : std_logic;
   signal master_rdy : std_logic;
   
   signal slave_reg0 : std_logic_vector(31 downto 0);
   signal slave_reg1 : std_logic_vector(31 downto 0);
   signal slave_reg2 : std_logic_vector(31 downto 0);
   signal slave_reg3 : std_logic_vector(31 downto 0);
   signal slave_reg4 : std_logic_vector(31 downto 0);
   signal slave_reg5 : std_logic_vector(31 downto 0);
   signal slave_reg6 : std_logic_vector(31 downto 0);
   signal slave_reg7 : std_logic_vector(31 downto 0);
   signal slave_reg8 : std_logic_vector(31 downto 0);
   signal slave_reg9 : std_logic_vector(31 downto 0);
   signal slave_regA : std_logic_vector(31 downto 0);
   signal slave_regB : std_logic_vector(31 downto 0);
   signal slave_regC : std_logic_vector(31 downto 0);
   signal slave_regD : std_logic_vector(31 downto 0);
   signal slave_regE : std_logic_vector(31 downto 0);
   signal slave_regF : std_logic_vector(31 downto 0);
   
   signal memory0 : std_logic_vector(31 downto 0);
   signal memory1 : std_logic_vector(31 downto 0);
   signal memory2 : std_logic_vector(31 downto 0);
   signal memory3 : std_logic_vector(31 downto 0);
   signal memory4 : std_logic_vector(31 downto 0);
   signal memory5 : std_logic_vector(31 downto 0);
   signal memory6 : std_logic_vector(31 downto 0);
   signal memory7 : std_logic_vector(31 downto 0);
   signal memory8 : std_logic_vector(31 downto 0);
   signal memory9 : std_logic_vector(31 downto 0);
   signal memoryA : std_logic_vector(31 downto 0);
   signal memoryB : std_logic_vector(31 downto 0);
   signal memoryC : std_logic_vector(31 downto 0);
   signal memoryD : std_logic_vector(31 downto 0);
   signal memoryE : std_logic_vector(31 downto 0);
   signal memoryF : std_logic_vector(31 downto 0);   
begin

   DUT : DISPATCH_WISHBONE
      port map(CLK_I        => W_CLK_I,
               RST_I        => W_RST_I,
               HEADER0_I    => W_HEADER0_I,
               HEADER1_I    => W_HEADER1_I,
               BUF_DATA_I   => W_BUF_DATA_I,
               BUF_DATA_O   => W_BUF_DATA_O,
               BUF_ADDR_O   => W_BUF_ADDR_O,
               BUF_WREN_O   => W_BUF_WREN_O,
               CMD_RDY_I    => W_CMD_RDY_I,
               WB_RDY_O     => W_WB_RDY_O,
               WB_ERR_O     => W_WB_ERR_O,
               DAT_O        => W_DAT_O,
               ADDR_O       => W_ADDR_O,
               TGA_O        => W_TGA_O,
               WE_O         => W_WE_O,
               STB_O        => W_STB_O,
               CYC_O        => W_CYC_O,
               DAT_I        => W_DAT_I,
               ACK_I        => W_ACK_I,
               ERR_I        => W_ERR_I,
               WDT_RST_O    => W_WDT_RST_O);

   W_CLK_I <= not W_CLK_I after PERIOD/2;
   
   
   -----------------------------------------------------------
   -- Randomizers for inserting Wishbone wait states
   -----------------------------------------------------------
   
   wb_randomizer0: lfsr
      generic map(WIDTH => 3)
      port map(clk_i  => W_CLK_I,
               rst_i  => W_RST_I,
               ena_i  => '1',
               load_i => '0',
               clr_i  => '0',
               lfsr_i => "000",
               lfsr_o => random0);
   
   wb_randomizer1: lfsr
      generic map(WIDTH => 4)
      port map(clk_i  => W_CLK_I,
               rst_i  => W_RST_I,
               ena_i  => '1',
               load_i => '0',
               clr_i  => '0',
               lfsr_i => "0000",
               lfsr_o => random1);            
   
   slave_rdy  <= random0(2);
   master_rdy <= random1(3);
        
   
   -----------------------------------------------------------
   -- Wishbone slave model
   -----------------------------------------------------------
          
   wb_slave_write_model: process(W_CLK_I, W_RST_I)
   begin
      if(W_RST_I = '1') then
         slave_reg0 <= (others => '0');
         slave_reg1 <= (others => '0');
         slave_reg2 <= (others => '0');
         slave_reg3 <= (others => '0');
         slave_reg4 <= (others => '0');
         slave_reg5 <= (others => '0');
         slave_reg6 <= (others => '0');
         slave_reg7 <= (others => '0');
         slave_reg8 <= (others => '0');
         slave_reg9 <= (others => '0');
         slave_regA <= (others => '0');
         slave_regB <= (others => '0');
         slave_regC <= (others => '0');
         slave_regD <= (others => '0');
         slave_regE <= (others => '0');
         slave_regF <= (others => '0');
      elsif(W_CLK_I'event and W_CLK_I = '1') then
         if(slave_rdy = '1') then
            if(W_CYC_O = '1' and W_STB_O = '1') then
               if(W_WE_O = '1') then
                  -- write cycle
                  case W_TGA_O is
                     when "00000000000000000000000000000000" => slave_reg0 <= W_DAT_O(15 downto 0) & x"0000";
                     when "00000000000000000000000000000001" => slave_reg1 <= W_DAT_O(15 downto 0) & x"0000";
                     when "00000000000000000000000000000010" => slave_reg2 <= W_DAT_O(15 downto 0) & x"0000";
                     when "00000000000000000000000000000011" => slave_reg3 <= W_DAT_O(15 downto 0) & x"0000";
                     when "00000000000000000000000000000100" => slave_reg4 <= W_DAT_O(15 downto 0) & x"0000";
                     when "00000000000000000000000000000101" => slave_reg5 <= W_DAT_O(15 downto 0) & x"0000";
                     when "00000000000000000000000000000110" => slave_reg6 <= W_DAT_O(15 downto 0) & x"0000";
                     when "00000000000000000000000000000111" => slave_reg7 <= W_DAT_O(15 downto 0) & x"0000";
                     when "00000000000000000000000000001000" => slave_reg8 <= W_DAT_O(15 downto 0) & x"0000";
                     when "00000000000000000000000000001001" => slave_reg9 <= W_DAT_O(15 downto 0) & x"0000";
                     when "00000000000000000000000000001010" => slave_regA <= W_DAT_O(15 downto 0) & x"0000";
                     when "00000000000000000000000000001011" => slave_regB <= W_DAT_O(15 downto 0) & x"0000";
                     when "00000000000000000000000000001100" => slave_regC <= W_DAT_O(15 downto 0) & x"0000";
                     when "00000000000000000000000000001101" => slave_regD <= W_DAT_O(15 downto 0) & x"0000";
                     when "00000000000000000000000000001110" => slave_regE <= W_DAT_O(15 downto 0) & x"0000";
                     when others =>                             slave_regF <= W_DAT_O(15 downto 0) & x"0000";

                  end case;   
               end if;
            end if;
         end if;
      end if;
   end process wb_slave_write_model;
   
   wb_slave_read_model: process(slave_rdy, W_CYC_O, W_STB_O, W_WE_O, W_TGA_O)
   begin
      if(slave_rdy = '1') then
         if(W_CYC_O = '1' and W_STB_O = '1') then
            if(W_WE_O = '0') then
               -- read cycle
               case W_TGA_O is
                  when "00000000000000000000000000000000" => W_DAT_I <= slave_reg0;
                  when "00000000000000000000000000000001" => W_DAT_I <= slave_reg1;
                  when "00000000000000000000000000000010" => W_DAT_I <= slave_reg2;
                  when "00000000000000000000000000000011" => W_DAT_I <= slave_reg3;
                  when "00000000000000000000000000000100" => W_DAT_I <= slave_reg4;
                  when "00000000000000000000000000000101" => W_DAT_I <= slave_reg5;
                  when "00000000000000000000000000000110" => W_DAT_I <= slave_reg6;
                  when "00000000000000000000000000000111" => W_DAT_I <= slave_reg7;
                  when "00000000000000000000000000001000" => W_DAT_I <= slave_reg8;
                  when "00000000000000000000000000001001" => W_DAT_I <= slave_reg9;
                  when "00000000000000000000000000001010" => W_DAT_I <= slave_regA;
                  when "00000000000000000000000000001011" => W_DAT_I <= slave_regB;
                  when "00000000000000000000000000001100" => W_DAT_I <= slave_regC;
                  when "00000000000000000000000000001101" => W_DAT_I <= slave_regD;
                  when "00000000000000000000000000001110" => W_DAT_I <= slave_regE;
                  when others =>                             W_DAT_I <= slave_regF;
               end case;
            end if;
         end if;
      end if;
   end process wb_slave_read_model;
   
   W_ACK_I <= (W_CYC_O and W_STB_O) when slave_rdy = '1' else '0';
   
--   W_WAIT_I <= '0' when master_rdy = '1' else '1';
   
   W_ERR_I <= '0' when W_HEADER1_I(BB_PARAMETER_ID'range) = x"97" else '1';
   
   
   -----------------------------------------------------------
   -- Command buffer model (altsyncram timing)
   -----------------------------------------------------------
    
   cmd_buf_model: process(W_RST_I, W_CLK_I)
   begin
      if(W_RST_I = '1') then
         memory0 <= x"0000F00F";
         memory1 <= x"0000F11F";
         memory2 <= x"0000F22F";
         memory3 <= x"0000F33F";
         memory4 <= x"0000F44F";
         memory5 <= x"0000F55F";
         memory6 <= x"0000F66F";
         memory7 <= x"0000F77F";
         memory8 <= x"0000F88F";
         memory9 <= x"0000F99F";
         memoryA <= x"0000FAAF";
         memoryB <= x"0000FBBF";
         memoryC <= x"0000FCCF";
         memoryD <= x"0000FDDF";
         memoryE <= x"0000FEEF";
         memoryF <= x"0000FFFF";
      elsif(W_CLK_I'event and W_CLK_I = '0') then
         if(W_BUF_WREN_O = '1') then
            case W_BUF_ADDR_O is
               when "000000000000000" => memory0 <= W_BUF_DATA_O;
               when "000000000000001" => memory1 <= W_BUF_DATA_O;
               when "000000000000010" => memory2 <= W_BUF_DATA_O;
               when "000000000000011" => memory3 <= W_BUF_DATA_O;
               when "000000000000100" => memory4 <= W_BUF_DATA_O;
               when "000000000000101" => memory5 <= W_BUF_DATA_O;
               when "000000000000110" => memory6 <= W_BUF_DATA_O;
               when "000000000000111" => memory7 <= W_BUF_DATA_O;
               when "000000000001000" => memory8 <= W_BUF_DATA_O;
               when "000000000001001" => memory9 <= W_BUF_DATA_O;
               when "000000000001010" => memoryA <= W_BUF_DATA_O;
               when "000000000001011" => memoryB <= W_BUF_DATA_O;
               when "000000000001100" => memoryC <= W_BUF_DATA_O;
               when "000000000001101" => memoryD <= W_BUF_DATA_O;
               when "000000000001110" => memoryE <= W_BUF_DATA_O;
               when others =>            memoryF <= W_BUF_DATA_O;
            end case;            
         else
            case W_BUF_ADDR_O is
               when "000000000000000" => W_BUF_DATA_I <= memory0;
               when "000000000000001" => W_BUF_DATA_I <= memory1;
               when "000000000000010" => W_BUF_DATA_I <= memory2;
               when "000000000000011" => W_BUF_DATA_I <= memory3;
               when "000000000000100" => W_BUF_DATA_I <= memory4;
               when "000000000000101" => W_BUF_DATA_I <= memory5;
               when "000000000000110" => W_BUF_DATA_I <= memory6;
               when "000000000000111" => W_BUF_DATA_I <= memory7;
               when "000000000001000" => W_BUF_DATA_I <= memory8;
               when "000000000001001" => W_BUF_DATA_I <= memory9;
               when "000000000001010" => W_BUF_DATA_I <= memoryA;
               when "000000000001011" => W_BUF_DATA_I <= memoryB;
               when "000000000001100" => W_BUF_DATA_I <= memoryC;
               when "000000000001101" => W_BUF_DATA_I <= memoryD;
               when "000000000001110" => W_BUF_DATA_I <= memoryE;
               when others =>            W_BUF_DATA_I <= memoryF;
            end case;  
         end if;    
      end if;
   end process cmd_buf_model; 


   -----------------------------------------------------------
   -- Dispatch_wishbone test stimulus
   -----------------------------------------------------------
          
   STIMULI : process
   procedure reset is
   begin
      W_RST_I              <= '1';
      W_CMD_RDY_I          <= '0';
      W_HEADER0_I          <= (others => '0');
      W_HEADER1_I          <= (others => '0');
      
      wait for PERIOD;
      
   end reset;
   
   procedure issue_cmd(header0 : std_logic_vector(31 downto 0);
                       header1 : std_logic_vector(31 downto 0)) is
   begin
      W_RST_I              <= '0';
      W_CMD_RDY_I          <= '1';
      W_HEADER0_I          <= header0;
      W_HEADER1_I          <= header1;
      
      wait for PERIOD;
      
      W_CMD_RDY_I          <= '0';

      wait until W_WB_RDY_O'event and W_WB_RDY_O = '0';
      
      wait for PERIOD * 10;

   end issue_cmd;
   
   begin
   
      reset;
      
      issue_cmd(x"AAAA8003", x"02970000");  -- write command
       
      issue_cmd(x"AAAA0003", x"02970000");  -- read command
      
      issue_cmd(x"AAAA8005", x"02000000");  -- invalid command (slave non-existent)
      
      issue_cmd(x"AAAA0001", x"02970000");  -- read 1 word command (boundary test case)
      
      issue_cmd(x"AAAA8001", x"02970000");  -- write 1 word command (boundary test case)
      
      issue_cmd(x"AAAA0000", x"02970000");  -- invalid command (invalid data size read)
      
      issue_cmd(x"AAAA8000", x"02970000");  -- invalid command (invalid data size write)
      
      wait for PERIOD * 10;
      
      assert false report "End of Simulation." severity FAILURE;
      
      wait for PERIOD;
      wait;
   end process STIMULI;

end BEH;