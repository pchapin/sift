---------------------------------------------------------------------------
-- FILE          : element_processing.ads
-- LAST REVISION : 2009-01-07
-- SUBJECT       : Interface to package that processes individual elements.
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

package Element_Processing is

   --  This procedure should not be called for Nil_Element;
   procedure Process_Construct(The_Element : Element);

end Element_Processing;
