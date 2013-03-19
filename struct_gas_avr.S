;;; Structured asm macros for gnu assembler

/*
 * This section contains cpu-specific definitions that are dependent on the
 * particular format of the conditional and unconditional branch instructions
 * for the CPU.  Change this part for other architectures!
 */


/*  This is support for the
 *         ------------------------
 *         |     Atmel AVR        |
 *         ------------------------
 */

.macro _st_jmp_always target, dir
	rjmp \target\dir
	.endm

/*
 * define all of our conditional branches, "true" logic
 */
.irp cond, eq, ne, cs, cc, sh, lo, mi, pl, ge, lt, hs, hc, ts, tc, vs, vc, ie, id
	.macro _st_jmp_\cond target
	  br\cond target
	.endm
.endr
	
/*
 * Additional positive logic branches
 */
.macro _st_jmp_z target
	breq target
	.endm

.macro _st_jmp_e target
	breq target
	.endm
	
.macro _st_jmp_nz target
	brne target
	.endm

/*
 * for each possible branch condition "x", create a macro _st_jmp_not_x
 * that does a jump for "NOT x".
 */
.macro _st_jmp_not_z target, dir
	brne \target\dir
	.endm
.macro _st_jmp_not_nz target, dir
	breq \target\dir
	.endm
.macro _st_jmp_not_e target, dir
	brne \target\dir
	.endm
.macro _st_jmp_not_n target, dir
	breq \target\dir
	.endm
.macro _st_jmp_not_eq target, dir
	brne \target\dir
	.endm
.macro _st_jmp_not_ne target, dir
	breq \target\dir
	.endm
.macro _st_jmp_not_cs target, dir
	brcc \target\dir
	.endm
.macro _st_jmp_not_cc target, dir
	brcs \target\dir
	.endm
.macro _st_jmp_not_sh target, dir
	brlo \target\dir
	.endm
.macro _st_jmp_not_lo target, dir
	brsh \target\dir
	.endm
.macro _st_jmp_not_mi target, dir
	brpl \target\dir
	.endm
.macro _st_jmp_not_pl target, dir
	brmi \target\dir
	.endm
.macro _st_jmp_not_ge target, dir
	brlt \target\dir
	.endm
.macro _st_jmp_not_lt target, dir
	brge \target\dir
	.endm
.macro _st_jmp_not_hs target, dir
	brhc \target\dir
	.endm
.macro _st_jmp_not_hc target, dir
	brhs \target\dir
	.endm
.macro _st_jmp_not_ts target, dir
	brtc \target\dir
	.endm
.macro _st_jmp_not_tc target, dir
	brts \target\dir
	.endm
.macro _st_jmp_not_vs target, dir
	brvc \target\dir
	.endm
.macro _st_jmp_not_vc target, dir
	brvs \target\dir
	.endm
.macro _st_jmp_not_ie target, dir
	brid \target\dir
	.endm
.macro _st_jmp_not_id target, dir
	brie \target\dir
	.endm

;;; allow _if skp after an instruction that might have skipped.
;;; this assembles to an unconditional jump
.macro	_st_jump_not_skp target, dir
	rjmp \target\dir
	.endm
/*
 * This is supposed to be the end of CPU-specific support.
 */
