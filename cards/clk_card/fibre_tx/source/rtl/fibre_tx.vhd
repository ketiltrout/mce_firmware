-- Copyright (c) 2003 SCUBA-2 Project
--               All Rights Reserved
-- THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
-- The copyright notice above does not evidence any
-- actual or intended publication of such source code.
--
-- SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
-- REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
-- MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
-- PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
-- THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
--
-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.
--
-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC, University of British Columbia, Physics & Astronomy Department,
-- Vancouver BC, V6T 1Z1
--
-- fibre_tx.vhd
--
-- Project: Scuba 2
-- Author: David Atkinson	
-- Organisation: UK ATC
--
-- Description:
-- <description text>
--
-- Revision history:
-- <date $Date: 2004/08/30 11:04:41 $> - <text> - <initials $Author: dca $>
--
-- $Log: fibre_tx.vhd,v $


library ieee;
use ieee.std_logic_1164.all;

library work;
use work.issue_reply_pack.all;
use work.fibre_tx_pack.all;

library sys_param;
use sys_param.command_pack.all;


entity fibre_tx is
      port(       
      -- global inputs
         rst_i        : in     std_logic;
         
      -- interface to reply_translator
      
         txd_i        : in     std_logic_vector (7 downto 0);
         tx_fw_i      : in     std_logic;        
         tx_ff_o      : out    std_logic;
      
       -- interface to HOTLINK transmitter
         tx_fr_i      : in     std_logic;
         ft_clkw_i    : in     std_logic;
         nTrp_i       : in     std_logic;
         tx_fe_o      : out    std_logic; 
         tx_data_o    : out    std_logic_vector (7 downto 0);
         tsc_nTd_o    : out    std_logic;
         nFena_o      : out    std_logic;
         tx_fr_o      : out    std_logic
      );

end fibre_tx;



-------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.issue_reply_pack.all;
use work.fibre_tx_pack.all;


architecture behav of fibre_tx is 


   -- Internal signal declarations
   signal tx_fr       : std_logic;                                        -- transmit fifo read request
   signal tx_fw       : std_logic;                                        -- transmit fifo write request
   signal tx_fe       : std_logic;                                        -- transmit fifo empty
   signal tx_ff       : std_logic;                                        -- transmit fifo full

   signal txd         : std_logic_vector(TX_FIFO_DATA_WIDTH-1 DOWNTO 0);  -- data input to fifo
   signal tx_data     : std_logic_vector(TX_FIFO_DATA_WIDTH-1 DOWNTO 0);  -- data ouput of fifo

   signal ft_clkw     : std_logic;                                        -- 25MHz hotlink clock
   signal nTrp        : std_logic;                                        -- hotlink tx read pulse (active low)
   signal tsc_nTd     : std_logic;                                        -- hotlink tx special char/ data sel
   signal nFena       : std_logic;                                        -- hotlink tx enable

  
              
   begin
 
   -- Instance port mappings.
   I0 : fibre_tx_fifo
      generic map (
         addr_size => TX_FIFO_ADDR_SIZE              -- fifo size = 2**addr_size
      )
      port map (
         rst_i       => rst_i,
         tx_fr_i     => tx_fr,
         tx_fw_i     => tx_fw,
         txd_i       => txd,
         tx_fe_o     => tx_fe,
         tx_ff_o     => tx_ff,
         tx_data_o   => tx_data
   );
   
 
   I1: fibre_tx_control 
      port map ( 
         ft_clkw_i   =>   ft_clkw,
         nTrp_i      =>   nTrp,
         tx_fe_i     =>   tx_fe,
         tsc_nTd_o   =>   tsc_nTd,
         nFena_o     =>   nFena,
         tx_fr_o     =>   tx_fr
   );
   
 
  end behav;
