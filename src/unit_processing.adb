---------------------------------------------------------------------------
-- FILE          : unit_processing.adb
-- LAST REVISION : 2009-01-07
-- SUBJECT       : Package for coordinating the processing a compilation unit.
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

-- Standard.
with Ada.Wide_Text_IO;   use Ada.Wide_Text_IO;

-- Asis.
with Asis.Elements;      use Asis.Elements;

-- Application specific.
with Sift_Debug;         use Sift_Debug;
with Dataflow;           use Dataflow;
with Element_Processing; use Element_Processing;

package body Unit_Processing is

   procedure Process_Unit (The_Unit : Compilation_Unit) is

      Contex_Clause_Elements : constant Element_List :=
        Context_Clause_Elements(Compilation_Unit => The_Unit, Include_Pragmas  => True);

      Unit_Decl : Element := Unit_Declaration(The_Unit);

   begin -- Process_Unit

      -- The following loop was in the original template. I may want to process context clauses
      -- in SIFT (for example to see annotations in dependent package specifications). However,
      -- for now I will comment this loop out.
      --
      -- for J in Contex_Clause_Elements'Range loop
      --    Process_Construct(Contex_Clause_Elements(J));
      -- end loop;

      New_Line;
      Put_Line("BUILDING CONTROL FLOW GRAPH");
      Process_Construct(Unit_Decl);
      Dump_CFG;

      New_Line;
      Put_Line("ITERATING DATAFLOW EQUATIONS");
      Compute_Dataflow;

      -- This procedure does not contain any exception handler because it supposes that
      -- Process_Construct handles all exceptions.
   end Process_Unit;

end Unit_Processing;
