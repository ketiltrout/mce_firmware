-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1
--
--
-- <revision control keyword substitutions e.g. $Id$>
--
-- Project:      MCE
-- Author:       Mandana Amiri
-- Organisation: UBC
--
-- Description:
-- This code handles critical_error and dev_clr commands. critical_error command 
-- results in asserting the critical_error pin for 30us which in turn triggers 
-- a reconfiguration of the FPGA from its configuration device.
-- dev_clr command results in asserting the dev_clr pin and hence clearing all
-- FPGA registers.
--
-- Revision history:
-- <date $Date: 2007/12/18 20:19:22$>
-- $Log$
--
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library sys_param;
use sys_param.wishbone_pack.all;

entity reset_clr is
   port(clk_i   : in std_logic;
        rst_i   : in std_logic;

        -- Wishbone signals
        dat_i   : in std_logic_vector (WB_DATA_WIDTH-1 downto 0);
        addr_i  : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
        tga_i   : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
        we_i    : in std_logic;
        stb_i   : in std_logic;
        cyc_i   : in std_logic;
        err_o   : out std_logic;
        dat_o   : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
        ack_o   : out std_logic;
        
        -- outputs
        critical_error_o: out std_logic;
        dev_clr_o : out std_logic        
      );
end reset_clr;

architecture rtl of reset_clr is

signal crit_error_rst_pending : std_logic;
signal crit_error_rst_cmd     : std_logic;

signal dev_clr_pending        : std_logic;
signal dev_clr_cmd        : std_logic;

begin
   -------------------------------------------------
   -- Hold critical error line for 100us (>26us according to MAX6301 datasheet)
   crit_error_rst_cmd <= '1' when (addr_i = CRIT_ERR_RST_ADDR and cyc_i = '1' and we_i = '1') else '0';

   err_proc : process (rst_i, clk_i)
   variable i: integer range 0 to (2**16-1):= 0;
   begin
      if (rst_i = '1') then
         crit_error_rst_pending <= '0';
         i := 0;
      elsif (clk_i'event and clk_i = '1') then
         if (crit_error_rst_cmd = '1') then 
            crit_error_rst_pending <= '1';            
         end if;
         if (crit_error_rst_pending = '1') then
            i := i + 1;
            if i = 5000 then -- 5000*20ns=100us
               i := 0;
               crit_error_rst_pending <= '0';
            end if;   
         end if;
      end if;
   end process err_proc;      
   critical_error_o <= crit_error_rst_pending;
   
   ---------------------------------------------------
   -- trying dev_clr or register reset
   dev_clr_cmd <= '1' when (addr_i = DEV_CLR_ADDR and cyc_i = '1' and we_i = '1') else '0';

   dev_clr_proc : process (rst_i, clk_i)
   variable j: integer range 0 to (2**16-1) :=0;
   begin
      if (rst_i = '1') then
         dev_clr_pending <= '0';
         j := 0;
      elsif (clk_i'event and clk_i = '1') then
         if (dev_clr_cmd = '1') then 
            dev_clr_pending <= '1';            
         end if;
         if (dev_clr_pending = '1') then
            j := j + 1;
            if j = 60000 then -- 60,000*20ns=1.2ms
               j := 0;
               dev_clr_pending <= '0';
            end if;   
         end if;
      end if;
   end process dev_clr_proc;      
   dev_clr_o <= not(dev_clr_pending);

   -- Acknowlege signal
   with addr_i select ack_o <=
      (stb_i and cyc_i) when CRIT_ERR_RST_ADDR | DEV_CLR_ADDR,      
      '0'               when others;

   -- Wishbone Error signal
   err_o <= '0';
   -- Wishbone readback data
   -- these are just reset signals and nothing to read back
   dat_o <= (others => '0');

end;