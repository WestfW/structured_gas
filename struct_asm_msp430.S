;;; Structured asm macros for gnu assembler

/*
 * This section contains cpu-specific definitions that are dependent on the
 * particular format of the conditional and unconditional branch instructions
 * for the CPU.  Change this part for other architectures!
 */


/*  This is support for the
 *         ------------------------
 *         |     TI MSP430        |
 *         ------------------------
 */

.macro _st_jmp_always target, dir
	jmp \target\dir
	.endm

/*
 * define all of our conditional branches, "true" logic
 */
.irp cond, eq, z, ne, nz, c, nc, n, ge, l
	.macro _st_jmp_\cond target
	  j\cond target
	.endm
.endr
	
	
/*
 * for each possible branch condition "x", create a macro _st_jmp_not_x
 * that does a jump for "NOT x".
 */
.irp cond, e, z, c
	.macro _st_jmp_not_\cond target
	  jn\cond target
	.endm
.endr

.macro _st_jmp_not_nz target, dir
	jeq \target\dir
	.endm
.macro _st_jmp_not_eq target, dir
	jne \target\dir
	.endm
.macro _st_jmp_not_z target, dir
	jne \target\dir
	.endm
.macro _st_jmp_not_ne target, dir
	jeq \target\dir
	.endm
.macro _st_jmp_not_c target, dir
	jnc \target\dir
	.endm
.macro _st_jmp_not_nc target, dir
	jc \target\dir
	.endm
.macro _st_jmp_not_n target, dir
	jge \target\dir
	.endm
.macro _st_jmp_not_ge target, dir
	jn \target\dir
	.endm
.macro _st_jmp_not_l target, dir
	jge \target\dir
	.endm

;;; allow _if skp after an instruction that might have skipped.
;;; this assembles to an unconditional jump
.macro	_st_jump_not_skp target, dir
	rjmp \target\dir
	.endm
/*
 * This is supposed to be the end of CPU-specific support.
 */
