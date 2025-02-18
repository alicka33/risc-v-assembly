	.globl main
	.data
prompt: .asciz "Please enter string:\n"
result: .asciz "Result:\n"
buf:	.space 100
num:	.space 100
rev_num:.space 100
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
	la t1, num
	la t2, rev_num
	la t4, buf
	li s1, '0'
	li s2, '9'
	# li s3, 0 # lenght of number string

find_numbers:
	lb t5, (t0)
	beqz t5, reverse_numbers
	blt t5, s1, skip
	bgt t5, s2, skip
	sb t5, (t1)
	addi t0, t0, 1
	addi t1, t1, 1
	addi s3, s3, 1
	b find_numbers

skip:
	addi t0, t0, 1
	b find_numbers

reverse_numbers:
	addi t1, t1, -1
reverse_loop:
	lb t5, (t1)
	beqz t5, store_buf # zobaczymy czy to wyjdzie czy jednak d³ugoœc
	sb t5, (t2)
	addi t2, t2, 1
	addi t1, t1, -1
	b reverse_loop
	
store_buf:
	sub t2, t2, s3 # tutaj indeksy

store_loop:
	lb t5, (t4)
	beqz t5, end
	blt t5, s1, skip_store
	bgt t5, s2, skip_store
	lb t6, (t2)
	sb t6, (t4)
	addi t2, t2, 1
	addi t4, t4, 1
	b store_loop

skip_store:
	addi t4, t4, 1
	b store_loop
	
end:
	li a7, 4
	la a0, result
	ecall
	li a7, 4
	la a0, buf
	ecall
	li a7, 10
	ecall
