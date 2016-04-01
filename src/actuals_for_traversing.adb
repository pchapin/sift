---------------------------------------------------------------------------
-- FILE          : actuals_for_traversing.adb
-- LAST REVISION : 2009-01-09
-- SUBJECT       : Implementation of the pre- and post-traversal subprograms.
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

package body Actuals_For_Traversing is

   procedure Post_Op
     (E       :        Asis.Element;
      Control : in out Asis.Traverse_Control;
      State   : in out Traversal_State)
   is separate;


   procedure Pre_Op
     (E       :        Asis.Element;
      Control : in out Asis.Traverse_Control;
      State   : in out Traversal_State)
   is separate;

end Actuals_For_Traversing;
