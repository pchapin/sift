---------------------------------------------------------------------------
-- FILE          : context_proccessing.adb
-- LAST REVISION : 2009-01-07
-- SUBJECT       : Implementation of the ASIS context processing package.
-- PROGRAMMER    : (C) Copyright 2009 by Peter C. Chapin
--
-- This code is based on the ASIS-for-GNAT template.
--
-- Please send comments or bug reports to
--
--      Peter C. Chapin
--      Computer Information Systems Department
--      Vermont Technical College
--      Randolph Center, VT 05061
---------------------------------------------------------------------------

with Ada.Wide_Text_IO;
with Ada.Characters.Handling;
with Ada.Exceptions;

with Asis.Compilation_Units;
with Asis.Exceptions;
with Asis.Errors;
with Asis.Implementation;

with Unit_Processing;

package body Context_Processing is

   -----------------------------
   -- Get_Unit_From_File_Name --
   -----------------------------

   function Get_Unit_From_File_Name
     (Ada_File_Name : String; The_Context : Asis.Context) return Asis.Compilation_Unit is
   begin
      --  To be completed....
      return Asis.Nil_Compilation_Unit;
   end Get_Unit_From_File_Name;

   ---------------------
   -- Process_Context --
   ---------------------

   procedure Process_Context
     (The_Context : Asis.Context; Trace : Boolean := False) is
      Units : Asis.Compilation_Unit_List :=
         Asis.Compilation_Units.Compilation_Units(The_Context);

      Next_Unit        : Asis.Compilation_Unit := Asis.Nil_Compilation_Unit;
      Next_Unit_Origin : Asis.Unit_Origins     := Asis.Not_An_Origin;
      Next_Unit_Class  : Asis.Unit_Classes     := Asis.Not_A_Class;
   begin
      for J in Units'Range loop
         Next_Unit        := Units (J);
         Next_Unit_Class  := Asis.Compilation_Units.Unit_Class(Next_Unit);
         Next_Unit_Origin := Asis.Compilation_Units.Unit_Origin(Next_Unit);

         if Trace then
            Ada.Wide_Text_IO.Put("Processing Unit: ");
            Ada.Wide_Text_IO.Put(Asis.Compilation_Units.Unit_Full_Name (Next_Unit));

            case Next_Unit_Class is
               when Asis.A_Public_Declaration |
                    Asis.A_Private_Declaration =>

                  Ada.Wide_Text_IO.Put(" (spec)");

               when Asis.A_Separate_Body =>
                  Ada.Wide_Text_IO.Put(" (subunit)");

               when Asis.A_Public_Body |
                    Asis.A_Public_Declaration_And_Body |
                    Asis.A_Private_Body =>

                  Ada.Wide_Text_IO.Put(" (body)");

               when others =>
                  Ada.Wide_Text_IO.Put(" (???)");
            end case;

            Ada.Wide_Text_IO.New_Line;
         end if;

         case Next_Unit_Origin is
            when Asis.An_Application_Unit =>
               Unit_Processing.Process_Unit(Next_Unit);
               if Trace then
                  Ada.Wide_Text_IO.Put("Done ...");
               end if;

            when Asis.A_Predefined_Unit =>
               if Trace then
                  Ada.Wide_Text_IO.Put("Skipped as a predefined unit");
               end if;

            when Asis.An_Implementation_Unit =>
               if Trace then
                  Ada.Wide_Text_IO.Put("Skipped as an implementation-defined unit");
               end if;

            when Asis.Not_An_Origin =>
               if Trace then
                  Ada.Wide_Text_IO.Put("Skipped as nonexistent unit");
               end if;
         end case;

         if Trace then
            Ada.Wide_Text_IO.New_Line;
            Ada.Wide_Text_IO.New_Line;
         end if;
      end loop;

   exception
         -- The exception handling in this procedure is somewhat redundant and may need some
         -- reconsidering when using this procedure as a template for a real ASIS tool

      when Ex : Asis.Exceptions.ASIS_Inappropriate_Context          |
                Asis.Exceptions.ASIS_Inappropriate_Container        |
                Asis.Exceptions.ASIS_Inappropriate_Compilation_Unit |
                Asis.Exceptions.ASIS_Inappropriate_Element          |
                Asis.Exceptions.ASIS_Inappropriate_Line             |
                Asis.Exceptions.ASIS_Inappropriate_Line_Number      |
                Asis.Exceptions.ASIS_Failed                         =>

         Ada.Wide_Text_IO.Put("Process_Context : ASIS exception (");
         Ada.Wide_Text_IO.Put(Ada.Characters.Handling.To_Wide_String(Ada.Exceptions.Exception_Name(Ex)));
         Ada.Wide_Text_IO.Put(") is raised when processing unit ");
         Ada.Wide_Text_IO.Put(Asis.Compilation_Units.Unit_Full_Name(Next_Unit));
         Ada.Wide_Text_IO.New_Line;

         Ada.Wide_Text_IO.Put("ASIS Error Status is ");
         Ada.Wide_Text_IO.Put(Asis.Errors.Error_Kinds'Wide_Image(Asis.Implementation.Status));
         Ada.Wide_Text_IO.New_Line;

         Ada.Wide_Text_IO.Put("ASIS Diagnosis is ");
         Ada.Wide_Text_IO.New_Line;

         Ada.Wide_Text_IO.Put(Asis.Implementation.Diagnosis);
         Ada.Wide_Text_IO.New_Line;

         Asis.Implementation.Set_Status;

      when Ex : others =>
         Ada.Wide_Text_IO.Put("Process_Context : ");
         Ada.Wide_Text_IO.Put(Ada.Characters.Handling.To_Wide_String(Ada.Exceptions.Exception_Name(Ex)));
         Ada.Wide_Text_IO.Put(" is raised (");
         Ada.Wide_Text_IO.Put(Ada.Characters.Handling.To_Wide_String(Ada.Exceptions.Exception_Information(Ex)));
         Ada.Wide_Text_IO.Put(")");
         Ada.Wide_Text_IO.New_Line;

         Ada.Wide_Text_IO.Put("when processing unit");
         Ada.Wide_Text_IO.Put(Asis.Compilation_Units.Unit_Full_Name(Next_Unit));
         Ada.Wide_Text_IO.New_Line;
   end Process_Context;

end Context_Processing;
