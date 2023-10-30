.data
	localArquivo: .asciiz "/home/victhor/Downloads/example_saida.asm"  # Caminho para o arquivo de entrada
	conteudoArquivo: .space 1024  # Espaço para armazenar o conteúdo do arquivo
	buffer_data: .space 64  # Buffer para armazenar a linha
	
	arquivoGeradoUrl: "/home/victhor/Downloads/data.mif"  
	conteudoHeader: .asciiz "DEPTH = 16384;\nWIDTH = 32;\nADDRESS_RADIX = HEX;\nDATA_RADIX = HEX;\nCONTENT\nBEGIN\n\n"
	conteudoData: .space 1024  # Espaço para armazenar dados do arquivo .mif
	mensagemErro: .asciiz "Há um erro de sintaxe!"
	
	armazenar_data_tmp: .space 11 	# armazenar temporariamente o dado a ser escrito em uma linha no .mif
	output_string: .asciiz "\n00000000 : 00000000;"  # Para armazenar a linha que vai ser escrita no .mif
	hex_digits: .asciiz "0123456789abcdef"
.text
	jal open_to_read  		# Chama a função para abrir o arquivo para leitura
	jal read_arq  			# Chama a função para ler o arquivo
	la $a0, ($s2) 			# Carrega o conteúdo do arquivo em $a0 
	la $t1, buffer_data  		# Carrega o endereço do buffer em $t1
	li $t0, 0  			# Inicializa o contador de quebras de linha
	li $t4, -2			# Contador de caracteres salvos

guarda_data:
	lb $t3, 0($a0)  		# Carrega um byte do conteúdo do arquivo em $t3
	beq $t3, 10, check_lf  		# Verifica se o byte é uma quebra de linha
	beqz $t0, pula_letra  		# Se o contador é igual a zero - para não salvar o trecho ".data"

armazena_letra:
	beq $t3, 46, check_dot  	# Verifica se o byte é um ponto (.)
	sb $t3, 0($t1)  		# Armazena o byte no buffer
	addi $a0, $a0, 1 		# Avança para o próximo byte no conteúdo do arquivo
	addi $t1, $t1, 1  		# Avança para a próxima posição no buffer
	addi $t4, $t4, 1		# Incrementa contador de bytes salvos			
	
	j guarda_data  			# Volta para a rotina de guarda_data

pula_letra:
	addi $a0, $a0, 1  		# Avança para o próximo byte no conteúdo do arquivo
	j guarda_data  			# Volta para a rotina de guarda_data

check_dot:
	lb $t3, 1($a0)  			# Carrega o próximo byte do conteúdo do arquivo em $t3
	beq $t3, 116, gerar_ou_abrir_mif	# Verifica se o próximo byte é 't' - se chegamos no .text
	lb $t3, 0($a0)  			# Carrega o byte original
	sb $t3, 0($t1)  			# Armazena o byte no buffer
	addi $a0, $a0, 1  			# Avança para o próximo byte no conteúdo do arquivo
	addi $t1, $t1, 1  			# Avança para a próxima posição no buffer
	j guarda_data  				# Volta para a rotina de guarda_data

check_lf:
	bne $t0, $zero, armazena_letra  # Verifica se houve alguma quebra de linha
	addi $t0, $t0, 1  		# Incrementa o contador de quebras de linha
	j pula_letra  			# Pula para a próxima letra

gerar_ou_abrir_mif:
	li $v0, 13  			# Chama a syscall para abrir um arquivo
	la $a0, arquivoGeradoUrl  	# Passa o caminho do arquivo .mif a ser gerado
	li $a1, 1  			# Define a flag para escrita
	syscall
	move $s1, $v0  			# Salva o descritor do arquivo

escrever_header:
	li $v0, 15  			# Chama a syscall para escrever em um arquivo
	move $a0, $s1  			# Passa o descritor do arquivo
	la $a1, conteudoHeader  	# Passa o conteúdo do cabeçalho a ser escrito
	la $a2, 80  			# Passa o tamanho do conteudoHeader
	syscall
	

# ---------- Começar a escrever o conteúdo abaixo do cabeçalho ----------: 

#t3: byte atual analisado
	
    	la $a0, buffer_data		# Carregue o .data armazenada em $t1 PRECISA?
    	la $s2, conteudoData  		# Carrega o endereço do buffer do conteúdo em $s2
    	li $s3, 0			# Contador de quantas linhas com dados foram salvas no .mips

		
verifica_diretiva:			# ------- Achar o primeiro (.) para verificar a diretiva (word, byte, etc) que vem depois -------	
	lb $t3, 0($a0)  		# Carrega um byte do conteúdo do arquivo em $t3
	beq $t3, 46, check_diretiva  	# Verifica se o byte é um ponto (.)	
	
pula_letra_diretiva:
	addi $a0, $a0, 1  		# Avança para o próximo byte no conteúdo do arquivo
	addi $t4, $t4, -1		# Decrementa contador com a quantidade de bytes no buffer
	beqz $t4, fechar_arquivo	# Se eu já percorri todos os bytes do buffer, fechar_arquivo
	
	j verifica_diretiva  		# Volta para a rotina de verificar_diretiva

check_diretiva:
	lb $t3, 1($a0)  		# Carrega o próximo byte do conteúdo do arquivo em $t3
	beq $t3, 119, verifica_word	# Verifica se o próximo byte é 'w' - se for, vai para verificação do .word
	j verifica_diretiva 		# Volta para a rotina de verificar_diretiva			

# ---------------------- Tratamento .word -------------------------#

verifica_word:
	lb $t3, 2($a0)			# Carrega próximo byte depois de w'
	bne $t3, 111, print_erro	# Se a próxima letra depois de 'w' não for 'o': erro; 
	lb $t3, 3($a0)			# Carrega próximo byte depois de 'wo'
	bne $t3, 114, print_erro	# Se a próxima letra depois de 'wo' não for 'r': erro; 
	lb $t3, 4($a0)			# Carrega próximo byte depois de 'wor'
	bne $t3, 100, print_erro	# Se a próxima letra depois de 'wor' não for 'd': erro; 
	
	addi $t4, $t4, -6		# decrementar quantidade de caracteres cobertos
	ble  $t4, $zero, fechar_arquivo	# se não houver mais caracteres, finalize
	addi $a0, $a0, 6  		# se houver, colocar primeira posição de a0 no primeiro byte depois de 'word'
	
analisa_word:				#################### Trocar o nome dessa label - aqui eu analiso um dado da variável por vez
	li $s4, 0			# Para contar quantos dígitos tem o número em questão
	la $t2, armazenar_data_tmp 	# Para armazenar os bytes de um dos números dos dados por vez - .word (12), (32), ... (n)
	li $t6, 0			# Armazenará o valor final decimal do número mapeado
	li $s6, 0			# Para verificar se o número é negativo (o: positivo, 1: negativo)
	
analisa_single_data:
	lb $t3, 0($a0)
	beq $t3, 45, tratar_negativo	# Se for (-) pular a letra logo
	beq $t3, 32, pular_letra_word	# Se for espaço, pular a letra logo
	beq $t3, 10, salvar_data_word	# Se for uma quebra de linha, ir salvar dados
	beq $t3, 44, salvar_data_word	# Se for uma vírgula, ir salvar dados
	
	beq $t3, 120, verificar_hex	# Se achar um x, verificar se é um hexadecimal no padrão correto
	
	ble $t3, 47  print_erro		# Se for um valor não numérico, printar erro:		
	bge $t3, 58, print_erro		# Se for um valor não numérico, printar erro:
	
	sb $t3, 0($t2)  		# Armazena o byte em armazenar_data_tmp
	addi $t2, $t2, 1		# Incrementar armazenador do numero do dado atual
	addi $s4, $s4, 1
	
pular_letra_word:
	addi $a0, $a0, 1
	addi $t4, $t4, -1	
	j analisa_single_data
	
tratar_negativo:
	li $s6, 1
	j pular_letra_word
	
verificar_hex:				# Caso algum valor da variável já seja hexadecimal
	li $t7, 0			# Para contar se tem 8 bytes	
	sb $t3, 0($t2)  		# Armazena o byte com o código de 'x' em armazenar_data_tmp
loop_verifica_num:
	lb $t3, 1($a0)			# Carrega próximo byte a ser verificado
	ble $t3, 47  print_erro		# Se for um valor não numérico, printar erro:		
	sge $t1, $t3, 58		# Se for um valor não numérico, talvez seja erro, guardar operação em $t1
	sge $t5, $t3, 97		# $t5 = 1 se valor estiver entre a e f
	bne $t1, $t5, print_erro	# Se os valores são diferentes, o caractere está entre 58 e antes de 97
	bge $t3, 103, print_erro
	
	beq $t7, 7, debug
	
	addi $a0, $a0, 1
	addi $t4, $t4, -1
	addi $t7, $t7, 1
	addi $t2, $t2, 1		# Incrementar armazenador do numero do dado atual
	
	sb $t3, 0($t2)			# Armazena o byte em armazenar_data_tmp
	
	bne $t7, 8, loop_verifica_num
	
salvar_data_word:
	# $s5 é para guardar por qual caractere eu entrei no salvar, se foi por (,) ou (\n) - Definir o retorno depois de armazenar linha no buffer
	# Se for (\n) vai ser necessário voltar a caçar novos (.word) depois de guardar o valor atual
	move $s5, $t3, 
	
	addi $a0, $a0, 1
	la $t2, armazenar_data_tmp	# Dado da variável para ser manupulado - ex: .word (123) - o 123

	loop_determinar_inteiro:
		# $t5 Usado para pegar byte atual de armazenar_data_tmp
		# $t6 Será usado para armazenar o valor inteiro final
		# $t7 Usada para armazenar um dígito com seu peso decimal
		# $t8 tem o valor de $s4, mas é usada para não afetar o valor do contador
		beq $s4, 0, converte_hex		# Se o contador for zero, ir pegar os outros inteiros na variável		
		lb $t5, 0($t2)
		addi $t7, $t5, -48			# Pegar número correspondente ao código ascii
		addi $t8, $s4, -1	
	
		add_peso_decimal:
			ble $t8, 0, pular_digito	# Só adicionar peso da posição decimal se houver mais de um dígito
			mul $t7, $t7, 10
			addi $t8, $t8, -1
			bnez $t8, add_peso_decimal	# Se a cópia do contador não for zero, continue multiplicando por 10
	
	pular_digito:
		add $t6, $t6, $t7			# Adicionando valores ao inteiro final
		addi $t2, $t2, 1			# Incrementa posicao do armazenar_data_tmp
		addi $s4, $s4, -1			# Decrementa contador da quantidade de dígitos do número	
		j loop_determinar_inteiro

tornar_valor_negativo:
	not $t6, $t6
	addi $t6, $t6, 1
	j keep_convert	
	
converte_hex:
	bne $s6, 0, tornar_valor_negativo
	
keep_convert:
	jal zerar_output_string

    	li $t1, 19      	# Posição inicial da string com a parte do dado no formato do .mif
    	li $t5,	8		# Posição inicial da string com a parte do endereço no formato do .mif
    	move $t7, $s3		# Temporária com valor da quantidade de dados na memória para não modificar s3 com o valor original
    	
convert_loop_data:
	andi $t2, $t6, 0xF  		# Get the lowest 4 bits of the integer
    	lb $t3, hex_digits($t2)  	# Get the corresponding hexadecimal character

    	sb $t3, output_string($t1)
    
	# Decrement the character position
    	subi $t1, $t1, 1

   	 # Shift the integer right by 4 bits
    	srl $t6, $t6, 4

    	bnez $t6, convert_loop_data
    	
convert_loop_endereco:
	andi $t2, $t7, 0xF  		# Get the lowest 4 bits of the integer
    	lb $t3, hex_digits($t2)  	# Get the corresponding hexadecimal character

    	# Insert the character in reverse order
    	sb $t3, output_string($t5)
    
	# Decrement the character position
    	subi $t5, $t5, 1

   	 # Shift the integer right by 4 bits
    	srl $t7, $t7, 4

    	bnez $t7, convert_loop_endereco
    	
    	la $t8, output_string		# Armazenar linha a ser escrita no arquivo
    	addi $s3, $s3, 1		# Aumentar contador de linhas escritas no conteúdo do .mif
    	
armazenar_no_arquivo_byte:
	lb $t9, 0($t8)	
	
	sb $t9, 0($s2)			# Armazenar bytes no conteudoData
	
	addi $t8, $t8, 1		# Incrementar posição da linha a ser escrita
	addi $s2, $s2, 1		# Incrementar posição do conteudoData
	
	bne $t9, $0, armazenar_no_arquivo_byte 
		
	beq $s5, 10, verifica_diretiva	# Se o próximo byte ao número armazenado for \n, voltar a caçar a diretiva word 
	j analisa_word

print_erro:
	li $v0, 16  		# Chama a syscall para fechar o arquivo
	move $a0, $s1  		# Passa o descritor do arquivo
	syscall	
	
	li $v0, 4  		# Chama a syscall para printar string
	la $a0, mensagemErro  	# Passa o descritor do arquivo
	syscall	
	
fechar_arquivo:
	li $v0, 16  		# Chama a syscall para fechar o arquivo
	move $a0, $s1  		# Passa o descritor do arquivo
	syscall	

# -------------------------------- Terminar --------------------------------	

Terminar_programa:
	li $v0, 10  		# Chama a syscall para terminar o programa
	syscall


# ------------------------ Leitura do arquivo ----------------------------

open_to_read:
	li $v0, 13  		# Chama a syscall para abrir um arquivo
	la $a0, localArquivo  	# Passa o caminho do arquivo
	li $a1, 0  		# Define a flag para leitura
	syscall
	move $s0, $v0  		# Salva o descritor do arquivo

read_arq:
	move $a0, $s0  		# Passa o descritor do arquivo
	li $v0, 14  		# Chama a syscall para ler o conteúdo do arquivo
	la $a1, conteudoArquivo # Passa o local para armazenar o conteúdo do arquivo
	li $a2, 1024  		# Passa o tamanho do buffer
	syscall
	move $s1, $v0  		# Salva o número de caracteres lidos
	move $s2, $a1  		# Salva o conteúdo do arquivo
	jr $ra  		# Retorna

# ----------------------- Subrotinas úteis -------------------------------------

zerar_output_string:
	li $t1, 1
	li $t2, 48
zerar_endereco:
	sb $t2, output_string($t1)
	addi $t1, $t1, 1
	bne $t1, 9, zerar_endereco
	li $t1, 12
zerar_dado:	
	sb $t2, output_string($t1)
	addi $t1, $t1, 1
	bne $t1, 20, zerar_dado
	jr $ra
	
# ------------------------------------------------------------------------
debug:
	la $a0, armazenar_data_tmp
	li $v0, 4
	syscall
	j fechar_arquivo
	
debug_write_file:
	la $s2, conteudoData
	
	move $a0, $s2
	li $v0, 4
	syscall
		
	addi $s2, $s2, 22
	
	move $a0, $s2
	li $v0, 4
	syscall
	
	addi $s2, $s2, 22
	
	move $a0, $s2
	li $v0, 4
	syscall

	addi $s2, $s2, 22
	
	move $a0, $s2
	li $v0, 4
	syscall

	addi $s2, $s2, 22
	
	move $a0, $s2
	li $v0, 4
	syscall
	
	addi $s2, $s2, 22
	
	move $a0, $s2
	li $v0, 4
	syscall					
	
	addi $s2, $s2, 22
	
	move $a0, $s2
	li $v0, 4
	syscall		
	
	addi $s2, $s2, 22
	
	move $a0, $s2
	li $v0, 4
	syscall	
						
	j fechar_arquivo
