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
-- dispatch_data_buf.vhd
--
-- Project:	      SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Data buffer for dispatch block
--
-- Revision history:
-- 
-- $Log$
--
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity dispatch_data_buf is
port(data	     : in std_logic_vector (31 downto 0);
     wren	     : in std_logic  := '1';
     wraddress	: in std_logic_vector (5 downto 0);
     rdaddress	: in std_logic_vector (5 downto 0);
     clock	    : in std_logic ;
     q         : out std_logic_vector (31 downto 0));
end dispatch_data_buf;


architecture struct of dispatch_data_buf is

signal sub_wire0	: std_logic_vector (31 downto 0);

component altsyncram
generic(operation_mode                     : string;
        width_a                            : natural;
        widthad_a                          : natural;
        numwords_a                         : natural;
        width_b                            : natural;
        widthad_b                          : natural;
        numwords_b                         : natural;
        lpm_type	                          : string;
        width_byteena_a                    : natural;
        outdata_reg_b                      : string;
        indata_aclr_a                      : string;
        wrcontrol_aclr_a                   : string;
        address_aclr_a                     : string;
        address_reg_b                      : string;
        address_aclr_b                     : string;
        outdata_aclr_b                     : string;
        read_during_write_mode_mixed_ports : string;
        ram_block_type                     : string;
        intended_device_family             : string);
port(wren_a	   : in std_logic ;
     clock0    : in std_logic ;
     clock1    : in std_logic ;
     address_a : in std_logic_vector (5 downto 0);
     address_b : in std_logic_vector (5 downto 0);
     q_b       : out std_logic_vector (31 downto 0);
     data_a    : in std_logic_vector (31 downto 0));
end component;

signal n_clock : std_logic;

begin
   q <= sub_wire0(31 downto 0);

   altsyncram_component : altsyncram
   generic map (operation_mode => "DUAL_PORT",
		width_a => 32,
		widthad_a => 6,
		numwords_a => 64,
		width_b => 32,
		widthad_b => 6,
		numwords_b => 64,
		lpm_type => "altsyncram",
		width_byteena_a => 1,
		outdata_reg_b => "UNREGISTERED",
		indata_aclr_a => "NONE",
		wrcontrol_aclr_a => "NONE",
		address_aclr_a => "NONE",
		address_reg_b => "CLOCK1",
		address_aclr_b => "NONE",
		outdata_aclr_b => "NONE",
		read_during_write_mode_mixed_ports => "OLD_DATA",
		ram_block_type => "AUTO",
		intended_device_family => "Stratix")
   port map(wren_a => wren,
            clock0 => clock,
            clock1 => n_clock,
            address_a => wraddress,
            address_b => rdaddress,
            data_a => data,
            q_b => sub_wire0);

   n_clock <= not clock;
   
end struct;