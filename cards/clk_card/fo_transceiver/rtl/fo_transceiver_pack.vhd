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
-- <Title> 
--
-- <revision control keyword substitutions e.g. $Id: fo_transceiver_pack.vhd,v 1.2 2004/04/28 12:17:08 dca Exp $>
--
-- Project:	     SCUBA-2
-- Author:	      David Atkinson
--               
-- Organisation:  UK ATC
--
-- Description: 
-- <description text>
--
-- Revision history:
-- 
-- <date $Date: 2004/04/28 12:17:08 $>	-		<text>		- <initials $Author: dca $>
-- <$log$>
--
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package fo_transceiver_pack is

--------------------------------------
-- fo_transceiver
---------------------------------------

   component fo_transceiver
   port( 
      Brst        : in     std_logic;
      clk         : in     std_logic;
      
      rx_data_i   : in     std_logic_vector (7 DOWNTO 0);
      nRx_rdy_i   : in     std_logic;
      rvs_i       : in     std_logic;
      rso_i       : in     std_logic;
      rsc_nRd_i   : in     std_logic;  
      
      nTrp_i      : in     std_logic;
      ft_clkw_i   : in     std_logic; 
      
      tx_data_o   : out    std_logic_vector (7 DOWNTO 0);      
      tsc_nTd_o   : out    std_logic;
      nFena_o     : out    std_logic
  
   );
   end component; 



--------------------------------------
-- rx_fibre
---------------------------------------

   component rx_fibre is
   port( 
      Brst        : in     std_logic;
      clk         : in     std_logic;
      
      rx_data_i   : in     std_logic_vector (7 DOWNTO 0);
      nRx_rdy_i   : in     std_logic;
      rvs_i       : in     std_logic;
      rso_i       : in     std_logic;
      rsc_nRd_i   : in     std_logic;  
     
      card_addr_o : out    std_logic_vector (7 DOWNTO 0);
      cmd_code_o  : out    std_logic_vector (15 DOWNTO 0);
      cmd_data_o  : out    std_logic_vector (15 DOWNTO 0);
      cksum_err_o : out    std_logic;
      cmd_rdy_o   : out    std_logic;
      data_clk_o  : out    std_logic;
      num_data_o  : out    std_logic_vector (7 downto 0);
      reg_addr_o  : out    std_logic_vector (23 DOWNTO 0)
    );
    end component;



--------------------------------------
-- async_fifo
---------------------------------------

   COMPONENT async_fifo
      generic(fifo_size : Positive);
      port( 
         rst_i     : in     std_logic;
         read_i    : in     std_logic;
         write_i   : in     std_logic;
         d_i       : in     std_logic_vector (7 DOWNTO 0);
         empty_o   : out    std_logic;
         full_o    : out    std_logic;
         q_o       : out    std_logic_vector (7 DOWNTO 0)
      );
   end component;


--------------------------------------
-- rx_control
---------------------------------------

   component rx_control
      port( 
         nRx_rdy_i : in     std_logic;
         rsc_nRd_i : in     std_logic;
         rso_i     : in     std_logic;
         rvs_i     : in     std_logic;
         rx_ff_i   : in     std_logic;
         rx_fw_o   : out    std_logic
   );
   end component;


--------------------------------------
-- tx_control
---------------------------------------


component tx_control 
   port( 
      ft_clkw_i : in     std_logic;
      nTrp_i    : in     std_logic;
      tx_fe_i   : in     std_logic;
      tsc_nTd_o : out    std_logic;
      nFena_o   : out    std_logic;
      tx_fr_o   : out    std_logic
   );

end component;


--------------------------------------
-- rx_fifo
---------------------------------------

component rx_fifo 
      generic(fifo_size : Positive);
      port( 
         Brst      : in     std_logic;
         rx_fr_i   : in     std_logic;
         rx_fw_i   : in     std_logic;
         rx_data_i : in     std_logic_vector (7 DOWNTO 0);
         rx_fe_o   : out    std_logic;
         rx_ff_o   : out    std_logic;
         rxd_o     : out    std_logic_vector (7 DOWNTO 0)
      );

end component;


--------------------------------------
-- rx_protcol_fsm
---------------------------------------

component rx_protocol_fsm 
   port( 
      Brst        : in     std_logic;
      clk         : in     std_logic;
      rx_fe_i     : in     std_logic;
      rxd_i       : in     std_logic_vector (7 DOWNTO 0);
      card_addr_o : out    std_logic_vector (7 DOWNTO 0);
      cmd_code_o  : out    std_logic_vector (15 DOWNTO 0);
      cmd_data_o  : out    std_logic_vector (15 DOWNTO 0);
      cksum_err_o : out    std_logic;
      cmd_rdy_o   : out    std_logic;
      data_clk_o  : out    std_logic;
      num_data_o  : out    std_logic_vector (7 downto 0);
      reg_addr_o  : out    std_logic_vector (23 DOWNTO 0);
      rx_fr_o     : out    std_logic
   );

end component;


--------------------------------------
-- simple_reply_fsm
---------------------------------------

   component simple_reply_fsm 
   port( 
        Brst        : IN     std_logic;
        clk         : IN     std_logic;

        cmd_code_i  : IN    std_logic_vector (15 DOWNTO 0);
        cksum_err_i : IN    std_logic;
        cmd_rdy_i   : IN    std_logic;
        tx_ff_i     : IN    std_logic;

        txd_o       : OUT    std_logic_vector (7 DOWNTO 0);
        tx_fw_o     : OUT    std_logic 
    );
   end component;


--------------------------------------
-- tx_fifo
---------------------------------------


   component tx_fifo 
      generic(fifo_size : Positive);
      port( 
         Brst      : in     std_logic;
         tx_fr_i   : in     std_logic;
         tx_fw_i   : in     std_logic;
         txd_i     : in     std_logic_vector (7 DOWNTO 0);
         tx_fe_o   : out    std_logic;
         tx_ff_o   : out    std_logic;
         tx_data_o : out    std_logic_vector (7 DOWNTO 0)
      );

   end component;


---------------------------------------
-- tx_hotlink_sim
---------------------------------------


   component tx_hotlink_sim 
      port( 
         ft_clkw_i : in     std_logic;
         nFena_i   : in     std_logic;
         tsc_nTd_i : in     std_logic;   
         tx_data_i : in     std_logic_vector (7 downto 0);
         nTrp_o    : out    std_logic
       );
    end component;

-----------------------------------------
end fo_transceiver_pack;