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

-- 
--
-- <revision control keyword substitutions e.g. $Id$>
--
-- Project:	      SCUBA-2
-- Author:	      David Atkinson
--               
-- Organisation:  UK ATC
--
-- Description:  simple_reply_fsm
--
-- This block is for test purposes and generates a an appropriate reply when a command
-- is received.  For use with the NIOS development kit / fo tranceiver board.
--
--
-- Revision history:
-- 
-- <date $Date$>	-		<text>		- <initials $Author$>
-- $log$
-----------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY simple_reply_fsm IS
   PORT( 
      Brst        : IN     std_logic;
      clk         : IN     std_logic;

      cmd_code_i  : IN    std_logic_vector (15 DOWNTO 0);
      cksum_err_i : IN    std_logic;
      cmd_rdy_i   : IN    std_logic;
      tx_ff_i     : IN    std_logic;

      txd_o       : OUT    std_logic_vector (7 DOWNTO 0);
      tx_fw_o     : OUT    std_logic 
   );

END simple_reply_fsm ;


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ARCHITECTURE rtl OF simple_reply_fsm IS


-- FSM's states defined

constant IDLE        : std_logic_vector(5 downto 0) := "000000";
--constant INIT_CMD    : std_logic_vector(5 downto 0) := "000001";
--constant INIT_ERR    : std_logic_vector(5 downto 0) := "000010";
constant TX_PRE0     : std_logic_vector(5 downto 0) := "000011";

constant TX_PRE1     : std_logic_vector(5 downto 0) := "000100";
constant TX_PRE2     : std_logic_vector(5 downto 0) := "000101";
constant TX_PRE3     : std_logic_vector(5 downto 0) := "000110";
constant TX_PRE4     : std_logic_vector(5 downto 0) := "000111";

constant TX_PRE5     : std_logic_vector(5 downto 0) := "001000";
constant TX_PRE6     : std_logic_vector(5 downto 0) := "001001";
constant TX_PRE7     : std_logic_vector(5 downto 0) := "001010";
constant TX_WD1_0    : std_logic_vector(5 downto 0) := "001011";

constant TX_WD1_1    : std_logic_vector(5 downto 0) := "001100";
constant TX_WD1_2    : std_logic_vector(5 downto 0) := "001101";
constant TX_WD1_3    : std_logic_vector(5 downto 0) := "001110";
constant TX_WD2_0    : std_logic_vector(5 downto 0) := "001111";

constant TX_WD2_1    : std_logic_vector(5 downto 0) := "010000";
constant TX_WD2_2    : std_logic_vector(5 downto 0) := "010001";
constant TX_WD2_3    : std_logic_vector(5 downto 0) := "010010";
constant TX_WD3_0    : std_logic_vector(5 downto 0) := "010011";

constant TX_WD3_1    : std_logic_vector(5 downto 0) := "010100";
constant TX_WD3_2    : std_logic_vector(5 downto 0) := "010101";
constant TX_WD3_3    : std_logic_vector(5 downto 0) := "010110";
constant TX_WD4_0    : std_logic_vector(5 downto 0) := "010111";

constant TX_WD4_1    : std_logic_vector(5 downto 0) := "011000";
constant TX_WD4_2    : std_logic_vector(5 downto 0) := "011001";
constant TX_WD4_3    : std_logic_vector(5 downto 0) := "011010";
constant LD_PRE0     : std_logic_vector(5 downto 0) := "011011";

constant LD_PRE1     : std_logic_vector(5 downto 0) := "011100";
constant LD_PRE2     : std_logic_vector(5 downto 0) := "011101";
constant LD_PRE3     : std_logic_vector(5 downto 0) := "011110";
constant LD_PRE4     : std_logic_vector(5 downto 0) := "011111";

constant LD_PRE5     : std_logic_vector(5 downto 0) := "100000";
constant LD_PRE6     : std_logic_vector(5 downto 0) := "100001";
constant LD_PRE7     : std_logic_vector(5 downto 0) := "100010";
constant LD_WD1_0    : std_logic_vector(5 downto 0) := "100011";

constant LD_WD1_1    : std_logic_vector(5 downto 0) := "100100";
constant LD_WD1_2    : std_logic_vector(5 downto 0) := "100101";
constant LD_WD1_3    : std_logic_vector(5 downto 0) := "100110";
constant LD_WD2_0    : std_logic_vector(5 downto 0) := "100111";

constant LD_WD2_1    : std_logic_vector(5 downto 0) := "101000";
constant LD_WD2_2    : std_logic_vector(5 downto 0) := "101001";
constant LD_WD2_3    : std_logic_vector(5 downto 0) := "101010";
constant LD_WD3_0    : std_logic_vector(5 downto 0) := "101011";

constant LD_WD3_1    : std_logic_vector(5 downto 0) := "101100";
constant LD_WD3_2    : std_logic_vector(5 downto 0) := "101101";
constant LD_WD3_3    : std_logic_vector(5 downto 0) := "101110";
constant LD_WD4_0    : std_logic_vector(5 downto 0) := "101111";

constant LD_WD4_1    : std_logic_vector(5 downto 0) := "110000";
constant LD_WD4_2    : std_logic_vector(5 downto 0) := "110001";
constant LD_WD4_3    : std_logic_vector(5 downto 0) := "110010";



-- controller state variables:
signal current_state  : std_logic_vector(5 downto 0) := "000000";
signal next_state     : std_logic_vector(5 downto 0) := "000000";


-- Architecture Declarations
constant preamble1 : std_logic_vector(7 downto 0) := "10100101";
constant preamble2 : std_logic_vector(7 downto 0) := "01011010";

constant rp_w1_byte3 : std_logic_vector(7 downto 0) := X"20";
constant rp_w1_byte2 : std_logic_vector(7 downto 0) := X"20";
constant rp_w1_byte1 : std_logic_vector(7 downto 0) := X"52";
constant rp_w1_byte0 : std_logic_vector(7 downto 0) := X"50";

constant rp_w2_byte3 : std_logic_vector(7 downto 0) := X"00";
constant rp_w2_byte2 : std_logic_vector(7 downto 0) := X"00";
constant rp_w2_byte1 : std_logic_vector(7 downto 0) := X"00";
constant rp_w2_byte0 : std_logic_vector(7 downto 0) := X"02";

-- command code makes up bytes 3 and 2 of word 3
constant rp_ok_byte1 : std_logic_vector(7 downto 0) := X"4f";  -- 'O'
constant rp_ok_byte0 : std_logic_vector(7 downto 0) := X"4b";  -- 'K'

constant rp_er_byte1 : std_logic_vector(7 downto 0) := X"45";  -- 'E'
constant rp_er_byte0 : std_logic_vector(7 downto 0) := X"52";  -- 'R'

-- dummy data word 

constant rp_w4_byte3 : std_logic_vector(7 downto 0) := X"00";
constant rp_w4_byte2 : std_logic_vector(7 downto 0) := X"00";
constant rp_w4_byte1 : std_logic_vector(7 downto 0) := X"00";
constant rp_w4_byte0 : std_logic_vector(7 downto 0) := X"00";


signal reply_wd3: std_logic_vector (31 downto 0);
signal command: std_logic_vector (15 downto 0);

signal txing_reply: std_logic;
signal tx_reply: std_logic;


BEGIN

  ----------------------------------------------------------------------------
   initialise_reply : PROCESS(
      cmd_rdy_i,
      cksum_err_i,
      txing_reply
   )
   ----------------------------------------------------------------------------
   BEGIN
      IF (txing_reply = '1') THEN   
         tx_reply <= '0';         
      ELSIF (cmd_rdy_i'EVENT AND cmd_rdy_i = '1') THEN
         reply_wd3(31 downto 16) <= cmd_code_i;
         reply_wd3(15 downto 8) <= rp_ok_byte1;
         reply_wd3(7 downto 0) <= rp_ok_byte0;     
         tx_reply <= '1';
      ELSIF (cksum_err_i'EVENT AND cksum_err_i = '1') THEN
         reply_wd3(31 downto 16) <= cmd_code_i;
         reply_wd3(15 downto 8) <= rp_er_byte1;
         reply_wd3(7 downto 0) <= rp_er_byte0;  
         tx_reply <= '1';
      END IF;

   END PROCESS initialise_reply;

   ----------------------------------------------------------------------------
   clocked : PROCESS(
      clk,
      Brst
   )
   ----------------------------------------------------------------------------
   BEGIN
         
      IF (Brst = '1') THEN
         current_state <= IDLE;
      ELSIF (clk'EVENT AND clk = '1') THEN
         current_state <= next_state;
      END IF;

   END PROCESS clocked;

   ----------------------------------------------------------------------------
   nextstate : PROCESS (
      current_state,
      tx_reply
   )
   ----------------------------------------------------------------------------
   BEGIN
     
      CASE current_state IS

      WHEN IDLE =>
         IF (tx_reply = '1') THEN
            next_state <= LD_PRE0;
         ELSE
            next_state <= IDLE; 
         END IF;

   ------------------------------------------------
   

      WHEN LD_PRE0 =>
         IF (tx_ff_i = '1') THEN
            next_state <= LD_PRE0;
         ELSE 
            next_state <= TX_PRE0;
         END IF;
      WHEN LD_PRE1 =>
         IF (tx_ff_i = '1') THEN
            next_state <= LD_PRE1;
         ELSE 
            next_state <= TX_PRE1;
         END IF;
      WHEN LD_PRE2 =>
         IF (tx_ff_i = '1') THEN
            next_state <= LD_PRE2;
         ELSE 
            next_state <= TX_PRE2;
         END IF;
      WHEN LD_PRE3 =>
         IF (tx_ff_i = '1') THEN
            next_state <= LD_PRE3;
         ELSE 
            next_state <= TX_PRE3;
         END IF;
      WHEN LD_PRE4 =>
         IF (tx_ff_i = '1') THEN
            next_state <= LD_PRE4;
         ELSE 
            next_state <= TX_PRE4;
         END IF;
      WHEN LD_PRE5 =>
         IF (tx_ff_i = '1') THEN
            next_state <= LD_PRE5;
         ELSE 
            next_state <= TX_PRE5;
         END IF;
      WHEN LD_PRE6 =>
         IF (tx_ff_i = '1') THEN
            next_state <= LD_PRE6;
         ELSE 
            next_state <= TX_PRE6;
         END IF;
      WHEN LD_PRE7 =>
         IF (tx_ff_i = '1') THEN
            next_state <= LD_PRE7;
         ELSE 
            next_state <= TX_PRE7;
         END IF;


      WHEN LD_WD1_0 =>
         IF (tx_ff_i = '1') THEN
            next_state <= LD_WD1_0;
         ELSE 
            next_state <= TX_WD1_0;
         END IF;
      WHEN LD_WD1_1 =>
         IF (tx_ff_i = '1') THEN
            next_state <= LD_WD1_1;
         ELSE 
            next_state <= TX_WD1_1;
         END IF;
      WHEN LD_WD1_2 =>
         IF (tx_ff_i = '1') THEN
            next_state <= LD_WD1_2;
         ELSE 
            next_state <= TX_WD1_2;
         END IF;
      WHEN LD_WD1_3 =>
         IF (tx_ff_i = '1') THEN
            next_state <= LD_WD1_3;
         ELSE 
            next_state <= TX_WD1_3;
         END IF;

      WHEN LD_WD2_0 =>
         IF (tx_ff_i = '1') THEN
            next_state <= LD_WD2_0;
         ELSE 
            next_state <= TX_WD2_0;
         END IF;
      WHEN LD_WD2_1 =>
         IF (tx_ff_i = '1') THEN
            next_state <= LD_WD2_1;
         ELSE 
            next_state <= TX_WD2_1;
         END IF;
      WHEN LD_WD2_2 =>
         IF (tx_ff_i = '1') THEN
            next_state <= LD_WD2_2;
         ELSE 
            next_state <= TX_WD2_2;
         END IF;
      WHEN LD_WD2_3 =>
         IF (tx_ff_i = '1') THEN
            next_state <= LD_WD2_3;
         ELSE 
            next_state <= TX_WD2_3;
         END IF;

      WHEN LD_WD3_0 =>
         IF (tx_ff_i = '1') THEN
            next_state <= LD_WD3_0;
         ELSE 
            next_state <= TX_WD3_0;
         END IF;
      WHEN LD_WD3_1 =>
         IF (tx_ff_i = '1') THEN
            next_state <= LD_WD3_1;
         ELSE 
            next_state <= TX_WD3_1;
         END IF;
      WHEN LD_WD3_2 =>
         IF (tx_ff_i = '1') THEN
            next_state <= LD_WD3_2;
         ELSE 
            next_state <= TX_WD3_2;
         END IF;
      WHEN LD_WD3_3 =>
         IF (tx_ff_i = '1') THEN
            next_state <= LD_WD3_3;
         ELSE 
            next_state <= TX_WD3_3;
         END IF;

      WHEN LD_WD4_0 =>
         IF (tx_ff_i = '1') THEN
            next_state <= LD_WD4_0;
         ELSE 
            next_state <= TX_WD4_0;
         END IF;
      WHEN LD_WD4_1 =>
         IF (tx_ff_i = '1') THEN
            next_state <= LD_WD4_1;
         ELSE 
            next_state <= TX_WD4_1;
         END IF;
      WHEN LD_WD4_2 =>
         IF (tx_ff_i = '1') THEN
            next_state <= LD_WD4_2;
         ELSE 
            next_state <= TX_WD4_2;
         END IF;
      WHEN LD_WD4_3 =>
         IF (tx_ff_i = '1') THEN
            next_state <= LD_WD4_3;
         ELSE 
            next_state <= TX_WD4_3;
         END IF;


      WHEN TX_PRE0 =>
         next_state <= LD_PRE1;
         
      WHEN TX_PRE1 =>
         next_state <= LD_PRE2;
      WHEN TX_PRE2 =>
         next_state <= LD_PRE3;
      WHEN TX_PRE3 =>
         next_state <= LD_PRE4;
      WHEN TX_PRE4 =>
         next_state <= LD_PRE5;
      WHEN TX_PRE5 =>
         next_state <= LD_PRE6;
      WHEN TX_PRE6 =>
         next_state <= LD_PRE7;
      WHEN TX_PRE7 =>
         next_state <= LD_WD1_0;

      WHEN TX_WD1_0 =>
         next_state <= LD_WD1_1;
      WHEN TX_WD1_1 =>
         next_state <= LD_WD1_2;
      WHEN TX_WD1_2 =>
         next_state <= LD_WD1_3;
      WHEN TX_WD1_3 =>
         next_state <= LD_WD2_0;

      WHEN TX_WD2_0 =>
         next_state <= LD_WD2_1;
      WHEN TX_WD2_1 =>
         next_state <= LD_WD2_2;
      WHEN TX_WD2_2 =>
         next_state <= LD_WD2_3;
      WHEN TX_WD2_3 =>
         next_state <= LD_WD3_0;

      WHEN TX_WD3_0 =>
         next_state <= LD_WD3_1;
      WHEN TX_WD3_1 =>
         next_state <= LD_WD3_2;
      WHEN TX_WD3_2 =>
         next_state <= LD_WD3_3;
      WHEN TX_WD3_3 =>
         next_state <= LD_WD4_0;

      WHEN TX_WD4_0 =>
         next_state <= LD_WD4_1;
      WHEN TX_WD4_1 =>
         next_state <= LD_WD4_2;
      WHEN TX_WD4_2 =>
         next_state <= LD_WD4_3;
      WHEN TX_WD4_3 =>
         next_state <= IDLE;
                   
      WHEN OTHERS =>
         next_state <= IDLE;
      END CASE;

   END PROCESS nextstate;

   ----------------------------------------------------------------------------
   output : PROCESS (
      current_state, reply_wd3
   )
   ----------------------------------------------------------------------------
   BEGIN

      CASE current_state IS
      
      WHEN IDLE =>
         tx_fw_o <= '0';
         

      WHEN LD_PRE0 =>
         txd_o <= preamble1;
         tx_fw_o <= '0';
      WHEN LD_PRE1 =>
         txd_o <= preamble1;
         tx_fw_o <= '0'; 
      WHEN LD_PRE2 =>
         txd_o <= preamble1;
         tx_fw_o <= '0';
      WHEN LD_PRE3 =>
         txd_o <= preamble1;
         tx_fw_o <= '0';
      WHEN LD_PRE4 =>
         txd_o <= preamble2;
         tx_fw_o <= '0';
      WHEN LD_PRE5 =>
         txd_o <= preamble2;
         tx_fw_o <= '0'; 
      WHEN LD_PRE6 =>
         txd_o <= preamble2;
         tx_fw_o <= '0';
      WHEN LD_PRE7 =>
         txd_o <= preamble2;
         tx_fw_o <= '0';

      WHEN LD_WD1_0 =>
         txd_o <= rp_w1_byte0;
         tx_fw_o <= '0'; 
      WHEN LD_WD1_1 =>
         txd_o <= rp_w1_byte1;
         tx_fw_o <= '0';
      WHEN LD_WD1_2 =>
         txd_o <= rp_w1_byte2;
         tx_fw_o <= '0'; 
      WHEN LD_WD1_3 =>
         txd_o <= rp_w1_byte3;
         tx_fw_o <= '0';

      WHEN LD_WD2_0 =>
         txd_o <= rp_w2_byte0;
         tx_fw_o <= '0';
      WHEN LD_WD2_1 =>
         txd_o <= rp_w2_byte1;
         tx_fw_o <= '0';
      WHEN LD_WD2_2 =>
         txd_o <= rp_w2_byte2;
         tx_fw_o <= '0';
      WHEN LD_WD2_3 =>
         txd_o <= rp_w2_byte3;
         tx_fw_o <= '0';

      WHEN LD_WD3_0 =>
         txd_o <= reply_wd3(7 downto 0);
         tx_fw_o <= '0';
      WHEN LD_WD3_1 =>
         txd_o <= reply_wd3(15 downto 8);
         tx_fw_o <= '0';
      WHEN LD_WD3_2 =>
         txd_o <= reply_wd3(23 downto 16);
         tx_fw_o <= '0';
      WHEN LD_WD3_3 =>
         txd_o <= reply_wd3(31 downto 24);
         tx_fw_o <= '0';

      WHEN LD_WD4_0 =>
         txd_o <= rp_w4_byte0;
         tx_fw_o <= '0';
      WHEN LD_WD4_1 =>
         txd_o <= rp_w4_byte1;
         tx_fw_o <= '0';
      WHEN LD_WD4_2 =>
         txd_o <= rp_w4_byte2;
         tx_fw_o <= '0';
      WHEN LD_WD4_3 =>
         txd_o <= rp_w4_byte3;
         tx_fw_o <= '0';


      WHEN TX_PRE0 =>
         tx_fw_o <= '1';
         txing_reply <= '1';
      WHEN TX_PRE1 =>
         tx_fw_o <= '1';
      WHEN TX_PRE2 =>
         tx_fw_o <= '1';
      WHEN TX_PRE3 =>
         tx_fw_o <= '1';
      WHEN TX_PRE4 =>
         tx_fw_o <= '1';
      WHEN TX_PRE5 =>
         tx_fw_o <= '1';
      WHEN TX_PRE6 =>
         tx_fw_o <= '1';
      WHEN TX_PRE7 =>
         tx_fw_o <= '1';

      WHEN TX_WD1_0 =>
         tx_fw_o <= '1';
      WHEN TX_WD1_1 =>
         tx_fw_o <= '1';
      WHEN TX_WD1_2 =>
         tx_fw_o <= '1';
      WHEN TX_WD1_3 =>
         tx_fw_o <= '1';

      WHEN TX_WD2_0 =>
         tx_fw_o <= '1';
      WHEN TX_WD2_1 =>
         tx_fw_o <= '1';
      WHEN TX_WD2_2 =>
         tx_fw_o <= '1';
      WHEN TX_WD2_3 =>
         tx_fw_o <= '1';

      WHEN TX_WD3_0 =>
         tx_fw_o <= '1';
      WHEN TX_WD3_1 =>
         tx_fw_o <= '1';
      WHEN TX_WD3_2 =>
         tx_fw_o <= '1';
      WHEN TX_WD3_3 =>
         tx_fw_o <= '1';

      WHEN TX_WD4_0 =>
         tx_fw_o <= '1';
      WHEN TX_WD4_1 =>
         tx_fw_o <= '1';
      WHEN TX_WD4_2 =>
         tx_fw_o <= '1';
      WHEN TX_WD4_3 =>
         tx_fw_o <= '1';
         txing_reply <= '0';
         
      WHEN OTHERS =>
            NULL;
  
      END CASE;

   END PROCESS output;
   
 
END rtl;
