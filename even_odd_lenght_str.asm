	.globl main
	.data
prompt:	.asciz "Please enter a string:\n"
result:	.asciz "Result:\n"
buf:	.space 100
	.text

main:
	li a7, 4
	la a0, prompt
	ecall
	li a7, 8
	la a0, buf
	li a1, 100
	ecall
	la t0, buf
	li t1, -1 # lenght
	li t2, '*'
	li t6, 2 # deividing by 2 gives us the information if even or odd
	li s1, 3 # every third char will be changed

lenght:
	lb t3, (t0)
	beqz t3, change_str
	addi t1, t1, 1
	addi t0, t0, 1
	b lenght

change_str:
	rem t4, t1, t6 # t4 holds modulo lenght%2
	sub t0, t0, t1
	addi t0, t0, -1
	li t5, 0 # counter
	beqz t4, even
	b odd

even:
	lb t3, (t0)
	beq t5, t1, end
	rem t4, t5, s1
	beq t4, t6, next_ascii
	sb t3, (t0)
	addi t5, t5, 1
	addi t0, t0, 1
	b even

next_ascii:
	addi t3, t3, 1
	sb t3, (t0)
	addi t0, t0, 1
	addi t5, t5, 1
	b even
	
odd:
	lb t3, (t0)
	beq t5, t1, end
	rem t4, t5, s1
	beq t4, t6, change_star
	sb t3, (t0)
	addi t5, t5, 1
	addi t0, t0, 1
	b odd

change_star:
	sb t2, (t0)
	addi t0, t0, 1
	addi t5, t5, 1
	b odd

end:
	li a7, 4
	la a0, result
	ecall
	li a7, 4
	la a0, buf
	ecall
	li a7, 10
	ecall
	