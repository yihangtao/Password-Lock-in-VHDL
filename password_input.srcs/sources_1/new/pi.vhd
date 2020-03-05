----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2019/08/30 14:49:50
-- Design Name: 
-- Module Name: pi - Behavioral
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



LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pi is
  Port (
  clk:in std_logic;--时钟信号
  led:out std_logic_vector(15 downto 0):="0000000000000000";--LED灯端口号
  input:in bit_vector(10 downto 0):="00000000000";--数字按键（0-9）和退格键端口
  disp_number:out std_logic_vector(6 downto 0):="1111111";--数码管七段LED端口
  disp_place:out std_logic_vector(7 downto 0):="11111111";--数码管使能端口
  red:out std_logic:='0';--彩色LED端口
  blue:out std_logic:='0';--彩色LED端口
  spe:in bit:='0';        --专用按键端口
  keyinput:in bit:='0';  --密码输入按键端口
  sure:in bit:='0');     --确认键端口
  
end pi;

architecture Behavioral of pi is
begin
process(clk)
variable spe_state:integer:=0;                               --专用按键状态变量
variable sure_state:integer:=0;                            --确认键状态变量
variable keyinput_state:integer:=0;                         --密码输入键状态变量
variable count:integer:=0;                         --密码输入个数
variable input_temp:bit_vector(10 downto 0):="00000000000";--上一个时刻的数字按键状态
variable input_next:bit_vector(10 downto 0):="00000000000";--异或后返回的数字按键状态变量
variable spe_temp:bit:='0';                       --上一个时刻专用按键状态
variable keyinput_temp:bit:='0';--上一个时刻密码输入按键状态
variable sure_temp:bit:='0';--上一个时刻确认键状态
variable spe_check:bit:='0';--由异或结果转换得到的反映专用按键是否按下的变量
variable sure_check:bit:='0';    --由异或结果转换得到的反映确认键是否按下的变量
variable keyinput_check:bit:='0';--由异或结果得到的反映密码输入按键是否按下的变量
variable count1:integer:=0;--动态扫描大周期计数变量
variable count2:integer:=0;--动态扫描小周期计数变量
variable count3:integer:=0;--动态扫描大周期计数变量
variable count4:integer:=0;--动态扫描小周期计数变量
variable ledcnt:integer:=0;--LED灯显示程序计数变量
variable reg1:std_logic_vector(6 downto 0):="1111111";--数码管1显示变量
variable reg2:std_logic_vector(6 downto 0):="1111111";--数码管2显示变量
variable reg3:std_logic_vector(6 downto 0):="1111111";--数码管3显示变量
variable reg4:std_logic_vector(6 downto 0):="1111111";--数码管4显示变量
variable reg5:std_logic_vector(6 downto 0):="1111111";--倒计时显示变量
variable reg6:std_logic_vector(6 downto 0):="1111111";--倒计时显示变量
variable reg1_temp:std_logic_vector(6 downto 0):="1000000";--密码设置存储变量
variable reg2_temp:std_logic_vector(6 downto 0):="1000000";--密码设置存储变量
variable reg3_temp:std_logic_vector(6 downto 0):="1000000";--密码设置存储变量
variable reg4_temp:std_logic_vector(6 downto 0):="1000000";--密码设置存储变量
variable reg1_temp2:std_logic_vector(6 downto 0):="1111111";--密码输入存储变量
variable reg2_temp2:std_logic_vector(6 downto 0):="1111111";--密码输入存储变量
variable reg3_temp2:std_logic_vector(6 downto 0):="1111111";--密码输入存储变量
variable reg4_temp2:std_logic_vector(6 downto 0):="1111111";--密码输入存储变量
variable period:integer :=0;--大时钟周期计数变量
variable speriod:integer :=0;--数字按键消抖计时变量
variable spe_period:integer:=0;--专用按键消抖计时变量
variable sure_period:integer:=0;--确认键消抖计时变量
variable errcnt:integer:=0;--“error”显示程序计时变量
variable enable:bit:='0';--等待界面锁定变量
variable enable2:bit:='0';--密码比较程序锁定变量
variable led_enable:bit:='0';--LED灯全亮程序锁定变量
variable lose_time:integer:=0;--失败次数
variable lock:bit:='0';--锁死状态变量
variable open_return:bit:='0';--开锁成功返回等待界面允许变量
variable lose_return:bit:='0';--开锁失败返回等待界面允许变量
variable sure_lock:bit:='0';--确认键检查程序锁定变量
variable spe_lock:bit:='0';--专用按键检查程序锁定变量
variable lose_lock:bit:='0';--开锁失败处理程序锁定变量
variable time:integer:=0;--时钟分频变量
variable lose_wait:integer:=0;--开锁失败等待时间变量
variable lose_wait_time:integer:=0;--等待时间校准变量
variable lose_wait_count:integer:=0;--开锁失败等待总时间变量
variable suc_wait:integer:=0;--开锁成功等待时间变量
variable lose_wait_count_lock:bit:='0';--开锁等待时间恢复变量
begin 
if(clk 'event and clk='1')then --检测时钟上升沿
time:=time+1;
if(time=25) then     --时钟分频，子时钟周期为250ns
time:=0;
period:=period+1;

if(period =27) then    --设定执行周期为27个子时钟周期
period:=0;
end if;
         
if(sure_lock='1') then
if(period<4 or period>20) then
period:=4;
end if;
if(period=5) then
period:=6;
end if;
if(period>6 and period<20) then
period:=20;
end if;
end if;   ----开锁成功后的程序调用（如果开锁成功，则只允许执行第5，7，21个周期的程序，分别是LED灯全亮程序，确认键检测及等待返回程序，数码管动态扫描显示“OPEN”程序）

if(lose_lock='1' and lock='0') then
if(period<3 or period>25) then
period:=3;
end if;
if(period=4) then
period:=5;
end if;
if(period>5 and period<21) then
period:=21;
end if;
if(period>22 and period<25) then
period:=25;
end if;
end if;-----开锁失败三次以内的程序调用（如果开锁失败且失败次数尚在三次以内，则只允许执行第4，6，22，23，26周期的程序，分别对应密码比较，锁死状态检测，等待返回主菜单，ERROR闪烁及倒计时显示，确认键检测）

if(lock='1') then
if(period<5 or period>25) then
period:=5;
end if;
if(period>5 and period<23) then
period:=23;
end if;
end if;    ----开锁失败三次的程序调用（如果开锁失败且次数达到了三次，则只允许执行第6，24，25周期程序，分别对应锁死状态检测，红蓝报警灯闪烁程序，“CLOSE”字样闪烁程序）

if(enable='0') then
period:=0;
end if;       ---如果等待界面锁定变量为0，则只允许循环执行此周期程序，直到专用按键或密码输入按键按下

if(period=0) then --第一个周期，检测专用按键和密码输入按键
if(spe_state=0 and keyinput_state=0) then

count3:=count3+1;
if(count3>400)then
count3:=0;
count4:=count4+1;
if(count4=1000)then
led<="0000000110000000";
end if;
if(count4=2000)then
led<="0000001001000000";
end if;
if(count4=3000)then
led<="0000010000100000";
end if;
if(count4=4000)then
led<="0000100000010000";
end if;
if(count4=5000)then
led<="0001000000001000";
end if;
if(count4=6000)then
led<="0010000000000100";
end if;
if(count4=7000)then
led<="0100000000000010";
end if;
if(count4=8000)then
led<="1000000000000001";
end if;
if(count4=9000)then
led<="0100000000000010";
end if;
if(count4=10000)then
led<="0010000000000100";
end if;
if(count4=11000)then
led<="0001000000001000";
end if;
if(count4=12000)then
led<="0000100000010000";
end if;
if(count4=13000)then
led<="0000010000100000";
end if;
if(count4>14000)then
led<="0000001001000000";
count4:=0;
end if;
end if;             ----粒子对撞显示程序

errcnt:=errcnt+1;
if(errcnt<1200000)then

count1:=count1+1;
if(count1>50)then
count1:=0;
count2:=count2+1;
if(count2=10)then
disp_place<="01111111";
disp_number<="0001011";
end if;
if(count2=20)then
disp_place<="10111111";
disp_number<="1000000";
end if;
if(count2=30)then
disp_place<="11011111";
disp_number<="1000111";
end if;
if(count2=40)then
disp_place<="11101111";
disp_number<="0100001";
end if;
if(count2=50)then
disp_place<="11111011";
disp_number<="1000000";
end if;
if(count2>60)then
disp_place<="11111101";
disp_number<="1001000";
count2:=0;
end if;
end if;

end if;
if(errcnt>1200000 and errcnt<2400000) then

disp_place<="11111111";
disp_number<="1111111";
end if;
if(errcnt>2400000) then
errcnt:=0;
end if;                         ---“hold on”闪烁程序

spe_period:=spe_period+1;
if(spe_period=1) then  ----防止每次重启程序记住上一次的状态
spe_temp:=spe;
keyinput_temp:=keyinput;
end if;
if(spe_period>20000) then 
spe_check:=spe xor spe_temp;--当前状态与20ms前的状态异或，返回值可表征按键是否按下
spe_temp:=spe;
if(spe_check='1') then    ---如果按键按下，给相应变量赋初值
spe_state:=1;
disp_number<="1111111";
disp_place<="11111111";
lose_wait:=0;
enable:='1';
input_temp:=input;  ---保证随意按键（数字按键）不会有影响
end if;           ---检测专用按键是否按下

keyinput_check:=keyinput xor keyinput_temp;
keyinput_temp:=keyinput;
if(keyinput_check='1') then
keyinput_state:=1;
lose_wait:=0;
enable:='1';
input_temp:=input;
end if;          ----检测密码输入按键是否按下

spe_period:=0;
end if;  


end if;

end if;

if(period=1) then   ---第2个周期，检测确认键是否按下，用于回归主菜单，密码设置等一系列操作
if(enable2='0') then
if(sure_state=0) then
sure_period:=sure_period+1;
if(sure_period=1) then
sure_temp:=sure;
end if;
if(sure_period>20000) then
sure_check:=sure xor sure_temp;
sure_temp:=sure;
if(sure_check='1') then
sure_state:=1;
lose_wait:=0;
end if;
sure_period:=0;
end if;
end if;
end if;
end if;   --检测确认键是否按下

if(period=2) then ---第3个周期，用于密码设置或密码输入给相应的变量记录输入的数字值
if(sure_state=1) then
if(spe_state=1) then
if(count>3) then---只有输入数字数等于4且按下确认键的情况下才会执行
reg1_temp:=reg1;
reg2_temp:=reg2;
reg3_temp:=reg3;
reg4_temp:=reg4;
reg1:="1111111";
reg2:="1111111";
reg3:="1111111";
reg4:="1111111";
disp_number<="1111111";
disp_place<="11111111";
count:=0;
sure_state:=0;
spe_state:=0;
enable:='0';
else
sure_state:=0;
end if;
end if;
end if;           --确认键按下，设置密码暂存,显示消隐，确认键弹开

if(sure_state=1) then
if(keyinput_state=1) then
if(count>3) then
reg1_temp2:=reg1;
reg2_temp2:=reg2;
reg3_temp2:=reg3;
reg4_temp2:=reg4;
reg1:="1111111";
reg2:="1111111";
reg3:="1111111";
reg4:="1111111";
disp_number<="1111111";
disp_place<="11111111";
count:=0;
sure_state:=0;
keyinput_state:=0;
enable2:='1';
else
sure_state:=0;
end if;
end if;
end if;         --确认键按下，输入密码暂存
end if;

if(period=3) then      ---第4个周期，进行密码比较，改变相应状态变量值，启动相应的状态程序

if(enable2='1') then 
if(reg1_temp=reg1_temp2 and reg2_temp=reg2_temp2 and reg3_temp=reg3_temp2 and reg4_temp=reg4_temp2) then
  led_enable:='1'; --开锁成功显示程序允许
  sure_lock:='1';--确认键检索锁开启
  enable2:='0';
else
lose_time:=lose_time+1;--开锁失败次数加1
lose_lock:='1'; --开锁失败程序允许
enable2:='0';--密码比较程序关闭
end if;
end if;

end if;

if( period=4) then    
if(led_enable='1') then
led<="1111111111111111";--LED灯全亮
end if;
end if;  --开锁成功程序

if( period=5) then     ---第6个周期，锁死状态专用按键检测程序
if(lose_time=3) then
lock:='1';
lose_lock:='0';
if(spe_state=0) then
spe_period:=spe_period+1;
if(spe_period=1) then
spe_temp:=spe;
end if;
if(spe_period>20000) then 

spe_check:=spe xor spe_temp;
spe_temp:=spe;
if(spe_check='1') then
spe_state:=1;
end if;   
spe_period:=0;
end if;


end if;

if(spe_state=1 ) then
lose_time:=0;
lock:='0';
spe_state:=0;
enable:='0';
reg1:="1111111";
reg2:="1111111";
reg3:="1111111";
reg4:="1111111";
disp_number<="1111111";
disp_place<="11111111";
red<='0';
blue<='0';
count:=0;                        ----变量状态复位
end if;
end if;


end if;  --开锁失败程序

if(period=6) then                 ---第7个周期，开锁成功确认键检测和等待返回程序
if(sure_lock='1') then

suc_wait:=suc_wait+1;
if(suc_wait<1330000) then
reg5:="1000000";
reg6:="0100100";
end if;
if(suc_wait>1330000 and suc_wait<2660000) then
reg5:="0010000";
reg6:="1111001";
end if;
if(suc_wait>2660000 and suc_wait<3990000) then
reg5:="0000000";
reg6:="1111001";
end if;
if(suc_wait>3990000 and suc_wait<5320000) then
reg5:="1111000";
reg6:="1111001";
end if;
if(suc_wait>5320000 and suc_wait<6650000) then
reg5:="0000010";
reg6:="1111001";
end if;
if(suc_wait>6650000 and suc_wait<7980000) then
reg5:="0010010";
reg6:="1111001";
end if;
if(suc_wait>7980000 and suc_wait<9310000) then
reg5:="0011001";
reg6:="1111001";
end if;
if(suc_wait>9310000 and suc_wait<10640000) then
reg5:="0110000";
reg6:="1111001";
end if;
if(suc_wait>10640000 and suc_wait<11970000) then
reg5:="0100100";
reg6:="1111001";
end if;
if(suc_wait>11970000 and suc_wait<13300000) then
reg5:="1111001";
reg6:="1111001";
end if;
if(suc_wait>13300000 and suc_wait<14630000) then
reg5:="1000000";
reg6:="1111001";
end if;
if(suc_wait>14630000 and suc_wait<15960000) then
reg5:="0010000";
reg6:="1000000";
end if;
if(suc_wait>15960000 and suc_wait<17290000) then
reg5:="0000000";
reg6:="1000000";
end if;
if(suc_wait>17290000 and suc_wait<18620000) then
reg5:="1111000";
reg6:="1000000";
end if;
if(suc_wait>18620000 and suc_wait<19950000) then
reg5:="0000010";
reg6:="1000000";
end if;
if(suc_wait>19950000 and suc_wait<21280000) then
reg5:="0010010";
reg6:="1000000";
end if;
if(suc_wait>21280000 and suc_wait<22610000) then
reg5:="0011001";
reg6:="1000000";
end if;
if(suc_wait>22610000 and suc_wait<23940000) then
reg5:="0110000";
reg6:="1000000";
end if;
if(suc_wait>23940000 and suc_wait<25270000) then
reg5:="0100100";
reg6:="1000000";
end if;
if(suc_wait>25270000 and suc_wait<26600000) then
reg5:="1111001";
reg6:="1000000";
end if;
if(suc_wait>26600000) then
reg5:="1000000";
reg6:="1000000";
end if;

if(suc_wait>26600000) then
open_return:='1';
suc_wait:=0;
end if;                                      ----倒计时状态枚举


if(sure_state=0) then
sure_period:=sure_period+1;
if(sure_period=1) then
sure_temp:=sure;
end if;
if(sure_period>20000) then
sure_check:=sure xor sure_temp;
sure_temp:=sure;
if(sure_check='1') then
sure_state:=1;
suc_wait:=0;
end if;
sure_period:=0;
end if;
end if;

if(sure_state=1 or open_return='1') then
sure_lock:='0';
open_return:='0';
lose_time:=0;
sure_state:=0;
enable:='0';
reg1:="1111111";
reg2:="1111111";
reg3:="1111111";
reg4:="1111111";
disp_number<="1111111";
disp_place<="11111111";
led_enable:='0';
led<="0000000000000000";
count:=0;
end if;

end if;
end if;                      --确认键检测
if(period=7) then          ----第8个周期，数字按键检测程序
--count3:=count3+1;
--if(count3=100)then
--count3:=0;
input_next:="00000000000";   --保证状态的锁存
speriod:=speriod+1;
if(speriod=1) then
input_temp:=input;
end if;
if(speriod>10000) then         --延时20ms消抖
input_next:=input_temp xor input;
input_temp:=input;
speriod:=0;
end if;
if(count>4) then
count:=4;
end if;

end if;
if(period=8) then             ----第9-19周期，数字按键按下执行程序
if(input_next(9)='1') then
lose_wait:=0;                ----等待返回变量置0
if(count=0) then
reg1:="0010000";
end if;
if(count=1) then
reg2:=reg1;
reg1:="0010000";
end if;
if(count=2) then
reg3:=reg2;
reg2:=reg1;
reg1:="0010000";
end if;
if(count=3) then
reg4:=reg3;
reg3:=reg2;
reg2:=reg1;
reg1:="0010000";
end if;
count:=count+1;               ---根据已输入密码数给相应的寄存器移动赋值
end if;
end if;

if(period=9) then
if(input_next(8)='1') then
lose_wait:=0;
if(count=0) then
reg1:="0000000";
end if;
if(count=1) then
reg2:=reg1;
reg1:="0000000";
end if;
if(count=2) then
reg3:=reg2;
reg2:=reg1;
reg1:="0000000";
end if;
if(count=3) then
reg4:=reg3;
reg3:=reg2;
reg2:=reg1;
reg1:="0000000";
end if;
count:=count+1;
end if;
end if;

if(period=10) then
if(input_next(7)='1') then
lose_wait:=0;
if(count=0) then
reg1:="1111000";
end if;
if(count=1) then
reg2:=reg1;
reg1:="1111000";
end if;
if(count=2) then
reg3:=reg2;
reg2:=reg1;
reg1:="1111000";
end if;
if(count=3) then
reg4:=reg3;
reg3:=reg2;
reg2:=reg1;
reg1:="1111000";
end if;
count:=count+1;
end if;
end if;

if(period=11) then
if(input_next(6)='1') then
lose_wait:=0;
if(count=0) then
reg1:="0000010";
end if;
if(count=1) then
reg2:=reg1;
reg1:="0000010";
end if;
if(count=2) then
reg3:=reg2;
reg2:=reg1;
reg1:="0000010";
end if;
if(count=3) then
reg4:=reg3;
reg3:=reg2;
reg2:=reg1;
reg1:="0000010";
end if;
count:=count+1;
end if;
end if;

if(period=12) then
if(input_next(5)='1') then
lose_wait:=0;
if(count=0) then
reg1:="0010010";
end if;
if(count=1) then
reg2:=reg1;
reg1:="0010010";
end if;
if(count=2) then
reg3:=reg2;
reg2:=reg1;
reg1:="0010010";
end if;
if(count=3) then
reg4:=reg3;
reg3:=reg2;
reg2:=reg1;
reg1:="0010010";
end if;
count:=count+1;
end if;
end if;

if(period=13) then
if(input_next(4)='1') then
lose_wait:=0;
if(count=0) then
reg1:="0011001";
end if;
if(count=1) then
reg2:=reg1;
reg1:="0011001";
end if;
if(count=2) then
reg3:=reg2;
reg2:=reg1;
reg1:="0011001";
end if;
if(count=3) then
reg4:=reg3;
reg3:=reg2;
reg2:=reg1;
reg1:="0011001";
end if;
count:=count+1;
end if;
end if;

if(period=14) then
if(input_next(3)='1') then
lose_wait:=0;
if(count=0) then
reg1:="0110000";
end if;
if(count=1) then
reg2:=reg1;
reg1:="0110000";
end if;
if(count=2) then
reg3:=reg2;
reg2:=reg1;
reg1:="0110000";
end if;
if(count=3) then
reg4:=reg3;
reg3:=reg2;
reg2:=reg1;
reg1:="0110000";
end if;
count:=count+1;
end if;
end if;

if(period=15) then
if(input_next(2)='1') then
lose_wait:=0;
if(count=0) then
reg1:="0100100";
end if;
if(count=1) then
reg2:=reg1;
reg1:="0100100";
end if;
if(count=2) then
reg3:=reg2;
reg2:=reg1;
reg1:="0100100";
end if;
if(count=3) then
reg4:=reg3;
reg3:=reg2;
reg2:=reg1;
reg1:="0100100";
end if;
count:=count+1;
end if;
end if;

if(period=16) then
if(input_next(1)='1') then
lose_wait:=0;
if(count=0) then
reg1:="1111001";
end if;
if(count=1) then
reg2:=reg1;
reg1:="1111001";
end if;
if(count=2) then
reg3:=reg2;
reg2:=reg1;
reg1:="1111001";
end if;
if(count=3) then
reg4:=reg3;
reg3:=reg2;
reg2:=reg1;
reg1:="1111001";
end if;
count:=count+1;
end if;
end if;

if(period=17) then
if(input_next(0)='1') then
lose_wait:=0;
if(count=0) then
reg1:="1000000";
end if;
if(count=1) then
reg2:=reg1;
reg1:="1000000";
end if;
if(count=2) then
reg3:=reg2;
reg2:=reg1;
reg1:="1000000";
end if;
if(count=3) then
reg4:=reg3;
reg3:=reg2;
reg2:=reg1;
reg1:="1000000";
end if;
count:=count+1;
end if;
end if;

if(period=18) then
if(input_next(10)='1') then
lose_wait:=0;
if(count=1) then
reg1:="1111111";
end if;
if(count=2) then
reg1:=reg2;
reg2:="1111111";
end if;
if(count=3) then
reg1:=reg2;
reg2:=reg3;
reg3:="1111111";
end if;
if(count=4) then
reg1:=reg2;
reg2:=reg3;
reg3:=reg4;
reg4:="1111111";
end if;
if(count/=0) then
count:=count-1;
end if;
end if;
end if;


if(period=19) then         ---第20个周期，动态扫描显示数字程序

count1:=count1+1;
if(count1>25)then
count1:=0;
count2:=count2+1;
if(count2=10)then
disp_place<="11110111";
disp_number<=reg4;
end if;
if(count2=20)then
disp_place<="11111011";
disp_number<=reg3;
end if;
if(count2=30)then
disp_place<="11111101";
disp_number<=reg2;
end if;
if(count2>40)then
disp_place<="11111110";
disp_number<=reg1;
count2:=0;
end if;
end if;
end if;

if(period=20 and sure_lock='1') then    ---第21个周期，开锁成功显示“OPEN”和倒计时程序
errcnt:=errcnt+1;
if(errcnt<600000)then

count1:=count1+1;
if(count1=25)then
count1:=0;
count2:=count2+1;
if(count2=10)then
disp_place<="11110111";
disp_number<="1000000";
end if;
if(count2=20)then
disp_place<="11111011";
disp_number<="0001100";
end if;
if(count2=30)then
disp_place<="11111101";
disp_number<="0000110";
end if;
if(count2=40)then
disp_place<="11111110";
disp_number<="1001000";
end if;
if(count2=50) then
disp_place<="10111111";
disp_number<=reg5;
end if;
if(count2>60) then
disp_place<="01111111";
disp_number<=reg6;
count2:=0;
end if;

end if;
end if;
if(errcnt>600000 and errcnt<1200000) then

count1:=count1+1;
if(count1=25)then
count1:=0;
count2:=count2+1;
if(count2=10)then
disp_place<="11110111";
disp_number<="1111111";
end if;
if(count2=20)then
disp_place<="11111011";
disp_number<="1111111";
end if;
if(count2=30)then
disp_place<="11111101";
disp_number<="1111111";
end if;
if(count2=40)then
disp_place<="11111110";
disp_number<="1111111";
end if;
if(count2=50) then
disp_place<="10111111";
disp_number<=reg5;
end if;
if(count2>60) then
disp_place<="01111111";
disp_number<=reg6;
count2:=0;
end if;

end if;
end if;
if(errcnt>1200000) then
errcnt:=0;
end if;
end if;

if(period=21) then            ----第22个周期，开锁失败确认键检测程序
if(lose_lock='1') then

if(sure_state=0) then
sure_period:=sure_period+1;
if(sure_period=1) then
sure_temp:=sure;
end if;
if(sure_period>20000) then
sure_check:=sure xor sure_temp;
sure_temp:=sure;
if(sure_check='1') then
sure_state:=1;
end if;
sure_period:=0;
end if;
end if;

if(sure_state=1 or lose_return='1') then
lose_return:='0';
lose_wait:=0;
if(sure_state=1) then
lose_wait_time:=0;
end if;
lose_wait_count:=0;
lose_wait_count_lock:='0';
lose_lock:='0';
sure_state:=0;
enable:='0';
reg1:="1111111";
reg2:="1111111";
reg3:="1111111";
reg4:="1111111";
disp_number<="1111111";
disp_place<="11111111";
count:=0;
end if;                        ------开锁失败后程序由此处返回主菜单

end if;
end if;

if(period=22 and lose_lock='1') then    ----第23个周期，开锁失败显示“err”和倒计时程序
led<="0000000000000000";
errcnt:=errcnt+1;
if(errcnt<600000)then

count1:=count1+1;
if(count1>25)then
count1:=0;
count2:=count2+1;
if(count2=10)then
disp_place<="11111011";
disp_number<="0000110";
end if;
if(count2=20)then
disp_place<="11111101";
disp_number<="0001000";
end if;
if(count2=30)then
disp_place<="11111110";
disp_number<="0001000";
end if;
if(count2=40)then
if(lose_time=1)then
disp_place<="11110111";
disp_number<="1111001";
end if;
if(lose_time=2) then
disp_place<="11110111";
disp_number<="0100100";
end if;
end if;
if(count2=50) then
disp_place<="10111111";
disp_number<=reg5;
end if;
if(count2>60) then
count2:=0;
disp_place<="01111111";
disp_number<=reg6;
end if;
end if;

end if;
if(errcnt>600000 and errcnt<1200000) then

count1:=count1+1;
if(count1>25)then
count1:=0;
count2:=count2+1;
if(count2=10)then
disp_place<="11111011";
disp_number<="1111111";
end if;
if(count2=20)then
disp_place<="11111101";
disp_number<="1111111";
end if;
if(count2=30)then
disp_place<="11111110";
disp_number<="1111111";
end if;
if(count2=40)then
if(lose_time=1)then
disp_place<="11110111";
disp_number<="1111111";
end if;
if(lose_time=2) then
disp_place<="11110111";
disp_number<="1111111";
end if;
end if;
if(count2=50)then
disp_place<="10111111";
disp_number<=reg5;
end if;
if(count2>60) then
disp_place<="01111111";
disp_number<=reg6;
count2:=0;
end if;

end if;
end if;
if(errcnt>1200000) then
errcnt:=0;
end if;
end if;

if(period=23 and lock='1') then     ----第24个周期，锁死状态红蓝报警程序

ledcnt:=ledcnt+1;
if(ledcnt<150000) then
red<='1';
blue<='0';
end if;

if(ledcnt>150000 and ledcnt<300000) then
red<='0';
blue<='0';
end if;

if(ledcnt>300000 and ledcnt<450000) then
red<='1';
blue<='0';
end if;

if(ledcnt>450000 and ledcnt<600000) then
red<='0';
blue<='0';
end if;

if(ledcnt>600000 and ledcnt<750000) then
red<='0';
blue<='1';
end if;

if(ledcnt>750000 and ledcnt<900000) then
red<='0';
blue<='0';
end if;

if(ledcnt>900000 and ledcnt<1050000) then
red<='0';
blue<='1';
end if;

if(ledcnt>1050000 and ledcnt<1200000) then
red<='0';
blue<='0';
end if;
if(ledcnt>1200000) then
ledcnt:=0;
end if;

end if;

if(period=24 and lock='1') then     ---第25个周期，锁死状态显示"CLOCK"程序

led<="0000000000000000";
errcnt:=errcnt+1;
if(errcnt<600000)then

count1:=count1+1;
if(count1=25)then
count1:=0;
count2:=count2+1;
if(count2=10)then
disp_place<="11101111";
disp_number<="1000110";
end if;
if(count2=20)then
disp_place<="11110111";
disp_number<="1000111";
end if;
if(count2=30)then
disp_place<="11111011";
disp_number<="1000000";
end if;
if(count2=40)then
disp_place<="11111101";
disp_number<="0010010";
end if;
if(count2>50)then
disp_place<="11111110";
disp_number<="0000110";
count2:=0;
end if;
end if;
end if;

if(errcnt>600000 and errcnt<1200000) then

disp_place<="11111111";
disp_number<="1111111";
end if;

if(errcnt>1200000) then
errcnt:=0;
end if;
end if;

if(period=25) then             -----第26个周期，开锁失败等待返回程序
if(sure_lock='0' and lock='0' ) then
lose_wait:=lose_wait+1;
if(lose_lock='1') then
if(lose_wait_count_lock='0') then
lose_wait_count:=0;
lose_wait_count_lock:='1';
end if;
lose_wait_count:=lose_wait_count+1;
end if;
if(lose_wait_count<1000000) then
reg5:="1000000";
reg6:="1111001";
end if;
if(lose_wait_count>1000000 and lose_wait_count<2000000) then
reg5:="0010000";
reg6:="1000000";
end if;
if(lose_wait_count>2000000 and lose_wait_count<3000000) then
reg5:="0000000";
reg6:="1000000";
end if;
if(lose_wait_count>3000000 and lose_wait_count<4000000) then
reg5:="1111000";
reg6:="1000000";
end if;
if(lose_wait_count>4000000 and lose_wait_count<5000000) then
reg5:="0000010";
reg6:="1000000";
end if;
if(lose_wait_count>5000000 and lose_wait_count<6000000) then
reg5:="0010010";
reg6:="1000000";
end if;
if(lose_wait_count>6000000 and lose_wait_count<7000000) then
reg5:="0011001";
reg6:="1000000";
end if;
if(lose_wait_count>7000000 and lose_wait_count<8000000) then
reg5:="0110000";
reg6:="1000000";
end if;
if(lose_wait_count>8000000 and lose_wait_count<9000000) then
reg5:="0100100";
reg6:="1000000";
end if;
if(lose_wait_count>9000000 and lose_wait_count<10000000) then
reg5:="1111001";
reg6:="1000000";
end if;
if(lose_wait_count>10000000) then
reg5:="1000000";
reg6:="1000000";
end if;
                                     -----枚举法列出倒计时状态
if(lose_wait>2000000) then
if(lose_lock='1') then
lose_wait_time:=lose_wait_time+1;
if(lose_wait_time>4) then
lose_return:='1';
lose_wait_time:=0;
lose_wait_count:=0;
end if;
lose_wait:=0;
else
enable:='0';
lose_wait:=0;
lose_wait_count:=0;
sure_state:=0;
keyinput_state:=0;
spe_state:=0;
reg1:="1111111";
reg2:="1111111";
reg3:="1111111";
reg4:="1111111";
disp_number<="1111111";
disp_place<="11111111";
count:=0;
end if;
end if;
end if;
end if;              ------时间到，自动返回


if(period=26) then          -----第27个周期，LED流水灯动画程序

count3:=count3+1;
if(count3>20)then
count3:=0;
count4:=count4+1;
if(count4=1000)then
led<="0000000000000001";
end if;
if(count4=2000)then
led<="0000000000000010";
end if;
if(count4=3000)then
led<="0000000000000100";
end if;
if(count4=4000)then
led<="0000000000001000";
end if;
if(count4=5000)then
led<="0000000000010000";
end if;
if(count4=6000)then
led<="0000000000100000";
end if;
if(count4=7000)then
led<="0000000001000000";
end if;
if(count4=8000)then
led<="0000000010000000";
end if;
if(count4=9000)then
led<="0000000100000000";
end if;
if(count4=10000)then
led<="0000001000000000";
end if;
if(count4=11000)then
led<="0000010000000000";
end if;
if(count4=12000)then
led<="0000100000000000";
end if;
if(count4=13000)then
led<="0001000000000000";
end if;
if(count4=14000)then
led<="0010000000000000";
end if;
if(count4=15000)then
led<="0100000000000000";
end if;
if(count4>16000)then
led<="1000000000000000";
count4:=0;
end if;
end if;



end if;


end if;
end if;
end process;
end Behavioral;
