-------------------------------------------------------------------------------
-- The Jeff Paradox - Terminal UI Package Body
-------------------------------------------------------------------------------

with Ada.Text_IO;              use Ada.Text_IO;
with Ada.Characters.Latin_1;   use Ada.Characters.Latin_1;
with Game_State;               use Game_State;

package body TUI is

   Screen_Width  : constant := 80;
   Screen_Height : constant := 24;

   ---------------------------------------------------------------------------
   -- Screen operations
   ---------------------------------------------------------------------------
   procedure Clear is
   begin
      Put (Clear_Screen & Cursor_Home);
   end Clear;

   procedure Move_To (Row, Col : Positive) is
      Row_Str : constant String := Positive'Image (Row);
      Col_Str : constant String := Positive'Image (Col);
   begin
      Put (ESC & "[" & Row_Str (2 .. Row_Str'Last) & ";" &
           Col_Str (2 .. Col_Str'Last) & "H");
   end Move_To;

   procedure Set_Color (FG : String; BG : String := "") is
   begin
      Put (FG);
      if BG /= "" then
         Put (BG);
      end if;
   end Set_Color;

   ---------------------------------------------------------------------------
   -- Drawing primitives
   ---------------------------------------------------------------------------
   procedure Draw_Box (X, Y, Width, Height : Positive; Title : String := "") is
      --  Unicode box drawing (fallback to ASCII if needed)
      H_Line : constant Character := '-';
      V_Line : constant Character := '|';
      Corner : constant Character := '+';
   begin
      --  Top border
      Move_To (Y, X);
      Put (Corner);
      for I in 2 .. Width - 1 loop
         Put (H_Line);
      end loop;
      Put (Corner);

      --  Title if provided
      if Title /= "" then
         Move_To (Y, X + 2);
         Put (" " & Title & " ");
      end if;

      --  Sides
      for Row in Y + 1 .. Y + Height - 2 loop
         Move_To (Row, X);
         Put (V_Line);
         Move_To (Row, X + Width - 1);
         Put (V_Line);
      end loop;

      --  Bottom border
      Move_To (Y + Height - 1, X);
      Put (Corner);
      for I in 2 .. Width - 1 loop
         Put (H_Line);
      end loop;
      Put (Corner);
   end Draw_Box;

   procedure Draw_Progress_Bar (X, Y, Width : Positive;
                                Value, Maximum : Natural;
                                Color : String := FG_Green) is
      Filled : Natural;
      Bar_Width : constant Positive := Width - 2;
   begin
      if Maximum > 0 then
         Filled := (Value * Bar_Width) / Maximum;
      else
         Filled := 0;
      end if;

      Move_To (Y, X);
      Put ("[");
      Set_Color (Color);
      for I in 1 .. Filled loop
         Put ("=");
      end loop;
      Set_Color (Reset);
      for I in Filled + 1 .. Bar_Width loop
         Put (" ");
      end loop;
      Put ("]");
   end Draw_Progress_Bar;

   procedure Draw_Centered (Y : Positive; Text : String) is
      X : constant Positive := (Screen_Width - Text'Length) / 2 + 1;
   begin
      Move_To (Y, X);
      Put (Text);
   end Draw_Centered;

   ---------------------------------------------------------------------------
   -- UI Components
   ---------------------------------------------------------------------------
   procedure Draw_Header is
   begin
      Set_Color (Bold & FG_Cyan);
      Draw_Centered (1, "THE JEFF PARADOX");
      Set_Color (Reset & Dim);
      Draw_Centered (2, "Infinite Conversation Experiment Control");
      Set_Color (Reset);
   end Draw_Header;

   procedure Draw_Status_Bar is
      Status : constant String := Get_Status_Line;
   begin
      Move_To (Screen_Height, 1);
      Set_Color (BG_Blue & FG_White);
      Put (Status);
      --  Pad to screen width
      for I in Status'Length + 1 .. Screen_Width loop
         Put (" ");
      end loop;
      Set_Color (Reset);
   end Draw_Status_Bar;

   procedure Draw_Menu is
   begin
      Draw_Box (2, 4, 36, 12, "Commands");

      Move_To (6, 4);
      Put (Bold & "L" & Reset & " - Load state from file");
      Move_To (7, 4);
      Put (Bold & "S" & Reset & " - Save state to file");
      Move_To (8, 4);
      Put (Bold & "R" & Reset & " - Reset state");
      Move_To (9, 4);
      Put (Bold & "N" & Reset & " - Advance to next turn");
      Move_To (10, 4);
      Put (Bold & "C" & Reset & " - Adjust chaos (+5)");
      Move_To (11, 4);
      Put (Bold & "E" & Reset & " - Adjust exposure (+5)");
      Move_To (12, 4);
      Put (Bold & "F" & Reset & " - Adjust faction (+10)");
      Move_To (13, 4);
      Put (Bold & "H" & Reset & " - Help / About");
      Move_To (14, 4);
      Put (Bold & "Q" & Reset & " - Quit");
   end Draw_Menu;

   procedure Draw_Game_State is
      S : State_Record renames Current_State;
      Chaos_Color : constant String :=
        (if Chaos_Warning then FG_Red else FG_Green);
      Exposure_Color : constant String :=
        (if Exposure_Warning then FG_Red else FG_Green);
      Faction_Color : constant String :=
        (if Faction_Critical then FG_Red else FG_Yellow);
   begin
      Draw_Box (40, 4, 38, 12, "Game State");

      Move_To (6, 42);
      Put ("Turn: " & Bold & Natural'Image (S.Turn_Number) & Reset);

      Move_To (7, 42);
      Put ("Node: " & Bold &
           (if S.Current_Node = Alpha then "ALPHA (Starbound)"
            else "BETA (Earthbound)") & Reset);

      Move_To (9, 42);
      Put ("Chaos:");
      Draw_Progress_Bar (50, 9, 25, S.Chaos, Max_Chaos, Chaos_Color);

      Move_To (10, 42);
      Put ("Exposure:");
      Draw_Progress_Bar (50, 10, 25, S.Exposure, Max_Exposure, Exposure_Color);

      Move_To (12, 42);
      Put ("Faction: ");
      Set_Color (Faction_Color);
      Put (Integer'Image (S.Faction_Slider));
      Set_Color (Reset);
      Put (" (");
      if S.Faction_Slider > 0 then
         Put ("Starbound");
      elsif S.Faction_Slider < 0 then
         Put ("Earthbound");
      else
         Put ("Neutral");
      end if;
      Put (")");

      --  Threshold warnings
      declare
         Event : constant Threshold_Event := Check_Thresholds;
      begin
         if Event /= None then
            Move_To (14, 42);
            Set_Color (Bold & FG_Red);
            case Event is
               when Chaos_High =>
                  Put ("WARNING: Chaos critical!");
               when Exposure_High =>
                  Put ("WARNING: Exposure critical!");
               when Faction_Starbound =>
                  Put ("WARNING: Faction extreme!");
               when Faction_Earthbound =>
                  Put ("WARNING: Faction extreme!");
               when None =>
                  null;
            end case;
            Set_Color (Reset);
         end if;
      end;
   end Draw_Game_State;

   procedure Draw_Help is
   begin
      Clear;
      Draw_Header;

      Draw_Box (5, 4, 70, 16, "About The Jeff Paradox");

      Move_To (6, 7);
      Put ("An experimental framework for infinite structured dialogue");
      Move_To (7, 7);
      Put ("between two LLM instances, exploring questions of diachronic");
      Move_To (8, 7);
      Put ("identity and the Kantian suprasensible substrate problem.");

      Move_To (10, 7);
      Set_Color (Bold);
      Put ("Philosophical Questions:");
      Set_Color (Reset);
      Move_To (11, 7);
      Put ("- Can an LLM maintain identity across conversation turns?");
      Move_To (12, 7);
      Put ("- What emerges from infinite structured dialogue?");
      Move_To (13, 7);
      Put ("- How do we measure convergence vs divergence?");

      Move_To (15, 7);
      Set_Color (Bold);
      Put ("Security: ");
      Set_Color (Reset);
      Put ("All GitHub Actions pinned to SHA for supply chain safety");

      Move_To (17, 7);
      Put ("Press any key to return...");

      declare
         Dummy : Character;
      begin
         Dummy := Get_Key;
      end;
   end Draw_Help;

   ---------------------------------------------------------------------------
   -- Input handling
   ---------------------------------------------------------------------------
   function Get_Key return Character is
      C : Character;
   begin
      Get_Immediate (C);
      return C;
   end Get_Key;

   function Confirm (Prompt : String) return Boolean is
      C : Character;
   begin
      Move_To (Screen_Height - 1, 1);
      Put (Prompt & " (y/n) ");
      C := Get_Key;
      return C = 'y' or C = 'Y';
   end Confirm;

   ---------------------------------------------------------------------------
   -- Main UI loop
   ---------------------------------------------------------------------------
   procedure Run is
      Running : Boolean := True;
      Key : Character;
   begin
      Put (Hide_Cursor);

      --  Try to load existing state
      Load_State;
      if not Current_State.Is_Loaded then
         Reset_State;
      end if;

      while Running loop
         Clear;
         Draw_Header;
         Draw_Menu;
         Draw_Game_State;
         Draw_Status_Bar;

         Key := Get_Key;

         case Key is
            when 'q' | 'Q' =>
               if Confirm ("Save before quitting?") then
                  Save_State;
               end if;
               Running := False;

            when 'l' | 'L' =>
               Load_State;

            when 's' | 'S' =>
               Save_State;

            when 'r' | 'R' =>
               if Confirm ("Reset all state?") then
                  Reset_State;
               end if;

            when 'n' | 'N' =>
               Advance_Turn;

            when 'c' | 'C' =>
               Increment_Chaos (5);

            when 'e' | 'E' =>
               Increment_Exposure (5);

            when 'f' | 'F' =>
               Adjust_Faction (10);

            when 'h' | 'H' =>
               Draw_Help;

            when others =>
               null;
         end case;
      end loop;

      Put (Show_Cursor);
      Clear;
   end Run;

end TUI;
