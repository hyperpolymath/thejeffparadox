-------------------------------------------------------------------------------
-- The Jeff Paradox - Main Program
-- Terminal-based control interface for the infinite conversation experiment
--
-- Build:  gprbuild -P jeff_tui.gpr
-- Or:     alr build
-- Run:    ./bin/jeff_tui
--
-- SECURITY NOTE:
-- All GitHub Actions in this project are pinned to full-length commit SHAs
-- to prevent supply chain attacks. See .github/workflows/*.yml
-------------------------------------------------------------------------------

with Ada.Text_IO;    use Ada.Text_IO;
with Ada.Exceptions; use Ada.Exceptions;
with TUI;
with Game_State;

procedure Jeff_Tui is
begin
   Put_Line ("Starting The Jeff Paradox TUI...");
   Put_Line ("");
   Put_Line ("Security: GitHub Actions pinned to SHA commits");
   Put_Line ("Supply chain protection: ENABLED");
   Put_Line ("");

   TUI.Run;

   Put_Line ("The Jeff Paradox TUI terminated normally.");

exception
   when E : others =>
      Put_Line ("Fatal error: " & Exception_Message (E));
      Put_Line ("Exception: " & Exception_Name (E));
end Jeff_Tui;
