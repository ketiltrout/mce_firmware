-- slave_ctrl.vhd
--
-- <revision control keyword substitutions e.g. $Id: slave_ctrl.vhd,v 1.1 2004/03/05 22:38:35 jjacob Exp $>
--
-- Project:		SCUBA 2
-- Author:		jjacob
-- Organisation:	UBC Physics and Astronomy
--
-- Description:
-- This code implements the Wishbone Slave state machine functionality
--
-- Revision history:
-- <date $Date: 2004/03/05 22:38:35 $>	-		<text>		- <initials $Author: jjacob $>
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library sys_param;
use sys_param.wishbone_pack.all;

entity slave_ctrl is

   generic (SLAVE_SEL      : std_logic_vector(WB_ADDR_WIDTH - 1 downto 0) := (others => '0');
            ADDR_WIDTH     : integer := WB_ADDR_WIDTH;
            DATA_WIDTH     : integer := WB_DATA_WIDTH;
            TAG_ADDR_WIDTH : integer := WB_TAG_ADDR_WIDTH);
      
   port (
 
   -- inputs from the slave to the slave controller indicating readiness
      slave_wr_ready      : in std_logic; -- slave is ready to be written to
      slave_rd_data_valid : in std_logic; -- the slave's data is ready to be read by master
      slave_retry         : in std_logic; -- signal from slave to master to try cycle again later
      
   -- outputs from the slave controller to the slave indicating validity of data
      master_wr_data_valid  : out std_logic; -- data from the master being written to the slave is valid
                
   -- slave_ctrl_dat_i gets fed through to dat_o when this slave is selected
      slave_ctrl_dat_i : in std_logic_vector (DATA_WIDTH-1 downto 0);
      
   -- data that always gets fed through to the slave
      slave_ctrl_dat_o : out std_logic_vector (DATA_WIDTH-1 downto 0);
      slave_ctrl_tga_o : out std_logic_vector (TAG_ADDR_WIDTH-1 downto 0);
      
   -- wishbone signals
      clk_i   : in std_logic;
      rst_i   : in std_logic;		
      dat_i 	 : in std_logic_vector (DATA_WIDTH-1 downto 0);
      addr_i  : in std_logic_vector (ADDR_WIDTH-1 downto 0); --define addr_width in pack file
      tga_i   : in std_logic_vector (TAG_ADDR_WIDTH-1 downto 0);
      we_i    : in std_logic;
      stb_i   : in std_logic;
      cyc_i   : in std_logic;
      

      dat_o   : out std_logic_vector (DATA_WIDTH-1 downto 0);
      rty_o   : out std_logic;
      ack_o   : out std_logic
 
   );
end slave_ctrl;

architecture rtl of slave_ctrl is

signal slave_selected : std_logic;

begin
 
------------------------------------------------------------------------
--
-- Wishbone bus protocol
--
------------------------------------------------------------------------
   
   process (slave_selected, stb_i, cyc_i, we_i, slave_wr_ready, slave_rd_data_valid)
   begin
   
      -- default assignments
      ack_o <= '0';
      --rty_o <= '0';
      master_wr_data_valid <= '0';

         if slave_selected = '1' and cyc_i = '1' then -- cycle has begun
            if stb_i = '1'  then -- indicates master is ready to read, or it's data for writing is valid
               if we_i = '1' then  -- write cycle
                  if slave_wr_ready = '1' then -- slave is ready to be written to
                     ack_o <= '1';
                     master_wr_data_valid <= '1';
                  end if;
               else  -- read cycle
                  if slave_rd_data_valid = '1' then -- slave's data is ready to be read by master
                     ack_o <= '1'; 
                  end if;
               end if;
            end if;
         end if;
      
   end process;

------------------------------------------------------------------------
--
-- Transfer of data to/from the slave from/to the slave_ctrl
--
------------------------------------------------------------------------
   
   dat_o <= slave_ctrl_dat_i when slave_selected = '1' and we_i = '0' else (others => '0');
   
   -- feedthrus
   slave_ctrl_dat_o <= dat_i;
   slave_ctrl_tga_o <= tga_i;
   
   -- retry signal
   rty_o <= slave_retry and cyc_i and stb_i and slave_selected;
   
   --rty_o <= slave_retry;
   
   slave_selected <= '1' when addr_i = SLAVE_SEL else '0';
   
end rtl;