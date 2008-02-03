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
-- $Id: reply_translator_pack.vhd,v 1.6 2006/01/16 19:00:33 bburger Exp $
--
-- Project:    SCUBA2
-- Author:     Greg Dennis
-- Organization:  UBC
--
-- Description:
-- Declares a few constants used as parameters in the reply_translator block
--
-- Revision history:
-- $Log: reply_translator_pack.vhd,v $
-- Revision 1.6  2006/01/16 19:00:33  bburger
-- Bryce:  minor bug fixes for handling crc errors and timeouts
--
-- Revision 1.5  2005/11/15 03:17:22  bburger
-- Bryce: Added support to reply_queue_sequencer, reply_queue and reply_translator for timeouts and CRC errors from the bus backplane
--
-- Revision 1.4  2004/12/03 16:42:51  dca
-- mop_error_code_i width changed
--
-- Revision 1.3  2004/12/02 12:34:06  dca
-- m_op_* signals names changed to mop_* for consistency across issue_reply.
--
-- Revision 1.2  2004/11/25 14:55:04  dca
-- internal command added & frame header buffer added to reply translator.  tb changed accordingly.
--
-- Revision 1.1  2004/11/24 01:15:52  bench2
-- Greg: Broke apart issue reply and created pack files for all of its sub-components
--
--
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;

library work;
use work.sync_gen_pack.all;

package reply_translator_pack is

end reply_translator_pack;
