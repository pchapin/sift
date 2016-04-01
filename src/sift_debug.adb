---------------------------------------------------------------------------
-- FILE          : sift_debug.adb
-- LAST REVISION : 2009-01-07
-- SUBJECT       : Implementation of SIFT specific debugging helpers.
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

-- Standard.
with Ada.Integer_Wide_Text_IO; use Ada.Integer_Wide_Text_IO;
with Ada.Wide_Text_IO;         use Ada.Wide_Text_IO;

-- Asis.
with Asis.Declarations; use Asis.Declarations;
with Asis.Elements;     use Asis.Elements;
with Asis.Expressions;  use Asis.Expressions;
with Asis.Statements;   use Asis.Statements;

-- Application specific.
with Global; use Global;

package body Sift_Debug is

   package Flow_Graph renames Dataflow.Flow_Graph;
   use Flow_Graph;

   package Symbol_Sets renames Dataflow.Symbol_Sets;
   use type Symbol_Sets.Cursor;

   -- The currently selected debug level.
   Current_Level : Natural := 0;

   package Statement_Kind_IO     is new Enumeration_IO(Statement_Kinds);
   package Expression_Kind_IO    is new Enumeration_IO(Expression_Kinds);
   package Mode_Kind_IO          is new Enumeration_IO(Mode_Kinds);
   package Defining_Name_Kind_IO is new Enumeration_IO(Defining_Name_Kinds);

   procedure Internal_Error(Message : in Wide_String) is
   begin
      Put("Internal Error!! (");
      Put(Message);
      Put_Line(")");
      raise Failure;
   end Internal_Error;


   procedure Unsupported_Feature(Message : in Wide_String) is
   begin
      Put("Warning! Unsupported Ada feature encountered. (");
      Put(Message);
      Put_Line(")");
   end Unsupported_Feature;


   procedure Set_Level(Level : in Natural) is
   begin
      Current_Level := Level;
   end Set_Level;


   procedure Dump_CFG is
   begin
      New_Line;
      Put_Line("Dump of CFG");
      Put_Line("===========");
      New_Line;
      Put_Line("(forward edges)");
      for I in 1 .. Size(CFG) loop
         Put(I);
         Put(":");
         declare
            Successors : Vertex_List := Get_Successor_List(CFG, I);
         begin
            for J in Successors'Range loop
               Put(Successors(J));
            end loop;
         end;
         New_Line;
      end loop;

      New_Line;
      Put_Line("(backward edges)");
      for I in 1 .. Size(CFG) loop
         Put(I);
         Put(":");
         declare
            Predecessors : Vertex_List := Get_Predecessor_List(CFG, I);
         begin
            for J in Predecessors'Range loop
               Put(Predecessors(J));
            end loop;
         end;
         New_Line;
      end loop;
   end Dump_CFG;


   procedure Dump_Dataflow_Sets(Sets : in Set_List) is
      It         : Symbol_Sets.Cursor;
      First_Pass : Boolean;
   begin
      New_Line;
      Put_Line("Dataflow Sets (by CFG Node Number)");
      Put_Line("==================================");
      for I in Sets'Range loop
         Put(I); Put(": ");
         It := Symbol_Sets.First(Sets(I));
         First_Pass := True;
         while It /= Symbol_Sets.No_Element loop
            if not First_Pass then
               Put(", ");
            end if;
            Put(Symbol_Names.To_Wide_String(Symbol_Sets.Element(It)));
            Symbol_Sets.Next(It);
            First_Pass := False;
         end loop;
         New_Line;
      end loop;
   end Dump_Dataflow_Sets;


   procedure Display_Procedure_Name(E : in Element; Level : in Natural := 0) is
      Procedure_Name_Expr : Expression := Called_Name(E);
   begin
      case Expression_Kind(Procedure_Name_Expr) is

      when An_Identifier =>
         declare
            Procedure_Name : Program_Text := Name_Image(Procedure_Name_Expr);
         begin
            Put_Line(Procedure_Name);
         end;

      when A_Selected_Component =>
         declare
            Unqualified_Name_Expr : Expression   := Selector(Procedure_Name_Expr);
            Procedure_Name        : Program_Text := Name_Image(Unqualified_Name_Expr);
         begin
            Put_Line(Procedure_Name);
         end;

      when others =>
         Internal_Error("Unexpected procedure call form");

      end case;
   end Display_Procedure_Name;


   procedure Display_Statement_Kind(E : in Element; Level : in Natural := 0) is
   begin
      if Level <= Current_Level then
         Put("Statement Kind : ");
         Statement_Kind_IO.Put(Statement_Kind(E));
         New_Line;
      end if;
   end Display_Statement_Kind;


   procedure Display_Expression_Kind(E : in Element; Level : in Natural := 0) is
   begin
      if Level <= Current_Level then
         Put("Expression Kind : ");
         Expression_Kind_IO.Put(Expression_Kind(E));
         New_Line;
      end if;
   end Display_Expression_Kind;


   procedure Display_Mode_Kind(E : in Element; Level : in Natural := 0) is
   begin
      if Level <= Current_Level then
         Put("Mode Kind : ");
         Mode_Kind_IO.Put(Mode_Kind(E));
         New_Line;
      end if;
   end Display_Mode_Kind;


   procedure Display_Defining_Name_Kind(E : in Element; Level : in Natural := 0) is
   begin
      if Level <= Current_Level then
         Put("Defining Name Kind : ");
         Defining_Name_Kind_IO.Put(Defining_Name_Kind(E));
         New_Line;
      end if;
   end Display_Defining_Name_Kind;
end Sift_Debug;
