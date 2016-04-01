---------------------------------------------------------------------------
-- FILE          : sift_debug.ads
-- LAST REVISION : 2009-01-07
-- SUBJECT       : SIFT specific debugging helper subprograms.
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
with Asis;     use Asis;
with Dataflow; use Dataflow;

package Sift_Debug is

   -- Raised by Internal_Error.
   Failure : exception;

   -- Wrapper for messages when an internal inconsistency is found.
   procedure Internal_Error(Message : in Wide_String);

   -- Wrapper for messages about unsupported Ada constructs.
   procedure Unsupported_Feature(Message : in Wide_String);

   -- Sets the debug level. Higher values produce more messages.
   procedure Set_Level(Level : in Natural);

   -- Displays the control flow graph held by the Dataflow package.
   procedure Dump_CFG;

   -- Displays all the symbols in the given set.
   procedure Dump_Dataflow_Sets(Sets : in Set_List);

   -- Displays a procedures name given the expression used to call it.
   procedure Display_Procedure_Name(E : in Element; Level : in Natural := 0);

   -- Displays the given element's statement kind.
   procedure Display_Statement_Kind(E : in Element; Level : in Natural := 0);

   -- Displays the given element's expression kind.
   procedure Display_Expression_Kind(E : in Element; Level : in Natural := 0);

   -- Displays the given element's mode kind (for parameter declarations).
   procedure Display_Mode_Kind(E : in Element; Level : in Natural := 0);

   -- Displays the given element's defining name kind.
   procedure Display_Defining_Name_Kind(E : in Element; Level : in Natural := 0);

end Sift_Debug;
