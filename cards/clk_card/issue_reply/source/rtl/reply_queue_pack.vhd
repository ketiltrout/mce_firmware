-----------------------------------------------------------------------------
--
-- Project:      MCE
-- Organization: Department of Physics & Astronomy, Univ. of British Columbia
-- Author:       Mandana A
-- 
-- $Id$
--
-- Description: 
--
-- $LOG
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;

library work;

-- Call Parent Library
use work.clk_card_pack.all;
use work.issue_reply_pack.all;

package reply_queue_pack is
   -----------------------------------------------------------------------------
   -- Reply Queue Receive component
   -----------------------------------------------------------------------------
   component reply_queue_receive
   port(
      clk_i          : in std_logic;
      comm_clk_i     : in std_logic;
      rst_i          : in std_logic;

      lvds_reply_a_i : in std_logic;
      lvds_reply_b_i : in std_logic;

      error_o        : out std_logic_vector(2 downto 0);   -- 3 error bits: Tx CRC error, Rx CRC error, Execute Error
      bad_preamble_o : out std_logic;

      data_o         : out std_logic_vector(31 downto 0);
      rdy_o          : out std_logic;
      pres_n_o       : out std_logic;
      ack_i          : in std_logic;
      clear_i        : in std_logic
   );
   end component;
   -----------------------------------------------------------------------------
   -- Reply Queue Sequencer Component
   -----------------------------------------------------------------------------
   component reply_queue_sequencer
   port(
      -- for debugging
      timer_trigger_o   : out std_logic;

      comm_clk_i        : in std_logic;
      clk_i             : in std_logic;
      rst_i             : in std_logic;

      card_data_size_i  : in std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
      -- cmd_translator interface
      cmd_code_i        : in  std_logic_vector (FIBRE_PACKET_TYPE_WIDTH-1 downto 0);       -- the least significant 16-bits from the fibre packet
      par_id_i          : in std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0);

      -- Bus Backplane interface
      lvds_reply_all_a_i     : in std_logic_vector(9 downto 0);
      lvds_reply_all_b_i     : in std_logic_vector(9 downto 0);

      card_not_present_o  : out std_logic_vector(9 downto 0);
      cards_to_report_i   : in std_logic_vector(9 downto 0);
      rcs_to_report_data_i   : in std_logic_vector(9 downto 0);
      dead_card_i            : in std_logic;

      -- fibre interface:
--      size_o            : out integer;
      error_o           : out std_logic_vector(29 downto 0);
      data_o            : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      rdy_o             : out std_logic;
      ack_i             : in std_logic;

      -- cmd_queue interface:
      card_addr_i       : in std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);
      cmd_valid_i       : in std_logic;
      matched_o         : out std_logic
   );
   end component;
   -----------------------------------------------------------------------------
   -- Reply Translator Frame Header RAM Component
   -----------------------------------------------------------------------------
   component reply_translator_frame_head_ram
   port(
      address  : in  std_logic_vector (RAM_HEAD_ADDR_WIDTH-1 downto 0);
      clock    : in  std_logic ;
      data     : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      wren     : in  std_logic ;
      q        : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0)
   );
   end component;

end reply_queue_pack;