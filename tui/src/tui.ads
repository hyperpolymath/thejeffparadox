-------------------------------------------------------------------------------
-- The Jeff Paradox - Terminal UI Package Specification
-- ANSI-based terminal interface for experiment control
-------------------------------------------------------------------------------

package TUI is

   --  ANSI escape codes for terminal control
   ESC : constant Character := Character'Val (27);

   --  Colors
   Reset      : constant String := ESC & "[0m";
   Bold       : constant String := ESC & "[1m";
   Dim        : constant String := ESC & "[2m";

   --  Foreground colors
   FG_Black   : constant String := ESC & "[30m";
   FG_Red     : constant String := ESC & "[31m";
   FG_Green   : constant String := ESC & "[32m";
   FG_Yellow  : constant String := ESC & "[33m";
   FG_Blue    : constant String := ESC & "[34m";
   FG_Magenta : constant String := ESC & "[35m";
   FG_Cyan    : constant String := ESC & "[36m";
   FG_White   : constant String := ESC & "[37m";

   --  Background colors
   BG_Black   : constant String := ESC & "[40m";
   BG_Red     : constant String := ESC & "[41m";
   BG_Green   : constant String := ESC & "[42m";
   BG_Yellow  : constant String := ESC & "[43m";
   BG_Blue    : constant String := ESC & "[44m";

   --  Cursor control
   Clear_Screen   : constant String := ESC & "[2J";
   Cursor_Home    : constant String := ESC & "[H";
   Hide_Cursor    : constant String := ESC & "[?25l";
   Show_Cursor    : constant String := ESC & "[?25h";

   --  Screen operations
   procedure Clear;
   procedure Move_To (Row, Col : Positive);
   procedure Set_Color (FG : String; BG : String := "");

   --  Drawing primitives
   procedure Draw_Box (X, Y, Width, Height : Positive; Title : String := "");
   procedure Draw_Progress_Bar (X, Y, Width : Positive;
                                Value, Maximum : Natural;
                                Color : String := FG_Green);
   procedure Draw_Centered (Y : Positive; Text : String);

   --  UI Components
   procedure Draw_Header;
   procedure Draw_Status_Bar;
   procedure Draw_Menu;
   procedure Draw_Game_State;
   procedure Draw_Help;

   --  Input handling
   function Get_Key return Character;
   function Confirm (Prompt : String) return Boolean;

   --  Main UI loop
   procedure Run;

end TUI;
