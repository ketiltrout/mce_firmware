-- slot_id.vhd
--
-- <revision control keyword substitutions e.g. $Id$>
--
-- Project:		SCUBA 2
-- Author:		Jonathan Jacob
-- Organisation:	UBC Physics and Astronomy
--
-- Description:
-- This code implements the Slot ID functionality
--
-- Revision history:
-- <date $Date$>	-		<text>		- <initials $Author$>
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.slot_id_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;

library components;
use components.component_pack.all;

entity slot_id is
   generic (
      SLOT_ID_ADDR  : std_logic_vector(WB_ADDR_WIDTH - 1 downto 0) := (others => '0');
      SLOT_ID_ADDR_WIDTH : integer := WB_ADDR_WIDTH;
      SLOT_ID_DATA_WIDTH : integer := WB_DATA_WIDTH;
      TAG_ADDR_WIDTH : integer := WB_TAG_ADDR_WIDTH
   );      
   port (   
      slot_id_i : in std_logic_vector (SLOT_ID_BITS-1 downto 0);
      -- wishbone signals
      clk_i   : in std_logic;
      rst_i   : in std_logic;		
      dat_i 	 : in std_logic_vector (WB_DATA_WIDTH-1 downto 0); -- not used since not writing to array ID
      addr_i  : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
      tga_i   : in std_logic_vector (TAG_ADDR_WIDTH-1 downto 0);
      we_i    : in std_logic;
      stb_i   : in std_logic;
      cyc_i   : in std_logic;
      dat_o   : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
      rty_o   : out std_logic;
      ack_o   : out std_logic
   );
end slot_id;

architecture rtl of slot_id is

-- internal signals
signal slot_id_reg : std_logic_vector (SLOT_ID_BITS-1 downto 0);
signal slot_id_valid : std_logic;
signal slave_wr_ready_sig : std_logic;
signal padded_slot_id_reg : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal no_connect : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal no_connect2 : std_logic;
signal no_connect3 : std_logic;

begin

------------------------------------------------------------------------
--
-- Read slot ID
--
------------------------------------------------------------------------

-- this is a simplified process, actual process might be more complex
   process (clk_i, rst_i)
   begin
      if rst_i = '1' then
         slot_id_reg <= "0000";
         slot_id_valid <= '0';
      elsif clk_i'event and clk_i = '1' then
         slot_id_reg <= slot_id_i;
         slot_id_valid <= '1';
      end if;     
   end process;
   
   slave_wr_ready_sig <= '0'; -- never ready since can't write to slot ID
   
------------------------------------------------------------------------
--
-- Wishbone
--
------------------------------------------------------------------------ 


   padded_slot_id_reg(WB_DATA_WIDTH-1 downto SLOT_ID_BITS) <= (others => '0');
   padded_slot_id_reg(SLOT_ID_BITS-1 downto 0) <= slot_id_reg;
   
   slot_id_slave_ctrl : slave_ctrl
   generic map (
      SLAVE_SEL  => SLOT_ID_ADDR,
      ADDR_WIDTH => WB_ADDR_WIDTH,
      DATA_WIDTH => WB_DATA_WIDTH,
      TAG_ADDR_WIDTH => TAG_ADDR_WIDTH)
   port map (
      slave_wr_ready        => slave_wr_ready_sig, -- can't write to the slot ID
      slave_rd_data_valid   => slot_id_valid,
      slave_retry           => no_connect3,
      master_wr_data_valid  => no_connect2,
      slave_ctrl_dat_i      => padded_slot_id_reg,
      slave_ctrl_dat_o      => no_connect,
      clk_i                 => clk_i,
      rst_i                 => rst_i,
      dat_i                 => dat_i,
      addr_i                => addr_i,
      tga_i                 => tga_i,
      we_i                  => we_i,
      stb_i                 => stb_i,
      cyc_i                 => cyc_i,
      dat_o                 => dat_o,
      rty_o                 => rty_o,
      ack_o                 => ack_o
   );

end rtl;
