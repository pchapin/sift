---------------------------------------------------------------------------
-- FILE          : unit_processing.ads
-- LAST REVISION : 2009-01-07
-- SUBJECT       : Interface to package that processes compilation units.
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

with Asis; use Asis;

package Unit_Processing is

   -- This procedure decomposes its argument unit and calls the element processing routine for
   -- all the top-level components of the unit element hierarchy. This element processing
   -- routine is the instance of Traverse_Element which performs the recursive traversing of the
   -- unit structural components.
   --
   procedure Process_Unit(The_Unit : Compilation_Unit);

end Unit_Processing;
