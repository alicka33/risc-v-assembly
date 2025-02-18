	.globl main
	.data
prompt: .asciz "Please enter a string:\n"
result: .asciz "Result:\n"
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
	li t1, '+'
	li t2, '*'
	li t3, 'a'
	li t4, 'z'
	li t5, 'A'
	sub t6, t3, t5 # how much you have to subtract from lower case to get upper
	li s1, 0 # number of + in str
	li s2, 2 # to check if even or odd number
	li s5, 4
	li s6, -1 # lenght of whole string
	li s7, 0 # index counter
	li s8, 3

count_plus:
	lb s3, (t0)
	beqz s3, odd_or_even
	addi s6, s6, 1
	addi t0, t0, 1
	beq s3, t1, add_plus
	b count_plus

add_plus:
	addi s1, s1, 1
	b count_plus

odd_or_even:
	rem s4, s1, s2
	sub t0, t0, s6
	addi t0, t0, -1
	beqz s4, even
	b odd

even:
	lb s3, (t0)
	beqz s3, end
	rem s4, s7, s5 # modulo 4
	beq s4, s8, replace_upper
	b store_even

replace_upper:
	blt s3, t3, store_even 
	bgt s3, t4, store_even # if they not a small letter
	sub s3, s3, t6
	b store_even

store_even:
	sb s3, (t0)
	addi s7, s7, 1
	addi t0, t0, 1
	b even
	
odd:
	lb s3, (t0)
	beqz s3, end
	rem s4, s7, s5 # modulo 4
	beq s4, s8, replace_star
	b store_odd

replace_star:
	mv s3, t2
	b store_odd

store_odd:
	sb s3, (t0)
	addi s7, s7, 1
	addi t0, t0, 1
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
	
	







