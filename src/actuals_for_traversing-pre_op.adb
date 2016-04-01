---------------------------------------------------------------------------
-- FILE          : actuals_for_traversing-pre_op.adb
-- LAST REVISION : 2009-01-07
-- SUBJECT       : Pre-operation procedure used during AST traversal.
-- PROGRAMMER    : (C) Copyright 2009 by Peter C. Chapin
--
-- This code is based on the ASIS-for-GNAT template.
--
-- The procedure Pre_Op is called when each element in the abstract syntax tree of the current
-- compilation unit is visited for the first time. This procedure does the bulk of the work of
-- building the unit's control flow graph. The graph itself is held in package Dataflow, where
-- the data flow analysis is later done, but most of the construction is done by the sub-
-- programs here.
--
-- Note that the control structures, that contain nested statements, are handled by invoking
-- Process_Construct on each nested statement separately. This causes the exploration of the
-- syntax tree to continue. The invocation of Process_Construct that lead to the current call of
-- Pre_Op must then be aborted.
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
with Ada.Wide_Text_IO;        use Ada.Wide_Text_IO;
with Ada.Characters.Handling; use Ada.Characters.Handling;
with Ada.Exceptions;          use Ada.Exceptions;

-- Asis.
with Asis.Elements;           use Asis.Elements;
with Asis.Exceptions;         use Asis.Exceptions;
with Asis.Errors;             use Asis.Errors;
with Asis.Implementation;     use Asis.Implementation;
with Asis.Statements;         use Asis.Statements;
with Asis.Text;               use Asis.Text;

-- Application specific.
with Sift_Debug;              use Sift_Debug;
with Dataflow;                use Dataflow;
with Element_Processing;      use Element_Processing;

separate(Actuals_For_Traversing)

procedure Pre_Op
  (E :        Element;
   Control : in out Traverse_Control;
   State   : in out Traversal_State) is

   package Flow_Graph renames Dataflow.Flow_Graph;
   use Flow_Graph;

   -- This procedure currently doesn't handle elsif.
   procedure Process_If_Paths(E : Element) is
      My_PathList : Path_List := Statement_Paths(E);
      Predicate   : Element   := Condition_Expression(My_PathList(My_PathList'First));
      Old_Current : Vertex_Index;
   begin
      Add_Simple_Vertex((E => Predicate));
      Old_Current := Current_Vertex;
      for I in My_PathList'Range loop
         declare
            My_StatementList : Statement_List := Sequence_Of_Statements(My_PathList(I));
            Temp             : Vertex_Index;
            Top_Statement    : Boolean := True;
         begin
            for J in My_StatementList'Range loop
               if I /= My_PathList'First and Top_Statement then
                  Temp           := Current_Vertex;
                  Current_Vertex := Old_Current;
                  Old_Current    := Temp;
                  Top_Statement  := False;
               end if;

               Process_Construct(My_StatementList(J));
            end loop;
         end;
      end loop;
      Add_Simple_Vertex((E => Nil_Element));
      Create_Edge(CFG, Old_Current, Current_Vertex);
   end Process_If_Paths;


   procedure Process_Loop_Paths(E : Element) is
      My_StatementList : Statement_List := Loop_Statements(E);
      Old_Current      : Vertex_Index;
   begin
      Add_Simple_Vertex((E => Nil_Element));
      Old_Current := Current_Vertex;
      for I in My_StatementList'Range loop
         Process_Construct(My_StatementList(I));
      end loop;
      Create_Edge(CFG, Current_Vertex, Old_Current);
   end Process_Loop_Paths;


   procedure Process_While_Paths(E : Element) is
      My_StatementList : Statement_List := Loop_Statements(E);
      Predicate        : Element        := While_Condition(E);
      Old_Current      : Vertex_Index;
   begin
      Add_Simple_Vertex((E => Predicate));
      Old_Current := Current_Vertex;
      for I in My_StatementList'Range loop
         Process_Construct(My_StatementList(I));
      end loop;
      Create_Edge(CFG, Current_Vertex, Old_Current);
      Current_Vertex := Old_Current;
   end Process_While_Paths;


   -- For loops are different than while loops because the header contains a declaration instead
   -- of an expression. Also the variables used in the header do not "see" changes made to them
   -- inside the loop body. I'm not sure how to best handle that situation yet.
   --
   procedure Process_For_Paths(E : Element) is
      My_StatementList : Statement_List := Loop_Statements(E);
      Loop_Spec        : Element        := For_Loop_Parameter_Specification(E);
      Old_Current      : Vertex_Index;
   begin
      Add_Simple_Vertex((E => Loop_Spec));
      Old_Current := Current_Vertex;
      for I in My_StatementList'Range loop
         Process_Construct(My_StatementList(I));
      end loop;
      Create_Edge(CFG, Current_Vertex, Old_Current);
      Current_Vertex := Old_Current;
   end Process_For_Paths;

begin -- Pre_Op
   case Element_Kind(E) is
      when A_Statement =>
         case Statement_Kind(E) is
            when An_Assignment_Statement =>
               Add_Simple_Vertex((E => E));

            when An_If_Statement =>
               Process_If_Paths(E);
               Control := Abandon_Children;

            when A_Loop_Statement =>
               Process_Loop_Paths(E);
               Control := Abandon_Children;

            when A_While_Loop_Statement =>
               Process_While_Paths(E);
               Control := Abandon_Children;

            when A_For_Loop_Statement =>
               Process_For_Paths(E);
               Control := Abandon_Children;

            when A_Procedure_Call_Statement =>
               Add_Simple_Vertex((E => E));

            when others =>
               Unsupported_Feature("Unknown statement kind in AST");
               Display_Statement_Kind(E);
         end case;

      -- This is where non-statements (like declarations) are handled.
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

      Put("Pre_Op : ASIS exception (");
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
      Put("Pre_Op : ");
      Put(To_Wide_String(Exception_Information(Ex)));
      New_Line;

end Pre_Op;
