---------------------------------------------------------------------------
-- FILE          : expressions_processing.ads
-- LAST REVISION : 2009-01-07
-- SUBJECT       : Interface to package that processes expressions.
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

with Asis;      use Asis;
with Dataflow;  use Dataflow;

package Expression_Processing is

   -- This function expects E to be an Asis.Expression. It returns True if the expression's
   -- value is tainted; False otherwise.
   --
   function Is_Tainted(E : Element; Tainted : Symbol_Sets.Set) return Boolean;

   -- This procedure expects E to be an Asis.Expression. It explores that expression and
   -- outputs warnings if tainted data is being sent to an Output subprogram.
   --
   procedure Expression_Warnings(E : Element; Tainted : Symbol_Sets.Set);

end Expression_Processing;
