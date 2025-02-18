	.globl main
	.data
prompt: .asciz "Please enter string:\n"
result: .asciz "Result\n"
buf:	.space 100
	.text

# wska¿nik czy mamy cyfry lub '.'
# je¿eli znajdziemy inny znak wska¿nik zerowany w przeciwnym wypadku = 1

main:
	li a7, 4
	la a0, prompt
	ecall
	li a7, 8
	la a0, buf
	li a1, 100
	ecall
	la t0, buf
	li t1, '0'
	li t2, '9'
	li t3, 0 # current number
	li t4, 0 # sum number
	li t5, 10 # moves

find_number:
	lb t6, (t0)
	beqz t6, end
	addi t0, t0, 1
	blt t6, t1, skip
	bgt t6, t2, skip
	mul t3, t3, t5
	sub t6, t6, t1
	add t3, t3, t6
	b find_number

skip:
	add t4, t4, t3
	li t3, 0
	b find_number

end:
	li a7, 4
	la a0, result
	ecall
	li a7, 1
	mv a0, t4
	ecall
	li a7, 10
	ecall