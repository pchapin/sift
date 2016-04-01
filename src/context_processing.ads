---------------------------------------------------------------------------
-- FILE          : context_processing.ads
-- LAST REVISION : 2009-01-07
-- SUBJECT       : Interface to subprograms for handling an ASIS context.
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
--------------------------------------------------------------------------

with Asis; use Asis;

package Context_Processing is

   procedure Process_Context(The_Context : Context; Trace : Boolean := False);

   -- Supposing that Ada_File_Name is the name of an Ada source file which follows the GNAT
   -- file naming rules (see the GNAT Users Guide), this function tries to get from The_Context
   -- the ASIS Compilation Unit contained in this source file. The source file name may contain
   -- the directory information in relative or absolute form.
   --
   -- If The_Context does not contain the ASIS Compilation Unit which may be the content of the
   -- argument file, Nil_Compilation_Unit is returned.
   --
   -- Note, that this function always return Nil_Compilation_Unit, if Ada_File_Name is a file
   -- name which is krunched. Nil_Compilation_Unit is also returned if Ada_File_Name correspond
   -- to any name of a child unit from the predefined or GNAT-specific hierarchy (children of
   -- System, Ada, Interfaces, and GNAT)
   --
   function Get_Unit_From_File_Name
     (Ada_File_Name : String; The_Context : Context) return Compilation_Unit;

end Context_Processing;
