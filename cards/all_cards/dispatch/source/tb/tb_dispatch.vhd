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
-- tb_dispatch.vhd
--
-- Project:	      SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Testbench for top-level dispatch module
--
-- Revision history:
-- 
-- $Log$
--
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library components;
use components.component_pack.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library work;
use work.dispatch_pack.all;

entity TB_DISPATCH is
end TB_DISPATCH;

architecture BEH of TB_DISPATCH is

   component DISPATCH

      generic(CARD   : std_logic_vector ( BB_CARD_ADDRESS_WIDTH - 1 downto 0 )  := READOUT_CARD_1 );

      port(CLK_I          : in std_logic ;
           MEM_CLK_I      : in std_logic ;
           COMM_CLK_I     : in std_logic ;
           RST_I          : in std_logic ;
           LVDS_CMD_I     : in std_logic ;
           LVDS_REPLY_O   : out std_logic ;
           DAT_O          : out std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 );
           ADDR_O         : out std_logic_vector ( WB_ADDR_WIDTH - 1 downto 0 );
           TGA_O          : out std_logic_vector ( WB_TAG_ADDR_WIDTH - 1 downto 0 );
           WE_O           : out std_logic ;
           STB_O          : out std_logic ;
           CYC_O          : out std_logic ;
           DAT_I          : in std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 );
           ACK_I          : in std_logic ;
           WDT_RST_O      : out std_logic );

   end component;

   component LVDS_TX
      port(CLK_I        : in std_logic ;
           COMM_CLK_I   : in std_logic ;
           RST_I        : in std_logic ;
           DAT_I        : in std_logic_vector ( 31 downto 0 );
           RDY_I        : in std_logic ;
           BUSY_O       : out std_logic ;
           LVDS_O       : out std_logic );

   end component;

   component LVDS_RX
      port(CLK_I        : in std_logic ;
           COMM_CLK_I   : in std_logic ;
           RST_I        : in std_logic ;
           DAT_O        : out std_logic_vector ( 31 downto 0 );
           RDY_O        : out std_logic;
           ACK_I        : in std_logic;
           LVDS_I       : in std_logic);
   end component;

   component LEDS
      port(clk_i   : in std_logic;
           rst_i   : in std_logic;		
           dat_i 	 : in std_logic_vector (WB_DATA_WIDTH-1 downto 0); -- not used since not writing to array ID
           addr_i  : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
           tga_i   : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
           we_i    : in std_logic;
           stb_i   : in std_logic; 
           cyc_i   : in std_logic;
           dat_o   : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
           ack_o   : out std_logic;
           power   : out std_logic;
           status  : out std_logic;
           fault   : out std_logic);
   end component;
        
   constant PERIOD      : time := 40 ns;  
   constant FAST_PERIOD : time := 10 ns;  

   signal W_CLK_I          : std_logic := '1';
   signal W_MEM_CLK_I      : std_logic := '1';
   signal W_COMM_CLK_I     : std_logic := '1';
   signal W_RST_I          : std_logic ;
   signal W_LVDS_CMD       : std_logic ;
   signal W_LVDS_REPLY     : std_logic ;
   signal W_DAT_O          : std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 );
   signal W_ADDR_O         : std_logic_vector ( WB_ADDR_WIDTH - 1 downto 0 );
   signal W_TGA_O          : std_logic_vector ( WB_TAG_ADDR_WIDTH - 1 downto 0 );
   signal W_WE_O           : std_logic ;
   signal W_STB_O          : std_logic ;
   signal W_CYC_O          : std_logic ;
   signal W_DAT_I          : std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 ) := (others => '0');
   signal W_ACK_I          : std_logic ;
   signal W_WDT_RST_O      : std_logic ;

   signal W_LVDS_DAT_I     : std_logic_vector ( 31 downto 0 );
   signal W_LVDS_RDY_I     : std_logic ;
   signal W_LVDS_BUSY_O    : std_logic ; 
   
   signal W_REPLY_DAT_O    : std_logic_vector ( 31 downto 0 );
   signal W_REPLY_RDY_O    : std_logic;
   
   signal W_GREEN  : std_logic;
   signal W_YELLOW : std_logic;
   signal W_RED    : std_logic;
   
   -- Used in wishbone model:
   signal random0    : std_logic_vector(39 downto 0);
   signal slave_rdy  : std_logic;
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

   DUT : DISPATCH

      generic map(CARD   => BIAS_CARD_1 )

      port map(CLK_I          => W_CLK_I,
               MEM_CLK_I      => W_MEM_CLK_I,
               COMM_CLK_I     => W_COMM_CLK_I,
               RST_I          => W_RST_I,
               LVDS_CMD_I     => W_LVDS_CMD,
               LVDS_REPLY_O   => W_LVDS_REPLY,
               DAT_O          => W_DAT_O,
               ADDR_O         => W_ADDR_O,
               TGA_O          => W_TGA_O,
               WE_O           => W_WE_O,
               STB_O          => W_STB_O,
               CYC_O          => W_CYC_O,
               DAT_I          => W_DAT_I,
               ACK_I          => W_ACK_I,
               WDT_RST_O      => W_WDT_RST_O);

   TX : LVDS_TX
      port map(CLK_I        => W_CLK_I,
               COMM_CLK_I   => W_COMM_CLK_I,
               RST_I        => W_RST_I,
               DAT_I        => W_LVDS_DAT_I,
               RDY_I        => W_LVDS_RDY_I,
               BUSY_O       => W_LVDS_BUSY_O,
               LVDS_O       => W_LVDS_CMD);
   
   RX : LVDS_RX
      port map(CLK_I        => W_CLK_I,
               COMM_CLK_I   => W_COMM_CLK_I,
               RST_I        => W_RST_I,
               DAT_O        => W_REPLY_DAT_O,
               RDY_O        => W_REPLY_RDY_O,
               ACK_I        => '1',
               LVDS_I       => W_LVDS_REPLY);
               
   W_CLK_I <= not W_CLK_I after PERIOD/2;
   W_MEM_CLK_I <= not W_MEM_CLK_I after FAST_PERIOD/2;
   W_COMM_CLK_I <= not W_COMM_CLK_I after FAST_PERIOD/2;

   -----------------------------------------------------------
   -- Wishbone slave model
   -----------------------------------------------------------
   
--   wb_randomizer0: lfsr
--      generic map(WIDTH => 40)
--      port map(clk_i  => W_CLK_I,
--               rst_i  => W_RST_I,
--               ena_i  => '1',
--               load_i => '0',
--               clr_i  => '0',
--               lfsr_i => (others => '0'),
--               lfsr_o => random0);       
--   
--   slave_rdy  <= '1'; --random0(2);
--          
--   wb_slave_write_model: process(W_CLK_I, W_RST_I)
--   begin
--      if(W_RST_I = '1') then
--         slave_reg0 <= (others => '0');
--         slave_reg1 <= (others => '0');
--         slave_reg2 <= (others => '0');
--         slave_reg3 <= (others => '0');
--         slave_reg4 <= (others => '0');
--         slave_reg5 <= (others => '0');
--         slave_reg6 <= (others => '0');
--         slave_reg7 <= (others => '0');
--         slave_reg8 <= (others => '0');
--         slave_reg9 <= (others => '0');
--         slave_regA <= (others => '0');
--         slave_regB <= (others => '0');
--         slave_regC <= (others => '0');
--         slave_regD <= (others => '0');
--         slave_regE <= (others => '0');
--         slave_regF <= (others => '0');
--      elsif(W_CLK_I'event and W_CLK_I = '1') then
--         if(slave_rdy = '1') then
--            if(W_CYC_O = '1' and W_STB_O = '1') then
--               if(W_WE_O = '1') then
--                  -- write cycle
--                  case W_TGA_O is
--                     when "00000000000000000000000000000000" => slave_reg0 <= W_DAT_O;
--                     when "00000000000000000000000000000001" => slave_reg1 <= W_DAT_O;
--                     when "00000000000000000000000000000010" => slave_reg2 <= W_DAT_O;
--                     when "00000000000000000000000000000011" => slave_reg3 <= W_DAT_O;
--                     when "00000000000000000000000000000100" => slave_reg4 <= W_DAT_O;
--                     when "00000000000000000000000000000101" => slave_reg5 <= W_DAT_O;
--                     when "00000000000000000000000000000110" => slave_reg6 <= W_DAT_O;
--                     when "00000000000000000000000000000111" => slave_reg7 <= W_DAT_O;
--                     when "00000000000000000000000000001000" => slave_reg8 <= W_DAT_O;
--                     when "00000000000000000000000000001001" => slave_reg9 <= W_DAT_O;
--                     when "00000000000000000000000000001010" => slave_regA <= W_DAT_O;
--                     when "00000000000000000000000000001011" => slave_regB <= W_DAT_O;
--                     when "00000000000000000000000000001100" => slave_regC <= W_DAT_O;
--                     when "00000000000000000000000000001101" => slave_regD <= W_DAT_O;
--                     when "00000000000000000000000000001110" => slave_regE <= W_DAT_O;
--                     when others =>                             slave_regF <= W_DAT_O;
--
--                  end case;   
--               end if;
--            end if;
--         end if;
--      end if;
--   end process wb_slave_write_model;
--   
--   wb_slave_read_model: process(slave_rdy, W_CYC_O, W_STB_O, W_WE_O, W_TGA_O)
--   begin
--      if(slave_rdy = '1') then
--         if(W_CYC_O = '1' and W_STB_O = '1') then
--            if(W_WE_O = '0') then
--               -- read cycle
--               case W_TGA_O is
--                  when "00000000000000000000000000000000" => W_DAT_I <= slave_reg0;
--                  when "00000000000000000000000000000001" => W_DAT_I <= slave_reg1;
--                  when "00000000000000000000000000000010" => W_DAT_I <= slave_reg2;
--                  when "00000000000000000000000000000011" => W_DAT_I <= slave_reg3;
--                  when "00000000000000000000000000000100" => W_DAT_I <= slave_reg4;
--                  when "00000000000000000000000000000101" => W_DAT_I <= slave_reg5;
--                  when "00000000000000000000000000000110" => W_DAT_I <= slave_reg6;
--                  when "00000000000000000000000000000111" => W_DAT_I <= slave_reg7;
--                  when "00000000000000000000000000001000" => W_DAT_I <= slave_reg8;
--                  when "00000000000000000000000000001001" => W_DAT_I <= slave_reg9;
--                  when "00000000000000000000000000001010" => W_DAT_I <= slave_regA;
--                  when "00000000000000000000000000001011" => W_DAT_I <= slave_regB;
--                  when "00000000000000000000000000001100" => W_DAT_I <= slave_regC;
--                  when "00000000000000000000000000001101" => W_DAT_I <= slave_regD;
--                  when "00000000000000000000000000001110" => W_DAT_I <= slave_regE;
--                  when others =>                             W_DAT_I <= slave_regF;
--               end case;
--            end if;
--         end if;
--      end if;
--   end process wb_slave_read_model;
--   
--   W_ACK_I <= (W_CYC_O and W_STB_O) when slave_rdy = '1' else '0';
--   


   led0: LEDS
   port map(clk_i => W_CLK_I,
            rst_i => W_RST_I,

            dat_i 	=> W_DAT_O,
            addr_i => W_ADDR_O,
            tga_i  => W_TGA_O,
            we_i   => W_WE_O,
            stb_i  => W_STB_O,
            cyc_i  => W_CYC_O,
            dat_o  => W_DAT_I,
            ack_o  => W_ACK_I,
      
            power  => W_GREEN,
            status => W_YELLOW,
            fault  => W_RED);
            
   -----------------------------------------------------------
   -- Testbench stimulus
   -----------------------------------------------------------

   STIMULI : process
   procedure reset is
   begin
      W_RST_I          <= '1';
      W_LVDS_RDY_I     <= '0';
      W_LVDS_DAT_I     <= (others => '0');
      
      wait for PERIOD;
      
      W_RST_I          <= '0';
      W_LVDS_RDY_I     <= '0';
      W_LVDS_DAT_I     <= (others => '0');
            
      wait for PERIOD*200;
      
   end reset;
   
   procedure transmit (data : in std_logic_vector(31 downto 0)) is
   begin
      W_RST_I          <= '0';
      W_LVDS_RDY_I     <= '1';      
      W_LVDS_DAT_I     <= data;
            
      wait for PERIOD;
      
      W_RST_I          <= '0';
      W_LVDS_RDY_I     <= '0';      
      W_LVDS_DAT_I     <= (others => '0');
      
      wait until W_LVDS_BUSY_O = '0';

      wait for PERIOD*2;
   
   end transmit;
   
   procedure pause (length : in integer) is
   begin
      wait for PERIOD*length;
      
   end pause;
      
   begin
         
      reset;
      
--      transmit("10101010101010100000000000000011");  -- write 3 data words
--      transmit("00000111001000000000000000000000");  -- for BC1
--      transmit("00000000000000000000000000001010");  -- 0x0000000A
--      transmit("00000000000000001101111010101111");  -- 0x0000DEAF
--      transmit("00000000110010101011101100011110");  -- 0x00CABB1E
--      transmit("01110010011010111110010111111111");  -- CRC = 0x726BE5FF
--      
--      pause(1000);
--      
--      transmit("10101010101010100000000000000001");  -- write 1 data word
--      transmit("00001100000011110001000000010001");  -- for all BCs
--      transmit("00000000000000001111101010110101");  -- 0x0000FAB5
--      transmit("00100101110000110110010000000100");  -- CRC = 0x25C36404
--      
--      pause(1000);
--      
--      transmit("10101010101010100010000000000011");  -- read 3 words
--      transmit("00000111001000000000000000000000");  -- for BC1
--      transmit("11001000110000100011101011000001");  -- CRC = 0xC8C23AC1
--      
--      pause(1000);
      
      transmit("10101010101010100000000000000001");
      transmit("00000111100110010000000000000000");
      transmit("00000000000000000000000000000101");
      transmit("11101011110000101011010110101101");
      
      pause(1000);
      
      transmit("10101010101010100010000000000001");
      transmit("00000111100110010000000000000000");
      transmit("10111111111000000010100001001101");
      
      pause(1000);

      assert FALSE report "End of Simulation." severity FAILURE;
      
      wait for PERIOD;
      wait;
   end process STIMULI;

end BEH;