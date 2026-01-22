---------------------------------------------------------------------------------
--                          Asteroids - EBAZ4205
--                            Code from MikeJ
--
--                          Modified for EBAZ4205 
--                            by pinballwiz.org 
--                               30/11/2025
---------------------------------------------------------------------------------
-- Keyboard inputs :
--   5            : Add coin
--   2            : Start 2 players
--   1            : Start 1 player
--   LCtrl        : Fire
--   UP arrow     : Thrust
--   DOWN arrow   : Hyperspace
--   RIGHT arrow  : Rotate Right
--   LEFT arrow   : Rotate Left
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;
---------------------------------------------------------------------------------
entity asteroids_ebaz4205 is
port(
	clock_50    : in std_logic;
   	I_RESET     : in std_logic;
	O_VIDEO_R	: out std_logic_vector(2 downto 0); 
	O_VIDEO_G	: out std_logic_vector(2 downto 0);
	O_VIDEO_B	: out std_logic_vector(1 downto 0);
	O_HSYNC	    : out std_logic;
	O_VSYNC	    : out std_logic;
	O_AUDIO_L 	: out std_logic;
	O_AUDIO_R 	: out std_logic;
	greenLED 	: out std_logic;
	redLED 	    : out std_logic;
    ps2_clk     : in std_logic;
	ps2_dat     : inout std_logic;
	led         : out std_logic_vector(7 downto 0)
 );
end asteroids_ebaz4205;
------------------------------------------------------------------------------
architecture struct of asteroids_ebaz4205 is

 signal clock_25  : std_logic;
 signal clock_24  : std_logic;
 signal clock_12  : std_logic;
 signal clock_9   : std_logic;
 signal clock_6   : std_logic;
 --
 signal reset      : std_logic;
 --
 signal kbd_intr        : std_logic;
 signal kbd_scancode    : std_logic_vector(7 downto 0);
 signal joy_BBBBFRLDU   : std_logic_vector(8 downto 0);
 --
 constant CLOCK_FREQ    : integer := 27E6;
 signal counter_clk     : std_logic_vector(25 downto 0);
 signal clock_4hz       : std_logic;
 signal AD              : std_logic_vector(15 downto 0);
------------------------------------------------------------------------- 
 component clk_wiz_37
port(
  clk_out1          : out    std_logic;
  clk_in1           : in     std_logic
 );
end component;
--------------------------------------------------------------------------
begin

 reset <= I_RESET; -- reset active low
---------------------------------------------------------------------------
-- keyboard clock

clock1 : clk_wiz_37
port map (
  clk_in1   => clock_25,
  clk_out1  => clock_9
);
---------------------------------------------------------------------------
-- clocks divide

process (Clock_50)
begin
 if rising_edge(Clock_50) then
	clock_25  <= not clock_25;
 end if;
end process;
--
process (Clock_25)
begin
 if rising_edge(Clock_25) then
	clock_12  <= not clock_12;
 end if;
end process;
--
process (Clock_12)
begin
 if rising_edge(Clock_12) then
	clock_6  <= not clock_6;
 end if;
end process;
--------------------------------------------------------------------------
-- Main

asteroids : entity work.asteroids_main
  port map (
 clk_25         => clock_25,
 clk_6          => clock_6,
 RESET_L        => reset,
 VIDEO_R_OUT    => O_VIDEO_R,
 VIDEO_G_OUT    => O_VIDEO_G,
 VIDEO_B_OUT    => O_VIDEO_B,
 HSYNC_OUT      => O_HSYNC,
 VSYNC_OUT      => O_VSYNC,
 AUDIO_L_OUT    => O_AUDIO_L,
 AUDIO_R_OUT    => O_AUDIO_R,
 greenled	    => greenLED,
 redled	        => redLED,
 SW_LEFT        => joy_BBBBFRLDU(2),
 SW_RIGHT       => joy_BBBBFRLDU(3),
 SW_UP          => joy_BBBBFRLDU(0),
 SW_DOWN        => joy_BBBBFRLDU(1),
 SW_FIRE        => joy_BBBBFRLDU(4),
 SW_BOMB        => joy_BBBBFRLDU(8),
 SW_COIN        => joy_BBBBFRLDU(7),
 P1_START       => joy_BBBBFRLDU(5),
 P2_START       => joy_BBBBFRLDU(6),
 AD             => AD
   );
------------------------------------------------------------------------------
-- get scancode from keyboard

keyboard : entity work.io_ps2_keyboard
port map (
  clk       => clock_9,
  kbd_clk   => ps2_clk,
  kbd_dat   => ps2_dat,
  interrupt => kbd_intr,
  scancode  => kbd_scancode
);
------------------------------------------------------------------------------
-- translate scancode to joystick

joystick : entity work.kbd_joystick
port map (
  clk           => clock_9,
  kbdint        => kbd_intr,
  kbdscancode   => std_logic_vector(kbd_scancode), 
  joy_BBBBFRLDU => joy_BBBBFRLDU 
);
------------------------------------------------------------------------------
-- debug

process(reset, clock_25)
begin
  if reset = '0' then -- reset active low
   clock_4hz <= '0';
   counter_clk <= (others => '0');
  else
    if rising_edge(clock_25) then
      if counter_clk = CLOCK_FREQ/8 then
        counter_clk <= (others => '0');
        clock_4hz <= not clock_4hz;
        led(7 downto 0) <= not AD(14 downto 7);
      else
        counter_clk <= counter_clk + 1;
      end if;
    end if;
  end if;
end process;
------------------------------------------------------------------------
end struct;