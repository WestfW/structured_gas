Theory

In general, a macro-based implementation of this sort of program structure
requires generating lables (and branch destinations) with two levels of
uniqueness.  One level of uniqueness is so that multiple structured
statements do not have their lables collide.  The second level handles
nesting.

The local label capability built into gas allows the collision problem to be
ignored entirely.  We can use non-unique lables for the else_label and
endif_lable, and in fact use the same local label name for each elseif
label, since gas has the ability to understand "jump forward to the next
instance of local label 0."  Similarly for looping, "jump backward to the
previous instance of local label 1" can be repeated.

This leaves nesting, which is relative easily handled with a counter.  These
macros use a single nesting counter, which is incremented by two for each
"begin" macro ("if" or "do") This gives us two usable local labels for each
structure.  For conditional statements, the two labels are used for the end
of full statement (endif label), and for the next else label (else labelN.)
For loops, we use one label for the start of the loop, and one for (past)
the end.)

There are a couple of symbols and support macros used internally by this
package.  Theoretically, all symbols are prefixed with "_ST_", and all
support macros are prefixed with "_st_", so as to reduce the likelyhood of
collisions with other macro packages or user code.


Here are some examples of how things work:

Generated Code Examples

_if/_endif

       cmp r1, r2                    cmp r1, r2
       _if z			     jnz 0f
         call args_equal	       call args_equal
	 call statprint		       call statprint
       _endif			    0: 1:


_if/_else/_endif

       cmp r1, r2		     cmp r1, r2
       _if z			     jnz 0f
         call args_equal	       call args_equal
       _else			     0: rjmp 1f
         call args_NOTequal	       call args_NOTequal
       _endif			     0: 1:
       call statprint         	       call statprint


_if/_elseif/_else/_endif

       cpi r16, 'a'		         cpi r16, 'a'
       _if e			         jne 0f
         call sub_for_a			   call sub_for_a
       _elseif <cpi r16, 'b'>, e           rjmp 1f
				      0: cpi r16, 'b'
					 jne 0f
         call sub_for_b		       	   call sub_for_b
       _elseif <cpi r16, 'c'>, e       	   rjmp 1f
				      0: cpi r16, 'c'
					 jne 0f
         call sub_for_c		       	   call sub_for_c
       _else			           rjmp 1f
         call badcmd		      0: call badcmd
       _endif			      0: 1:


_if/_else with nesting

       cpi r16, 'a'                  cpi r16, 'a'
       _if e			     jne 0f
         cpi r17, NEWLINE	       cpi r17, 13
	 _if e			       jne 2f
	   call dummy			 call dummy
         _endif			       2: 3:
         call afunc		       call afunc
       _else			       rjmp 1f
         call badcmd		     0: call badcmd
       _endif			     1:

_break cc
Branch out of the loop, past the closing _while or _until.


_until cc

Branch back to the beginning of the loop, if the condition is NOT true.

       _do
         call movechar
	 cpse r1, r2
       _until skp


_while cc

Branch back to the beginning of the loop, IF the connection is true.
"_while always" creates an infinite loop.

       _do
         cpi r16, 16
	 _break lt
	 call moveit
       _while always



Testing

The implementation includes a test-cases directory containing at least avr
assembly code that uses each of the macros.  There's no magic, but the code produced
can be inspected for correctness.

For looking at the final code, you should produce an executable so that the
linker resolves all of the symbol references.

       avr-gcc -mmcu=atmega8 -Istruct_asm_dir myprogram.S -o myprogram.elf
       avr-objdump -S myprogram.elf


Porting

The Gnu Assembler supports a great number of different CPU architectures,
and the core functionality of the structured programming macros should be usable
without changes on most of them.

What DOES change between different cpus is the exact format of conditional
branch instructions and what condition codes can be used.  The macros are
designed to have these parts of the code be easily modified to support
other CPUs.

The core "struct_gas.S" file includes a conditional chain to include the
appropriate cpu-specific defintions.  This can be extended as needed.  The
symbols pre-defined by the specific version of gas should be documented,
but you can also get hints by using the compiler binary to "dump" the
predefined symbols using "xxx-gcc -dM -E - </dev/null"

#ifdef __AVR__
#include "struct_gas_avr.S"
#elif __MSP430__
#include "struct_gas_msp430.S"
#elif __x86_64__
#include "struct_gas_x86.S"
#elif __m68k__
#include "struct_gas_m68k.S"
#else
#error No recognized Architecture for struct_gas.S
#endif

The main content of the cpu-specific files is a set of macros that define
"cannonical" forms of all the available conditional jumps, and their
logical opposites.  For example, if your CPU supports only "zero/not zero"
(jz, jnz) and "carry set/carry clear" (jcs, jcc) conditions, you would
define macros for "st_jmp_z", "st_jmp_nz", "st_jmp_not_z", "st_jmp_not_nz",
"st_jmp_cs", "st_jmp_cc", "st_jmp_not_cs", "st_jmp_not_cc", plus
"st_jmp_always."  Note that "st_jmp_not_nz" would generate the same code as
"st_jmp_z", and that the use of cannonical forms prevents the need for
"double jumps" to implement the "not" conditionals ("jz .+2; jmp endif" to
implement "if z")

This may sound like a lot of work, but it is very mechanical, and can
usually be assisted by using the ".irp" assembler directive (use the
existing struct_gas_xxx.S files as examples.)


References
(I haven't read all of these, but they turned up while I was searching for an
existing implementation.)


"Adding Structured Control-flow to any* Assembler" (*Except gas) (Nov 2010)
http://dkeenan.com/AddingStructuredControlFlowToAnyAssembler.htm
The immediate motivation for this work.


"Structured Assembler Language Programming Using HLASM" by Edward E. Jaffe.
HLASM is apparently an IBM Mainframe thing.  This is a pretty nice
presentation on the whys and hows, for a much more extensive package than the
gas implementation presented here.


"Macro Implementation of a Structured Assembly Language" (may 1982)
http://ieeexplore.ieee.org/xpl/articleDetails.jsp?reload=true&arnumber=1702943&contentType=Journals+%26+Magazines
I couldn't find a version of this that wasn't paywalled.

"Macsym.mac" The tops20 operating system support macros that include .ifskp
and similar, circa 1981.
http://pdp-10.trailing-edge.com/BB-4172H-BM/01/4-1-sources/macsym.mac.html

struct.mac for PDP10 from DECUS tapes
http://pdp-10.trailing-edge.com/decuslib10-08/01/43,50500/struct.mac.html
