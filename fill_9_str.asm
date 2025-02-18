	.globl main
	.data
prompt: .asciz "Enter a digit\n"
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
	li t1, '0'
	li t2, '9'

loop:
	lb t3, (t0)
	beqz t3, end
	blt t3, t1, skip
	bgt t3, t2, skip
	sub t3, t2, t3
	add t3, t3, t1
	sb t3, (t0)
	addi t0, t0, 1
	b loop
skip:
	addi t0, t0, 1
	b loop

end:
	li a7, 4
	la a0, buf 
	ecall
	li a7, 10
	ecall