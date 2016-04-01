---------------------------------------------------------------------------
-- FILE          : global.adb
-- LAST REVISION : 2009-01-07
-- SUBJECT       : Implementation of various global entities used in SIFT
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

package body Global is

   procedure Get_Version(Major : out Natural; Minor : out Natural; Revision : out Natural) is
   begin
      Major := 1;
      Minor := 0;
      Revision := 0;
   end Get_Version;

end Global;
