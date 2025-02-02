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
-- packet_ram.vhd
--
-- Project:       SCUBA-2
-- Author:        Anthony & Mohsen
-- Organisation:  UBC
--
-- Description:
-- This file is used together with packet.hex in order to validate readout 
-- card firmware on the hardware.  Its contents is initialized with the
-- command stored in the packet.hex.  
-- NOTE: The final working of the readout card project does not need to refer 
-- to this.  Please refer to the documentation for proper usage.
--
-- Revision history:
-- 
-- $Log$
--
-- 
--
-----------------------------------------------------------------------------
