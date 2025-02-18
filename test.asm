	.globl main
	.data
file:	.asciz "xxtea.bin"
key:	.asciz "00000000000000000000000000000000111111111111111111111111111111110000000000000000000000000000000011111111111111111111111111111111"
result:	.asciz "result.bin"
error:  .asciz "The coded file is too short!"
mess:	.asciz "To code enter 0, to decode enter 1"
buffer: .space 1024 # na 32 bity (ale jak to tu opisa�)
	.text
 
# funckja MX raczej ci�zko 
# 4. dodanie unsigned 
# 5. �adniejszy podzia� na funkcje

# s0 --> n (ilo�� s��w)	
# s1 --> s�owo przed kodowanym s�owem
# s2 --> kodowane s�owo
# s3 --> s�owo po kodowanym s�owie
# s4 --> delta
# s5 --> buffor 
# s6 --> ilo�� cykli 
# s7 --> klucz
# s8 --> indeks pocz�tkowy obecnie kodowanego s�owa
# s9 --> iteartor i
# s10 --> suma
# s11 --> e
# t6 --> r

########### okre�lenie sta�ych dla ca�ego programu #############
main:
	li s0, 0 
	li s4, 0x9e3779b9 # delta
	la s7, key # klucz
	li s11, 1 # 0 --> kodowanie, 1 --> dekodowanie
	
	jal file_read
	b xxtea

##### obliczenia przed rozpocz�ciem kodowania lub dekodowania #####
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

# cykle = 6+52/n
caluclate_cycles:
	li s6, 52
	div s6, s6, s0
	addi s6, s6, 6

choose_operation:
	beqz s11, coding
	b decoding

################### kodowanie #############################
coding:
set_coded_words:
	# s�owo przed kodowanym s�owem
	mv t0, t1
	addi t0, t0, -32 # ustalenie indeksu ostatniego bajtu
	mv t2, t0
	mv t4, s5
	jal convert
	mv s1, t1
	
	# kodowane s�owo
	li t2, 0  # offset
	mv t4, s5 # s5 trzyma buffor
	jal convert
	mv s2, t1 # w t1 jest wynik --> int
	
	# s�owo po kodowanym s�owie
	li t2, 32
	mv t4, s5
	jal convert
	mv s3, t1
	
	# indeks pocz�tkowy obecnie kodowanego s�owa
	li s8, 0
	
prepere_for_cycle_iteration:
	li s9, 1 # s9 i --> iterator 

iterate_cycles:
	bgt s9, s6, coding_end 
	mul s10, s9, s4 # s10 --> suma
	srli s11, s10, 2  # s11 --> e
	addi s9, s9, 1 
	li t6, 0 # t6 --> r

loop:
	beq t6, s0, iterate_cycles
	
	# (( z>>5^y<<2)+(y>>3^z <<4))^((sum^y )+( key [ ( r ^e )%4]^ z ))
	# t0 wynik pierwszego nawiasu
	srli t0, s1, 5 # z >> 5
	xor t0, t0, s3 # z >> 5 ^ y
	slli t0, t0, 2 # z >> 5 ^ y << 2
	
	# t1 wynik drugiego nawiasu 
	srli t1, s3, 3 # y >> 3
	xor t1, t1, s1 # y >> 3 ^ z
	slli t1, t1, 4 # y >> 3 ^  << 4
	
	# t5 wynik dodania dw�ch pierwszych
	add t5, t0, t1
	
	# a4 wynik trzeciego nawiasu
	xor a4, s10, s3 # sum^y
	
	# t4 wynik 4 nawiasu dzia�aj�cy na kluczu
	# t4 to na pocz�tku indeks klucza
	xor t4, t6, s11 # r ^ e
	li t0, 4 # do zwolnionego rejestru t0 wk�adamy 4
	remu t4, t4, t0  # ( r ^e )%4
	
	# pobieramy warto�� z klucza o tym indeksie do t1
	li t0, 32
	mul t4, t4, t0 # przeliczenie offsetu jako wielokrotno�ci 8
	mv t2, t4 # warto�� offsetu
	mv t4, s7 # przszukiwany klucz
	jal convert

	xor t4, t1, s1 # key [ ( r ^e )%4]^ z )
	
	# dodanie trzeciego i czwartego nawiasu
	add t4, t4, a4
	
	# xor miedzy du�ymi nawiasami (t4 i t5)
	xor t5, t5, t4
	
	# dodanie do kodowanego s�owa nawiasu koduj�cego t5
	add s2, s2, t5
	
	# nadpisanie buffora nowo zakodowanym s�owem 
	mv t1, s2
	mv t2, s8
	mv t4, s5
	jal deconvert
	mv s5, t4
	
	# przepisanie na nowo do rejestr�w s�owa przed i s�owa kodzonego
	mv s1, s2
	mv s2, s3
	
	# zwi�kszenie lciznika indeksu s�owa kodowanego
	addi s8, s8, 32
	sub s5, s5, s8 # powr�cenie wska�nikiem wykresu po deconvert
	

	# s8 m�wi o indeksie kodowanego s�owa, a t0 czytanego s�owa
	addi t0, s8, 32
	slli t1, s0, 5  # n * 32 --> ca�kowita ilo�� bit�w kodowanego tekstu
	remu t0, t0, t1 # eliminacja wykroczenia poza zakres
	remu s8, s8, t1 # eliminacja wykroczenia poza zakres
	
	# do s3 pobranie nast�pnego s�owa
	mv t2, t0
	mv t4, s5
	jal convert
	mv s3, t1
	
	addi t6, t6, 1
	b loop

##############################################################
################ DEKODOWANIE #################################
decoding:
set_coded_words_decoding:
	# s�owo przed kodowanym s�owem
	mv t0, t1
	addi t0, t0, -64 # ustalenie indeksu przedostatniego bajtu
	mv t2, t0
	mv t4, s5
	jal convert
	mv s1, t1
	
	# kodowane
	slli t0, s0, 5
	addi t0, t0, -32 # ustalenie indeksu ostatniego bajtu
	
	# indeks pocz�tkowy obecnie kodowanego s�owa
	mv s8, t0
	
	mv t2, t0 
	mv t4, s5 
	jal convert
	mv s2, t1 # w t1 jest wynik --> int
	
	# s�owo po kodowanym s�owie
	li t2, 0
	mv t4, s5
	jal convert
	mv s3, t1

prepere_for_cycle_iteration_decoding:
	mv s9, s6 # s9 i --> iterator 

iterate_cycles_decoding:
	beqz s9, coding_end
	mul s10, s9, s4 # s10 --> sum
	srli s11, s10, 2  # s11 --> e 	
	
	addi s9, s9, -1
	
	mv t6, s0 # t6 --> r = n
	addi t6, t6, -1 # t6 --> r = n-1

loop_decoding:
	bltz t6, iterate_cycles_decoding
	
	jal mx

	# odj�cie od kodowanego s�owa nawiasu koduj�cego s�owo
	sub s2, s2, t5
	
	# nadpisanie buffora nowo zakodowanym s�owem 
	mv t1, s2
	mv t2, s8
	mv t4, s5
	jal deconvert
	mv s5, t4
	
	# przepisanie na nowo do rejestr�w s�owa przed i kodzonego
	mv s3, s2
	mv s2, s1
	
	addi s8, s8, -32
	sub s5, s5, s8 # powr�cenie wska�nikiem wykresu po deconvert
	addi s5, s5, -64

	# s8 m�wi o indeksie kodowanego s�owa, a t0 czytanego s�owa
	addi t0, s8, -32
	slli t1, s0, 5

	# sprawdzenie czy indeksy nie wychodz� poza zakres i eliminacja b��du
check_range:
	bltz t0, set_range_reading
	bltz s8, set_range_coding
	
	# do s3 pobranie nast�pnego s�owa
	mv t2, t0
	mv t4, s5
	jal convert
	mv s1, t1
	
	addi t6, t6, -1
	b loop_decoding

set_range_reading:
	add t0, t1, t0
	b check_range
	
set_range_coding:
	add s8, t1, s8
	b check_range

###############################################################


########### koniec procesu kodowania / dekodowania ############
coding_end:
	jal file_write
	# jr ra
	li a7, 4
	la a0, buffer
	ecall
	
	li a7, 10
	ecall

####### otworzenie, wczytanie danych i zamkni�cie pliku #######
file_read:
open_file_to_read:
	li   a7, 1024     
	la   a0, result     
	li   a1, 0        
	ecall             
	mv   s6, a0    

read_from_file:
	li   a7, 63    
	mv   a0, s6       
	la   a1, buffer   
	li   a2, 1024       
	ecall            
	mv s5, a1

close_read_file:
	li   a7, 57      
	mv   a0, s6       
	ecall            
	
	jr ra
###################################################################

###########  zapisanie danych z buffora do pliku #################
file_write:
open_file_to_write:
	li   a7, 1024     
	la   a0, result    
	li   a1, 1        
	ecall             
	mv   s6, a0       


write_file:
	li   a7, 64      
	mv   a0, s6      
	la   a1, buffer   
	li   a2, 1024     
	ecall            

close_writing_file:
	li   a7, 57       
	mv   a0, s6      
	ecall            
	
	jr ra
###############################################################

############## konwertuje zapis 32 bit�w na inta ##############
convert:
	li t1, 0 # suma --> int
	li t3, 31 # ilos� przesuni��
	add t4, t4, t2 # dodawanie offsetu t2
	
binary_converter:
	lb t0, (t4)
	bltz t3, end_binary_converter
	
	addi t0, t0, -48
	sll t0, t0, t3
	add t1, t1, t0
	
	addi t3, t3, -1
	addi t4, t4, 1
	b binary_converter

end_binary_converter:
	jr ra # powr�t do miesjca wywo�ania funkcji

#############################################################

############### dekonwertuje inta na 32 bity ################
deconvert:
	li t3, 31 # ilos� przesuni��
	add t4, t4, t2 # dodawanie offsetu t2
	
binary_deconverter:
	bltz t3, end_binary_deconverter

	srl t0, t1, t3
	addi t0, t0, 48
	sb t0, (t4)
	addi t0, t0, -48
	
	# t1 - pow(2, t3)
	sll t0, t0, t3
	sub t1, t1, t0
	
	addi t3, t3, -1
	addi t4, t4, 1
	b binary_deconverter

end_binary_deconverter:
	jr ra # powr�t do miesjca wywo�ania funkcji
############################################################


###################### MX ##################################    ->>>>>>>>>> nie dzia�a po �le przeskakuje mi�dzy funkcjami
mx:
#(( z>>5^y<<2)+(y>>3^z <<4))^((sum^y )+( key [ ( r ^e )%4]^ z ))
	# t0 wynik pierwszego nawiasu
	srli t0, s1, 5 # z >> 5
	xor t0, t0, s3 # z >> 5 ^ y
	slli t0, t0, 2 # z >> 5 ^ y << 2
	
	# t1 wynik drugiego nawiasu 
	srli t1, s3, 3 # y >> 3
	xor t1, t1, s1 # y >> 3 ^ z
	slli t1, t1, 4 # y >> 3 ^  << 4
	
	# t5 wynik dodania dw�ch pierwszych nawias�w
	add t5, t0, t1
	
	# a4 wynik trzeciego nawiasu
	xor a4, s10, s3 # sum^y
	
	# t4 wynik czwartego nawiasu dzia�aj�cy na key
	# t4 na pocz�tek indeks key
	xor t4, t6, s11 # r ^ e
	li t0, 4 # do zwolnionego rejestru t0 wk�adamy 4
	remu t4, t4, t0  # ( r ^e )%4
	
	# pobieramy warto�� z klucza o tym indeksie do t1
	li t0, 32
	mul t4, t4, t0
	mv t2, t4 
	mv t4, s7
	jal convert

	xor t4, t1, s1 # key [ ( r ^e )%4]^ z )
	
	# dodanie trzeciego i czwartego nawiasu
	add t4, t4, a4
	
	# xor miedzy du�ymi nawiasami (t4 i t5)
	xor t5, t5, t4
	
jr ra
###############################################################