	.globl main
	.data
prompt: .asciz "Please enter string:\n"
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
	li t3, 2
	li s1, 'A'
	sub t5, t1, s1 # tyle trzeba odj¹c ¿eby ma³¹ literê zamieniæ na du¿a
	li t6, 0 # licznik
	
loop:
	lb t4, (t0)
	beqz t4, end
	blt t4, t1, other
	bgt t4, t2, other
	beq t6, t3, change
	addi t6, t6, 1
	addi t0, t0, 1
	b loop

other:
	sb t4, (t0)
	addi t0, t0, 1
	b loop

change:
	sub t4, t4, t5
	sb t4, (t0)
	li t6, 0
	addi t0, t0, 1
	b loop
	
end:
	li a7, 4
	la a0, buf
	ecall
	li a7, 10
	ecall