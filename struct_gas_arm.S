/* ;;; Structured asm macros for gnu assembler */

/*
 * This section contains cpu-specific definitions that are dependent on the
 * particular format of the conditional and unconditional branch instructions
 * for the CPU.  Change this part for other architectures!
 */


/*  This is support for the
 *         ------------------------
 *         |     ARM Cortex       |
 *         ------------------------
 */

.macro _st_jmp_always target, dir
	b.n \target\dir
	.endm

/*
 * define all of our conditional branches, "true" logic
 * EQual, NotEqual, CarrySet, HigherorSame, CarryClear, LOwer, MInus, PLus,
 * HIgher, LowerorSame, GreaterorEqual, LessThan, GreaterThan, LessorEqual,
 * Overflow, NoOverflow
 */
.irp cond, eq, ne, cs, hs,  cc, lo,  mi, pl, hi, ls, ge, lt, gt, le, vs, vc
	.macro _st_jmp_\cond target
	  b\cond\().n \target
	.endm
.endr
	
/*
 * Additional positive logic branches
 * (Zero, Equal, NotZero)
 */
.macro _st_jmp_z target
	beq.n \target
	.endm

.macro _st_jmp_e target
	beq.n \target
	.endm
	
.macro _st_jmp_nz target
	bne.n \target
	.endm

/*
 * for each possible branch condition "x", create a macro _st_jmp_not_x
 * that does a jump for "NOT x".
 */
.macro _st_jmp_not_z target, dir
	bne.n \target\dir
	.endm
.macro _st_jmp_not_nz target, dir
	beq.n \target\dir
	.endm
.macro _st_jmp_not_e target, dir
	bne.n \target\dir
	.endm
.macro _st_jmp_not_eq target, dir
	bne.n \target\dir
	.endm
.macro _st_jmp_not_ne target, dir
	beq.n \target\dir
	.endm
.macro _st_jmp_not_cs target, dir
	bcc.n \target\dir
	.endm
.macro _st_jmp_not_cc target, dir
	bcs.n \target\dir
	.endm
.macro _st_jmp_not_hs target, dir
	blo.n \target\dir
	.endm
.macro _st_jmp_not_lo target, dir
	bhs.n \target\dir
	.endm
.macro _st_jmp_not_mi target, dir
	bpl.n \target\dir
	.endm
.macro _st_jmp_not_pl target, dir
	bmi.n \target\dir
	.endm
.macro _st_jmp_not_ge target, dir
	blt.n \target\dir
	.endm
.macro _st_jmp_not_lt target, dir
	bge.n \target\dir
	.endm
.macro _st_jmp_not_vs target, dir
	bvc.n \target\dir
	.endm
.macro _st_jmp_not_vc target, dir
	bvs.n \target\dir
	.endm

/*
 * ;;; allow _if skp after an instruction that might have skipped.
 * ;;; this assembles to an unconditional jump
 */
.macro	_st_jump_not_skp target, dir
	b.n \target\dir
	.endm
/*
 * This is supposed to be the end of CPU-specific support.
 */
