	.globl main
	.data
prompt: .asciz "Please enter a string:\n"
buf:    .space 100
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
	li t2, 0
	la t4, buf
	li s1, 'A'
	li s2, 'Z'
	
loop:
	lb t1, (t0)
	beqz t1, end
	blt t1, s1, add_to
	bgt t1, s2, add_to
	beqz t2, add_fir  #tylko jesli pierwsza litera
	addi t0, t0, 1
	b loop
	
add_to:
	sb t1, (t4)
	addi t0, t0, 1
	addi t4, t4, 1
	b loop

add_fir:
	sb t1, (t4)
	addi t0, t0, 1
	addi t4, t4, 1
	addi t2, t2, 1
	b loop

end:
	sb zero, (t4)
	li a7, 4
	la a0, buf
	ecall
	li a7, 10
	ecall
