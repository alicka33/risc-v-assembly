	.globl remove
	.data
string:	.asciz "string"
	.text

# ³adujemy wynikowy do a0
main:
	la a0, string
	jal remove
	
	li a7, 1
	mv a0, t1 # tu wynik ma ponoæ odrazu ybæ zapisywany do a0
	ecall
	li a7, 10
	ecall

remove:
	la t0, string
	li t1, 0

lenght:
	lb t2, (t0)
	beqz t2, end
	addi t1, t1, 1
	addi t0, t0, 1
	b lenght

end:
	ret
	# jt ra

	