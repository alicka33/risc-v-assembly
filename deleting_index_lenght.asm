	.globl main
	.data
p_str:	.asciz "Please enter a string:\n"
p_ind:  .asciz "Please enter the beginning index:\n"
p_len: .asciz "Please enter the lenght:\n"
error:	.asciz "Wrong input data!"
result:	.asciz "Result:\n"
buf:	.space 100
	.text
# ind and len have to be given as ints 

main:
	li a7, 4
	la a0, p_str
	ecall
	li a7, 8
	la a0, buf
	li a1, 100
	ecall
	la t0, buf
	
	li a7, 4
	la a0, p_ind
	ecall
	li a7, 5
	ecall
	mv t1, a0 # t1 index number 
	
	li a7, 4
	la a0, p_len
	ecall
	li a7, 5
	ecall
	mv t2, a0 # t2 lenght
	 
	li t4, -1 # lenght counter of str
	la t5, buf
	li t6, 0


count_real_lenght:
	lb t3, (t0)
	beqz t3, check_error
	addi t4, t4, 1
	addi t0, t0, 1
	b count_real_lenght

check_error:
	blt t1, t6, show_error
	bgt t1, t4, show_error
	blt t2, t6, show_error
	bgt t2, t4, show_error
	add t3, t1, t2
	bgt t3, t4, show_error

set_counter:
	sub t0, t0, t4
	addi t0, t0, -1

removing:
	lb t3, (t0)
	beqz t3, end
	beq t6, t1, skip
	sb t3, (t5)
	addi t6, t6, 1
	addi t5, t5, 1
	addi t0, t0, 1
	b removing
	
skip:
	beqz t2, removing
	addi t2, t2, -1
	addi t0, t0, 1
	addi t6, t6, 1
	b skip
	
show_error:
	li a7, 4
	la a0, error
	ecall
	li a7, 10
	ecall	

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
















	