.include "struct_gas_arm.S"	
.include "struct_gas.S"	
/*	_struct_init */
	
main:

IFTEST:	cmp r0, #'I'
	_if e
	   bl dummyfunc
	   mov r2, r0
	_endif

IFELSETEST:	cmp r0, #'E'
	_if e
	   bl dummyfunc
	   add r0, r1
	_else
	   mov r0, #'X'
	_endif

NESTIFTEST:		
	cmp r0, 12
	_if e
	  mov r0, #5
	  cmp r1, #13
	  _if cs
	    eor r2, r2
	  _else
	    add r2, r2
	  _endif
	  mov r4, #123
	_endif
	
	adds r0, r4
	_if eq
	   add  r2,#1
	_else
	   add  r2,#2
	_endif

IFELSEIFTEST:
	cpi r2, #'a'
	_if e
	   mov r3,#'A'
	_elseif <cpi r27, 'b'>, e
	   mov r3,#'B'
	_elseif <cpi r27, 'c'>, e
	   mov r3,#'C'
	_elseif <cpi r27, 'd'>, e
	   mov r3,#'D'
	_else
	   lr dummyfunc
	_endif

DELAYTEST:
	mov r2, #100
	_do
	  sub r4, r4
	  _do
	    nop
	    nop
	    subs r4, #1
	    _while nz
	  subs r2, #1
	  _while nz
	ret

LOOPWBREAKTEST:
	sub r1, r1
	_do
	  ldr r2, [r1] #1
	  ands r2, r2
	  _break e
	  add r1, #1
	  _while always
	ret


;;; string length
;;; pointer entry in X, output in r10
strlen: clr r2
        _do			;Start of loop
	  _do
	    subs r1, #1		;delay
	  _while ne
          ld r3, [r2] #1
          ands r17, r17		;check for end of string
	_until z
        ret

.if 0
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
#endif

dummyfunc:	bx lr

 
.end
