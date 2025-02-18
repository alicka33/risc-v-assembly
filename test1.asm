	.globl remove
	.data
input:	.asciz "Il ][ barbiere ][ di Siviglia"
result:	.asciz "Lenght of final word:\n"
	.text

main:
	la a0, input
	jal remove
	
	mv t1, a0
	li a7, 4
	la a0, result
	ecall
	li a7, 1
	mv a0, t1
	ecall
	li a7, 10
	ecall

remove:
	mv t0, a0
	li t1, 0 	# lenght of final word
	li t2, '['
	li t3, ']'
	mv t4, a0

find_open:
	lb t5, (t0)
	addi t0, t0, 1
	beq t5, t2, find_close
	beqz t5, correct_output
	b find_open
	
find_close:
	lb t5, (t0)
	addi t0, t0, 1
	beq t5, t3, correct_output
	beqz t5, correct_output
	sb t5, (t4)
	addi t4, t4, 1
	addi t1, t1, 1
	b find_close

correct_output:
	sb zero, (t4)

end:
	mv a0, t1
	jr ra
