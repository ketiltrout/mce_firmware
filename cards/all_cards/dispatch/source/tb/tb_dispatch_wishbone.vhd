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
-- $Log$
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

library work;
use work.dispatch_pack.all;

entity TB_DISPATCH_WISHBONE is
end TB_DISPATCH_WISHBONE;

architecture BEH of TB_DISPATCH_WISHBONE is

   component DISPATCH_WISHBONE
      port(CLK_I              : in std_logic ;
           RST_I              : in std_logic ;
           CMD_RDY_I          : in std_logic ;
           DATA_SIZE_I        : in integer range 0 to MAX_DATA_WORDS - 1 ;
           CMD_TYPE_I         : in std_logic_vector ( COMMAND_TYPE_WIDTH - 1 downto 0 );
           PARAM_ID_I         : in std_logic_vector ( PARAMETER_ID_WIDTH - 1 downto 0 );
           CMD_BUF_DATA_I     : in std_logic_vector ( BUF_DATA_WIDTH - 1 downto 0 );
           CMD_BUF_ADDR_O     : out std_logic_vector ( BUF_ADDR_WIDTH - 1 downto 0 );
           REPLY_RDY_O        : out std_logic ;
           REPLY_BUF_DATA_O   : out std_logic_vector ( BUF_DATA_WIDTH - 1 downto 0 );
           REPLY_BUF_ADDR_O   : out std_logic_vector ( BUF_ADDR_WIDTH - 1 downto 0 );
           REPLY_BUF_WREN_O   : out std_logic ;
           WAIT_I             : in std_logic ;
           DAT_O              : out std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 );
           ADDR_O             : out std_logic_vector ( WB_ADDR_WIDTH - 1 downto 0 );
           TGA_O              : out std_logic_vector ( WB_TAG_ADDR_WIDTH - 1 downto 0 );
           WE_O               : out std_logic ;
           STB_O              : out std_logic ;
           CYC_O              : out std_logic ;
           DAT_I              : in std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 );
           ACK_I              : in std_logic );

   end component;


   constant PERIOD : time := 80 ns;
   constant FAST_PERIOD : time := 10 ns;
   
   signal W_CLK_I              : std_logic := '1';
   signal W_FAST_CLK_I         : std_logic := '1';  -- memory is clocked 8x faster
   signal W_RST_I              : std_logic ;
   signal W_CMD_RDY_I          : std_logic ;
   signal W_DATA_SIZE_I        : integer range 0 to MAX_DATA_WORDS - 1 ;
   signal W_CMD_TYPE_I         : std_logic_vector ( COMMAND_TYPE_WIDTH - 1 downto 0 );
   signal W_PARAM_ID_I         : std_logic_vector ( PARAMETER_ID_WIDTH - 1 downto 0 );
   signal W_CMD_BUF_DATA_I     : std_logic_vector ( BUF_DATA_WIDTH - 1 downto 0 );
   signal W_CMD_BUF_ADDR_O     : std_logic_vector ( BUF_ADDR_WIDTH - 1 downto 0 );
   signal W_REPLY_RDY_O        : std_logic ;
   signal W_REPLY_BUF_DATA_O   : std_logic_vector ( BUF_DATA_WIDTH - 1 downto 0 );
   signal W_REPLY_BUF_ADDR_O   : std_logic_vector ( BUF_ADDR_WIDTH - 1 downto 0 );
   signal W_REPLY_BUF_WREN_O   : std_logic ;
   signal W_WAIT_I             : std_logic ;
   signal W_DAT_O              : std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 );
   signal W_ADDR_O             : std_logic_vector ( WB_ADDR_WIDTH - 1 downto 0 );
   signal W_TGA_O              : std_logic_vector ( WB_TAG_ADDR_WIDTH - 1 downto 0 );
   signal W_WE_O               : std_logic ;
   signal W_STB_O              : std_logic ;
   signal W_CYC_O              : std_logic ;
   signal W_DAT_I              : std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 ) := (others => '0');
   signal W_ACK_I              : std_logic ;

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
   
begin

   DUT : DISPATCH_WISHBONE
      port map(CLK_I              => W_CLK_I,
               RST_I              => W_RST_I,
               CMD_RDY_I          => W_CMD_RDY_I,
               DATA_SIZE_I        => W_DATA_SIZE_I,
               CMD_TYPE_I         => W_CMD_TYPE_I,
               PARAM_ID_I         => W_PARAM_ID_I,
               CMD_BUF_DATA_I     => W_CMD_BUF_DATA_I,
               CMD_BUF_ADDR_O     => W_CMD_BUF_ADDR_O,
               REPLY_RDY_O        => W_REPLY_RDY_O,
               REPLY_BUF_DATA_O   => W_REPLY_BUF_DATA_O,
               REPLY_BUF_ADDR_O   => W_REPLY_BUF_ADDR_O,
               REPLY_BUF_WREN_O   => W_REPLY_BUF_WREN_O,
               WAIT_I             => W_WAIT_I,
               DAT_O              => W_DAT_O,
               ADDR_O             => W_ADDR_O,
               TGA_O              => W_TGA_O,
               WE_O               => W_WE_O,
               STB_O              => W_STB_O,
               CYC_O              => W_CYC_O,
               DAT_I              => W_DAT_I,
               ACK_I              => W_ACK_I);

   W_CLK_I <= not W_CLK_I after PERIOD/2;
   W_FAST_CLK_I <= not W_FAST_CLK_I after FAST_PERIOD/2;
   
   
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
                     when "00000000000000000000000000000000" => slave_reg0 <= W_DAT_O;
                     when "00000000000000000000000000000001" => slave_reg1 <= W_DAT_O;
                     when "00000000000000000000000000000010" => slave_reg2 <= W_DAT_O;
                     when "00000000000000000000000000000011" => slave_reg3 <= W_DAT_O;
                     when "00000000000000000000000000000100" => slave_reg4 <= W_DAT_O;
                     when "00000000000000000000000000000101" => slave_reg5 <= W_DAT_O;
                     when "00000000000000000000000000000110" => slave_reg6 <= W_DAT_O;
                     when "00000000000000000000000000000111" => slave_reg7 <= W_DAT_O;
                     when "00000000000000000000000000001000" => slave_reg8 <= W_DAT_O;
                     when "00000000000000000000000000001001" => slave_reg9 <= W_DAT_O;
                     when "00000000000000000000000000001010" => slave_regA <= W_DAT_O;
                     when "00000000000000000000000000001011" => slave_regB <= W_DAT_O;
                     when "00000000000000000000000000001100" => slave_regC <= W_DAT_O;
                     when "00000000000000000000000000001101" => slave_regD <= W_DAT_O;
                     when "00000000000000000000000000001110" => slave_regE <= W_DAT_O;
                     when others =>                             slave_regF <= W_DAT_O;

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
   
   W_WAIT_I <= '0' when master_rdy = '1' else '1';
   
   
   -----------------------------------------------------------
   -- Command buffer model (altsyncram timing)
   -----------------------------------------------------------
    
   cmd_buf_model: process(W_FAST_CLK_I)
   begin
      if(W_FAST_CLK_I'event and W_FAST_CLK_I = '1') then
         case W_CMD_BUF_ADDR_O is
            when "000000" => W_CMD_BUF_DATA_I <= "00000000000000001111000000001111" ;  --0x0000F00F
            when "000001" => W_CMD_BUF_DATA_I <= "00000000000000001111000100011111" ;  --0x0000F11F
            when "000010" => W_CMD_BUF_DATA_I <= "00000000000000001111001000101111" ;  --0x0000F22F
            when "000011" => W_CMD_BUF_DATA_I <= "00000000000000001111001100111111" ;  --0x0000F33F
            when "000100" => W_CMD_BUF_DATA_I <= "00000000000000001111010001001111" ;  --0x0000F44F
            when "000101" => W_CMD_BUF_DATA_I <= "00000000000000001111010101011111" ;  --0x0000F55F
            when "000110" => W_CMD_BUF_DATA_I <= "00000000000000001111011001101111" ;  --0x0000F66F
            when "000111" => W_CMD_BUF_DATA_I <= "00000000000000001111011101111111" ;  --0x0000F77F
            when "001000" => W_CMD_BUF_DATA_I <= "00000000000000001111100010001111" ;  --0x0000F88F
            when "001001" => W_CMD_BUF_DATA_I <= "00000000000000001111100110011111" ;  --0x0000F99F
            when "001010" => W_CMD_BUF_DATA_I <= "00000000000000001111101010101111" ;  --0x0000FAAF
            when others =>   W_CMD_BUF_DATA_I <= "00000000000000000000000000000000" ;
         end case;
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
      W_DATA_SIZE_I        <= 0;
      W_CMD_TYPE_I         <= (others => '0');
      W_PARAM_ID_I         <= (others => '0');
      
      wait for PERIOD;
      
   end reset;
   
   procedure issue_cmd(header0 : std_logic_vector(CMD_WORD_WIDTH-1 downto 0);
                       header1 : std_logic_vector(CMD_WORD_WIDTH-1 downto 0)) is
   begin
      W_RST_I              <= '0';
      W_CMD_RDY_I          <= '1';
      W_DATA_SIZE_I        <= conv_integer(header0(CMD_DATA_SIZE'range));
      W_CMD_TYPE_I         <= header0(COMMAND_TYPE'range);
      W_PARAM_ID_I         <= header1(PARAMETER_ID'range);

      wait for PERIOD;
      
      W_RST_I              <= '0';
      W_CMD_RDY_I          <= '0';
      W_DATA_SIZE_I        <= conv_integer(header0(CMD_DATA_SIZE'range));
      W_CMD_TYPE_I         <= header0(COMMAND_TYPE'range);
      W_PARAM_ID_I         <= header1(PARAMETER_ID'range);
      
      wait until W_REPLY_RDY_O'event and W_REPLY_RDY_O = '0';

   end issue_cmd;
   
   begin
   
      reset;
      
      issue_cmd("10101010101010100000000000000011", "00000010100101110000000000000000");  -- write command
       
      issue_cmd("10101010101010100010000000000011", "00000010100101110000000000000000");  -- read command
      
      wait for PERIOD * 10;
      
      assert false report "End of Simulation." severity FAILURE;
      
      wait for PERIOD;
      wait;
   end process STIMULI;

end BEH;