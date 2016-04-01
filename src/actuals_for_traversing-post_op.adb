---------------------------------------------------------------------------
-- FILE          : actuals_for_traversing-post_op.adb
-- LAST REVISION : 2009-01-07
-- SUBJECT       : Implementation of the post-traversal procedure.
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
--      Peter.Chapin@vtc.vsc.edu
---------------------------------------------------------------------------

with Ada.Wide_Text_IO;        use Ada.Wide_Text_IO;
with Ada.Characters.Handling; use Ada.Characters.Handling;
with Ada.Exceptions;          use Ada.Exceptions;

with Asis.Elements;           use Asis.Elements;
with Asis.Exceptions;         use Asis.Exceptions;
with Asis.Errors;             use Asis.Errors;
with Asis.Implementation;     use Asis.Implementation;

with Sift_Debug;              use Sift_Debug;

separate(Actuals_For_Traversing)

procedure Post_Op
  (E       :        Element;
   Control : in out Traverse_Control;
   State   : in out Traversal_State)
is
begin
   case Element_Kind(E) is
      when A_Statement =>
         case Statement_Kind(E) is
            when An_If_Statement =>
               Internal_Error("Inside Post_Op: end-of-if");
            when A_Loop_Statement =>
               Internal_Error("Inside Post_Op: end-of-loop");
            when A_While_Loop_Statement =>
               Internal_Error("Inside Post_Op: end-of-while");
            when A_For_Loop_Statement =>
               Internal_Error("Inside Post_Op: end-of-for");
             when others =>
               null;
         end case;

      when others => null;
   end case;

exception
   when Ex : ASIS_Inappropriate_Context          |
             ASIS_Inappropriate_Container        |
             ASIS_Inappropriate_Compilation_Unit |
             ASIS_Inappropriate_Element          |
             ASIS_Inappropriate_Line             |
             ASIS_Inappropriate_Line_Number      |
             ASIS_Failed                         =>

      Put("Post_Op : ASIS exception (");
      Put(To_Wide_String(Exception_Name(Ex)));
      Put(") is raised");
      New_Line;

      Put("ASIS Error Status is ");
      Put(Error_Kinds'Wide_Image(Status));
      New_Line;

      Put("ASIS Diagnosis is ");
      New_Line;
      Put(Diagnosis);
      New_Line;

      Set_Status;

   when Ex : others =>
      Put("Post_Op : ");
      Put(To_Wide_String(Exception_Information(Ex)));
      New_Line;

end Post_Op;
