	.globl main
	.data
in:     .asciz "Enter string:\n"
out:    .asciz "\nThe result:\n"
buf:	.space 100
	.text

main:
	li a7, 4
	la a0, in #send string to stdout
	ecall
	li a7, 8 #read string from stdin
	la a0, buf #load byte space into addr
	li a1, 100 #create byte space for string
	# zmienna trafia do bufora
	# stworzyliœmy miejsce na 100 bajtów (100 znaków)  1char - 1bajt -> 8 bitów czyli lizba zapisana w kodzie ascii
	ecall
	la t0, buf
	# to co wpisaliœmy do bufora umieszczamy teraz w rejestrze t0 i na nim bêdziemy operowaæ
	li t1, 'a'
	li t2, 'z'
	li t3, 0x20

loop:
	lb t4, (t0)
	beqz t4, end
	blt t4, t1, skip
	bgt t4, t2, skip
	sub t4, t4, t3
	sb t4, (t0) # wartoœæ t4 jest zapisywana do (t0) (dzia³a jakby odwrotnie)
skip:
	addi t0, t0, 1
	b loop
end:
	li a7, 4
	la a0, out
	ecall
	li a7, 4
	la a0, buf
	# dlaczego zwaracmy bufor? czy on siê zmienia razem z nasz¹ zmienn¹ t0?
	ecall
	li a7, 10 #kill program 
	ecall
	
