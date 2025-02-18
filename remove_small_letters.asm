	.globl main
	.data
prompt: .asciz "Please enter string:\n"
result: .asciz "Result:\n"
lenght: .asciz "Lenght:\n"
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
	li t1, 'a'
	li t2, 'z'
	la t4, buf
	li t5, -1

loop:
	lb t3, (t0)
	beqz t3, end
	blt t3, t1, skip
	bgt t3, t2, skip
	addi t0, t0, 1
	b loop

skip:
	sb t3, (t4)
	addi t5, t5, 1
	addi t0, t0, 1
	addi t4, t4, 1
	b loop
end:
	sb zero, (t4)
	li a7, 4
	la a0, result
	ecall
	li a7, 4
	la a0, buf
	ecall
	li a7, 4
	la a0, lenght
	ecall
	li a7, 1
	mv a0, t5
	ecall
	li a7, 10
	ecall