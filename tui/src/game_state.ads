-------------------------------------------------------------------------------
-- The Jeff Paradox - Game State Package Specification
-- Manages the persistent game state for the infinite conversation experiment
-------------------------------------------------------------------------------

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package Game_State is

   --  Game state bounds
   Max_Chaos    : constant := 100;
   Max_Exposure : constant := 100;
   Min_Faction  : constant := -100;
   Max_Faction  : constant := 100;

   --  Threshold triggers
   Chaos_Warning_Threshold    : constant := 80;
   Exposure_Warning_Threshold : constant := 80;
   Faction_Critical_Threshold : constant := 90;

   --  Node identifiers
   type Node_Type is (Alpha, Beta);

   --  Core game state record
   type State_Record is record
      Turn_Number    : Natural := 0;
      Chaos          : Natural := 0;
      Exposure       : Natural := 0;
      Faction_Slider : Integer := 0;
      Current_Node   : Node_Type := Alpha;
      Is_Loaded      : Boolean := False;
   end record;

   --  Global game state (loaded from YAML)
   Current_State : State_Record;

   --  State file path
   State_File_Path : Unbounded_String :=
     To_Unbounded_String ("../orchestrator/data/game_state.yml");

   --  Operations
   procedure Load_State (Path : String := To_String (State_File_Path));
   procedure Save_State (Path : String := To_String (State_File_Path));
   procedure Reset_State;

   --  Modifiers
   procedure Increment_Chaos (Amount : Natural := 1);
   procedure Increment_Exposure (Amount : Natural := 1);
   procedure Adjust_Faction (Delta : Integer);
   procedure Switch_Node;
   procedure Advance_Turn;

   --  Queries
   function Chaos_Warning return Boolean;
   function Exposure_Warning return Boolean;
   function Faction_Critical return Boolean;
   function Get_Status_Line return String;

   --  Threshold events
   type Threshold_Event is (None, Chaos_High, Exposure_High,
                            Faction_Starbound, Faction_Earthbound);
   function Check_Thresholds return Threshold_Event;

end Game_State;
