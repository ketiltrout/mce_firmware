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
-- tb_dispatch_reply_transmit.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Testbench for dispatch reply transmitter
--
-- Revision history:
-- 
-- $Log: tb_dispatch_reply_transmit.vhd,v $
-- Revision 1.1  2004/09/10 16:54:24  erniel
-- initial version
--
--
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

library work;
use work.dispatch_pack.all;

entity TB_DISPATCH_REPLY_TRANSMIT is
end TB_DISPATCH_REPLY_TRANSMIT;

architecture BEH of TB_DISPATCH_REPLY_TRANSMIT is

   component DISPATCH_REPLY_TRANSMIT
      port(CLK_I         : in std_logic ;
           COMM_CLK_I    : in std_logic ;
           RST_I         : in std_logic ;
           LVDS_TX_O     : out std_logic ;
           REPLY_RDY_I   : in std_logic ;
           REPLY_ACK_O   : out std_logic ;
           HEADER0_I     : in std_logic_vector ( PACKET_WORD_WIDTH - 1 downto 0 );
           HEADER1_I     : in std_logic_vector ( PACKET_WORD_WIDTH - 1 downto 0 );
           HEADER2_I     : in std_logic_vector ( PACKET_WORD_WIDTH - 1 downto 0 );
           BUF_DATA_I    : in std_logic_vector ( BUF_DATA_WIDTH - 1 downto 0 );
           BUF_ADDR_O    : out std_logic_vector ( BUF_ADDR_WIDTH - 1 downto 0 ) );

   end component;

   component lvds_rx
      port(clk_i      : in std_logic;
           comm_clk_i : in std_logic;
           rst_i      : in std_logic;
           dat_o      : out std_logic_vector(31 downto 0);
           rdy_o      : out std_logic;
           ack_i      : in std_logic;
           lvds_i     : in std_logic);
   end component;

   constant PERIOD : time := 80 ns;
   constant COMM_PERIOD : time := 10 ns;
   
   signal W_CLK_I         : std_logic := '1';
   signal W_COMM_CLK_I    : std_logic := '1';
   signal W_RST_I         : std_logic ;
   signal W_LVDS_TX_O     : std_logic ;
   signal W_REPLY_RDY_I   : std_logic ;
   signal W_REPLY_ACK_O   : std_logic ;
   signal W_HEADER0_I     : std_logic_vector ( PACKET_WORD_WIDTH - 1 downto 0 );
   signal W_HEADER1_I     : std_logic_vector ( PACKET_WORD_WIDTH - 1 downto 0 );
   signal W_HEADER2_I     : std_logic_vector ( PACKET_WORD_WIDTH - 1 downto 0 );
   signal W_BUF_DATA_I    : std_logic_vector ( BUF_DATA_WIDTH - 1 downto 0 );
   signal W_BUF_ADDR_O    : std_logic_vector ( BUF_ADDR_WIDTH - 1 downto 0 ) ;

   signal lvds_rx_word : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal lvds_rx_rdy : std_logic;
   signal lvds_rx_ack : std_logic;
   
begin

   DUT : DISPATCH_REPLY_TRANSMIT
      port map(CLK_I         => W_CLK_I,
               COMM_CLK_I    => W_COMM_CLK_I,
               RST_I         => W_RST_I,
               LVDS_TX_O     => W_LVDS_TX_O,
               REPLY_RDY_I   => W_REPLY_RDY_I,
               REPLY_ACK_O   => W_REPLY_ACK_O,
               HEADER0_I     => W_HEADER0_I,
               HEADER1_I     => W_HEADER1_I,
               HEADER2_I     => W_HEADER2_I,
               BUF_DATA_I    => W_BUF_DATA_I,
               BUF_ADDR_O    => W_BUF_ADDR_O);

   W_CLK_I <= not W_CLK_I after PERIOD/2;
   W_COMM_CLK_I <= not W_COMM_CLK_I after COMM_PERIOD/2;
   
   reply_buf_model: process(W_COMM_CLK_I)
   begin
      if(W_COMM_CLK_I'event and W_COMM_CLK_I = '1') then
         case W_BUF_ADDR_O is
            when "000000" => W_BUF_DATA_I <= "00000000000000001111000000001111" ;  --0x0000F00F
            when "000001" => W_BUF_DATA_I <= "00000000000000001111000100011111" ;  --0x0000F11F
            when "000010" => W_BUF_DATA_I <= "00000000000000001111001000101111" ;  --0x0000F22F
            when "000011" => W_BUF_DATA_I <= "00000000000000001111001100111111" ;  --0x0000F33F
            when "000100" => W_BUF_DATA_I <= "00000000000000001111010001001111" ;  --0x0000F44F
            when "000101" => W_BUF_DATA_I <= "00000000000000001111010101011111" ;  --0x0000F55F
            when "000110" => W_BUF_DATA_I <= "00000000000000001111011001101111" ;  --0x0000F66F
            when "000111" => W_BUF_DATA_I <= "00000000000000001111011101111111" ;  --0x0000F77F
            when "001000" => W_BUF_DATA_I <= "00000000000000001111100010001111" ;  --0x0000F88F
            when "001001" => W_BUF_DATA_I <= "00000000000000001111100110011111" ;  --0x0000F99F
            when "001010" => W_BUF_DATA_I <= "00000000000000001111101010101111" ;  --0x0000FAAF
            when others =>   W_BUF_DATA_I <= "00000000000000000000000000000000" ;
         end case;
      end if;
   end process reply_buf_model;
   
   receiver: lvds_rx
      port map(clk_i      => W_CLK_I,
               comm_clk_i => W_COMM_CLK_I,
               rst_i      => W_RST_I,
               dat_o      => lvds_rx_word,
               rdy_o      => lvds_rx_rdy,
               ack_i      => '1',
               lvds_i     => W_LVDS_TX_O);


   STIMULI : process
   procedure reset is
   begin
      W_RST_I         <= '1';
      W_REPLY_RDY_I   <= '0';
      W_HEADER0_I     <= (others => '0');
      W_HEADER1_I     <= (others => '0');
      W_HEADER2_I     <= (others => '0');
      lvds_rx_ack     <= '0';
      
      wait for PERIOD;
   end reset;
   
   procedure transmit (header0 : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
                       header1 : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
                       header2 : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0)) is
   begin
      W_RST_I         <= '0';
      W_REPLY_RDY_I   <= '1';
      W_HEADER0_I     <= header0;
      W_HEADER1_I     <= header1;
      W_HEADER2_I     <= header2;
      
      wait until W_REPLY_ACK_O = '1';

      W_RST_I         <= '0';
      W_REPLY_RDY_I   <= '0';
      W_HEADER0_I     <= (others => '0');
      W_HEADER1_I     <= (others => '0');
      W_HEADER2_I     <= (others => '0');
      
      wait for 10 us;
   end transmit;
   
   begin
      
--      W_RST_I         <= '0';
--      W_REPLY_RDY_I   <= '0';
--      W_HEADER0_I     <= (others => '0');
--      W_HEADER1_I     <= (others => '0');
--      W_HEADER2_I     <= (others => '0');
--      W_BUF_DATA_I    <= (others => '0');
--
--      wait for PERIOD;
--      wait;

      reset;
      
      transmit("10101010101010100000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000");
      
      transmit("10101010101010100000000000000010", "11110000000010111010000000000000", "11111111000000000000000000000000");
      
      transmit("10101010101010100000000000001000", "00000000000000000000000000011111", "00000000000000000000000000000000");
      
      assert false report "End of simulation." severity FAILURE;

   end process STIMULI;

end BEH;