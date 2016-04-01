---------------------------------------------------------------------------
-- FILE          : sift.adb
-- LAST REVISION : 2009-01-07
-- SUBJECT       : Main procedure of the Secure Information Flow Tracer.
-- PROGRAMMER    : (C) Copyright 2009 by Peter C. Chapin
--
-- Please send comments or bug reports to
--
--      Peter C. Chapin
--      Computer Information Systems Department
--      Vermont Technical College
--      Randolph Center, VT 05061
--      Peter.Chapin@vtc.vsc.edu
---------------------------------------------------------------------------

with Ada.Exceptions;
with Ada.Wide_Text_IO;
with Ada.Characters.Handling;

with Asis;
with Asis.Ada_Environments;
with Asis.Implementation;
with Asis.Exceptions;
with Asis.Errors;

with Context_Processing;

procedure Sift is
   My_Context            : Asis.Context;

   My_Context_Name       : Wide_String := Asis.Ada_Environments.Default_Name;
   My_Context_Parameters : Wide_String := Asis.Ada_Environments.Default_Parameters;
   -- The default COntext parameters in case of the GNAT ASIS implementation are an empty
   -- string. This corresponds to the following Context definition: "-CA -FT -SA", and has the
   -- following meaning:
   --
   -- -CA - a Context is made up by all the tree files in the tree search path; the tree search
   --       path is not set, so the default is used, and the default is the current directory;
   -- -FT - only pre-created trees are used, no tree file can be created by ASIS;
   -- -SA - source files for all the Compilation Units belonging to the Context (except the
   --       predefined Standard package) are considered in the consistency check when opening
   --       the Context;

   Initialization_Parameters : Wide_String := "";
   Finalization_Parameters   : Wide_String := "";

begin
   Asis.Implementation.Initialize(Initialization_Parameters);
   Asis.Ada_Environments.Associate
     (The_Context => My_Context,
      Name        => My_Context_Name,
      Parameters  => My_Context_Parameters);

   Asis.Ada_Environments.Open(My_Context);
   Context_Processing.Process_Context(The_Context => My_Context, Trace => False);
   Asis.Ada_Environments.Close(My_Context);
   Asis.Ada_Environments.Dissociate(My_Context);
   Asis.Implementation.Finalize(Finalization_Parameters);

exception
      -- The exception handling in this driver is somewhat redundant and may need some
      -- reconsidering when using this driver in real ASIS tools

   when Ex : Asis.Exceptions.ASIS_Inappropriate_Context          |
             Asis.Exceptions.ASIS_Inappropriate_Container        |
             Asis.Exceptions.ASIS_Inappropriate_Compilation_Unit |
             Asis.Exceptions.ASIS_Inappropriate_Element          |
             Asis.Exceptions.ASIS_Inappropriate_Line             |
             Asis.Exceptions.ASIS_Inappropriate_Line_Number      |
             Asis.Exceptions.ASIS_Failed                         =>

      Ada.Wide_Text_IO.Put("ASIS exception (");
      Ada.Wide_Text_IO.Put(Ada.Characters.Handling.To_Wide_String(Ada.Exceptions.Exception_Name(Ex)));
      Ada.Wide_Text_IO.Put(") is raised");
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
      Ada.Wide_Text_IO.Put(Ada.Characters.Handling.To_Wide_String(Ada.Exceptions.Exception_Name(Ex)));
      Ada.Wide_Text_IO.Put(" is raised (");
      Ada.Wide_Text_IO.Put(Ada.Characters.Handling.To_Wide_String(Ada.Exceptions.Exception_Information(Ex)));
      Ada.Wide_Text_IO.Put(")");
      Ada.Wide_Text_IO.New_Line;

end Sift;
