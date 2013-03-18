#include <avr/io.h>
#include "struct_asm.S"	
/*	_struct_init */
	
main:	cli
IFTEST:	cpi r16, 'I'
	_if e
	   call dummyfunc
	   mov r2, r24
	   sei
	_endif

IFELSETEST:	cpi r16, 'E'
	_if e
	   call dummyfunc
	   lpm
	   cli
	_else
	  ldi r17, 'X'
	_endif

NESTIFTEST:		
	cpi r27, 12
	_if e
	  ldi r16, 5
	  cpi r27, 13
	  _if ts
	    eor r16, r16
	  _else
	    add r16, r20
	  _endif
	  ldi r17, 123
	_endif
	
	add r0, r16
	_if eq
	   adiw  r24, 1
	_else
	   adiw r26, 2
	_endif

IFELSEIFTEST:
	cpi r27, 'a'
	_if e
	   ldi r27,'A'
	_elseif <cpi r27, 'b'>, e
	   ldi r27, 'B'
	_elseif <cpi r27, 'c'>, e
	   ldi r27, 'C'
	_elseif <cpi r27, 'd'>, e
	   ldi r27, 'D'
	_endif

DELAYTEST:
	ldi r27, 100
	_do
	  ldi r28, 0
	  _do
	    nop
	    nop
	    dec r28
	    _while nz
	  dec r27
	  _while nz
	ret


;;; string length
;;; pointer entry in X, output in r10
strlen: clr r10
        _do			;Start of loop
	  _do
	    dec r16		;delay
	  _while ne
          ld r17, X+
          and r17, r17		;check for end of string
	_until z
        ret

	.equ xl, r26
	.equ yl, r28
strcmp: push r17
	push r18
0:	ld r17, x
	ld r18, y
	cp r17, r18
	breq 1f
	  adiw r26,1
	  adiw r28,1
	  rjmp 2f
1:	pop r18
	pop r17
	ret
1:
2:	rjmp 0b


dummyfunc:	ret
	
	 
.end
