---------------------------------------------------------------------------
-- FILE          : subprogram_info.adb
-- LAST REVISION : 2009-01-07
-- SUBJECT       : Implementation of subprogram information package.
-- PROGRAMMER    : (C) Copyright 2009 by Peter C. Chapin
--
--
-- Please send comments or bug reports to
--
--      Peter C. Chapin
--      Computer Information Systems Department
--      Vermont Technical College
--      Randolph Center, VT 05061
--      Peter.Chapin@vtc.vsc.edu
---------------------------------------------------------------------------

with Ada.Containers.Hashed_Maps;
with Ada.Strings.Wide_Fixed; use Ada.Strings.Wide_Fixed;
with Ada.Wide_Text_IO;       use Ada.Wide_Text_IO;

package body Subprogram_Info is

   package Symbol_Names renames Global.Symbol_Names;
   use Symbol_Names;

   use type Ada.Containers.Hash_Type;

   function Name_Hash(N : Symbol_Name_Type) return Ada.Containers.Hash_Type is
   begin
      -- Do something stupid for now.
      if Length(N) = 0 then return 0; end if;
      return Wide_Character'Pos(Element(N, 1));
   end Name_Hash;

   package Subprogram_Maps is new Ada.Containers.Hashed_Maps
     (Element_Type    => Subprogram_Status,
      Key_Type        => Symbol_Name_Type,
      Hash            => Name_Hash,
      Equivalent_Keys => Symbol_Names."=",
      "="             => "=");
   use Subprogram_Maps;

   Name_Map : Map;

   procedure Read_Subprogram_Info(File_Name : in String) is

      -- This procedure truncates the line by modifying its count.
      procedure Remove_Comments(Line : Wide_String; Count : in out Natural) is
         Position : Natural := Index(Line(Line'First..Count), "#");
      begin
         if Position = 0 then return; end if;
         Count := Position - 1;
      end Remove_Comments;

      -- This function defines comments in the subprogram info file.
      function Blank(Line : Wide_String) return Boolean is

         function Is_Blank(C : Wide_Character) return Boolean is
         begin
            if C = ' ' then return True; end if;
            return False;
         end Is_Blank;

      begin -- Is_Comment
         for I in Line'First..Line'Last loop
            if not Is_Blank(Line(I)) then return False; end if;
         end loop;
         return True;
      end Blank;

      Input_File : File_Type;
      Line       : Wide_String(1..128);
      Count      : Natural;
      Split      : Natural;
      Position   : Natural;
      Status     : Subprogram_Status;

   begin -- Read_Subprogram_Info
      Open(Input_File, In_File, File_Name);
      while not End_Of_File(Input_File) loop
         Status := (Is_Output => False, Class => Invalid);
         Get_Line(Input_File, Line, Count);
         Remove_Comments(Line, Count);
         if not Blank(Line(1..Count)) then
            Split := Index(Line(1..Count), ":");
            if Split /= 0 then
               Position := Index(Line(Split..Count), "O");
               if Position /= 0 then
                  Status.Is_Output := True;
               end if;
               Position := Index(Line(Split..Count), "I");
               if Position /= 0 then
                  Status.Class := Input;
               end if;
               Position := Index(Line(Split..Count), "S");
               if Position /= 0 then
                  Status.Class := Sanitizing;
               end if;
               Position := Index(Line(Split..Count), "P");
               if Position /= 0 then
                  Status.Class := Passive;
               end if;
               Include(Name_Map, To_Bounded_Wide_String(Line(Line'First .. Split-1)), Status);
            end if;
         end if;
      end loop;
      Close(Input_File);

   exception
      -- If we can't open the file, don't worry about it.
      when Name_Error =>
         null;
   end Read_Subprogram_Info;


   function Is_Output_Subprogram(N : Symbol_Name_Type) return Boolean is
      Status : Subprogram_Status := Element(Name_Map, N);
   begin
      return Status.Is_Output;
   end Is_Output_Subprogram;


   function Get_Subprogram_Class(N : Symbol_Name_Type) return Subprogram_Class_Type is
      Current_Node : Cursor := Find(Name_Map, N);
      Status       : Subprogram_Status;
   begin
      -- This is where I defined the default classification for unknown things.
      if Current_Node = No_Element then
         Status.Class := Passive;
      else
         Status := Element(Current_Node);
      end if;
      return Status.Class;
   end Get_Subprogram_Class;

begin
   Read_Subprogram_Info("ATC-subinfo.txt");
end Subprogram_Info;
