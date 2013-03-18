/* struct_asm.S
 * Feb 2013 by Bill Westfield (westfw@westfw.info)
 * Structured Assembly macros for the Gnu assembler.
 * These permit the use of _if _else _endif without the use of explicit labels.
 */

/*
 *
 * Based on PDP10 Macro macros that appeared at my highschool back in the 1970s,
 * published in some DEC10-related news media.  I don't even remember the details.
 * Similar but more complex macros occur in DEC's MACSYM.MAC file,
 *  and struct.mac on DECUS decus/20-0143 by Robert Nix.
 *
 * Here are the original (macro-10) definitions that followed me from HS:

DEFINE %LOOP	<SAVCTR==SAVCTR+1
		 %STNAM(SAV,\SAVCTR,.)>

DEFINE LOOPER(INSTRC)
<IRP INSTRC, <DEFINE %'INSTRC(AC) <INSTRC AC,<%GTNAM(SAV,\SAVCTR)>
		SAVCTR==SAVCTR-1>>>

LOOPER (<AOBJN,JRST,JUMPN,SOJG,SOJGE,SOJA,JUMPGE,AOJA>)

DEFINE %IF
<BEGCTR==BEGCTR+1
 JRST <%GTNAM(BEG,\BEGCTR)>
 SAVCTR==SAVCTR+1
 %STNAM(SAV,\SAVCTR,BEGCTR)>

DEFINE %ELSE
<%VAL==%GTNAM(SAV,\SAVCTR)
 BEGCTR==BEGCTR+1
 JRST <%GTNAM(BEG,\BEGCTR)>
 %STNAM(BEG,\%VAL,.)
 %STNAM(SAV,\SAVCTR,BEGCTR)>

DEFINE %END
<%VAL==%GTNAM(SAV,\SAVCTR)
 SAVCTR==SAVCTR-1
 %STNAM(BEG,\%VAL,.)>

DEFINE %GTNAM(VAR,IND) <VAR'IND>

DEFINE %STNAM(VAR,IND,VAL) <VAR'IND=VAL>

*/
	.nolist

#ifdef __AVR__
#include "struct_asm_avr.S"
#elif __MSP430__
#include "struct_asm_msp430.S"
#elif __x86_64__
#include "struct_asm_x86.S"
#elif __m68k__
#include "struct_asm_m68k.S"
#endif
	
.altmacro

;;; We try to make use of the gnu assembler's "local labels.
;;; So an "if" statement ends up like:
;;; brnCC 0f
;;;  if code
;;; rjmp 1f  ; else
;;; 0:
;;;  else code
;;; 0:
;;; 1:	     ; endif
;;;
;;; When there is no else clause, this simplifies to:
;;; brnCC 0f
;;;  if code
;;; 0:     ; endif
;;; 1:
;;;
;;; Because the local lables can be redefined, and the Nf form use as a jump
;;;  target jumps to the nearest label N, the start of the else and the endif
;;;  can both define the same target label.
;;; But we still need some symbol munging magic to handle nesting.
;;;  a counter  __ST_IFNEST is maintained, indicating the current nesting.
;;;  An "else" defines label __ST_IFNEST,
;;;   and an "endif" __ST_IFNEST and __ST_IFNEST+1
;;;  Another "if" adds two to __ST_IFNEST
;;; 
	
;;; _st_mkjmp generate a jump to one of our defined local labels.
.macro _st_mkjmp jmp, ind, dir, prefix=10
	\jmp \prefix\ind\dir
	.endm

;;; _st_label
;;; define a local label here (at "."), depending on the counter "ind",
;;;   and optional prefix
.macro _st_label ind, prefix=10
\prefix\ind:	
	.endm

.macro _if cond
	.set __ST_IFNEST, __ST_IFNEST+2
	_st_mkjmp _st_jmp_not_\cond, %__ST_IFNEST, f
	.endm

.macro _endif
	_st_label %__ST_IFNEST
	_st_label %__ST_IFNEST+1
	.set __ST_IFNEST, __ST_IFNEST-2
	.endm

.macro _else
	_st_mkjmp _st_jmp_always, %__ST_IFNEST+1, f
	_st_label %__ST_IFNEST
	.endm
	
;;; elseif is annoying, because we want to jump around the clause
;;; (from the successful if clause immediately preceeding) before
;;; doing the test for the new condition.
.macro _elseif ins, cond
	_st_mkjmp _st_jmp_always, %__ST_IFNEST+1, f
	_st_label %__ST_IFNEST
	ins
	_st_mkjmp _st_jmp_not_\cond, %__ST_IFNEST, f
	.endm


;;; Looping macros.  "until cc" will generate a jmp_not_cc backward,
;;; and "while cc" will generate a jmp_cc backward.
.macro _do
	.set __ST_LPNEST, __ST_LPNEST+1
	_st_label %__ST_LPNEST, 20
	.endm
	
.macro _until cond
	_st_mkjmp _st_jmp_not_\cond, %__ST_LPNEST, b, 20
	.set __ST_LPNEST, __ST_LPNEST-1
	.endm

.macro _while cond
	_st_mkjmp _st_jmp_\cond, %__ST_LPNEST, b, 20
	.set __ST_LPNEST, __ST_LPNEST-1
	.endm

;;; Nesting level initialization
	.set __ST_IFNEST, -2
	.set __ST_LPNEST, -1
.list
