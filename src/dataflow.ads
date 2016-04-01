---------------------------------------------------------------------------
-- FILE          : dataflow.ads
-- LAST REVISION : 2009-01-07
-- SUBJECT       : Specification of dataflow analysis package.
-- PROGRAMMER    : (C) Copyright 2009 by Peter C. Chapin
--
-- Please send comments or bug reports to
--
--      Peter C. Chapin
--      Computer Information Systems Department
--      Vermont Technical College
--      Randolph Center, VT 05061
--      Peter.Chapin@vtc.vsc.edu
---------------------------------------------------------------------------

with Ada.Containers.Ordered_Sets;
with Asis;      use Asis;
with Asis.Text; use Asis.Text;

with Spica.Graphs;

with Global; use Global;

package Dataflow is

   -- There is an issue with elaboration order between package Dataflow and package Sift_Debug.
   -- I don't *think* the issue will cause an actual problem, but it should be resolved at some
   -- point.
   --
   -- pragma Elaborate_Body;

   -- This type represents the information stored at each vertex of the CFG.
   type CFG_Vertex_Type is record
      E : Element;
   end record;

   -- Make a specific flow graph package using the above vertex type.
   package Flow_Graph is new Spica.Graphs(CFG_Vertex_Type);
   use Flow_Graph;

   -- Make a package for handling sets of symbol names.
   package Symbol_Sets is new Ada.Containers.Ordered_Sets
     (Element_Type => Symbol_Name_Type, "=" => Symbol_Names."=", "<" => Symbol_Names."<");
   use Symbol_Sets;

   -- An array of Symbol_Sets used for In/Out information in the analysis.
   type Set_List is array(Positive range <>) of Set;

   -- Much of the logic for building the flow graph is in the traversal procedures. Consequently
   -- Current_Vertex and Start_Vertex need to be publically available. This is probably not an
   -- ideal design but it will do for now.
   --
   CFG            : Graph;
   Current_Vertex : Vertex_Index;
   Start_Vertex   : Vertex_Index;

   -- Helper procedure: Attachs a new vertex to the graph.
   procedure Add_Simple_Vertex(Vertex_Data : CFG_Vertex_Type);

   -- Performs dataflow analysis on taint-tracking dataflow equations.
   procedure Compute_Dataflow;

end Dataflow;
