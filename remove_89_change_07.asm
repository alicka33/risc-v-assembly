	.globl main
	.data
prompt: .asciz "Please enter string:\n"
result: .asciz "Result\n"
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
	li t2, '7'
	li t3, '8'
	li t4, '9'
	la t5, buf

search_numbers:	
	lb t6, (t0)
	beqz t6, end
	blt t6, t1, store # not number
	bgt t6, t4, store # not number
	beq t6, t3, skip # if 8
	beq t6, t4, skip # if 9
	b fill_to_7

store:
	sb t6, (t5)
	addi t0, t0, 1
	addi t5, t5, 1
	b search_numbers

skip:
	addi t0, t0, 1
	b search_numbers

fill_to_7:
	sub t6, t2, t6
	add t6, t6, t1
	b store

end:
	sb zero, (t5)
	li a7, 4
	la a0, result
	ecall
	li a7, 4
	la a0, buf
	ecall
	li a7, 10
	ecall