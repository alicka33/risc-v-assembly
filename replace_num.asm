	.globl main
	.data
prompt: .asciz "Please enter string:\n"
ans_str: .asciz "Result string:\n"
num_rep: .asciz "Number of replacements:\n"
buf:    .space 100
num:	.space 100
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
	li t3, '*'
	li t5, 0 #iloœæ wykonanych zmian
	li t5, 0
	la t6, num

loop:
	lb t4, (t0)
	beqz t4, end
	blt t4, t1, skip
	bgt t4, t2, skip
	sb t3, (t0)
	addi t5, t5, 1
	addi t0, t0, 1
	b loop

skip:
	sb t4, (t0)
	addi t0, t0, 1
	b loop
	
end:
	sb t5, num, t6
	li a7, 4
	la a0, ans_str
	ecall
	li a7, 4
	la a0, buf
	ecall
	li a7, 4
	la a0, num_rep
	ecall
	li a7, 1
	mv a0, t5
	ecall
	li a7, 10
	ecall
