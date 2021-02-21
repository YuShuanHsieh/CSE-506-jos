/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>
#include <kern/macro.h>

#include <kern/picirq.h>


###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushq $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushq $0;							\
	pushq $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
   Find the PUSHA,POPA macros in kern/macro.h. Since amd64 doesn't support
   pusha,popa so you will find these macros handy.
 */

	TRAPHANDLER_NOEC(DIVIDE_F, T_DIVIDE)
	TRAPHANDLER_NOEC(DEBUG_F, T_DEBUG)
	TRAPHANDLER_NOEC(NMI_F, T_NMI)
	TRAPHANDLER_NOEC(BRKPT_F, T_BRKPT)
	TRAPHANDLER_NOEC(OFLOW_F, T_OFLOW)
	TRAPHANDLER_NOEC(BOUND_F, T_BOUND)
	TRAPHANDLER_NOEC(ILLOP_F, T_ILLOP)
	TRAPHANDLER_NOEC(DEVICE_F, T_DEVICE)
	TRAPHANDLER(DBLFLT_F, T_DBLFLT)
	TRAPHANDLER(TSS_F, T_TSS)
	TRAPHANDLER(SEGNP_F, T_SEGNP)
	TRAPHANDLER(STACK_F, T_STACK)
	TRAPHANDLER(GPFLT_F, T_GPFLT)
	TRAPHANDLER(PGFLT_F, T_PGFLT)
	TRAPHANDLER_NOEC(FPERR_F, T_FPERR)
	TRAPHANDLER(ALIGN_F, T_ALIGN)
	TRAPHANDLER_NOEC(MCHK_F, T_MCHK)
	TRAPHANDLER_NOEC(SIMDERR_F, T_SIMDERR)

	TRAPHANDLER_NOEC(SYSCALL_F, T_SYSCALL)
	TRAPHANDLER(DEFAULT_F, T_DEFAULT)

/*
 * Lab 3: Your code here for _alltraps
 *
 * Hint: Be sure to review the x64 calling convention from lab1
 *       for how to pass a pointer to the trapframe.
 */

_alltraps:
	sub $16,%rsp
	movw %ds,8(%rsp)
	movw %es,0(%rsp)
	PUSHA
	movq $GD_KD, %rax
	movq %rax, %es
	movq %rax, %ds
	movq %rsp, %rdi
	call trap
