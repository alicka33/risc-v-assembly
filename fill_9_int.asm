	.globl main
	.data
prompt: .asciz "Please enter a digit:\n"
error:  .asciz "Wrong input data!\n"
result:  .asciz "Result:\n"
	.text

main:
	li a7, 4
	la a0, prompt
	ecall
	li a7, 5
	ecall
	mv t0, a0 # t0 stores the given intiger
	li t1, 0
	li t2, 9

check_data:
	blt t0, t1, show_error
	bgt t0, t2, show_error
	b convert

show_error:
	li a7, 4
	la a0, error
	ecall
	li a7, 10
	ecall

convert:
	sub t0, t2, t0

end:
	li a7, 4
	la a0, result
	ecall
	li a7, 1
	mv a0, t0
	ecall
	li a7, 10
	ecall
	