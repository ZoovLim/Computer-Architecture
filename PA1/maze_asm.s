	.option nopic
	.attribute arch, "rv64i2p0_m2p0_a2p0_f2p0_d2p0_c2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text

	#------You can declare additional functions here
	.align	1
	.globl	your_funct
	.type	your_funct, @function
your_funct:
	addi sp, sp, -40
	sd a3, 32(sp)
	sd a4, 24(sp)
	sd a5, 16(sp)
	sd x31, 8(sp)
	sd x1, 0(sp)
	blt x28, x30, xpos
	addi a0, x0, -1
	beq x0, x0, exit
exit:
	ld x1, 0(sp)
	ld x31, 8(sp)
	ld a5, 16(sp)
	ld a4, 24(sp)
	ld a3, 32(sp)
	addi sp, sp, 40
	jalr x0, 0(x1)
xpos:
	bge x6, x0, ypos
	addi a0, x0, -1
	beq x0, x0, exit
ypos:
	bge x7, x0, width
	addi a0, x0, -1
	beq x0, x0, exit
width:
	blt x6, a1, height
	addi a0, x0, -1
	beq x0, x0, exit
height:
	blt x7, a2, dead_end
	addi a0, x0, -1
	beq x0, x0, exit
dead_end:
	mul a3, x7, a1
	add a3, a3, x6
	slli a3, a3, 3
	add x5, x5, a3
	ld x31, 0(x5)
	sub x5, x5, a3
	add a3, x0, x0
	beq x31, x0, success_x
	addi a0, x0, -1
	beq x0, x0, exit
success_x:
	addi x31, a1, -1
	bne x6, x31, min
	beq x0, x0, success_y
success_y:
	addi x31, a2, -1
	bne x7, x31, min
	add a0, x0, x28
	beq x0, x0, exit
min:
	addi x31, x0, -1
	add a4, x0, x29
	beq x0, x0, traverse_up
traverse_up:
	addi a3, x0, 3
	beq x29, a3, traverse_left
	addi x7, x7, -1
	addi x28, x28, 1
	add x29, x0, x0
	jal x1, your_funct
	add x31, x0, a0
	addi x7, x7, 1
	addi x28, x28, -1
	add x29, x0, a4
	beq x0, x0, traverse_left
traverse_left:
	addi a3, x0, 2
	beq x29, a3, traverse_right
	addi x6, x6, -1
	addi x28, x28, 1
	addi x29, x0, 1
	jal x1, your_funct
	add a5, x0, a0
	addi x6, x6, 1
	addi x28, x28, -1
	add x29, x0, a4
	blt a5, x0, traverse_right
	blt x31, x0, left_result
	blt a5, x31, left_result
	beq x0, x0, traverse_right
left_result:
	add x31, x0, a5
	beq x0, x0, traverse_right
traverse_right:
	addi a3, x0, 1
	beq x29, a3, traverse_down
	addi x6, x6, 1
	addi x28, x28, 1
	addi x29, x0, 2
	jal x1, your_funct
	add a5, x0, a0
	addi x6, x6, -1
	addi x28, x28, -1
	add x29, x0, a4
	blt a5, x0, traverse_down
	blt x31, x0, right_result
	blt a5, x31, right_result
right_result:
	add	x31, x0, a5
	beq x0, x0, traverse_down
traverse_down:
	addi a3, x0, 0
	beq x29, a3, min_exit
	addi x7, x7, 1
	addi x28, x28, 1
	addi x29, x0, 3
	jal x1, your_funct
	add a5, x0, a0
	addi x7, x7, -1
	addi x28, x28, -1
	add x29, x0, a4
	blt a5, x0, min_exit
	blt x31, x0, down_result
	blt a5, x31, down_result
	beq x0, x0, min_exit
down_result:
	add x31, x0, a5
	beq x0, x0, min_exit
min_exit:
	add a0, x0, x31
	ld x1, 0(sp)
	ld x31, 8(sp)
	ld a5, 16(sp)
	ld a4, 24(sp)
	ld a3, 32(sp)
	addi sp, sp, 40
	jalr x0, 0(x1)
	#Ret
	jr	ra
	.size	your_funct, .-your_funct
	#------Your code ends here



	.align	1
	.globl	solve_maze
	.type	solve_maze, @function
solve_maze:
	#------Your code starts here------
	#maze: a0, width: a1, height: a2		
	addi sp, sp, -56
	sd x1, 48(sp)
	sd x30, 40(sp)
	sd x29, 32(sp)
	sd x28, 24(sp)
	sd x7, 16(sp)
	sd x6, 8(sp)
	sd x5, 0(sp)
	add x5, x0, a0
	add x6, x0, x0
	add x7, x0, x0
	add x28, x0, x0
	addi x29, x0, 2
	addi x30, x0, 20
	jal x1, your_funct
	ld x5, 0(sp)
	ld x6, 8(sp)
	ld x7, 16(sp)
	ld x28, 24(sp)
	ld x29, 32(sp)
	ld x30, 40(sp)
	ld x1, 48(sp)
	addi sp, sp, 56
	jalr x0, 0(x1)
	#Load return value to reg a0
	#------Your code ends here------

	#Ret
	jr	ra
	.size	solve_maze, .-solve_maze


	.ident	"GCC: (GNU) 9.2.0"
