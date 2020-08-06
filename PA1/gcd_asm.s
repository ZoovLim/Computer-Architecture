	.option nopic
	.attribute arch, "rv64i2p0_m2p0_a2p0_f2p0_d2p0_c2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text


	.align	1
	.globl	gcd
	.type	gcd, @function
gcd:
	#------Your code starts here------
	#LHS: a0, RHS: a1
	addi sp, sp, -24
	sd x5, 16(sp)
	sd x6, 8(sp)
	sd x7, 0(sp)
	add x5, a0, x0
	add x6, a1, x0
	bne x5, x6, loop
	add x10, x5, x0
	ld x7, 0(sp)
	ld x6, 8(sp)
	ld x5, 16(sp)
	addi sp, sp, 24
	jalr x0, 0(x1)
loop:
	beq x5, x6, exit
	bge x6, x5, else
	sub x5, x5, x6
	beq x0, x0, loop
else:
	add x7, x5, x0
	add x5, x6, x0
	add x6, x7, x0
	beq x0, x0, loop
exit:
	add x10, x5, x0
	ld x7, 0(sp)
	ld x6, 8(sp)
	ld x5, 16(sp)
	addi sp, sp, 24
	jalr x0, 0(x1)
	#Load return value to reg a0
	#------Your code ends here------

	#Ret
	jr	ra
	.size	gcd, .-gcd


	.ident	"GCC: (GNU) 9.2.0"
