# Structured Programming Macros For Gnu Asembler

## Intro

These macros implement standard Structured Programming code flow mechanisms
for the Gnu Assembler ("gas").  Macros should expand to the minimum-sized
code (typically single conditional or unconditional branches.)  They make
extensive use the the gas local label feature ("nnnn:")

Condition Code ("cc") are based on whatever conditions are available on the
target CPU.  Typically, a negated cc argument will be appended to the
condiional branch opcode (so "_if z" will generate a "bnz" instruction.)
"skp" and "always" are also defined to accomadate instructions that skip
based on results, or unconditional branches.  ("_while always")

### Usage

To use the structured programming macros, put a "#include <struct_gas.S>"
at the beginning of your program, and use the gcc compiler front-end so that
correct pre-processing is done.

    gcc -mmcu=xxxx -Istruct-gas-dir myprogram.S

There shouldn't be any great surprises in how the macros are used.

Blocks of code are delimited by the macros, so every _if needs a matching
_endif.  Loops are always started with "_do", but can be terminated with
either "_while" or "_until."


### Individual Macro Descriptions

**_if cc**

If the specified condition code is not true, branch to the matching
_else, _elseif, or _endif statement.

       cmp r1, r2                    cmp r1, r2
       _if z			     jnz 0f
         call args_equal	       call args_equal
	 call statprint		       call statprint
       _endif			    0: 1:

**_else**

Branch unconditioally to the matching _endif statement.  (Also serves as a
target for _if branches.)

       cmp r1, r2		     cmp r1, r2
       _if z			     jnz 0f
         call args_equal	       call args_equal
       _else			     0: rjmp 1f
         call args_NOTequal	       call args_NOTequal
       _endif			     0: 1:
       call statprint         	       call statprint


**_elseif \<statement\>, cc**

Insert an unconditional branch to the matching _endif statement, then
include \<statement\> in the code, followed by a conditional branch to the
matching _else, _elseif, or _endif statment.  The start of "<statement>" is
used as the target for the previous _if or _elseif statements.

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


**_endif**

Ends a conditional code block.  Used as a target for the matching
_if/_else/_elseif statements.



**_do**

Defines the start of a loop.


**_break cc**
Branch out of the loop, past the closing _while or _until.


**_until cc**

Branch back to the beginning of the loop, if the condition is NOT true.

       _do
         call movechar
	 cpse r1, r2
       _until skp


**_while cc**

Branch back to the beginning of the loop, IF the connection is true.
"_while always" creates an infinite loop.

       _do
         cpi r16, 16
	 _break lt
	 call moveit
       _while always


### Notes and Limitations

The macro package uses C preprocessor macros (#if, #include) and uses
predefined symbols defined by the C compiler (__AVR__) for selecting which
architecture-specific files to include.  Therefore, you should assemble using
the C compiler front-end instead of invoking gas directly:

    gcc -mmcu=xxxx -Istruct-gas-dir myprogram.S

Your source should use "#include <struct_gas.S>"


The Macros make use of gas's ".altmacro" direction and capabilities.  This
adds meaning to certain characters ("<>'%") that may have implications on
your code.

The if/else macros use local labels starting with "80", and the loop code
uses local labels starting with "90";  This range of local lables should be
avoided in the user program.

There is little error checking.  There are probably any number of sequences
of macro invocations that will not result in any error message, but will
nevertheless produce code that does not do what you had in mind.

In theory, the basic macros are not dependent on any particular CPU
architecture.  The initial implementation supports Atmel AVR and TI MSP430
cpus, but the structure can be easily ported to other CPUs.  See
"implementation.md" for details.
