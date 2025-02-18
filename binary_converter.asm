	.globl main
	.data
file:	.asciz "xxtea.bin"
key:	.asciz "00000000000000000000000000000000111111111111111111111111111111110000000000000000000000000000000011111111111111111111111111111111"
result:	.asciz "result.bin"
error:  .asciz "The coded file is too short!"
mess:	.asciz "To code enter 0, to decode enter 1"
buffer: .space 1024 # na 32 bity (ale jak to tu opisaæ)
	.text
 
# ZMIANA NAZW REJESTRÓW!!!!!!!!!!!!
# funckja MX
# 4. dodanie unsigned 
# 5. ³adniejszy podzia³ na funkcje

########### okreœlenie sta³ych dla ca³ego programu #############
main:
	li s0, 0 
	li s4, 0x9e3779b9 # delta
	la s7, key
	li s11, 1 # 0 bêdzie oznacza³o kodowanie a 1 dekodowanie
	
	jal file_read
	b xxtea
	# jal xxtea


####### otworzenie, wczytanie danych i zamkniêcie pliku #######
file_read:
open_file_to_read:
	li   a7, 1024     # system call for open file
	la   a0, result     # output file name
	li   a1, 0        # Open for writing (flags are 0: read, 1: write)
	ecall             # open a file (file descriptor returned in a0)
	mv   s6, a0       # save the file descriptor

read_from_file:
	li   a7, 63       # system call for reading from file
	mv   a0, s6       # file descriptor
	la   a1, buffer   # address of buffer from which to write
	li   a2, 1024       # hardcoded buffer length
	ecall             # write to file 
	mv s5, a1

close_read_file:
	li   a7, 57       # system call for close file
	mv   a0, s6       # file descriptor to close
	ecall             # close file
	
	jr ra
###################################################################

###########  zapisanie danych z buffora do pliku #################
file_write:
open_file_to_write:
	li   a7, 1024     # system call for open file
	la   a0, result     # output file name
	li   a1, 1        # Open for writing (flags are 0: read, 1: write)
	ecall             # open a file (file descriptor returned in a0)
	mv   s6, a0       # save the file descriptor


write_file:
	li   a7, 64       # system call for reading from file
	mv   a0, s6       # file descriptor
	la   a1, buffer   # address of buffer from which to write
	li   a2, 1024     # hardcoded buffer length
	ecall             # write to file 

close_writing_file:
	li   a7, 57       # system call for close file
	mv   a0, s6       # file descriptor to close
	ecall             # close file
	
	jr ra
###################################################################

##### CALCULATIONS BEFORE STARTING XXTEA CODING OR DECODING #####
xxtea:
iterate_lenght:
	lb t0, (s5)
	beqz t0, check_lenght
	
	addi s0, s0, 1
	addi s5, s5, 1
	b iterate_lenght

check_lenght:
	li t0, 64
	blt s0, t0, show_error
	b calculate_lenght
	
show_error:
	li a7, 4
	la a0, error
	ecall

	li a7, 10
	ecall
	
calculate_lenght:
	li t0, 32
	mv t1, s0
	div s0, s0, t0

reset_buffor:
	sub s5, s5, t1

# cycles = 6+52/n
caluclate_cycles:
	li s6, 52
	div s6, s6, s0
	addi s6, s6, 6

choose_operation:
	beqz s11, coding
	b decoding

################ KODOWANIE ################################
coding:
set_coded_words:
	# jeden przed
	mv t0, t1
	addi t0, t0, -32 # ustalenie indeksu ostatniego bajtu
	mv t2, t0
	mv a3, s5
	jal convert
	mv s1, t1
	
	# kodowane
	li t2, 0  # offset
	mv a3, s5 # s5 trzyma buffor
	jal convert
	mv s2, t1 # w t1 jest wynik --> int
	
	#jeden po
	li t2, 32
	mv a3, s5
	jal convert
	mv s3, t1
	
	# indeks pocz¹tkowy obecnie kodowanego s³owa
	li s8, 0
	
# s0 --> n (iloœæ s³ów)	
# s1 --> jeden przed
# s2 --> kodowane s³owo
# s3 --> jeden po
# s4 --> delta
# s5 --> buffor 
# s6 --> iloœæ cykli 
# s7 --> key
# s8 --> indeks pocz¹tkowy obecnie kodowanego s³owa

prepere_for_cycle_iteration:
	li t3, 1 # t3 i --> iterator 

iterate_cycles:
	bgt t3, s6, coding_end # iterator equals number of cycles
	mul t4, t3, s4 # t4 --> sum
	srli t5, t4, 2  # t5 --> e // nwm czy tu napewno ma byc arytmetyczne
	
	addi t3, t3, 1 # zwiêkszenie iloœci cyklów 
	
	li t6, 0 # t6 --> r

# t3 --> iteartor i
# t4 --> sum
# t5 --> e
# t6 --> r

loop:
	beq t6, s0, iterate_cycles
	
	mv a5, s1 # z
	mv a6, s3 # y
	
	# ( ( z>>5^y<<2)+(y>>3^z <<4))^((sum^y )+( key [ ( r ^e )%4]^ z ) )
	# s9 wynik pierwszego nawiasu
	srli s9, a5, 5 # z >> 5
	xor s9, s9, a6 # z >> 5 ^ y
	slli s9, s9, 2 # z >> 5 ^ y << 2
	
	# s10 wynik drugiego nawiasu 
	srli s10, a6, 3 # y >> 3
	xor s10, s10, a5 # y >> 3 ^ z
	slli s10, s10, 4 # y >> 3 ^  << 4
	
	# dodanie dwóch pierwszych
	add s9, s9, s10
	
	# 3 nawias
	xor a4, t4, a6 # sum^y
	
	# s11 wynik 4 nawiasu dzia³aj¹cy na key
	# s11 na pocz¹tek indeks key
	xor s11, t6, t5 # r ^ e
	li s10, 4 # do zwolnionego rejestru s10 wk³adamy 4
	remu s11, s11, s10  # ( r ^e )%4
	
	# pobieramy wartoœæ z klucza o tym indeksie do s10
	li t0, 32
	mul s11, s11, t0 # przeliczenie offsetu jako wielokrotnoœci 8
	mv t2, s11 # wartoœæ offsetu
	mv a3, s7 # przszukiwany klucz
	jal convert
	mv s10, t1 # zapisanie wyniku do s10

	xor s11, s10, a5 # key [ ( r ^e )%4]^ z )
	
	# dodanie 3 i 4 nawiasu
	add s11, s11, a4
	
	# xor miedzy du¿ymi nawiasami
	xor s9, s9, s11
	
	# dodanie do kodowanego s³owa nawiasu koduj¹cego 
	add s2, s2, s9
	
	# nadpisanie buffora nowo zakodowanym s³owem 
	mv t1, s2
	mv t2, s8
	mv a3, s5
	jal deconvert
	mv s5, a3
	
	# przepisanie na nowo rejestu przed, kodz¹cego i po
	mv s1, s2
	mv s2, s3
	
	addi s8, s8, 32
	#addi s5, s5, -32 # powrócenie wska¿nikiem wykresu po deconvert
	sub s5, s5, s8 # powrócenie wska¿nikiem wykresu po deconvert
	

	# s8 mówi o indeksie kodowanego s³owa, a a4 czytanego s³owa
	addi a4, s8, 32
	# mv a4, s8
	slli a3, s0, 5
	remu a4, a4, a3 # wykroczenie poza zakres
	remu s8, s8, a3 # wykroczenie poza zakres
	
	# do s3 pobranie nastêpnego s³owa
	mv t2, a4
	mv a3, s5
	jal convert
	mv s3, t1
	
	addi t6, t6, 1
	b loop

##############################################################
################ DEKODOWANIE #################################
decoding:
set_coded_words_decoding:
	# jeden przed
	mv t0, t1
	addi t0, t0, -64 # ustalenie indeksu ostatniego bajtu
	mv t2, t0
	mv a3, s5
	jal convert
	mv s1, t1
	
	# kodowane
	slli t0, s0, 5 # d³ugoœæ razy 32
	addi t0, t0, -32
	# indeks pocz¹tkowy obecnie kodowanego s³owa
	mv s8, t0
	
	mv t2, t0  # offset
	mv a3, s5 # s5 trzyma buffor
	jal convert
	mv s2, t1 # w t1 jest wynik --> int
	
	#jeden po
	li t2, 0
	mv a3, s5
	jal convert
	mv s3, t1
	
# s0 --> n (iloœæ s³ów)	
# s1 --> jeden przed
# s2 --> kodowane s³owo
# s3 --> jeden po
# s4 --> delta
# s5 --> buffor 
# s6 --> iloœæ cykli 
# s7 --> key
# s8 --> indeks pocz¹tkowy obecnie kodowanego s³owa

prepere_for_cycle_iteration_decoding:
	mv t3, s6 # t3 i --> iterator 

iterate_cycles_decoding:
	beqz t3, coding_end # iterator equals number of cycles
	mul t4, t3, s4 # t4 --> sum
	srli t5, t4, 2  # t5 --> e // nwm czy tu napewno ma byc arytmetyczne
	
	addi t3, t3, -1 # zmniejszanie iloœci cyklów 
	
	mv t6, s0 # t6 --> r = n
	addi t6, t6, -1 # t6 --> r = n-1

# t3 --> iteartor i
# t4 --> sum
# t5 --> e
# t6 --> r

loop_decoding:
	bltz t6, iterate_cycles_decoding
	
	mv a5, s1 # z
	mv a6, s3 # y
	
	# ( ( z>>5^y<<2)+(y>>3^z <<4))^((sum^y )+( key [ ( r ^e )%4]^ z ) )
	# s9 wynik pierwszego nawiasu
	srli s9, a5, 5 # z >> 5
	xor s9, s9, a6 # z >> 5 ^ y
	slli s9, s9, 2 # z >> 5 ^ y << 2
	
	# s10 wynik drugiego nawiasu 
	srli s10, a6, 3 # y >> 3
	xor s10, s10, a5 # y >> 3 ^ z
	slli s10, s10, 4 # y >> 3 ^  << 4
	
	# dodanie dwóch pierwszych
	add s9, s9, s10
	
	# 3 nawias
	xor a4, t4, a6 # sum^y
	
	# s11 wynik 4 nawiasu dzia³aj¹cy na key
	# s11 na pocz¹tek indeks key
	xor s11, t6, t5 # r ^ e
	li s10, 4 # do zwolnionego rejestru s10 wk³adamy 4
	remu s11, s11, s10  # ( r ^e )%4
	
	# pobieramy wartoœæ z klucza o tym indeksie do s10
	li t0, 32
	mul s11, s11, t0 # przeliczenie offsetu jako wielokrotnoœci 8
	mv t2, s11 # wartoœæ offsetu
	mv a3, s7 # przszukiwany klucz
	jal convert
	mv s10, t1 # zapisanie wyniku do s10

	xor s11, s10, a5 # key [ ( r ^e )%4]^ z )
	
	# dodanie 3 i 4 nawiasu
	add s11, s11, a4
	
	# xor miedzy du¿ymi nawiasami
	xor s9, s9, s11
	
##########################################################

	# odjêcie od kodowanego s³owa nawiasu koduj¹cego 
	sub s2, s2, s9
	
	# nadpisanie buffora nowo zakodowanym s³owem 
	mv t1, s2
	mv t2, s8
	mv a3, s5
	jal deconvert
	mv s5, a3
	
	# przepisanie na nowo rejestu przed, kodz¹cego i po
	mv s3, s2
	mv s2, s1
	
	addi s8, s8, -32
	#addi s5, s5, -32 # powrócenie wska¿nikiem wykresu po deconvert
	sub s5, s5, s8 # powrócenie wska¿nikiem wykresu po deconvert       !!!!!!!!!!!!!!!!!!!!!!!
	addi s5, s5, -64

	# s8 mówi o indeksie kodowanego s³owa, a a4 czytanego s³owa
	addi a4, s8, -32
	# mv a4, s8
	slli a3, s0, 5

check_range:
	bltz a4, set_range_reading
	bltz s8, set_range_coding
	
	# do s3 pobranie nastêpnego s³owa
	mv t2, a4
	mv a3, s5
	jal convert
	mv s1, t1
	
	addi t6, t6, -1 # zmniejszenie iteratora
	b loop_decoding

set_range_reading:
	add a4, a3, a4
	b check_range
	
set_range_coding:
	add s8, a3, s8
	b check_range
###############################################################


############# END OF CODING / DECODING PROCESS ################
coding_end:
	jal file_write
	# jr ra
	li a7, 4
	la a0, buffer
	ecall
	
	li a7, 10
	ecall



############## konwertuje zapis 32 bitów na inta ##############
convert:
	li t1, 0 # suma --> int
	li a2, 31 # ilosæ przesuniêæ
	add a3, a3, t2 # dodawanie offsetu t2
	
binary_converter:
	lb t0, (a3)
	bltz a2, end_binary_converter
	
	addi t0, t0, -48
	sll t0, t0, a2
	add t1, t1, t0
	
	addi a2, a2, -1
	addi a3, a3, 1
	b binary_converter

end_binary_converter:
	jr ra # powrót do miesjca wywo³ania funkcji

#############################################################

############### dekonwertuje inta na 32 bity ################
deconvert:
	li a2, 31 # ilosæ przesuniêæ
	add a3, a3, t2 # dodawanie offsetu t2
	
binary_deconverter:
	bltz a2, end_binary_deconverter

	srl t0, t1, a2
	addi t0, t0, 48
	sb t0, (a3)
	addi t0, t0, -48
	
	# t1 - pow(2, t3)
	sll t0, t0, a2
	sub t1, t1, t0
	
	addi a2, a2, -1
	addi a3, a3, 1
	b binary_deconverter

end_binary_deconverter:
	jr ra # powrót do miesjca wywo³ania funkcji
############################################################
