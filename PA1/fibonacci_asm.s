	.option nopic
	.attribute arch, "rv64i2p0_m2p0_a2p0_f2p0_d2p0_c2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	1
	.globl	fibonacci
	.type	fibonacci, @function
fibonacci:
	#------Your code starts here------
	addi sp, sp, -40
	sd x5, 32(sp)
	sd x6, 24(sp)
	sd x7, 16(sp)
	sd x28, 8(sp)
	sd a0, 0(sp)
	addi x5, x0, 1
	sd x5, 0(a0)
	add x7, x5, x5
	blt a1, x7, exit
	addi a0, a0, 8
	sd x5, 0(a0)
	addi a0, a0, -8
loop:
	bge x7, a1, exit
	ld x5, 0(a0)
	addi a0, a0, 8
	ld x6, 0(a0)
	addi a0, a0, 8
	add x28, x5, x6
	sd x28, 0(a0)
	addi a0, a0, -8
	addi x7, x7, 1
	beq x0, x0, loop
exit:
	ld a0, 0(sp)
	ld x28, 8(sp)
	ld x7, 16(sp)
	ld x6, 24(sp)
	ld x5, 32(sp)
	addi sp, sp, 40
	jalr x0, 0(x1)
	#Load return value to reg a0
	#------Your code ends here------

	#Ret
	jr	ra
	.size	fibonacci, .-fibonacci
	.ident	"GCC: (GNU) 9.2.0"
