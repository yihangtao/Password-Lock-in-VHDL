-- Company: 
-- Engineer: 
-- 
-- Create Date: 2019/08/30 16:12:00
-- Design Name: 
-- Module Name: scan_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pi_tb is
--  Port ( );
end pi_tb;

architecture Behavioral of pi_tb is
component pi port(
clk:in std_logic;
disp_number: out std_logic_vector(6 downto 0);
disp_place:out std_logic_vector(7 downto 0);
input:in bit_vector(10 downto 0));
end component;
signal clk: std_logic;
signal disp_number:  std_logic_vector(6 downto 0);
signal disp_place: std_logic_vector(7 downto 0);
signal input:bit_vector(10 downto 0);
begin
dut:pi port map(
clk=>clk,disp_number=>disp_number,disp_place=>disp_place,input=>input);
process
variable cnt:integer:=0;
begin
clk<='1';
wait for 10ms;
cnt:=cnt+1;
if(cnt=10000) then 
input(9)<='1';
end if;
clk<='0';
wait for 10ms;
end process;
end Behavioral;