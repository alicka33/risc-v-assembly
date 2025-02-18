	.globl main
	.data
prompt: .asciz "Plese enter a string\n"
result: .asciz "Result:\n"
buf:	.space 100
ans:	.space 100
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
	la t1, ans
	li t2, '0'
	li t3, '9'
	li t4, 0 # lenght
	li t5, 0 # max_len
	li t6, 0 # begining indeks of the temporary longest
	li s2, 0 # iterator
	li s3, 0 # # begining indeks of the longest
	li s4, 0 # counter
	li s5, 0 # second loop counter

loop:
	lb s2, (t0)
	beqz s2, find_array
	blt s2, t2, skip
	bgt s2, t3, skip
	addi t4, t4, 1
	bgt t4, t5, set_max
	addi t0, t0, 1
	addi s4, s4, 1
	b loop
	
skip:
	li t4, 0
	addi t0, t0, 1
	addi s4, s4, 1
	mv t6, s4
	b loop

set_max:
	mv t5, t4
	mv s3, t6
	addi t0, t0, 1
	addi s4, s4, 1
	b loop

find_array:
	la t0, buf
	li t6, 0

find_loop:
	lb s2, (t0)
	beq t6, s3, create_array
	addi t6, t6, 1
	addi t0, t0, 1
	b find_loop
	
create_array:
	lb s2, (t0)
	beq s5, t5, end
	sb s2, (t1)
	addi t1, t1, 1
	addi t0, t0, 1
	addi s5, s5, 1
	b create_array
	
end:
	li a7, 4
	la a0, result 
	ecall
	li a7, 4
	la a0, ans
	ecall
	li a7, 10
	ecall

