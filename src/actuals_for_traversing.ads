---------------------------------------------------------------------------
-- FILE          : actuals_for_traversing.ads
-- LAST REVISION : 2009-01-07
-- SUBJECT       : Interface to pre- and post-element traversal subprograms.
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

package Actuals_For_Traversing is

   type Traversal_State is (Not_Used);
   Initial_Traversal_State : constant Traversal_State := Not_Used;

   procedure Pre_Op
     (E       :        Element;
      Control : in out Traverse_Control;
      State   : in out Traversal_State);

   procedure Post_Op
     (E       :        Element;
      Control : in out Traverse_Control;
      State   : in out Traversal_State);

end Actuals_For_Traversing;
