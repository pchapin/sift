
Secure Information Flow Tracker (SIFT)
======================================

SIFT is an information flow tracker for Ada originally developed as a class project for a
graduate software analysis course at the University of Vermont. It is my hope to eventually
complete and extend the project to make it actually useful on real programs.

This program makes use of an additional library of algorithms and data structures named
"Allegra." You can find Allegra here: https://github.com/pchapin/allegra. You should clone the
Allegra repository into a folder that is a sibling of the folder were SIFT's is located so the
project files here can find the Allegra source code properly.

Building SIFT
-------------

To build SIFT you must use the GNAT Ada compiler (SIFT currently uses a few GNAT specific
libraries). You also need to have ASIS-for-GNAT installed on your system. This document does not
describe how to install ASIS-for-GNAT nor how to configure your environment so that you can use
the ASIS libraries. See

    http://gnat-asis.sourceforge.net/

for more information about ASIS-for-GNAT.

To compile SIFT you can either start GPS using the GNAT project file sift.gpr or you can use the
command line tools as follows

     gnatmake -Psift.gpr

After compilation you will find an executable named 'sift' in the build directory.

Running SIFT
------------

Before you can use SIFT on a program you need to compile the program so that tree files are
generated. For example to compile myprog.adb use a command such as

     gnatmake -gnatc -gnatt myprog.adb

This does not generate an executable. If you need an executable version of your program as well,
you should recompile without the '-gnatc' and '-gnatt' options. Note that if you use '-gnatt'
when building an executable, the resulting tree files can't be processed by ASIS-for-GNAT.

After preparing the target program, run SIFT. It will search the current directory for tree
files and analyze the corresponding program.

At the time of this writing, SIFT has many limitations. It will not function on any realistic
Ada code and can only be used successfully on toy programs. See the documentation for more
information.

License
-------

It is my intention to make this program available under the terms of the GNU Public License. For
more information about the GPL see the file GPL.txt in this distribution.

Enjoy!

Peter C. Chapin  
<PChapin@vtc.vsc.edu>
