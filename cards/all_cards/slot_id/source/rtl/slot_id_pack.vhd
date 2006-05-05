-- slave_ctrl_pack.vhd
--
-- <revision control keyword substitutions e.g. $Id: slot_id_pack.vhd,v 1.2 2005/01/25 21:47:47 erniel Exp $>
--
-- Project:		SCUBA 2
-- Author:		Jonathan Jacob
-- Organisation:	UBC Physics and Astronomy
--
-- Description:
-- This file has the constant definitions and package declaration for
-- the Wishbone Slave controller
--
-- Revision history:
-- <date $Date: 2005/01/25 21:47:47 $>	-		<text>		- <initials $Author: erniel $>
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.wishbone_pack.all;

package slot_id_pack is

   constant SLOT_ID_BITS : integer := 4;
   
   component bp_slot_id
   --generic (
      --SLOT_ID_ADDR  : std_logic_vector(WB_ADDR_WIDTH - 1 downto 0) := SLOT_ID_ADDR;
      --SLOT_ID_ADDR_WIDTH : integer := WB_ADDR_WIDTH;
      --SLOT_ID_DATA_WIDTH : integer := WB_DATA_WIDTH;
      --TAG_ADDR_WIDTH : integer := WB_TAG_ADDR_WIDTH
   -- );      
   port (   
      slot_id_i : in std_logic_vector (SLOT_ID_BITS-1 downto 0);
      -- wishbone signals
      clk_i   : in std_logic;
      rst_i   : in std_logic;		
      dat_i 	 : in std_logic_vector (WB_DATA_WIDTH-1 downto 0); -- not used since not writing to array ID
      addr_i  : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
      tga_i   : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i    : in std_logic;
      stb_i   : in std_logic;
      cyc_i   : in std_logic;
      err_o   : out std_logic;
      dat_o   : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
      ack_o   : out std_logic
   );
   end component;

end slot_id_pack;