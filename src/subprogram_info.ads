---------------------------------------------------------------------------
-- FILE          : subprogram_info.ads
-- LAST REVISION : 2009-01-07
-- SUBJECT       : Specification of subprogram information package.
-- PROGRAMMER    : (C) Copyright 2009 by Peter C. Chapin
--
-- This package provides information about the security "class" of each subprogram. It
-- maintains, in effect, a database that maps subprogram names to security classes.
--
-- Please send comments or bug reports to
--
--      Peter C. Chapin
--      Computer Information Systems Department
--      Vermont Technical College
--      Randolph Center, VT 05061
--      Peter.Chapin@vtc.vsc.edu
---------------------------------------------------------------------------
with Global; use Global;

package Subprogram_Info is

   type Subprogram_Class_Type is (Invalid, Input, Sanitizing, Passive);

   type Subprogram_Status is record
      Is_Output : Boolean               := False;
      Class     : Subprogram_Class_Type := Invalid;
   end record;

   function Is_Output_Subprogram(N : Symbol_Name_Type) return Boolean;
   function Get_Subprogram_Class(N : Symbol_Name_Type) return Subprogram_Class_Type;

end Subprogram_Info;
