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
-- Description:  rx_protocol_fsm
--
-- This block reads any incomming commands buffered in the rx_fifo and 
-- packages them up for subsequent blocks.
--
-- It checks that the command is preceded by the correct preamble.
-- It also calculates a checksum (sequential 32bit XOR) and compares
-- it to the one tranmitted by the host pc.  If they do not match 
-- an error is flagged at the output.
--
-- If the checksum is correct then the various words of the command
-- are made available at the block's output the and command ready
-- line (cmd_rdy_o) is asserted.   
--
-- The data words associated with the command are clocked out
-- sequentially (cmd_data_o) on the rising 
-- edge of the clock "data_clk_o", while cmd_rdy_o is asserted.  
--
--  see rx_protocol_fsm.doc for more details
--
-- The command stucture for all commands (WB, RB, ST, GO, RS) is as follows:
--
-- word 1 : Preamble
-- word 2 : Preamble
-- word 3 : Command code 
-- word 4 : Address (card and register)
-- word 5 : Number of valid data
-- word 6 : DataV1
-- word 7 : DataV2
--  ''    :  ''
-- word 63: DataV58 
-- word 64: checksum
--
-- Note that all words in the command structure are 32bit and arrive 
-- from the host in byte packets (little endian).
--
-- Revision history:
-- 1st March 2004   - Initial version      - DA
-- 
-- <date $Date$>	-		<text>		- <initials $Author$>
-- $log$
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rx_protocol_fsm is
   port( 
      Brst        : IN     std_logic;
      clk         : IN     std_logic;
      rx_fe_i     : IN     std_logic;
      rxd_i       : IN     std_logic_vector (7 DOWNTO 0);
      card_addr_o : OUT    std_logic_vector (7 DOWNTO 0);
      cmd_code_o  : OUT    std_logic_vector (15 DOWNTO 0);
      cmd_data_o  : OUT    std_logic_vector (15 DOWNTO 0);
      cksum_err_o : OUT    std_logic;
      cmd_rdy_o   : OUT    std_logic;
      data_clk_o  : OUT    std_logic;
      num_data_o  : OUT    std_logic_vector (7 downto 0);
      reg_addr_o  : OUT    std_logic_vector (23 DOWNTO 0);
      rx_fr_o     : OUT    std_logic
   );

end rx_protocol_fsm ;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture rtl of rx_protocol_fsm is


-- FSM's states defined

constant IDLE        : std_logic_vector(5 downto 0) := "000000";

constant RQ_PRE0     : std_logic_vector(5 downto 0) := "000001";
constant CK_PRE0     : std_logic_vector(5 downto 0) := "000010";
constant RQ_PRE1     : std_logic_vector(5 downto 0) := "000011";
constant CK_PRE1     : std_logic_vector(5 downto 0) := "000100";
constant RQ_PRE2     : std_logic_vector(5 downto 0) := "000101";
constant CK_PRE2     : std_logic_vector(5 downto 0) := "000110";
constant RQ_PRE3     : std_logic_vector(5 downto 0) := "000111";
constant CK_PRE3     : std_logic_vector(5 downto 0) := "001000";

constant RQ_PRE4     : std_logic_vector(5 downto 0) := "001001";
constant CK_PRE4     : std_logic_vector(5 downto 0) := "001010";
constant RQ_PRE5     : std_logic_vector(5 downto 0) := "001011";
constant CK_PRE5     : std_logic_vector(5 downto 0) := "001100";
constant RQ_PRE6     : std_logic_vector(5 downto 0) := "001101";
constant CK_PRE6     : std_logic_vector(5 downto 0) := "001110";
constant RQ_PRE7     : std_logic_vector(5 downto 0) := "001111";
constant CK_PRE7     : std_logic_vector(5 downto 0) := "010000";

constant RQ_CMD0     : std_logic_vector(5 downto 0) := "010001";
constant LD_CMD0     : std_logic_vector(5 downto 0) := "010010";
constant RQ_CMD1     : std_logic_vector(5 downto 0) := "010011";
constant LD_CMD1     : std_logic_vector(5 downto 0) := "010100";
constant RQ_CMD2     : std_logic_vector(5 downto 0) := "010101";
constant LD_CMD2     : std_logic_vector(5 downto 0) := "010110";
constant RQ_CMD3     : std_logic_vector(5 downto 0) := "010111";
constant LD_CMD3     : std_logic_vector(5 downto 0) := "011000";

constant RQ_ADDR0    : std_logic_vector(5 downto 0) := "011001";
constant LD_ADDR0    : std_logic_vector(5 downto 0) := "011010";
constant RQ_ADDR1    : std_logic_vector(5 downto 0) := "011011";
constant LD_ADDR1    : std_logic_vector(5 downto 0) := "011100";
constant RQ_ADDR2    : std_logic_vector(5 downto 0) := "011101";
constant LD_ADDR2    : std_logic_vector(5 downto 0) := "011110";
constant RQ_ADDR3    : std_logic_vector(5 downto 0) := "011111";
constant LD_ADDR3    : std_logic_vector(5 downto 0) := "100000";

constant RQ_CKSM0    : std_logic_vector(5 downto 0) := "100001";
constant LD_CKSM0    : std_logic_vector(5 downto 0) := "100010";
constant RQ_CKSM1    : std_logic_vector(5 downto 0) := "100011";
constant LD_CKSM1    : std_logic_vector(5 downto 0) := "100100";
constant RQ_CKSM2    : std_logic_vector(5 downto 0) := "100101";
constant LD_CKSM2    : std_logic_vector(5 downto 0) := "100110";
constant RQ_CKSM3    : std_logic_vector(5 downto 0) := "100111";
constant LD_CKSM3    : std_logic_vector(5 downto 0) := "101000";

constant RQ_NDA0     : std_logic_vector(5 downto 0) := "101001";
constant LD_NDA0     : std_logic_vector(5 downto 0) := "101010";
constant RQ_NDA1     : std_logic_vector(5 downto 0) := "101011";
constant LD_NDA1     : std_logic_vector(5 downto 0) := "101100";
constant RQ_NDA2     : std_logic_vector(5 downto 0) := "101101";
constant LD_NDA2     : std_logic_vector(5 downto 0) := "101110";
constant RQ_NDA3     : std_logic_vector(5 downto 0) := "101111";
constant LD_NDA3     : std_logic_vector(5 downto 0) := "110000";

constant RQ_BLK0     : std_logic_vector(5 downto 0) := "110001";
constant LD_BLK0     : std_logic_vector(5 downto 0) := "110010";
constant RQ_BLK1     : std_logic_vector(5 downto 0) := "110011";
constant LD_BLK1     : std_logic_vector(5 downto 0) := "110100";
constant RQ_BLK2     : std_logic_vector(5 downto 0) := "110101";
constant LD_BLK2     : std_logic_vector(5 downto 0) := "110110";
constant RQ_BLK3     : std_logic_vector(5 downto 0) := "110111";
constant LD_BLK3     : std_logic_vector(5 downto 0) := "111000";

constant CKSM_FAIL   : std_logic_vector(5 downto 0) := "111001";
constant READ_DATA   : std_logic_vector(5 downto 0) := "111010";
constant TX_DATA     : std_logic_vector(5 downto 0) := "111011";


-- controller state variables:
signal current_state  : std_logic_vector(5 downto 0) := "000000";
signal next_state     : std_logic_vector(5 downto 0) := "000000";


-- Architecture Declarations
constant preamble1 : std_logic_vector(7 downto 0) := "10100101";
constant preamble2 : std_logic_vector(7 downto 0) := "01011010";
constant write_block : std_logic_vector (15 downto 0) := X"5742"; 

signal command: std_logic_vector (15 downto 0);
signal cksum_calc : std_logic_vector(31 downto 0);
signal cksum_in : std_logic_vector(31 downto 0);
signal cksum_rcvd : std_logic_vector(31 downto 0);
signal check_update : std_logic;
signal check_reset : std_logic;


constant mem_size: positive := 64;
subtype mem_deep is integer range 0 to mem_size-1;
signal write_pointer: mem_deep;
signal read_pointer: mem_deep;


constant block_size: mem_deep := 58;  -- total number of data words in a write_block

signal number_data: positive;  -- this will be a value between 1 and 58
signal data_in: std_logic_vector(15 downto 0); -- current data word written to memory 
signal data_out: std_logic_vector(15 downto 0); -- current data word read from memory
signal write_mem: std_logic;  
signal read_mem: std_logic;
signal reset_mem: std_logic; 


subtype word is std_logic_vector(15 downto 0);
type mem is array (0 to mem_size-1) of word;
signal memory: mem;


begin

   ----------------------------------------------------------------------------
   clocked : process(
      clk,
      Brst
   )
   ----------------------------------------------------------------------------
   begin
         
      IF (Brst = '1') then
         current_state <= IDLE;
      elsif (clk'EVENT AND clk = '1') then
         current_state <= next_state;
      end if;

   end process clocked;

   ----------------------------------------------------------------------------
   nextstate : process (
      current_state,
      rx_fe_i,
      rxd_i,
      cksum_calc,
      cksum_rcvd
   )
   ----------------------------------------------------------------------------
   begin
     
      case current_state IS



      when IDLE =>
         if (rx_fe_i = '0') then
            next_state <= RQ_PRE0;
         else
            next_state <= IDLE;
         end if;

   ------------------------------------------------
   
   --preamble states

      when RQ_PRE0 =>
         next_state <= CK_PRE0;
      when RQ_PRE1 =>
         next_state <= CK_PRE1;
      when RQ_PRE2 =>
         next_state <= CK_PRE2;
      when RQ_PRE3 =>
         next_state <= CK_PRE3;
      when RQ_PRE4 =>
         next_state <= CK_PRE4;
      when RQ_PRE5 =>
         next_state <= CK_PRE5;
      when RQ_PRE6 =>
         next_state <= CK_PRE6;
      when RQ_PRE7 =>
         next_state <= CK_PRE7;


      when CK_PRE0 =>
         if (rxd_i(7 downto 0) /= preamble1) then
            next_state <= IDLE;
         else
            if (rx_fe_i = '0') then
               next_state <= RQ_PRE1;
            else
               next_state <= CK_PRE0;
            end if; 
         end if;
         
      when CK_PRE1 =>
         if (rxd_i(7 downto 0) /= preamble1) then
            next_state <= IDLE;
         else
            if (rx_fe_i = '0') then
               next_state <= RQ_PRE2;
            else
               next_state <= CK_PRE1;
            end if; 
         end if;
         
      when CK_PRE2 =>
         if (rxd_i(7 downto 0) /= preamble1) then
            next_state <= IDLE;
         else
            if (rx_fe_i = '0') then
               next_state <= RQ_PRE3;
            else
               next_state <= CK_PRE2;
            end if; 
         end if;
         
      when CK_PRE3 =>
         if (rxd_i(7 downto 0) /= preamble1) then
            next_state <= IDLE;
         else
            if (rx_fe_i = '0') then
               next_state <= RQ_PRE4;
            else
               next_state <= CK_PRE3;
            end if; 
         end if;
         
      when CK_PRE4 =>
         if (rxd_i(7 downto 0) /= preamble2) then
            next_state <= IDLE;
         else
            if (rx_fe_i = '0') then
               next_state <= RQ_PRE5;
            else
               next_state <= CK_PRE4;
            end if; 
         end if;

      when CK_PRE5 =>
         if (rxd_i(7 downto 0) /= preamble2) then
            next_state <= IDLE;
         else
            if (rx_fe_i = '0') then
               next_state <= RQ_PRE6;
            else
               next_state <= CK_PRE5;
            end if; 
         end if;

      when CK_PRE6 =>
         if (rxd_i(7 downto 0) /= preamble2) then
            next_state <= IDLE;
         else
            if (rx_fe_i = '0') then
               next_state <= RQ_PRE7;
            else
               next_state <= CK_PRE6;
            end if; 
         end if;
         
      when CK_PRE7 =>
         if (rxd_i(7 downto 0) /= preamble2) then
            next_state <= IDLE;
         else
            if (rx_fe_i = '0') then
               next_state <= RQ_CMD0;
            else
               next_state <= CK_PRE7;
            end if; 
         end if;                           
                                             
 
                  
   --------------------------------------------
   -- command word states
       
      when RQ_CMD0 =>
            next_state <= LD_CMD0;
      when RQ_CMD1 =>
            next_state <= LD_CMD1;
      when RQ_CMD2 =>
            next_state <= LD_CMD2;
      when RQ_CMD3 =>
            next_state <= LD_CMD3;


      when LD_CMD0 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_CMD1;
         else
            next_state <= LD_CMD0;
         end if;
      when LD_CMD1 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_CMD2;
         else
            next_state <= LD_CMD1;
         end if;
      when LD_CMD2 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_CMD3;
         else
            next_state <= LD_CMD2;
         end if;
      when LD_CMD3 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_ADDR0;
         else
            next_state <= LD_CMD3;
         end if;
   ---------------------------------------------------------
   --- address word states

      when RQ_ADDR0 =>
            next_state <= LD_ADDR0;
      when RQ_ADDR1 =>
            next_state <= LD_ADDR1;
      when RQ_ADDR2 =>
            next_state <= LD_ADDR2;
      when RQ_ADDR3 =>
            next_state <= LD_ADDR3;
 


      when LD_ADDR0 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_ADDR1;
         else
            next_state <= LD_ADDR0;
         end if;
      when LD_ADDR1 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_ADDR2;
         else
            next_state <= LD_ADDR1;
         end if;
      when LD_ADDR2 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_ADDR3;
         else
            next_state <= LD_ADDR2;
         end if;        

      when LD_ADDR3 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_NDA0;
         else
            next_state <= LD_ADDR3;
         end if; 

-------------------------------------------------------------
   -- number of data states
         
      when RQ_NDA0 =>
            next_state <= LD_NDA0;    
      when RQ_NDA1 =>
            next_state <= LD_NDA1;
      when RQ_NDA2 =>
            next_state <= LD_NDA2;
      when RQ_NDA3 =>
            next_state <= LD_NDA3;
           
      when LD_NDA0 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_NDA1;
         else
            next_state <= LD_NDA0;
         end if;        
      when LD_NDA1 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_NDA2;
         else
            next_state <= LD_NDA1;
         end if;
      when LD_NDA2 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_NDA3;
         else
            next_state <= LD_NDA2;
         end if;
      when LD_NDA3 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_BLK0;
         else
            next_state <= LD_NDA3;
         end if;


-----------------------------------------------
   --- store data states

      when RQ_BLK0 =>
            next_state <= LD_BLK0;    
      when RQ_BLK1 =>
            next_state <= LD_BLK1;              
      when RQ_BLK2 =>
            next_state <= LD_BLK2;
      when RQ_BLK3 =>
            next_state <= LD_BLK3;


      when LD_BLK0 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_BLK1;
         else
            next_state <= LD_BLK0;
         end if;
       
      when LD_BLK1 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_BLK2;
         else
            next_state <= LD_BLK1;
         end if;
      when LD_BLK2 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_BLK3;
         else
            next_state <= LD_BLK2;
         end if;
      when LD_BLK3 =>
         if (rx_fe_i = '0') then
           if (write_pointer < block_size) then
               next_state <= RQ_BLK0;
            else 
               next_state <= RQ_CKSM0;
            end if;
         else      
            next_state <= LD_BLK3;
         end if;        


------------------------------------------------
   -- checksum states

      when RQ_CKSM0 =>
            next_state <= LD_CKSM0; 
      when RQ_CKSM1 =>
            next_state <= LD_CKSM1;            
      when RQ_CKSM2 =>
            next_state <= LD_CKSM2;            
      when RQ_CKSM3 =>
            next_state <= LD_CKSM3;

      when LD_CKSM0 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_CKSM1;
         else
            next_state <= LD_CKSM0;
         end if;
      when LD_CKSM1 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_CKSM2;
         else
            next_state <= LD_CKSM1;
         end if;
      when LD_CKSM2 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_CKSM3;
         else
            next_state <= LD_CKSM2;
         end if;
      when LD_CKSM3 =>
         if (cksum_calc = cksum_rcvd) then
            next_state <= READ_DATA;
         else
            next_state <= CKSM_FAIL;
         end if;
            
      when CKSM_FAIL =>
            next_state <= IDLE;

-----------------------------------------------
            
      when READ_DATA =>
            next_state <= TX_DATA;
      when TX_DATA =>
         if (read_pointer < number_data) then   
            next_state <= READ_DATA;
         else   
            next_state <= IDLE;
         end if;               
                   
      when OTHERS =>
         next_state <= IDLE;
      end case;

   end PROCESS nextstate;

   ----------------------------------------------------------------------------
   output : PROCESS (
      current_state,
      rxd_i,
      data_out
   )
   ----------------------------------------------------------------------------
   BEGIN
      -- Default Assignment
      cksum_err_o <= '0';
      cmd_rdy_o <= '0';
      rx_fr_o <= '0';
      data_clk_o <= '0';
     
      write_mem <= '0'; 
      read_mem <= '0';
      reset_mem <= '0';
      check_update <= '0';
      check_reset <= '0';
      -- Combined Actions
      
      
      case current_state IS
         when IDLE =>
            reset_mem <= '1';
            check_reset <= '1';  
            number_data <= 1;
            cksum_rcvd <= X"00000000";
            cksum_in <= X"00000000";
            

         when LD_CMD0 =>
            cmd_code_o(7 downto 0) <= rxd_i(7 downto 0);
            command(7 downto 0) <= rxd_i(7 downto 0);   
            cksum_in(7 downto 0) <= rxd_i(7 downto 0);
         when LD_CMD1 =>
            cmd_code_o(15 downto 8) <= rxd_i(7 downto 0);
            cksum_in(15 downto 8) <= rxd_i(7 downto 0);
            command(15 downto 8) <= rxd_i(7 downto 0); 
         when LD_CMD2 =>
            cksum_in(23 downto 16) <= rxd_i(7 downto 0);
         when LD_CMD3 =>
            cksum_in(31 downto 24) <= rxd_i(7 downto 0);
            check_update <= '1';

         when LD_ADDR0 =>
            reg_addr_o(7 downto 0) <= rxd_i(7 downto 0);
            cksum_in(7 downto 0) <= rxd_i(7 downto 0);
         when LD_ADDR1 =>
            reg_addr_o(15 downto 8) <= rxd_i(7 downto 0);
            cksum_in(15 downto 8) <= rxd_i(7 downto 0);
         when LD_ADDR2 =>
            reg_addr_o(23 downto 16) <= rxd_i(7 downto 0);
            cksum_in(23 downto 16) <= rxd_i(7 downto 0);
         when LD_ADDR3 =>
            card_addr_o(7 downto 0) <= rxd_i(7 downto 0);
            cksum_in(31 downto 24) <= rxd_i(7 downto 0);
            check_update <= '1';

         when LD_NDA0 =>
            num_data_o <= rxd_i(7 downto 0);
            cksum_in(7 downto 0) <= rxd_i(7 downto 0);
            number_data <= To_integer(Unsigned(rxd_i(7 downto 0)));
         when LD_NDA1 =>
            cksum_in(15 downto 8) <=  rxd_i(7 downto 0);
         when LD_NDA2 =>
            cksum_in(23 downto 16) <= rxd_i(7 downto 0);
         when LD_NDA3 =>
            cksum_in(31 downto 24) <= rxd_i(7 downto 0);
            check_update <= '1';


         when LD_BLK0 =>
            cksum_in(7 downto 0) <= rxd_i(7 downto 0);
            data_in (7 downto 0) <= rxd_i(7 downto 0);
         when LD_BLK1 =>
            cksum_in(15 downto 8) <= rxd_i(7 downto 0);
            data_in (15 downto 8) <= rxd_i(7 downto 0);
            write_mem <= '1';
         when LD_BLK2 =>
            cksum_in(23 downto 16) <= rxd_i(7 downto 0);
         when LD_BLK3 =>
            cksum_in(31 downto 24) <= rxd_i(7 downto 0);
            check_update <= '1';           

            
         when LD_CKSM0 =>
            cksum_rcvd(7 downto 0) <= rxd_i(7 downto 0);  
         when LD_CKSM1 =>
            cksum_rcvd(15 downto 8) <= rxd_i(7 downto 0);
         when LD_CKSM2 =>
            cksum_rcvd(23 downto 16) <= rxd_i(7 downto 0);      
         when LD_CKSM3 =>
            cksum_rcvd(31 downto 24) <= rxd_i(7 downto 0); 

  
         when RQ_PRE7 =>
            rx_fr_o <= '1' ;
         when RQ_PRE6 =>
            rx_fr_o <= '1' ;
         when RQ_PRE5 =>
            rx_fr_o <= '1' ;
         when RQ_PRE4 =>
            rx_fr_o <= '1' ;
         when RQ_PRE3 =>
            rx_fr_o <= '1' ;
         when RQ_PRE2 =>
            rx_fr_o <= '1' ;
         when RQ_PRE1 =>
            rx_fr_o <= '1' ;
         when RQ_PRE0 =>
            rx_fr_o <= '1' ;
 
         when RQ_CMD3 =>
            rx_fr_o <= '1' ;
         when RQ_CMD2 =>
            rx_fr_o <= '1' ;
         when RQ_CMD1 =>
            rx_fr_o <= '1' ;
         when RQ_CMD0 =>
            rx_fr_o <= '1' ;

         when RQ_ADDR3 =>
            rx_fr_o <= '1' ;
         when RQ_ADDR2 =>
            rx_fr_o <= '1' ;
         when RQ_ADDR1 =>
            rx_fr_o <= '1' ;
         when RQ_ADDR0 =>
            rx_fr_o <= '1' ;

         when RQ_NDA3 =>
            rx_fr_o <= '1' ;
         when RQ_NDA2 =>
            rx_fr_o <= '1' ;
         when RQ_NDA1 =>
            rx_fr_o <= '1' ;
         when RQ_NDA0 =>
            rx_fr_o <= '1' ;
        
         when RQ_BLK3 =>
            rx_fr_o <= '1' ;
         when RQ_BLK2 =>
            rx_fr_o <= '1' ;
         when RQ_BLK1 =>
            rx_fr_o <= '1' ;
         when RQ_BLK0 =>
            rx_fr_o <= '1' ;                  

         when RQ_CKSM3 =>
            rx_fr_o <= '1' ;
         when RQ_CKSM2 =>
            rx_fr_o <= '1' ;
         when RQ_CKSM1 =>
            rx_fr_o <= '1' ;
         when RQ_CKSM0 =>
            rx_fr_o <= '1' ;
         
         when CKSM_FAIL =>
            cksum_err_o <= '1' ;

         when READ_DATA =>
            read_mem <= '1'; 
            cmd_rdy_o <= '1' ;
            data_clk_o <= '0' ;
         when TX_DATA =>
            cmd_data_o <= data_out ;
            cmd_rdy_o <= '1' ;
            data_clk_o <= '1' ;

         when others =>
            null;
      
      end case;

   end process output;
   

  ------------------------------------------------------------------------------
  checksum_calculator: process(check_update, check_reset, cksum_in)
  ----------------------------------------------------------------------------
  -- process to update calculated checksum
  ----------------------------------------------------------------------------
  
  begin
     
    if (check_reset = '1') then
       cksum_calc <= X"00000000";
    elsif (check_update'EVENT AND check_update = '1') then
       cksum_calc <= cksum_calc XOR cksum_in;
    end if;
     
  end process checksum_calculator;   
   
  ------------------------------------------------------------------------------
  write_memory: process(reset_mem, write_mem)
  ----------------------------------------------------------------------------
  -- process to write data word into local memory
  ----------------------------------------------------------------------------

 begin
     if (reset_mem = '1') then
        write_pointer <= 0;
     elsif (write_mem'EVENT AND write_mem = '1') then
        memory(write_pointer) <= data_in; 
        write_pointer <= write_pointer + 1;
     end if; 

  end process write_memory;
  
 ------------------------------------------------------------------------------
  read_memory: process(reset_mem, read_mem)
  ----------------------------------------------------------------------------
  -- process to read data word from local memory
  ----------------------------------------------------------------------------

 begin
     if (reset_mem = '1') then
        read_pointer <= 0;
     elsif (read_mem'EVENT AND read_mem = '1') then
        data_out <= memory(read_pointer); 
        read_pointer <= read_pointer + 1;
     end if; 

  end process read_memory;  
  
end rtl;
