with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

procedure Sample_1 is

   function F(X, Y : Integer) return Integer is
   begin
      return X + 1;
   end F;

   function Clean(X : Integer) return Integer is
   begin
      return 0;
   end Clean;

   X : Integer := 0;
   A : Integer;

begin -- Sample_1

   while X < 10 loop
      Get(A);
      A := F(3, A) + (2 * Clean(F(A, 1)));
      Put(A);
      Put(X);
      if A = 0 then
         Get(A);
         X := A mod 5;
      else
         A := Clean(A);
      end if;
      Put(A);
      Put(1 + F(X, 2));
      X := X + 1;
   end loop;

end Sample_1;
