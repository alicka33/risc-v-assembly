	.globl main
	.data
prompt: .asciz "Please enter a string:\n"
prompt2:.asciz "Please enter symbols to delete\n"
res:	.asciz "Result:\n"
buf:	.space 100
buf2: 	.space 100
	.text

main:
	li a7, 4
	la a0, prompt
	ecall
	li a7, 8
	la a0, buf
	li a1, 100
	ecall
	li a7, 4
	la a0, prompt2
	ecall
	li a7, 8
	la a0, buf2
	li a1, 100
	ecall
	la t0, buf
	la t1, buf

loop1:
	lb t3, (t0)
	la t2, buf2
	beqz t3, end

loop2:
	lb t4, (t2)
	beqz t4, end_loop2
	beq t3, t4, skip
	addi t2, t2, 1
	b loop2
skip: 
	addi t0, t0, 1
	b loop1

end_loop2:
	sb t3, (t1)
	addi t1, t1, 1
	addi t0, t0, 1
	b loop1
	
end:
	li s1, 0
	sb s1, (t1) # BARDZO WA¯NY ELEMENT - dodanie na koñcu 0 spowoduje zakoñczeie str 
	li a7, 4
	la a0, res
	ecall
	li a7, 4
	la a0, buf
	ecall
	li a7, 10
	ecall