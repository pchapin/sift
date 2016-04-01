---------------------------------------------------------------------------
-- FILE          : global.ads
-- LAST REVISION : 2009-01-07
-- SUBJECT       : Interface to various global entities used in SIFT.
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
with Ada.Strings.Wide_Bounded;

package Global is

   package Symbol_Names is new Ada.Strings.Wide_Bounded.Generic_Bounded_Length(128);
   use Symbol_Names;

   subtype Symbol_Name_Type is Bounded_Wide_String;

   procedure Get_Version(Major : out Natural; Minor : out Natural; Revision : out Natural);

end Global;
