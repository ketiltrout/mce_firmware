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
-- reply_queue_accumulator.vhd
--
-- Project:	      SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Accumulator block used by reply_queue_sequencer
--
-- Revision history:
-- 
-- $Log$
--
-----------------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY reply_queue_accumulator IS
	PORT
	(
		data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		clock		: IN STD_LOGIC  := '0';
		sload		: IN STD_LOGIC  := '0';
		clken		: IN STD_LOGIC  := '1';
		aclr		: IN STD_LOGIC  := '0';
		result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END reply_queue_accumulator;


ARCHITECTURE SYN OF reply_queue_accumulator IS

	SIGNAL sub_wire0	: STD_LOGIC_VECTOR (31 DOWNTO 0);



	COMPONENT altaccumulate
	GENERIC (
		width_in		: NATURAL;
		width_out		: NATURAL;
		lpm_representation		: STRING;
		lpm_type		: STRING
	);
	PORT (
			sload	: IN STD_LOGIC ;
			clken	: IN STD_LOGIC ;
			aclr	: IN STD_LOGIC ;
			clock	: IN STD_LOGIC ;
			data	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			result	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
	END COMPONENT;

BEGIN
	result    <= sub_wire0(31 DOWNTO 0);

	altaccumulate_component : altaccumulate
	GENERIC MAP (
		width_in => 32,
		width_out => 32,
		lpm_representation => "UNSIGNED",
		lpm_type => "altaccumulate"
	)
	PORT MAP (
		sload => sload,
		clken => clken,
		aclr => aclr,
		clock => clock,
		data => data,
		result => sub_wire0
	);



END SYN;
