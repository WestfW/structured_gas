/* struct_gas.S
 * Feb 2013 by Bill Westfield (westfw@westfw.info)
 * Structured Assembly macros for the Gnu assembler.
 * These permit the use of conditionals ( _if _else _elseif _endif)
 * and looping (_do _break _while _until) without the use of explicit labels.
 */

#ifdef __AVR__
#include "struct_gas_avr.S"
#elif __MSP430__
#include "struct_gas_msp430.S"
#elif __x86_64__
#include "struct_gas_x86.S"
#elif __m68k__
#include "struct_gas_m68k.S"
#elif __aarch64__
#include "struct_gas_aarch64.S"
#else
#error No recognized Architecture for struct_gas.S
#endif
	
.altmacro

/*	
;;; We try to make use of the gnu assembler's "local labels.
;;; So an "if" statement ends up like:
;;; brnCC 0f
;;;  if code
;;; rjmp 1f  ; else
;;; 100:
;;;  else code
;;; 100:
;;; 101:	     ; endif
;;;
;;; When there is no else clause, this simplifies to:
;;; brnCC 0f
;;;  if code
;;; 100:     ; endif
;;; 101:
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
*/	
	
/* _st_mkjmp generate a jump to one of our defined local labels. */
.macro _st_mkjmp jmp, ind, dir, prefix=10
	\jmp \prefix\ind\dir
	.endm

/*	
;;; _st_label
;;; define a local label here (at "."), depending on the counter "ind",
;;;   and optional prefix
*/
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
	
/*	
;;; elseif is annoying, because we want to jump around the clause
;;; (from the successful if clause immediately preceeding) before
;;; doing the test for the new condition.
*/
.macro _elseif ins, cond
	_st_mkjmp _st_jmp_always, %__ST_IFNEST+1, f
	_st_label %__ST_IFNEST
	\ins
	_st_mkjmp _st_jmp_not_\cond, %__ST_IFNEST, f
	.endm


/*
;;; Looping macros.  "until cc" will generate a jmp_not_cc backward,
;;; and "while cc" will generate a jmp_cc backward.
*/
.macro _do
	.set __ST_LPNEST, __ST_LPNEST+2
	_st_label %__ST_LPNEST, 20
	.endm
	
.macro _until cond
	_st_mkjmp _st_jmp_not_\cond, %__ST_LPNEST, b, 20
	_st_label %__ST_LPNEST+1, 20
	.set __ST_LPNEST, __ST_LPNEST-2
	.endm

.macro _while cond
	_st_mkjmp _st_jmp_\cond, %__ST_LPNEST, b, 20
	_st_label %__ST_LPNEST+1, 20
	.set __ST_LPNEST, __ST_LPNEST-2
	.endm

.macro _break cond=always
	_st_mkjmp _st_jmp_\cond, %(__ST_LPNEST+1), f, 20
	.endm

/* Nesting level initialization */
	.set __ST_IFNEST, -2
	.set __ST_LPNEST, -2
