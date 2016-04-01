---------------------------------------------------------------------------
-- FILE          : dataflow.adb
-- LAST REVISION : 2009-01-07
-- SUBJECT       : Implementation of dataflow analysis package.
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

-- Standard.
with Ada.Wide_Text_IO;         use Ada.Wide_Text_IO;
with Ada.Integer_Wide_Text_IO; use Ada.Integer_Wide_Text_IO;

-- Asis.
with Asis.Declarations; use Asis.Declarations;
with Asis.Elements;     use Asis.Elements;
with Asis.Expressions;  use Asis.Expressions;
with Asis.Statements;   use Asis.Statements;

-- Application specific.
with Sift_Debug;            use Sift_Debug;
with Expression_Processing; use Expression_Processing;
with Subprogram_Info;       use Subprogram_Info;


package body Dataflow is

   procedure Add_Simple_Vertex(Vertex_Data : CFG_Vertex_Type) is
      New_Vertex : Vertex_Index;
   begin
      Create_Vertex(CFG, Vertex_Data, New_Vertex);
      Create_Edge(CFG, Current_Vertex, New_Vertex);
      Current_Vertex := New_Vertex;
   end Add_Simple_Vertex;


   -- Find dirty/clean sets for the given CFG vertex.
   procedure DC
     (Vertex_Data     : in  CFG_Vertex_Type;
      Dirty_Result    : out Set;
      Clean_Result    : out Set;
      Current_Tainted : in  Set) is

      D_Result : Set;
      C_Result : Set;

      -- Find dirty/clean sets for procedure calls.
      procedure Handle_Procedure_Call is
         Procedure_Arguments   : Association_List   := Call_Statement_Parameters(Vertex_Data.E);
         Procedure_Declaration : Declaration        := Corresponding_Called_Entity(Vertex_Data.E);
         Name_List             : Defining_Name_List := Names(Procedure_Declaration);
         Primary_Name          : Defining_Name renames Name_List(Name_List'First);
         Procedure_Name        : Program_Text       := Defining_Name_Image(Primary_Name);
         Procedure_Formals     : Parameter_Specification_List :=
           Parameter_Profile(Procedure_Declaration);

         -- This procedure enters all output parameters into the given set.
         procedure Record_Outputs(The_Set : in out Set) is
            Actual_Name : Expression;
            Mode        : Mode_Kinds;
         begin
            for I in Procedure_Arguments'Range loop
               Actual_Name := Actual_Parameter(Procedure_Arguments(I));
               Mode := Mode_Kind(Procedure_Formals(I));
               if Mode = An_Out_Mode or Mode = An_In_Out_Mode then
                  declare
                     Actual_Name_Image : Program_Text := Name_Image(Actual_Name);
                  begin
                     Include(The_Set, Symbol_Names.To_Bounded_Wide_String(Actual_Name_Image));
                  end;
               end if;
            end loop;
         end Record_Outputs;

         -- Returns True if at least one input is tainted.
         function Has_Tainted_Input return Boolean is
            Actual_Expression : Expression;
            Mode              : Mode_Kinds;
         begin
            for I in Procedure_Arguments'Range loop
               Actual_Expression := Actual_Parameter(Procedure_Arguments(I));
               Mode := Mode_Kind(Procedure_Formals(I));
               if Mode = An_In_Mode or Mode = An_In_Out_Mode then
                  if Is_Tainted(Actual_Expression, Current_Tainted) then
                     return True;
                  end if;
               end if;
            end loop;
            return False;
         end Has_Tainted_Input;

      begin -- Handle_Procedure_Call
         case Get_Subprogram_Class(Symbol_Names.To_Bounded_Wide_String(Procedure_Name)) is
            when Invalid =>
               Internal_Error("Procedure with Invalid classification encountered");

            when Input =>
               Record_Outputs(D_Result);

            when Sanitizing =>
               Record_Outputs(C_Result);

            when Passive =>
               if Has_Tainted_Input then
                  Record_Outputs(D_Result);
               else
                  Record_Outputs(C_Result);
               end if;
         end case;
      end Handle_Procedure_Call;

      procedure Handle_Assignment is
         Expr        : Expression   := Assignment_Expression(Vertex_Data.E);
         Target      : Expression   := Assignment_Variable_Name(Vertex_Data.E);
         Target_Name : Program_Text := Name_Image(Target);
      begin
         if Is_Tainted(Expr, Current_Tainted) then
            Include(D_Result, Symbol_Names.To_Bounded_Wide_String(Target_Name));
         else
            Include(C_Result, Symbol_Names.To_Bounded_Wide_String(Target_Name));
         end if;
      end Handle_Assignment;


   begin -- DC
      case Element_Kind(Vertex_Data.E) is

         -- There are Nil elements in the CFG.
         when Not_An_Element =>
            null;

         -- Predicates representing conditions are expressions.
         when An_Expression =>
            null;

         -- Control of a for loop is a declaration.
         when A_Declaration =>
            null;

         -- "Ordinary" nodes in the CFG are statements.
         when A_Statement =>
            case Statement_Kind(Vertex_Data.E) is

               when A_Procedure_Call_Statement =>
                  Handle_Procedure_Call;

               when An_Assignment_Statement =>
                  Handle_Assignment;

               -- It's a statement, but not one I am prepared to handle.
               when others =>
                  Internal_Error("Unexpected statement kind in CFG");
                  Display_Statement_Kind(Vertex_Data.E);
            end case;

         when others =>
            Internal_Error("Bad CFG node while analyzing dataflow");
      end case;

      Dirty_Result := D_Result;
      Clean_Result := C_Result;
   end DC;


   -- This procedure is used to display the results of the analysis.
   procedure Print_Results(In_Vars : Set_List; Out_Vars : Set_List) is

      Output_Node : Set renames Out_Vars(Current_Vertex);
      Iterator    : Cursor;

      procedure Handle_Assignment(I : Vertex_Index) is
         Vertex_Data : CFG_Vertex_Type := Get_Vertex(CFG, I);
         Expr        : Expression      := Assignment_Expression(Vertex_Data.E);
         Target      : Expression      := Assignment_Variable_Name(Vertex_Data.E);
      begin
         Expression_Warnings(Expr, In_Vars(I));
      end Handle_Assignment;

      procedure Handle_Procedure_Call(I : Vertex_Index) is
         Vertex_Data           : CFG_Vertex_Type    := Get_Vertex(CFG, I);
         Procedure_Arguments   : Association_List   := Call_Statement_Parameters(Vertex_Data.E);
         Procedure_Declaration : Declaration        := Corresponding_Called_Entity(Vertex_Data.E);
         Name_List             : Defining_Name_List := Names(Procedure_Declaration);
         Primary_Name          : Defining_Name renames Name_List(Name_List'First);
         Procedure_Name        : Program_Text       := Defining_Name_Image(Primary_Name);
         Procedure_Formals     : Parameter_Specification_List :=
           Parameter_Profile(Procedure_Declaration);
         Mode                  : Mode_Kinds;
      begin
         if Is_Output_Subprogram(Symbol_Names.To_Bounded_Wide_String(Procedure_Name)) then
            for J in Procedure_Arguments'Range loop
               Mode := Mode_Kind(Procedure_Formals(J));
               if Mode = An_In_Mode or Mode = An_In_Out_Mode then
                  if Is_Tainted(Actual_Parameter(Procedure_Arguments(J)), In_Vars(I)) then
                     Put("(L");
                     Put(First_Line_Number(Vertex_Data.E), 0);
                     Put("): Statement sends tainted value to Output procedure");
                     New_Line;
                  end if;
               end if;
            end loop;
         end if;

         -- Now explore procedure's input arguments for possible warnings.
         for J in Procedure_Arguments'Range loop
            Mode := Mode_Kind(Procedure_Formals(J));
            if Mode = An_In_Mode or Mode = An_In_Out_Mode then
               Expression_Warnings(Actual_Parameter(Procedure_Arguments(J)), In_Vars(I));
            end if;
         end loop;
      end Handle_Procedure_Call;

   begin -- Print_Results
      New_Line;
      Put_Line("RESULTS");

      New_Line;
      Put_Line("Variables Tainted at Exit");
      Put_Line("=========================");
      Iterator := First(Output_Node);
      while Iterator /= No_Element loop
         Put_Line(Symbol_Names.To_Wide_String(Symbol_Sets.Element(Iterator)));
         Next(Iterator);
      end loop;

      New_Line;
      Put_Line("Warnings");
      Put_Line("========");
      for I in 1..Size(CFG) loop
         case Element_Kind(Get_Vertex(CFG, I).E) is
            when Not_An_Element =>
               null;
            when An_Expression =>
               null;
            when A_Declaration =>
               null;
            when A_Statement =>
               case Statement_Kind(Get_Vertex(CFG, I).E) is
                  when An_Assignment_Statement =>
                     Handle_Assignment(I);
                  when A_Procedure_Call_Statement =>
                     Handle_Procedure_Call(I);
                  when others =>
                     null;
               end case;
            when others =>
               null;
         end case;
      end loop;
   end Print_Results;


   procedure Compute_Dataflow is
      In_Vars   : Set_List(1 .. Size(CFG));
      Out_Vars  : Set_List(1 .. Size(CFG));
      Changed   : Boolean;
      Temp      : Set;
      Dirty_Set : Set;
      Clean_Set : Set;
   begin
      -- TODO: Initialize In_Vars
      loop
         Changed := False;

         -- forall i . (In[i] = Union_{p in pred[i]} (Out[p]))
         for I in In_Vars'Range loop
            Clear(Temp);
            declare
               Predecessors : Vertex_List := Get_Predecessor_List(CFG, I);
            begin
               for J in Predecessors'Range loop
                  Union(Temp, Out_Vars(Predecessors(J)));
               end loop;
            end;
            if Temp /= In_Vars(I) then
               In_Vars(I) := Temp;
               Changed := True;
            end if;
         end loop;

         -- forall i . (Out[i] = D[i] U (In[i] - C[i]))
         for I in Out_Vars'Range loop
            Clear(Temp);
            Clear(Dirty_Set);
            Clear(Clean_Set);
            DC(Get_Vertex(CFG, I), Dirty_Set, Clean_Set, In_Vars(I));
            Temp := Difference(In_Vars(I), Clean_Set);
            Union(Temp, Dirty_Set);
            if Temp /= Out_Vars(I) then
               Out_Vars(I) := Temp;
               Changed := True;
            end if;
         end loop;

         exit when not Changed;
      end loop;
      Dump_Dataflow_Sets(Out_Vars);

      -- Probably the results should be stored somewhere and queried from above.
      Print_Results(In_Vars, Out_Vars);
   end Compute_Dataflow;


begin -- package initialization
   Create_Vertex(CFG, (E => Nil_Element), Current_Vertex);
   Start_Vertex := Current_Vertex;
end Dataflow;
