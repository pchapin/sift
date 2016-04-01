---------------------------------------------------------------------------
-- FILE          : expression_processing.adb
-- LAST REVISION : 2009-01-07
-- SUBJECT       : Implementation of package that processes expressions.
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
with Ada.Wide_Text_IO;         use Ada.Wide_Text_IO;
with Ada.Integer_Wide_Text_IO; use Ada.Integer_Wide_Text_IO;

-- Asis.
with Asis.Elements;     use Asis.Elements;
with Asis.Expressions;  use Asis.Expressions;
with Asis.Text;         use Asis.Text;

-- Application specific.
with Sift_Debug;        use Sift_Debug;
with Global;            use Global;
with Subprogram_Info;   use Subprogram_Info;


package body Expression_Processing is

   package Symbol_Set renames Dataflow.Symbol_Sets;
   use type Symbol_Sets.Cursor;

   function Is_Tainted(E : Element; Tainted : Symbol_Sets.Set) return Boolean is

      function Handle_Function_Call return Boolean is
         Function_Expression : Expression   := Prefix(E);
         Function_Name_Image : Program_Text := Name_Image(Function_Expression);
      begin
         case Get_Subprogram_Class(Symbol_Names.To_Bounded_Wide_String(Function_Name_Image)) is
            when Invalid =>
               Internal_Error("Function with invalid classification encountered");

            when Input =>
               return True;

            when Sanitizing =>
               return False;

            when Passive =>
               declare
                  Function_Arguments : Association_List := Function_Call_Parameters(E);
               begin
                  for I in Function_Arguments'Range loop
                     if Is_Tainted(Actual_Parameter(Function_Arguments(I)), Tainted) then
                        return True;
                     end if;
                  end loop;
                  return False;
               end;
         end case;
         return True;  -- Needed to keep the compiler happy. Never executes.
      end Handle_Function_Call;

   begin -- Is_Tainted
      case Expression_Kind(E) is
         -- Literals are not tainted.
         when An_Integer_Literal  |
              A_Real_Literal      |
              A_String_Literal    |
              A_Character_Literal |
              An_Enumeration_Literal =>
            return False;

         when An_Identifier =>
            declare
               Name : Program_Text := Name_Image(E);
            begin
               if Symbol_Sets.Contains(Tainted, Symbol_Names.To_Bounded_Wide_String(Name)) then
                  return True;
               else
                  return False;
               end if;
            end;

         -- Unwind one layer of parentheses using recursion.
         when A_Parenthesized_Expression =>
            return Is_Tainted(Expression_Parenthesized(E), Tainted);

         -- Most expressions are function calls (eg built-in operators).
         when A_Function_Call =>
            return Handle_Function_Call;

         when others =>
            Display_Expression_Kind(E);
            Internal_Error("Unexpected expression kind encountered");
      end case;
      return True;
   end Is_Tainted;


   procedure Expression_Warnings(E : Element; Tainted : Symbol_Sets.Set) is

      procedure Handle_Function_Call is
         Function_Expression : Expression       := Prefix(E);
         Function_Name_Image : Program_Text     := Name_Image(Function_Expression);
         Function_Arguments  : Association_List := Function_Call_Parameters(E);
         Location            : Span;
      begin
         if Is_Output_Subprogram(Symbol_Names.To_Bounded_Wide_String(Function_Name_Image)) then
            for I in Function_Arguments'Range loop
               if Is_Tainted(Actual_Parameter(Function_Arguments(I)), Tainted) then
                  Location := Element_Span(Actual_Parameter(Function_Arguments(I)));
                  Put("(L");
                  Put(Location.First_Line, 0);
                  Put(", C");
                  Put(Location.First_Column, 0);
                  Put("): Expression sends tainted value to Output function");
                  New_Line;
               end if;
            end loop;
         end if;

         -- Explore arguments to see if any subexpressions need warnings.
         for I in Function_Arguments'Range loop
            Expression_Warnings(Actual_Parameter(Function_Arguments(I)), Tainted);
         end loop;
      end Handle_Function_Call;

   begin -- Expression_Warnings
      case Expression_Kind(E) is
         when A_Parenthesized_Expression =>
            Expression_Warnings(Expression_Parenthesized(E), Tainted);

         when A_Function_Call =>
            Handle_Function_Call;

         when others =>
            null;
      end case;
   end Expression_Warnings;

end Expression_Processing;
