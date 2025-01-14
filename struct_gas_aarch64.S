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
	b \target\dir
	.endm

/*
 * define all of our conditional branches, "true" logic
 * EQual, NotEqual, CarrySet, HigherorSame, CarryClear, LOwer, MInus, PLus,
 * HIgher, LowerorSame, GreaterorEqual, LessThan, GreaterThan, LessorEqual,
 * Overflow, NoOverflow
 */
.irp cond, eq, ne, cs, hs,  cc, lo,  mi, pl, hi, ls, ge, lt, gt, le, vs, vc
	.macro _st_jmp_\cond target
	  b.\cond\() \target
	.endm
.endr
	
/*
 * Additional positive logic branches
 * (Zero, Equal, NotZero)
 */
.macro _st_jmp_z target
	b.eq \target
	.endm

.macro _st_jmp_e target
	b.eq \target
	.endm
	
.macro _st_jmp_nz target
	b.ne \target
	.endm

/*
 * for each possible branch condition "x", create a macro _st_jmp_not_x
 * that does a jump for "NOT x".
 */
.macro _st_jmp_not_z target, dir
	b.ne \target\dir
	.endm
.macro _st_jmp_not_nz target, dir
	b.eq \target\dir
	.endm
.macro _st_jmp_not_e target, dir
	b.ne \target\dir
	.endm
.macro _st_jmp_not_eq target, dir
	b.ne \target\dir
	.endm
.macro _st_jmp_not_ne target, dir
	b.eq \target\dir
	.endm
.macro _st_jmp_not_cs target, dir
	b.cc \target\dir
	.endm
.macro _st_jmp_not_cc target, dir
	b.cs \target\dir
	.endm
.macro _st_jmp_not_hs target, dir
	b.lo \target\dir
	.endm
.macro _st_jmp_not_lo target, dir
	b.hs \target\dir
	.endm
.macro _st_jmp_not_mi target, dir
	b.pl \target\dir
	.endm
.macro _st_jmp_not_pl target, dir
	b.mi \target\dir
	.endm
.macro _st_jmp_not_ge target, dir
	b.lt \target\dir
	.endm
.macro _st_jmp_not_lt target, dir
	b.ge \target\dir
	.endm
.macro _st_jmp_not_gt target, dir
	b.le \target\dir
	.endm
.macro _st_jmp_not_le target, dir
	b.gt \target\dir
	.endm
.macro _st_jmp_not_vs target, dir
	b.vc \target\dir
	.endm
.macro _st_jmp_not_vc target, dir
	b.vs \target\dir
	.endm
.macro _st_jmp_not_hi target, dir
	b.ls \target\dir
	.endm
.macro _st_jmp_not_ls target, dir
	b.hi \target\dir
	.endm

/*
 * ;;; allow _if skp after an instruction that might have skipped.
 * ;;; this assembles to an unconditional jump
 */
.macro	_st_jump_not_skp target, dir
	b \target\dir
	.endm
/*
 * This is supposed to be the end of CPU-specific support.
 */
