-- Copyright (c) 2003 SCUBA-2 Project
--               All Rights Reserved
--
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
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- $Id: first_stage_fb_queue_pack.vhd,v 1.2 2004/08/31 00:00:04 bburger Exp $
-- Description:
-- Pack file for the raw_data_queue generated with the Quartus Megawizard
--
-- Revision history:
-- $Log: first_stage_fb_queue_pack.vhd,v $
-- Revision 1.2  2004/08/31 00:00:04  bburger
-- Bryce:  removed compilation errors
--
-- Revision 1.1  2004/08/25 23:07:10  bburger
-- Bryce:  new
--
--
------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;

package first_stage_fb_queue_pack is

   constant FSFB_Q_LEN        : integer :=                     41;
   constant FSFB_Q_WIDTH      : integer :=                     32;
   constant FSFB_Q_ADDR_WIDTH : integer :=                      6;

   component first_stage_fb_queue IS
      PORT
      (
         data        : IN STD_LOGIC_VECTOR (FSFB_Q_WIDTH-1 DOWNTO 0);
         wraddress   : IN STD_LOGIC_VECTOR (FSFB_Q_ADDR_WIDTH-1 DOWNTO 0);
         rdaddress_a : IN STD_LOGIC_VECTOR (FSFB_Q_ADDR_WIDTH-1 DOWNTO 0);
         rdaddress_b : IN STD_LOGIC_VECTOR (FSFB_Q_ADDR_WIDTH-1 DOWNTO 0);
         wren        : IN STD_LOGIC  := '1';
         clock       : IN STD_LOGIC ;
         qa          : OUT STD_LOGIC_VECTOR (FSFB_Q_WIDTH-1 DOWNTO 0);
         qb          : OUT STD_LOGIC_VECTOR (FSFB_Q_WIDTH-1 DOWNTO 0)
      );
   END component;

end first_stage_fb_queue_pack;