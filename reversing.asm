	.globl main
	.data
prompt: .asciz "Please enter string:\n"
result: .asciz "Result:\n"
len:	.asciz "\nLenght:\n"
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
	li t2, 0 #lenght 
	
find_end_str:
	lb t3, (t0)
	beqz t3, lenght
	addi t2, t2, 1
	addi t0, t0, 1
	b find_end_str

lenght:
	addi t2, t2, -1
	addi t0, t0, -2
	mv t4, t2 # stores lenght for iteration in commming loop
reverse:
	beqz t4, end
	lb t3, (t0)
	sb t3, (t1)
	addi t0, t0, -1
	addi t1, t1, 1
	addi t4, t4, -1
	b reverse

end:
	li a7, 4
	la a0, result
	ecall
	li a7, 4
	la a0, ans
	ecall
	li a7, 4
	la a0, len
	ecall
	li a7, 1
	mv a0, t2
	ecall
	li a7, 10
	ecall
