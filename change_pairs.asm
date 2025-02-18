	.globl main
	.data
prompt: .asciz "Please enter string:\n"
result: .asciz "Result\n"
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
	li t1, '0'
	li t2, '9'
	la t3, buf

loop:
	lb t4, (t0)
	beqz t4, end
	blt t4, t1, skip
	bgt t4, t2, skip
	mv t3, t0 # t3 ma teraz t¹ sam¹ wartoœæ co t0 i idziemy szukac
	b search_for_pair

skip:
	addi t0, t0, 1
	b loop

search_for_pair:
	addi t3, t3, 1
	lb t5, (t3)
	beqz t5, end
	blt t5, t1, search_for_pair
	bgt t5, t2, search_for_pair
	b swap

swap:
	sb t4, (t3)
	sb t5, (t0)
	mv t0, t3
	addi t0, t0, 1
	b loop

end:
	li a7, 4
	la a0, result
	ecall
	li a7, 4
	la a0, buf
	ecall
	li a7, 10
	ecall