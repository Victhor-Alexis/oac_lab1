.data
	#C:/Users/guilh/OneDrive/Área de Trabalho/teste.asm
	#localArquivo: .asciiz "/home/victhor/Downloads/example_saida.asm"  
	localArquivo: .space 200
	conteudoArquivoData: .space 1024  # Espaço para armazenar o conteúdo do arquivo
	buffer_data: .space 64  # Buffer para armazenar a linha
	
	arquivoGeradoUrl: .asciiz "/home/victhor/Downloads/teste.mif"  
	#arquivoGeradoUr2l: .space 200
	arquivoGeradoUrlText: .space 200
	conteudoHeader: .asciiz "DEPTH = 16384;\nWIDTH = 32;\nADDRESS_RADIX = HEX;\nDATA_RADIX = HEX;\nCONTENT\nBEGIN\n"
	conteudoData: .space 1024  # Espaço para armazenar dados do arquivo .mif
	mensagemErro: .asciiz "Há um erro de sintaxe!"
	
	armazenar_data_tmp: .space 22 	# armazenar temporariamente o dado a ser escrito em uma linha no .mif
	output_string: .asciiz "\n00000000 : 00000000;"  # Para armazenar a linha que vai ser escrita no .mif
	hex_digits: .asciiz "0123456789abcdef"
	
	promptLer: .asciiz "Local do arquivo a ser lido: "
	promptEsc: .asciiz "Local para salvar arquivo gerado a partir do data: "
	
	res:    .word    0x00132
	
	
	num_instrucoes:     .byte 0
	prompt_entrada:     .asciiz "Digite o diretório do arquivo de leitura: "
	prompt_escrita:     .asciiz "Digite o diretório do arquivo de escrita: "
	conteudoLinha: .asciiz "\n00000000 : 00000000;"
	machine_code: .space 1200
	diretorio_escrita: .space 300
	conteudoArquivo: .space 1024
	buffer_linha_bin: .space 33 #Buffer que armazena a instrução interira em binario
	buffer_text: .space 64  # Buffer para armazenar a linha
	inst_buffer: .space 64  # Buffer para armazenar a primeira palavra
	arg1_buffer: .space 64
	arg2_buffer: .space 64
	arg3_buffer: .space 64
	n0: .byte  48
	n1: .byte  49
	n2: .byte  50
	n3: .byte  51
	n4: .byte  52
	n5: .byte  53
	n6: .byte  54
	n7: .byte  55
	n8: .byte  56
	n9: .byte  57
	l: .byte  108
	i: .byte  105
	w: .byte  119
	u: .byte  117
	b: .byte  98
	a: .byte  97
	d: .byte  100
	n: .byte  110
	s: .byte  115
	t: .byte  116
	r: .byte  114
	v: .byte  118
	o: .byte  111
	m: .byte  109
	f: .byte  102
	h: .byte  104
	e: .byte  101
	q: .byte  113
	g: .byte  103
	z: .byte  122
	x: .byte  120
	j: .byte  106
	c: .byte  99
	_$: .byte  36
	lf: .byte  10
	virg: .byte 44
	par: .byte 40
.text
	
	# Exiba uma mensagem para solicitar a entrada do usuário
        li $v0, 4           # Carregar o código da syscall para imprimir uma string
        la $a0, promptLer     # Carregar o endereço da mensagem a ser exibida
        syscall

        # Leia o local para se ler o arquivo
        li $v0, 8           		# Carregar o código da syscall "Read String"
        la $a0, localArquivo    	# Carregar o endereço onde a entrada será armazenada
        li $a1, 200         		# Especificar o tamanho máximo da entrada (200 caracteres)
        syscall
	
	jal remover_newline		# Remove \n do final do endereço passado para localArquivo
	
	# Exiba uma mensagem para solicitar a entrada do usuário
        li $v0, 4           # Carregar o código da syscall para imprimir uma string
        la $a0, promptEsc     # Carregar o endereço da mensagem a ser exibida
        syscall
	
	#Local do arquivo escrito para .data
        li $v0, 8           		# Carregar o código da syscall "Read String"
        la $a0, arquivoGeradoUrl    	# Carregar o endereço onde a entrada será armazenada
        li $a1, 200         		# Especificar o tamanho máximo da entrada (200 caracteres)
        syscall
	
	jal remover_newline
                        
	jal open_to_read_data  		# Chama a função para abrir o arquivo para leitura
	jal read_arq_data  			# Chama a função para ler o arquivo
	la $a0, ($s2) 			# Carrega o conteúdo do arquivo em $a0 
	la $t1, buffer_data  		# Carrega o endereço do buffer em $t1
	li $t0, 0  			# Inicializa o contador de quebras de linha
	li $t4, -2			# Contador de caracteres salvos

guarda_data:
	lb $t3, 0($a0)  		# Carrega um byte do conteúdo do arquivo em $t3
	beq $t3, 10, check_lf_data  		# Verifica se o byte é uma quebra de linha
	beqz $t0, pula_letra  		# Se o contador é igual a zero - para não salvar o trecho ".data"

armazena_letra_data:
	beq $t3, 46, check_dot_data  	# Verifica se o byte é um ponto (.)
	sb $t3, 0($t1)  		# Armazena o byte no buffer
	addi $a0, $a0, 1 		# Avança para o próximo byte no conteúdo do arquivo
	addi $t1, $t1, 1  		# Avança para a próxima posição no buffer
	addi $t4, $t4, 1		# Incrementa contador de bytes salvos			
	
	j guarda_data  			# Volta para a rotina de guarda_data

pula_letra:
	addi $a0, $a0, 1  		# Avança para o próximo byte no conteúdo do arquivo
	j guarda_data  			# Volta para a rotina de guarda_data

check_dot_data:
	lb $t3, 1($a0)  			# Carrega o próximo byte do conteúdo do arquivo em $t3
	beq $t3, 116, gerar_ou_abrir_mif	# Verifica se o próximo byte é 't' - se chegamos no .text
	lb $t3, 0($a0)  			# Carrega o byte original
	sb $t3, 0($t1)  			# Armazena o byte no buffer
	addi $a0, $a0, 1  			# Avança para o próximo byte no conteúdo do arquivo
	addi $t1, $t1, 1  			# Avança para a próxima posição no buffer
	j guarda_data  				# Volta para a rotina de guarda_data

check_lf_data:
	bne $t0, $zero, armazena_letra_data  # Verifica se houve alguma quebra de linha
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
	li $a2, 80  			# Passa o tamanho do conteudoHeader
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
	blez $t4, fechar_arquivo	# Se eu já percorri todos os bytes do buffer, fechar_arquivo
	
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
	blt  $t4, $zero, fechar_arquivo	# se não houver mais caracteres, finalize
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
	
	beq $t3, 120, tratar_hex_direto	# Se achar um x, verificar se é um hexadecimal no padrão correto
	
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
	
tratar_hex_direto:			# Caso algum valor da variável já seja hexadecimal
	li $t7, 0			# Para contar se tem 8 bytes	
	li $t8, 11			# Posição inicial para precheencher dado da linha a ser salva no .mif
	jal zerar_output_string
	
loop_verifica_hex:
	lb $t3, 1($a0)			# Carrega próximo byte a ser verificado
	ble $t3, 47  print_erro		# Se for um valor não numérico, printar erro:		
	sge $t1, $t3, 58		# Se for um valor não numérico, talvez seja erro, guardar operação em $t1
	sge $t5, $t3, 97		# $t5 = 1 se valor estiver entre a e f
	bne $t1, $t5, print_erro	# Se os valores são diferentes, o caractere está entre 58 e antes de 97
	bge $t3, 103, print_erro
	
	addi $a0, $a0, 1
	addi $t4, $t4, -1
	addi $t7, $t7, 1
	
	addi $t8, $t8, 1		# Incrementar contador da posição em output_string

	sb $t3, output_string($t8)
	
	#beq $t7, 8, debug
	
	bne $t7, 8, loop_verifica_hex   # Quando preencher os 8 bytes, continue
	
	# ----- Verificar se o próximo byte tem o código da quebra de linha para continuar a verificação na próxima linha: -----
	
	addi $a0, $a0, 1 
	lb $t2, 0($a0)
	move $s5, $t2 			# Guardar o \n para indicar que devo pular a linha depois de salvar o dado
	
	#------------------------------------------------------------
	addi $a0, $a0, 1
	addi $t4, $t4, -2
	
	li $t5, 8			# Posição inicial para escrever na parte do endereço
	move $t7, $s3			# Temporária com valor da quantidade de dados na memória para não modificar s3 com o valor original
	j convert_loop_endereco		# Como o dado já foi salvo, pular para salvar o endereço
	
	
salvar_data_word:
	# $s5 é para guardar por qual caractere eu entrei no salvar, se foi por (,) ou (\n) - Definir o retorno depois de armazenar linha no buffer
	# Se for (\n) vai ser necessário voltar a caçar novos (.word) depois de guardar o valor atual
	move $s5, $t3
	
	addi $a0, $a0, 1
	la $t2, armazenar_data_tmp	# Dado da variável para ser manupulado - ex: .word (123) - o 123

	loop_determinar_inteiro:
	
		# $t5 Usado para pegar byte atual de armazenar_data_tmp
		# $t6 Será usado para armazenar o valor inteiro final
		# $t7 Usada para armazenar um dígito com seu peso decimal
		# $t8 tem o valor de $s4, mas é usada para não afetar o valor do contador
		beq $s4, 0, converte_hex		# Se o contador for zero, ir converter esse valor para hexa		
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

    	li $t1, 19      		# Posição inicial da string com a parte do dado no formato do .mif
    	li $t5,	8			# Posição inicial da string com a parte do endereço no formato do .mif
    	move $t7, $s3			# Temporária com valor da quantidade de dados na memória para não modificar s3 com o valor original
    	
convert_loop_data:
	andi $t2, $t6, 0xF  		# Get the lowest 4 bits of the integer
    	lb $t3, hex_digits($t2)  	# Get the corresponding hexadecimal character
    	
    	sb $t3, output_string($t1)
    
	# Decrement the character position
    	subi $t1, $t1, 1

   	# Shift de 4 bits no inteiro
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
	la $s2, conteudoData
loop_escrever_conteudo:
	li $v0, 15  			# Chama a syscall para escrever em um arquivo
	move $a0, $s1  			# Passa o descritor do arquivo
	move $a1, $s2  			# Passa o conteúdo da linha a ser escrita
	li $a2, 21  			# Passa o tamanho do conteudoData
	syscall	
	
	addi $s2, $s2, 22
	addi $s3, $s3, -1
	
	bne $s3, 0, loop_escrever_conteudo

	li $v0, 16  			# Chama a syscall para fechar o arquivo
	move $a0, $s1  			# Passa o descritor do arquivo
	syscall	

# -------------------------------- Terminar --------------------------------	

Terminar_data:
	j comecar_text
	#li $v0, 10  		# Chama a syscall para terminar o programa
	#syscall


# ------------------------ Leitura do arquivo ----------------------------

open_to_read_data:
	li $v0, 13  		# Chama a syscall para abrir um arquivo
	la $a0, localArquivo  	# Passa o caminho do arquivo
	li $a1, 0  		# Define a flag para leitura
	syscall
	move $s0, $v0  		# Salva o descritor do arquivo

read_arq_data:
	move $a0, $s0  		# Passa o descritor do arquivo
	li $v0, 14  		# Chama a syscall para ler o conteúdo do arquivo
	la $a1, conteudoArquivoData # Passa o local para armazenar o conteúdo do arquivo
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
	
     
        
 #-------------------------------------------------- Parte do.text ---------------------------------------------------------


comecar_text:


    # receber o diretório do arquivo de entrada
# Exiba uma mensagem para solicitar a entrada do usuário
        #li $v0, 4           # Carregar o código da syscall para imprimir uma string
        #la $a0, prompt_entrada     # Carregar o endereço da mensagem a ser exibida
        #syscall

        # Leia o local para se ler o arquivo
        #li $v0, 8           		# Carregar o código da syscall "Read String"
        #la $a0, localArquivo    	# Carregar o endereço onde a entrada será armazenada
        #li $a1, 300         		# Especificar o tamanho máximo da entrada (200 caracteres)
        #syscall
	
	#jal remover_newline		# Remove \n do final do endereço passado para localArquivo
	
	# Exiba uma mensagem para solicitar a entrada do usuário
        li $v0, 4           # Carregar o código da syscall para imprimir uma string
        la $a0, prompt_escrita     # Carregar o endereço da mensagem a ser exibida
        syscall
	
	#Local do arquivo escrito para .data
        li $v0, 8           		# Carregar o código da syscall "Read String"
        la $a0, diretorio_escrita    	# Carregar o endereço onde a entrada será armazenada
        li $a1, 300         		# Especificar o tamanho máximo da entrada (200 caracteres)
        syscall
	
	jal remover_newline

#    	li $v0, 4
#    	la $a0, prompt
#    	syscall	
#    	la $a0, diretorio_leitura
#    	li $a1, 200
#   	li $v0, 8
#    	syscall
#	li $v0, 4
#    	la $a0, prompt2
#   	syscall
#    	la $a0, diretorio_escrita
#    	li $a1, 200
#    	li $v0, 8
#    	syscall

	#jal open_to_read
	#jal read_arq

	la $a0, conteudoArquivoData		#carrega conteudo do arquivo em $a0				
	la $t1, buffer_text
	li $t0, 0		#indicador de ".text"
	li $t5, 0		#contadr de lf

guarda_text:
	lb $t3, 0($a0)
	beq $t3, 46, check_dot  #se for ponto
	beqz $t0, pula_letra_guarda_text
	beq $t3, 10, check_lf  #se for fim de linha (lf = line feed)
	beqz $t5, pula_letra_guarda_text
	
armazena_letra:   
	beq $t3, $zero, done_guarda_text
	sb $t3, 0($t1)
	addi $a0, $a0, 1
	addi $t1, $t1, 1
	j guarda_text
	
pula_letra_guarda_text:
	addi $a0, $a0, 1
	j guarda_text
	
check_dot:
	lb $t4, 1($a0)  #olha para o proximo caractere
	beq $t4, 116, check_text   #verifica se é ".t"
	j pula_letra_guarda_text
	
check_text:
	addi $t0, $t0, 1
	j pula_letra_guarda_text
	
check_lf:
	bnez $t5, armazena_letra
	addi $t5, $t5, 1
	j pula_letra_guarda_text	
	
done_guarda_text:
	# Termine a string com um caractere nulo
    #sb $zero, 0($t1)

    # Carregue .text armazenado em $t1
    la $s3, buffer_text			#$s3 = bufffer_.text
    j identifica_linha

#------------------------------------------------------------------- PEGA AS INSTRUÇÕES DO .TEXT
identifica_linha:

	# Carregue o endereço da string em $a1
	la $a1, buffer_text
	la $s0, buffer_linha_bin
	#Inicialize um registrador para armazenar a palavra
	
	la $t1 , inst_buffer
	la $t5, arg1_buffer
	la $t6, arg2_buffer
	la $t7, arg3_buffer	
	# Inicialize um contador em $t0	
	li $t0, 0   	#contador de virgulas
	li $t9, 0	

	pega_inst:
    		# Carregue o caractere atual na string em $t3
    		lb $t3, 0($a1)
    		lb $t8, num_instrucoes
    		bne $t9, $t8, inst_atual
	
    		# Verifique se o caractere é um espaço em branco ou nulo (fim da string)
    		beq $t3, 0, escrever_text
    		beq $t3, 32, check_inst		#se for espaço
    		sb $t3, 0($t1)
    		# Avance para o próximo caractere na string
    		addi $a1, $a1, 1  
    		addi $t1, $t1, 1
    		addi $t4, $t4, 1  #incrementa o contador de caracteres da instrução (1-5) - será usado para resetar o buffer
    		j pega_inst
    		j done
    	inst_atual:
    		beq $t3, 10, add_linha		
		addi $a1, $a1, 1		#se não chegou na linha certa, pula letra
    		j pega_inst
    	add_linha:
    		addi $t9, $t9, 1		#se achou fim da linha, adiciona o contador e recomeça
    		addi $a1, $a1, 1
    		j pega_inst
	check_inst:
		li $s5, 0		#Contador caracteres arg1
     		li $s6, 0		#Contador caracteres arg1
     		li $s7, 0		#Contador caracteres arg1
		move $s4, $t4		#contagem de caracteres guardado em $S4
		sb $zero, 0($t1)
		la $a2, inst_buffer	#Armazena a instrução em $a2
		addi $a1, $a1, 1	#pula para o proximo caractere
		jal compara_l		#Funções de comparação, $t0 para navegar pela instrução ($a2), e t4 e $t9 como suportes para alocação em bin
		jal compara_a
		jal compara_s
		jal compara_o
		jal compara_n
		jal compara_m
		jal compara_b
		jal compara_x
		jal compara_j
		jal compara_d
		jal compara_c
#----------------
     		j pega_inst
     			
     	compara_l:   		#caracteres a comparar: $t4 / inst: $a2_____________________________
     		lb $t0 , 0($a2)
     		lb $t4, l
     		beq $t0, $t4, l_
     		jr $ra
     		
     		l_:
     			lb $t0 , 1($a2)
     			lb $t4, w
     			beq $t0, $t4, lw.	#inst = lw(op: 100011)
     			lb $t4, u
     			beq $t0, $t4, lu_
     			lb $t4, b
			beq $t0, $t4, lb.	#inst = lb(op:100000) 
			lb $t4, i
			beq $t0, $t4, li.	#inst = li = lui(op: 001111) + ori (op: 001101)
			j rong_inst
     		lu_:
     			lb $t0 , 2($a2)
     			lb $t4, i
     			beq $t0, $t4, lui.	#inst = lui(op:001111) (SEM RS)
     			j rong_inst
     			
     			lw.:
     				lb $t4, n1
     				lb $t9, n0
     				sb $t4, 0($s0)
     				sb $t9, 1($s0)
     				sb $t9, 2($s0)
     				sb $t9, 3($s0)
     				sb $t4, 4($s0)
     				sb $t4, 5($s0)
     				#--- IMM
     				sb $t9, 16($s0)
     				sb $t9, 17($s0)
     				sb $t9, 18($s0)
     				sb $t9, 19($s0)
     				sb $t9, 20($s0)
     				sb $t9, 21($s0)
     				sb $t9, 22($s0)
     				sb $t9, 23($s0)
     				sb $t9, 24($s0)
     				sb $t9, 25($s0)
     				sb $t9, 26($s0)
     				sb $t9, 27($s0)
     				sb $t9, 28($s0)
     				sb $t9, 29($s0)
     				sb $t9, 30($s0)
     				sb $t9, 31($s0)
     				j typeI	
     			
     			lb.:	
     				lb $t4, n1
     				lb $t9, n0
				sb $t4, 0($s0)
     				sb $t9, 1($s0)
     				sb $t9, 2($s0)
     				sb $t9, 3($s0)
     				sb $t9, 4($s0)
     				sb $t9, 5($s0)
     				#--- IMM
     				sb $t9, 16($s0)
     				sb $t9, 17($s0)
     				sb $t9, 18($s0)
     				sb $t9, 19($s0)
     				sb $t9, 20($s0)
     				sb $t9, 21($s0)
     				sb $t9, 22($s0)
     				sb $t9, 23($s0)
     				sb $t9, 24($s0)
     				sb $t9, 25($s0)
     				sb $t9, 26($s0)
     				sb $t9, 27($s0)
     				sb $t9, 28($s0)
     				sb $t9, 29($s0)
     				sb $t9, 30($s0)
     				sb $t9, 31($s0)
     				j typeI
     			lui.:
     				lb $t4, n1
     				lb $t9, n0
     				sb $t4, 0($s0)
     				sb $t9, 1($s0)
     				sb $t9, 2($s0)
     				sb $t9, 3($s0)
     				sb $t4, 4($s0)
     				sb $t4, 5($s0)
     				j typeI	
     			li.:	
     				j done
     				j typeI_li		#função que vai imprimir lui + ori
     	compara_a:   		#caracteres a comparar: $t4 / inst: $a2_____________________________
     		lb $t0 , 0($a2)
     		lb $t4, a
     		beq $t0, $t4, a_
     		jr $ra
     		a_:
     			lb $t0 , 1($a2)
     			lb $t4, d
     			beq $t0, $t4, ad_
     			lb $t4, n
     			beq $t0, $t4, an_
     			j rong_inst
     			
     		an_:
     			lb $t0 , 2($a2)
     			lb $t4, d
     			beq $t0, $t4, and_
     			j rong_inst
     		and_:
     			lb $t0 , 3($a2)
     			beq $t0, $zero, and.  	#inst = and(op:000000) SMT(00000)FUNCT(100100)
     			lb $t4, i
     			beq $t0, $t4, andi.	#inst = andi(op:001100) 
     			j rong_inst
     			
     		ad_:	
     			lb $t0 , 2($a2)
     			lb $t4, d
     			beq $t0, $t4, add_
     			j rong_inst	
     			
     		add_:
     			lb $t0 , 3($a2)
     			beq $t0, $zero, add.  	#inst = add(op:000000) SMT(00000) FNCT(100000)
     			lb $t4, i
     			beq $t0, $t4, addi_
     			lb $t4, u
     			beq $t0, $t4, addu.	#inst = addu(op:) 
     			j rong_inst
     		addi_:
     			lb $t0 , 4($a2)
     			beq $t0, $zero, addi.  	#inst = addi(op:001000) 
     			lb $t4, u
     			beq $t0, $t4, addiu.	#inst = addiu(op:) 
     			j rong_inst
     		and.:
     				lb $t4, n1
     				lb $t9, n0
     				sb $t9, 0($s0)
     				sb $t9, 1($s0)
     				sb $t9, 2($s0)
     				sb $t9, 3($s0)
     				sb $t9, 4($s0)
     				sb $t9, 5($s0)
     				#-----SHMT
     				sb $t9, 21($s0)
     				sb $t9, 22($s0)
     				sb $t9, 23($s0)
     				sb $t9, 24($s0)
     				sb $t9, 25($s0)
     				#-----FUNCT
     				sb $t4, 26($s0)
     				sb $t9, 27($s0)
     				sb $t9, 28($s0)
     				sb $t4, 29($s0)
     				sb $t9, 30($s0)
     				sb $t9, 31($s0)
     				j typeR	

     		andi.:
     				lb $t4, n1
     				lb $t9, n0
     				sb $t9, 0($s0)
     				sb $t9, 1($s0)
     				sb $t4, 2($s0)
     				sb $t4, 3($s0)
     				sb $t9, 4($s0)
     				sb $t9, 5($s0)
     				#--- IMM
     				sb $t9, 16($s0)
     				sb $t9, 17($s0)
     				sb $t9, 18($s0)
     				sb $t9, 19($s0)
     				sb $t9, 20($s0)
     				sb $t9, 21($s0)
     				sb $t9, 22($s0)
     				sb $t9, 23($s0)
     				sb $t9, 24($s0)
     				sb $t9, 25($s0)
     				sb $t9, 26($s0)
     				sb $t9, 27($s0)
     				sb $t9, 28($s0)
     				sb $t9, 29($s0)
     				sb $t9, 30($s0)
     				sb $t9, 31($s0)
     				j typeI	
     		add.:
     				lb $t4, n1
     				lb $t9, n0
     				sb $t9, 0($s0)
     				sb $t9, 1($s0)
     				sb $t9, 2($s0)
     				sb $t9, 3($s0)
     				sb $t9, 4($s0)
     				sb $t9, 5($s0)
     				#-----SHMT
     				sb $t9, 21($s0)
     				sb $t9, 22($s0)
     				sb $t9, 23($s0)
     				sb $t9, 24($s0)
     				sb $t9, 25($s0)
     				#-----FUNCT
     				sb $t4, 26($s0)
     				sb $t9, 27($s0)
     				sb $t9, 28($s0)
     				sb $t9, 29($s0)
     				sb $t9, 30($s0)
     				sb $t9, 31($s0)
     				j typeR	
     		addu.:
     				lb $t4, n1
     				lb $t9, n0
     				sb $t9, 0($s0)
     				sb $t9, 1($s0)
     				sb $t9, 2($s0)
     				sb $t9, 3($s0)
     				sb $t9, 4($s0)
     				sb $t9, 5($s0)
     				#-----SHMT
     				sb $t9, 21($s0)
     				sb $t9, 22($s0)
     				sb $t9, 23($s0)
     				sb $t9, 24($s0)
     				sb $t9, 25($s0)
     				#-----FUNCT
     				sb $t4, 26($s0)
     				sb $t9, 27($s0)
     				sb $t9, 28($s0)
     				sb $t9, 29($s0)
     				sb $t9, 30($s0)
     				sb $t4, 31($s0)
     				j typeR	
     		addi.:
     				lb $t4, n1
     				lb $t9, n0
     				sb $t9, 0($s0)
     				sb $t9, 1($s0)
     				sb $t4, 2($s0)
     				sb $t9, 3($s0)
     				sb $t9, 4($s0)
     				sb $t9, 5($s0)
     				#--- IMM
     				sb $t9, 16($s0)
     				sb $t9, 17($s0)
     				sb $t9, 18($s0)
     				sb $t9, 19($s0)
     				sb $t9, 20($s0)
     				sb $t9, 21($s0)
     				sb $t9, 22($s0)
     				sb $t9, 23($s0)
     				sb $t9, 24($s0)
     				sb $t9, 25($s0)
     				sb $t9, 26($s0)
     				sb $t9, 27($s0)
     				sb $t9, 28($s0)
     				sb $t9, 29($s0)
     				sb $t9, 30($s0)
     				sb $t9, 31($s0)
     				j typeI	
     		addiu.:
     				lb $t4, n1
     				lb $t9, n0
     				sb $t9, 0($s0)
     				sb $t9, 1($s0)
     				sb $t4, 2($s0)
     				sb $t9, 3($s0)
     				sb $t9, 4($s0)
     				sb $t4, 5($s0)
     				#--- IMM
     				sb $t9, 16($s0)
     				sb $t9, 17($s0)
     				sb $t9, 18($s0)
     				sb $t9, 19($s0)
     				sb $t9, 20($s0)
     				sb $t9, 21($s0)
     				sb $t9, 22($s0)
     				sb $t9, 23($s0)
     				sb $t9, 24($s0)
     				sb $t9, 25($s0)
     				sb $t9, 26($s0)
     				sb $t9, 27($s0)
     				sb $t9, 28($s0)
     				sb $t9, 29($s0)
     				sb $t9, 30($s0)
     				sb $t9, 31($s0)
     				j typeI	
     		
     	compara_s:   		#caracteres a comparar: $t4 / inst: $a2_____________________________
     		lb $t0 , 0($a2)
     		lb $t4, s
     		beq $t0, $t4, s_
     		jr $ra
     		s_: 
     			lb $t0 , 1($a2)
     			lb $t4, w
     			beq $t0, $t4, sw.	#inst = sw(op:101011) 
     			lb $t4, b
     			beq $t0, $t4, sb.	#inst = sb(op:101000) 
     			lb $t4, u
     			beq $t0, $t4, su_
     			lb $t4, l
     			beq $t0, $t4, sl_
     			lb $t4, r
     			beq $t0, $t4, sr_
     			j rong_inst
     			
     		sr_:
     			lb $t0 , 2($a2)
     			lb $t4, a
     			beq $t0, $t4, sra_
     			lb $t4, l
     			beq $t0, $t4, srl.	#inst = srl(op:) 
     			j rong_inst
     		sra_:
     			lb $t0 , 3($a2)
     			lb $t4, v
     			beq $t0, $t4, srav.	#inst = srav(op:000000) SMT(00000) FNCT(00000)typeR?
     			j rong_inst
     			
     		sl_: 
     			lb $t0 , 2($a2)
     			lb $t4, l
     			beq $t0, $t4, sll.	#inst = sll(op:000000)  SHMT(00000)FNCT(000000)
     			lb $t4, t
     			beq $t0, $t4, slt_
     			j rong_inst
     		slt_:
     			lb $t0 , 3($a2)
     			beq $t0, $zero, slt.	#inst = slt(op:000000) SHMT(00000)FNCT(101010)
     			lb $t4, i
     			beq $t0, $t4, slti_
     			j rong_inst
     			
     		slti_:
     			lb $t0 , 4($a2)
     			beq $t0, $zero, slti.	#inst = slti(op:001010) 
     			lb $t4, u
     			beq $t0, $t4, sltiu.	#inst = sltiu(op:) 
     			j rong_inst
     			
     		su_:
     			lb $t0 , 2($a2)
     			lb $t4, b
     			beq $t0, $t4, sub_
     			j rong_inst
     			
     		sub_:
     			lb $t0 , 3($a2)
     			beq $t0, $zero, sub.	#inst = sub(op:000000) SHMT(00000)FNCT(100010)
     			lb $t4, u
     			beq $t0, $t4, subu.	#inst = subu(op:) 
     			j rong_inst
     				
     		sw.:
     				lb $t4, n1
     				lb $t9, n0
     				sb $t4, 0($s0)
     				sb $t9, 1($s0)
     				sb $t4, 2($s0)
     				sb $t9, 3($s0)
     				sb $t4, 4($s0)
     				sb $t4, 5($s0)
     				#--- IMM
     				sb $t9, 16($s0)
     				sb $t9, 17($s0)
     				sb $t9, 18($s0)
     				sb $t9, 19($s0)
     				sb $t9, 20($s0)
     				sb $t9, 21($s0)
     				sb $t9, 22($s0)
     				sb $t9, 23($s0)
     				sb $t9, 24($s0)
     				sb $t9, 25($s0)
     				sb $t9, 26($s0)
     				sb $t9, 27($s0)
     				sb $t9, 28($s0)
     				sb $t9, 29($s0)
     				sb $t9, 30($s0)
     				sb $t9, 31($s0)
     				j typeI	
     		sb.:
     				lb $t4, n1
     				lb $t9, n0
     				sb $t4, 0($s0)
     				sb $t9, 1($s0)
     				sb $t4, 2($s0)
     				sb $t9, 3($s0)
     				sb $t9, 4($s0)
     				sb $t9, 5($s0)
     				#--- IMM
     				sb $t9, 16($s0)
     				sb $t9, 17($s0)
     				sb $t9, 18($s0)
     				sb $t9, 19($s0)
     				sb $t9, 20($s0)
     				sb $t9, 21($s0)
     				sb $t9, 22($s0)
     				sb $t9, 23($s0)
     				sb $t9, 24($s0)
     				sb $t9, 25($s0)
     				sb $t9, 26($s0)
     				sb $t9, 27($s0)
     				sb $t9, 28($s0)
     				sb $t9, 29($s0)
     				sb $t9, 30($s0)
     				sb $t9, 31($s0)
     				j typeI	
     		srl.:
     				lb $t4, n1
     				lb $t9, n0
     				sb $t9, 0($s0)
     				sb $t9, 1($s0)
     				sb $t9, 2($s0)
     				sb $t9, 3($s0)
     				sb $t9, 4($s0)
     				sb $t9, 5($s0)
     				#-----SHMT**
     				sb $t9, 6($s0)
     				sb $t9, 7($s0)
     				sb $t9, 8($s0)
     				sb $t9, 9($s0)
     				sb $t9, 10($s0)
     				#-----FUNCT
     				sb $t9, 26($s0)
     				sb $t9, 27($s0)
     				sb $t9, 28($s0)
     				sb $t9, 29($s0)
     				sb $t4, 30($s0)
     				sb $t9, 31($s0)
     				j typeR	
     		srav.:
     				lb $t4, n1
     				lb $t9, n0
     				sb $t9, 0($s0)
     				sb $t9, 1($s0)
     				sb $t9, 2($s0)
     				sb $t9, 3($s0)
     				sb $t9, 4($s0)
     				sb $t9, 5($s0)
     				#-----SHMT
     				sb $t9, 21($s0)
     				sb $t9, 22($s0)
     				sb $t9, 23($s0)
     				sb $t9, 24($s0)
     				sb $t9, 25($s0)
     				#-----FUNCT
     				sb $t9, 26($s0)
     				sb $t9, 27($s0)
     				sb $t9, 28($s0)
     				sb $t4, 29($s0)
     				sb $t4, 30($s0)
     				sb $t4, 31($s0)
     				j typeR
     		sll.:
     				lb $t4, n1
     				lb $t9, n0
     				sb $t9, 0($s0)
     				sb $t9, 1($s0)
     				sb $t9, 2($s0)
     				sb $t9, 3($s0)
     				sb $t9, 4($s0)
     				sb $t9, 5($s0)
     				#-----SHMT**
     				sb $t9, 6($s0)
     				sb $t9, 7($s0)
     				sb $t9, 8($s0)
     				sb $t9, 9($s0)
     				sb $t9, 10($s0)
     				#-----FUNCT
     				sb $t9, 26($s0)
     				sb $t9, 27($s0)
     				sb $t9, 28($s0)
     				sb $t9, 29($s0)
     				sb $t9, 30($s0)
     				sb $t9, 31($s0)
     				j typeR
     		slt.:
     				lb $t4, n1
     				lb $t9, n0
     				sb $t9, 0($s0)
     				sb $t9, 1($s0)
     				sb $t9, 2($s0)
     				sb $t9, 3($s0)
     				sb $t9, 4($s0)
     				sb $t9, 5($s0)
     				#-----SHMT
     				sb $t9, 21($s0)
     				sb $t9, 22($s0)
     				sb $t9, 23($s0)
     				sb $t9, 24($s0)
     				sb $t9, 25($s0)
     				#-----FUNCT
     				sb $t4, 26($s0)
     				sb $t9, 27($s0)
     				sb $t4, 28($s0)
     				sb $t9, 29($s0)
     				sb $t4, 30($s0)
     				sb $t9, 31($s0)
     				j typeR
     		slti.:
     				lb $t4, n1
     				lb $t9, n0
     				sb $t9, 0($s0)
     				sb $t9, 1($s0)
     				sb $t4, 2($s0)
     				sb $t9, 3($s0)
     				sb $t4, 4($s0)
     				sb $t9, 5($s0)
     				#--- IMM
     				sb $t9, 16($s0)
     				sb $t9, 17($s0)
     				sb $t9, 18($s0)
     				sb $t9, 19($s0)
     				sb $t9, 20($s0)
     				sb $t9, 21($s0)
     				sb $t9, 22($s0)
     				sb $t9, 23($s0)
     				sb $t9, 24($s0)
     				sb $t9, 25($s0)
     				sb $t9, 26($s0)
     				sb $t9, 27($s0)
     				sb $t9, 28($s0)
     				sb $t9, 29($s0)
     				sb $t9, 30($s0)
     				sb $t9, 31($s0)
     				j typeI	
     		sltiu.:
     				lb $t4, n1
     				lb $t9, n0
     				sb $t9, 0($s0)
     				sb $t9, 1($s0)
     				sb $t4, 2($s0)
     				sb $t9, 3($s0)
     				sb $t4, 4($s0)
     				sb $t4, 5($s0)
     				#--- IMM
     				sb $t9, 16($s0)
     				sb $t9, 17($s0)
     				sb $t9, 18($s0)
     				sb $t9, 19($s0)
     				sb $t9, 20($s0)
     				sb $t9, 21($s0)
     				sb $t9, 22($s0)
     				sb $t9, 23($s0)
     				sb $t9, 24($s0)
     				sb $t9, 25($s0)
     				sb $t9, 26($s0)
     				sb $t9, 27($s0)
     				sb $t9, 28($s0)
     				sb $t9, 29($s0)
     				sb $t9, 30($s0)
     				sb $t9, 31($s0)
     				j typeI	
     		sub.:
     				lb $t4, n1
     				lb $t9, n0
     				sb $t9, 0($s0)
     				sb $t9, 1($s0)
     				sb $t9, 2($s0)
     				sb $t9, 3($s0)
     				sb $t9, 4($s0)
     				sb $t9, 5($s0)
     				#-----SHMT
     				sb $t9, 21($s0)
     				sb $t9, 22($s0)
     				sb $t9, 23($s0)
     				sb $t9, 24($s0)
     				sb $t9, 25($s0)
     				#-----FUNCT
     				sb $t4, 26($s0)
     				sb $t9, 27($s0)
     				sb $t9, 28($s0)
     				sb $t9, 29($s0)
     				sb $t4, 30($s0)
     				sb $t9, 31($s0)
     				j typeR
     		subu.:
     				lb $t4, n1
     				lb $t9, n0
     				sb $t9, 0($s0)
     				sb $t9, 1($s0)
     				sb $t9, 2($s0)
     				sb $t9, 3($s0)
     				sb $t9, 4($s0)
     				sb $t9, 5($s0)
     				#-----SHMT
     				sb $t9, 21($s0)
     				sb $t9, 22($s0)
     				sb $t9, 23($s0)
     				sb $t9, 24($s0)
     				sb $t9, 25($s0)
     				#-----FUNCT
     				sb $t4, 26($s0)
     				sb $t9, 27($s0)
     				sb $t9, 28($s0)
     				sb $t9, 29($s0)
     				sb $t4, 30($s0)
     				sb $t4, 31($s0)
     				j typeR
     		
     	compara_o:   		#caracteres a comparar: $t4 / inst: $a2_____________________________
     		lb $t0 , 0($a2)
     		lb $t4, o
     		beq $t0, $t4, o_
     		jr $ra
     		o_:
     			lb $t0 , 1($a2)
     			lb $t4, r
     			beq $t0, $t4, or_
     			j rong_inst
     			
     		or_:	
     			lb $t0 , 2($a2)
     			beq $t0, $zero, or.	#inst = or(op:000000) SMT(00000)FUNCT(100101)
     			lb $t4, i
     			beq $t0, $t4, ori.	#inst = ori(op:001101) 
     			j rong_inst
     		
     		or.:
     				lb $t4, n1
     				lb $t9, n0
     				sb $t9, 0($s0)
     				sb $t9, 1($s0)
     				sb $t9, 2($s0)
     				sb $t9, 3($s0)
     				sb $t9, 4($s0)
     				sb $t9, 5($s0)
     				#-----SHMT
     				sb $t9, 21($s0)
     				sb $t9, 22($s0)
     				sb $t9, 23($s0)
     				sb $t9, 24($s0)
     				sb $t9, 25($s0)
     				#-----FUNCT
     				sb $t4, 26($s0)
     				sb $t9, 27($s0)
     				sb $t9, 28($s0)
     				sb $t4, 29($s0)
     				sb $t9, 30($s0)
     				sb $t4, 31($s0)
     				j typeR
     		ori.:
     				lb $t4, n1
     				lb $t9, n0
     				sb $t9, 0($s0)
     				sb $t9, 1($s0)
     				sb $t4, 2($s0)
     				sb $t4, 3($s0)
     				sb $t9, 4($s0)
     				sb $t4, 5($s0)
     				#---IMM
     				sb $t9, 16($s0)
     				sb $t9, 17($s0)
     				sb $t9, 18($s0)
     				sb $t9, 19($s0)
     				sb $t9, 20($s0)
     				sb $t9, 21($s0)
     				sb $t9, 22($s0)
     				sb $t9, 23($s0)
     				sb $t9, 24($s0)
     				sb $t9, 25($s0)
     				sb $t9, 26($s0)
     				sb $t9, 27($s0)
     				sb $t9, 28($s0)
     				sb $t9, 29($s0)
     				sb $t9, 30($s0)
     				sb $t9, 31($s0)
     				j typeI	
     		
     	compara_n:   		#caracteres a comparar: $t4 / inst: $a2_____________________________
     		lb $t0 , 0($a2)
     		lb $t4, n
     		beq $t0, $t4, n_
     		jr $ra
     		n_:
     			lb $t0 , 1($a2)
     			lb $t4, o
     			beq $t0, $t4, no_
     			j rong_inst
     		no_:
     			lb $t0 , 2($a2)
     			lb $t4, r
     			beq $t0, $t4, nor_	
     			j rong_inst
     		nor_:
     			lb $t0, 3($a2)
     			beq $t0, $zero, nor.	#inst = nor(op:)  typeR?
     			j rong_inst
     		
     		nor.:
     				lb $t4, n1
     				lb $t9, n0
     				sb $t9, 0($s0)
     				sb $t9, 1($s0)
     				sb $t9, 2($s0)
     				sb $t9, 3($s0)
     				sb $t9, 4($s0)
     				sb $t9, 5($s0)
     				#-----SHMT
     				sb $t9, 21($s0)
     				sb $t9, 22($s0)
     				sb $t9, 23($s0)
     				sb $t9, 24($s0)
     				sb $t9, 25($s0)
     				#-----FUNCT
     				sb $t4, 26($s0)
     				sb $t9, 27($s0)
     				sb $t9, 28($s0)
     				sb $t4, 29($s0)
     				sb $t4, 30($s0)
     				sb $t4, 31($s0)
     				j typeR

     	compara_m:   		#caracteres a comparar: $t4 / inst: $a2_____________________________
     		lb $t0 , 0($a2)
     		lb $t4, m
     		beq $t0, $t4, m_
     		jr $ra
     		m_:
     			lb $t0 , 1($a2)
     			lb $t4, u
     			beq $t0, $t4, mu_
     			lb $t4, o
     			beq $t0, $t4, mo_
     			lb $t4, f
     			beq $t0, $t4, mf_
     			j rong_inst
     		mo_:
     			lb $t0 , 2($a2)
     			lb $t4, v
     			beq $t0, $t4, mov_
     			j rong_inst
     			
     		mov_:
     			lb $t0 , 3($a2)
     			lb $t4, n
     			beq $t0, $t4, movn.	#inst = movn(op:000000) (00000)(001011) typeR?
     			j rong_inst
     			
     		mf_:
     			lb $t0 , 2($a2)
     			lb $t4, h
     			beq $t0, $t4, mfh_
     			lb $t4, l
     			beq $t0, $t4, mfl_
     			j rong_inst
     		mfl_:
     			lb $t0 , 3($a2)
     			lb $t4, o
     			beq $t0, $t4, mflo.	#inst = mflo(op:000000) (00000)(010010)
     			j rong_inst
     		mfh_:
     			lb $t0 , 3($a2)
     			lb $t4, i
     			beq $t0, $t4, mfhi.	#inst = mfhiSO TEM O RD(op:000000) (00 0000 0000)(00000)(010000)
     			j rong_inst
     			
     		mu_:
     			lb $t0 , 2($a2)
     			lb $t4, l
     			beq $t0, $t4, mul_
     			j rong_inst
     		mul_:
     			lb $t0 , 3($a2)
     			beq $t0, $zero, mul.	#inst = mul(op:011100) (00000)(000010) typeR?
     			lb $t4, t
     			beq $t0, $t4, mult.	#inst = mult(op:000000) (00 0000 0000)(011000)
     			j rong_inst
    
     		movn.:
     				lb $t4, n1
     				lb $t9, n0
     				sb $t9, 0($s0)
     				sb $t9, 1($s0)
     				sb $t9, 2($s0)
     				sb $t9, 3($s0)
     				sb $t9, 4($s0)
     				sb $t9, 5($s0)
     				#-----SHMT
     				sb $t9, 21($s0)
     				sb $t9, 22($s0)
     				sb $t9, 23($s0)
     				sb $t9, 24($s0)
     				sb $t9, 25($s0)
     				#-----FUNCT
     				sb $t9, 26($s0)
     				sb $t9, 27($s0)
     				sb $t4, 28($s0)
     				sb $t9, 29($s0)
     				sb $t4, 30($s0)
     				sb $t4, 31($s0)
     				j typeR
     		mflo.:		#----************** RS e RT = 0

     				lb $t4, n1
     				lb $t9, n0
     				sb $t9, 0($s0)
     				sb $t9, 1($s0)
     				sb $t9, 2($s0)
     				sb $t9, 3($s0)
     				sb $t9, 4($s0)
     				sb $t9, 5($s0)
     				sb $t9, 6($s0)
     				sb $t9, 7($s0)
     				sb $t9, 8($s0)
     				sb $t9, 9($s0)
     				sb $t9, 10($s0)
     				sb $t9, 11($s0)
     				sb $t9, 12($s0)
     				sb $t9, 13($s0)
     				sb $t9, 14($s0)
     				sb $t9, 15($s0)

     				#-----SHMT
     				sb $t9, 21($s0)
     				sb $t9, 22($s0)
     				sb $t9, 23($s0)
     				sb $t9, 24($s0)
     				sb $t9, 25($s0)
     				#-----FUNCT
     				sb $t9, 26($s0)
     				sb $t4, 27($s0)
     				sb $t9, 28($s0)
     				sb $t9, 29($s0)
     				sb $t4, 30($s0)
     				sb $t9, 31($s0)
     				j typeR
     		mfhi.:		#----************** RS e RT = 0
     				lb $t4, n1
     				lb $t9, n0
     				sb $t9, 0($s0)
     				sb $t9, 1($s0)
     				sb $t9, 2($s0)
     				sb $t9, 3($s0)
     				sb $t9, 4($s0)
     				sb $t9, 5($s0)
     				sb $t9, 6($s0)
     				sb $t9, 7($s0)
     				sb $t9, 8($s0)
     				sb $t9, 9($s0)
     				sb $t9, 10($s0)
     				sb $t9, 11($s0)
     				sb $t9, 12($s0)
     				sb $t9, 13($s0)
     				sb $t9, 14($s0)
     				sb $t9, 15($s0)

     				#-----SHMT
     				sb $t9, 21($s0)
     				sb $t9, 22($s0)
     				sb $t9, 23($s0)
     				sb $t9, 24($s0)
     				sb $t9, 25($s0)
     				#-----FUNCT
     				sb $t9, 26($s0)
     				sb $t4, 27($s0)
     				sb $t9, 28($s0)
     				sb $t9, 29($s0)
     				sb $t9, 30($s0)
     				sb $t9, 31($s0)
     				j typeR
     		mul.:
     				lb $t4, n1
     				lb $t9, n0
     				sb $t9, 0($s0)
     				sb $t4, 1($s0)
     				sb $t4, 2($s0)
     				sb $t4, 3($s0)
     				sb $t9, 4($s0)
     				sb $t9, 5($s0)
     				#-----SHMT
     				sb $t9, 21($s0)
     				sb $t9, 22($s0)
     				sb $t9, 23($s0)
     				sb $t9, 24($s0)
     				sb $t9, 25($s0)
     				#-----FUNCT
     				sb $t9, 26($s0)
     				sb $t9, 27($s0)
     				sb $t9, 28($s0)
     				sb $t9, 29($s0)
     				sb $t4, 30($s0)
     				sb $t9, 31($s0)
     				j typeR	
     		mult.:		#-------*********** sem RD
     				lb $t4, n1
     				lb $t9, n0
     				sb $t9, 0($s0)
     				sb $t9, 1($s0)
     				sb $t9, 2($s0)
     				sb $t9, 3($s0)
     				sb $t9, 4($s0)
     				sb $t9, 5($s0)
     				#-----SHMT
     				sb $t9, 16($s0)
     				sb $t9, 17($s0)
     				sb $t9, 18($s0)
     				sb $t9, 19($s0)
     				sb $t9, 20($s0)
     				sb $t9, 21($s0)
     				sb $t9, 22($s0)
     				sb $t9, 23($s0)
     				sb $t9, 24($s0)
     				sb $t9, 25($s0)
     				#-----FUNCT
     				sb $t9, 26($s0)
     				sb $t4, 27($s0)
     				sb $t4, 28($s0)
     				sb $t9, 29($s0)
     				sb $t9, 30($s0)
     				sb $t9, 31($s0)
     				#-----
     				j typeR	
     		
     	compara_b:   		#caracteres a comparar: $t4 / inst: $a2_____________________________
     		lb $t0 , 0($a2)
     		lb $t4, b
     		beq $t0, $t4, b_
     		jr $ra
     		b_:
     			lb $t0 , 1($a2)
     			lb $t4, e
     			beq $t0, $t4, be_
     			lb $t4, n
     			beq $t0, $t4, bn_
     			lb $t4, g
     			beq $t0, $t4, bg_
     			j rong_inst
     		bn_:
     			lb $t0 , 2($a2)
     			lb $t4, e
     			beq $t0, $t4, bne.	#inst = bne(op:000101) 
     			j rong_inst
     			
     		be_:
     			lb $t0 , 2($a2)
     			lb $t4, q
     			beq $t0, $t4, beq.	#inst = beq(op:000100) 
     			j rong_inst
     			
     			
		bg_:
			lb $t0 , 2($a2)
     			lb $t4, e
     			beq $t0, $t4, bge_
     			j rong_inst
     		bge_:
			lb $t0 , 3($a2)
     			lb $t4, z
     			beq $t0, $t4, bgez_
     			j rong_inst
     		bgez_:
			lb $t0 , 4($a2)
     			beq $t0, $zero, bgez.	#inst = bgez(op:000001) (00001) typeR?
     			lb $t4, a
     			beq $t0, $t4, bgeza_
     			j rong_inst
     		bgeza_:
     			lb $t0 , 5($a2)
     			lb $t4, l
     			beq $t0, $t4, bgezal.	#inst = bgezal(op:000001) (10001) typeR?
     			j rong_inst
     		bne.:
     				lb $t4, n1
     				lb $t9, n0
     				sb $t9, 0($s0)
     				sb $t9, 1($s0)
     				sb $t9, 2($s0)
     				sb $t4, 3($s0)
     				sb $t9, 4($s0)
     				sb $t4, 5($s0)
     				j typeI	
     		beq.:
     				lb $t4, n1
     				lb $t9, n0
     				sb $t9, 0($s0)
     				sb $t9, 1($s0)
     				sb $t9, 2($s0)
     				sb $t4, 3($s0)
     				sb $t9, 4($s0)
     				sb $t9, 5($s0)
     				j typeI	
     		bgez.:
     				lb $t4, n1
     				lb $t9, n0
     				sb $t9, 0($s0)
     				sb $t9, 1($s0)
     				sb $t9, 2($s0)
     				sb $t9, 3($s0)
     				sb $t9, 4($s0)
     				sb $t4, 5($s0)
     				#-----RT
     				sb $t9, 11($s0)
     				sb $t9, 12($s0)
     				sb $t9, 13($s0)
     				sb $t9, 14($s0)
     				sb $t4, 15($s0)
     				j typeI	
     		bgezal.:
     				lb $t4, n1
     				lb $t9, n0
     				sb $t9, 0($s0)
     				sb $t9, 1($s0)
     				sb $t9, 2($s0)
     				sb $t9, 3($s0)
     				sb $t9, 4($s0)
     				sb $t4, 5($s0)
     				#-----RT
     				sb $t4, 11($s0)
     				sb $t9, 12($s0)
     				sb $t9, 13($s0)
     				sb $t9, 14($s0)
     				sb $t4, 15($s0)
     				j typeI	
     		
     	compara_x:   		#caracteres a comparar: $t4 / inst: $a2_____________________________
     		lb $t0 , 0($a2)
     		lb $t4, x
     		beq $t0, $t4, x_
     		jr $ra
     		x_:
     			lb $t0 , 1($a2)
     			lb $t4, o
     			beq $t0, $t4, xo_
     			j rong_inst
     		xo_:
     			lb $t0 , 2($a2)
     			lb $t4, r
     			beq $t0, $t4, xor_
     			j rong_inst
     		xor_:
     			lb $t0 , 3($a2)
     			beq $t0, $zero, xor.	#inst = xor(op:000000) (00000)(100110)
     			lb $t4, i
     			beq $t0, $t4, xori.	#inst = xori(op:001110)  typeR?
     			j rong_inst
     		xor.:
     				lb $t4, n1
     				lb $t9, n0
     				sb $t9, 0($s0)
     				sb $t9, 1($s0)
     				sb $t9, 2($s0)
     				sb $t9, 3($s0)
     				sb $t9, 4($s0)
     				sb $t9, 5($s0)
     				#-----SHMT
     				sb $t9, 21($s0)
     				sb $t9, 22($s0)
     				sb $t9, 23($s0)
     				sb $t9, 24($s0)
     				sb $t9, 25($s0)
     				#-----FUNCT
     				sb $t4, 26($s0)
     				sb $t9, 27($s0)
     				sb $t9, 28($s0)
     				sb $t4, 29($s0)
     				sb $t4, 30($s0)
     				sb $t9, 31($s0)	
     				j typeR
     		xori.:
     				lb $t4, n1
     				lb $t9, n0
     				sb $t9, 0($s0)
     				sb $t9, 1($s0)
     				sb $t4, 2($s0)
     				sb $t4, 3($s0)
     				sb $t4, 4($s0)
     				sb $t9, 5($s0)
     				#--- IMM
     				sb $t9, 16($s0)
     				sb $t9, 17($s0)
     				sb $t9, 18($s0)
     				sb $t9, 19($s0)
     				sb $t9, 20($s0)
     				sb $t9, 21($s0)
     				sb $t9, 22($s0)
     				sb $t9, 23($s0)
     				sb $t9, 24($s0)
     				sb $t9, 25($s0)
     				sb $t9, 26($s0)
     				sb $t9, 27($s0)
     				sb $t9, 28($s0)
     				sb $t9, 29($s0)
     				sb $t9, 30($s0)
     				sb $t9, 31($s0)
     				j typeI	
     		
     			
     	compara_j:   		#caracteres a comparar: $t4 / inst: $a2_____________________________
     		lb $t0 , 0($a2)
     		lb $t4, j
     		beq $t0, $t4, j_
     		jr $ra
     		j_:
     			lb $t0 , 1($a2)
     			beq $t0, $zero, j.	#inst = j(op:000010) 
     			lb $t4, r
     			beq $t0, $t4, jr.	#inst = jr(op:) PESQUISAR
     			lb $t4, a
     			beq $t0, $t4, ja_
     			j rong_inst
     		ja_:
     			lb $t0 , 2($a2)
     			lb $t4, l
     			beq $t0, $t4, jal.	#inst = jal(op:000011) 
     			j rong_inst
     			
     		j.:
     				lb $t4, n1
     				lb $t9, n0
     				sb $t9, 0($s0)
     				sb $t9, 1($s0)
     				sb $t9, 2($s0)
     				sb $t9, 3($s0)
     				sb $t4, 4($s0)
     				sb $t9, 5($s0)
     				j typeJ
     		jr.:		#------------PESQUISAR
     				lb $t4, n1
     				lb $t9, n0
     				sb $t4, 0($s0)
     				sb $t9, 1($s0)
     				sb $t9, 2($s0)
     				sb $t9, 3($s0)
     				sb $t4, 4($s0)
     				sb $t4, 5($s0)
     				j typeJ	
     		jal.:		
     				lb $t4, n1
     				lb $t9, n0
     				sb $t9, 0($s0)
     				sb $t9, 1($s0)
     				sb $t9, 2($s0)
     				sb $t9, 3($s0)
     				sb $t4, 4($s0)
     				sb $t4, 5($s0)
     				j typeJ	
     		
     	compara_d:   		#caracteres a comparar: $t4 / inst: $a2_____________________________
     		lb $t0 , 0($a2)
     		lb $t4, d
     		beq $t0, $t4, d_
     		jr $ra
     		d_:
     			lb $t0 , 1($a2)
     			lb $t4, i
     			beq $t0, $t4, di_
     			j rong_inst
     		di_:
     			lb $t0 , 2($a2)
     			lb $t4, v
     			beq $t0, $t4, div.	#inst = div(op:000011) (000011) PESQUISAR
     			j rong_inst
     		div.:
     				lb $t4, n1
     				lb $t9, n0
     				sb $t9, 0($s0)
     				sb $t9, 1($s0)
     				sb $t9, 2($s0)
     				sb $t9, 3($s0)
     				sb $t9, 4($s0)
     				sb $t9, 5($s0)
     				#-----
     				sb $t9, 16($s0)
     				sb $t9, 17($s0)
     				sb $t9, 18($s0)
     				sb $t9, 19($s0)
     				sb $t9, 20($s0)
     				sb $t9, 21($s0)
     				sb $t9, 22($s0)
     				sb $t9, 23($s0)
     				sb $t9, 24($s0)
     				sb $t9, 25($s0)
     				#-----
     				sb $t9, 26($s0)
     				sb $t4, 27($s0)
     				sb $t4, 28($s0)
     				sb $t9, 29($s0)
     				sb $t4, 30($s0)
     				sb $t9, 31($s0)
     				j typeR	
     		
     	compara_c:   		#caracteres a comparar: $t4 / inst: $a2_____________________________
     		lb $t0 , 0($a2)
     		lb $t4, c
     		beq $t0, $t4, c_
     		jr $ra
     		c_:
     			lb $t0 , 1($a2)
     			lb $t4, l
     			beq $t0, $t4, cl_
     			j rong_inst
     		cl_:
     			lb $t0 , 2($a2)
     			lb $t4, o
     			beq $t0, $t4, clo.	#inst = clo(op:)  PESQUISAR typeR?
     			j rong_inst
		clo.:		#------------PESQUISAR
     				lb $t4, n1
     				lb $t9, n0
     				sb $t4, 0($s0)
     				sb $t9, 1($s0)
     				sb $t9, 2($s0)
     				sb $t9, 3($s0)
     				sb $t4, 4($s0)
     				sb $t4, 5($s0)
     				j typeR
     		
#--------------------------------------------------------------------------------------------

     	typeR:				#$t5 = arg1_buffer / $t6 = arg2_buffer / $t7 = arg3_buffer
     		

     		jal Rreseta_arg1
     		jal Rreseta_arg2
     		jal Rreseta_arg3
     		
     		lb $t4, virg
     		lb $t2, lf
     		li $t0, 0
     		jal pega_reg
     		li $t0, 0		#zera o contador de vírgulas
		sb $zero, 0($t5)	#Coloca "Null" no fim do arg1
		sb $zero, 0($t6)	#Coloca "Null" no fim do arg2
		sb $zero, 0($t7)	#Coloca "Null" no fim do arg3
		
#		la $a0, arg1_buffer
#     		li $v0, 4
#     		syscall
#		la $a0, arg2_buffer
#     		li $v0, 4
#     		syscall
#     		la $a0, arg3_buffer
#     		li $v0, 4
#     		syscall
     		#lb $t8, num_instrucoes
     		#li $t9, 1
    		#beq $t9, $t8, done
     		j arg1_bin			#começa a converter os argumentos para binário
		
     	typeI:
     		bnez $s5, Ireseta_arg1
     		bnez $s6, Ireseta_arg2
     		bnez $s7, Ireseta_arg3

     		lb $t4, virg
     		lb $t2, lf
     		li $t0, 0		#zera o contador de vírgulas
     		jal pega_reg	
		sb $zero, 0($t5)	#Coloca "Null" no fim do arg1
		sb $zero, 0($t6)	#Coloca "Null" no fim do arg2
		sb $zero, 0($t7)	#Coloca "Null" no fim do arg3
     		#la $a0, arg1_buffer
     		#li $v0, 4		#Imprime arg1
		#syscall
		#la $a0, arg2_buffer
    		#li $v0, 4		#Imprime arg2
		#syscall
		#la $a0, arg3_buffer
     		#li $v0, 4		#Imprime arg3
		#syscall
     		j arg1_bin
     		
     	typeI_li:				#arg1= reg1, arg2=primeira metade do HEX(IMM-lui), arg2=primeira metade do HEX(IMM-ori)
     		bnez $s5, Ireseta_arg1
     		bnez $s6, Ireseta_arg2
     		bnez $s7, Ireseta_arg3

     		lb $t4, virg
     		lb $t2, lf
     		li $t0, 0		#zera o contador de vírgulas
     		jal pega_reg
		sb $zero, 0($t5)	#Coloca "Null" no fim do arg1
		sb $zero, 0($t6)	#Coloca "Null" no fim do arg2
		sb $zero, 0($t7)	#Coloca "Null" no fim do arg3
     		la $a0, arg1_buffer
     		li $v0, 4		#Imprime arg1
		syscall
		la $a0, arg2_buffer
    		li $v0, 4		#Imprime arg2
		syscall
		la $a0, arg3_buffer
     		li $v0, 4		#Imprime arg3
		syscall
		j done
		j arg1_bin			#começa a converter os argumentos para binário
		
	typeJ:
		lb $t2, lf
     		j done

	Rreseta_arg1:
     		sub $t5, $t5, $s5
     		li $s5, 0
     		jr $ra
     	Rreseta_arg2:
     		sub $t6, $t6, $s6
     		li $s6, 0
     		jr $ra
     	Rreseta_arg3:
		sub $t7, $t7, $s7
     		li $s7, 0
     		jr $ra
	Ireseta_arg1:
     		li $s5, 0
     		jr $ra
     	Ireseta_arg2:
     		sub $t6, $t6, $s6
     		li $s6, 0
     		jr $ra
     	Ireseta_arg3:
		sub $t7, $t7, $s7
     		li $s7, 0
     		jr $ra
     		
	pega_reg:
		li $t8, 1
		li $t9, 2
		beqz $t0, add_arg1		#se 0 virgulas, coloca no arg1
		beq $t0, $t8, add_arg2		#se 1 virgulas, coloca no arg2
		beq $t0, $t9 add_arg3		#se 2 virgulas, coloca no arg3
		

	add_arg1:
		lb $t4, virg
		lb $t3, 0($a1)
		beq $t3, $t4, proximo_arg		#se for vírgula
		beq $t3, $t2, fim_da_linha
		sb $t3, 0($t5)
		addi $a1, $a1, 1		#proxima letra buffer.text
		addi $t5, $t5, 1		#incrementa posição arg1_buffer
		addi $s5, $s5, 1		#contador de caracteres +1
		j add_arg1
	add_arg2:
		lb $t4, par			#carrega o caractere "("
		lb $t3, 1($a1)
		beq $t3, $t4, arg2_address	#se arg2 for um adress (preenche arg 2 e 3 juntos)
		lb $t4, x			#carrega o caractere "x" 
		lb $t3, 1($a1)
		beq $t3, $t4, arg2_hex		#se arg2 for um hex (preenche arg2 e 3 juntos)
		lb $t4, virg
		lb $t3, 0($a1)
		
		beq $t3, $t4, proximo_arg
		beq $t3, $t2, fim_da_linha	#se for lf
		sb $t3, 0($t6)
		addi $a1, $a1, 1		#proxima letra buffer.text
		addi $t6, $t6, 1		#incrementa posição arg2_buffer
		addi $s6, $s6, 1		#contador de caracteres +1
		j add_arg2
	arg2_hex:
		lb $t3, 2($a1)			#coloca a primeira metade de do hex no arg2
		sb $t3, 0($t6)
		addi $t6, $t6, 1
		lb $t3, 3($a1)	
		sb $t3, 0($t6)
		addi $t6, $t6, 1
		lb $t3, 4($a1)	
		sb $t3, 0($t6)
		addi $t6, $t6, 1
		lb $t3, 5($a1)			
		sb $t3, 0($t6)
		addi $t6, $t6, 1
		lb $t3, 6($a1)			#coloca a segunda metade de do hex no arg3	
		sb $t3, 0($t7)
		addi $t7, $t7, 1
		lb $t3, 7($a1)			
		sb $t3, 0($t7)
		addi $t7, $t7, 1
		lb $t3, 8($a1)	
		sb $t3, 0($t7)
		addi $t7, $t7, 1
		lb $t3, 9($a1)			
		sb $t3, 0($t7)
		addi $t7, $t7, 1
		addi $s6, $s6, 4
		addi $t7, $t7, 4
		j fim_da_linha_hex
	arg2_address:				
		lb $t3, 0($a1)			#coloca a base no arg3
		sb $t3, 0($t7)
		addi $s7, $s7, 1
		lb $t3, 2($a1)			#coloca o offet no arg2
		sb $t3, 0($t6)
		addi $t6, $t6, 1
		lb $t3, 3($a1)
		sb $t3, 0($t6)
		addi $t6, $t6, 1
		lb $t3, 4($a1)
		sb $t3, 0($t6)
		addi $t6, $t6, 1
		addi $s6, $s6, 3
		addi $t7, $t7, 3
		j fim_da_linha_adress
	add_arg3:
		lb $t4, virg
		lb $t3, 0($a1)
		beq $t3, $t2, fim_da_linha	#se for lf
		sb $t3, 0($t7)
		addi $a1, $a1, 1		#proxima letra buffer.text
		addi $t7, $t7, 1		#incrementa posição arg3_buffer
		addi $s7, $s7, 1		#contador de caracteres +1
		j add_arg3
	proximo_arg:
		addi $t0, $t0, 1		#Soma 1 virgula
		addi $a1, $a1, 2		#primeiro caractere do proximo argumento
		j pega_reg
		
	fim_da_linha:				#se a linha acabar no segundo argumento
		addi $a1, $a1, 1		#olha para a proxima linha
		jr $ra
	fim_da_linha_adress:
		addi $a1, $a1, 7		#olha para a proxima linha
		jr $ra
	fim_da_linha_hex:
		addi $a1, $a1, 11		#olha para a proxima linha
		jr $ra
		
	rong_inst:	#instrução para printar algo na tela se encontrar uma instrução inexistente
		li $v0, 10
		syscall
#-----------------------------------------------CONVERTENDO PARA BINARIO---------------------------#
	
		
		
		arg1_bin:			# Está assumindo que tudo neste campo começa com $
		la $a3, arg1_buffer
		lb $t2, 1($a3)
		lb $t4, a
		beq $t2, $t4, $r1a_		#se a segunda letra é "a"
		lb $t4, v
		beq $t2, $t4, $r1v_		#se a segunda letra é "v"
		lb $t4, t
		beq $t2, $t4, $r1t_		#se a segunda letra é "t"
		lb $t4, s
		beq $t2, $t4, $r1s_		#se a segunda letra é "s"
		#printa erro se for outro número
		j done
			
			$r1a_:
				lb $t2, 2($a3)
				lb $t4, n0
				beq $t2, $t4, $r1a_0		#se o num do registrador for 0:
				lb $t4, n1
				beq $t2, $t4, $r1a_1		#se o num do registrador for 1:
				lb $t4, n2
				beq $t2, $t4, $r1a_2		#se o num do registrador for 2:
				lb $t4, n3
				beq $t2, $t4, $r1a_3		#se o num do registrador for 3:
				lb $t4, t
				beq $t2, $t4, $r1a_t		#se o num do registrador for t:
				#printa erro se for outro número
				j done
				$r1a_t:		
					jal Rreseta_arg1
					lb $t4, n0
					sb $t4, 0($t5)
					sb $t4, 1($t5)
					sb $t4, 2($t5)
					sb $t4, 3($t5)
					lb $t4, n1
					sb $t4, 4($t5)
					sb $zero, 5($t5)
					#la $t8, ($t5)
					#move $s0, $t8
					j arg2_bin
					
				$r1a_0:
					jal Rreseta_arg1
					lb $t4, n0
					sb $t4, 0($t5)
					sb $t4, 1($t5)
					lb $t4, n1
					sb $t4, 2($t5)
					lb $t4, n0
					sb $t4, 3($t5)
					sb $t4, 4($t5)
					sb $zero, 5($t5)

					#la $t8, ($t5)
					#move $s0, $t8
					j arg2_bin
				$r1a_1:
					jal Rreseta_arg1
					lb $t4, n0
					sb $t4, 0($t5)
					sb $t4, 1($t5)
					lb $t4, n1
					sb $t4, 2($t5)
					lb $t4, n0
					sb $t4, 3($t5)
					lb $t4, n1
					sb $t4, 4($t5)
					sb $zero, 5($t5)

					#la $t8, ($t5)
					#move $s0, $t8
					j arg2_bin
				$r1a_2:					
					jal Rreseta_arg1
					lb $t4, n0
					sb $t4, 0($t5)
					sb $t4, 1($t5)
					lb $t4, n1
					sb $t4, 2($t5)
					sb $t4, 3($t5)
					lb $t4, n0
					sb $t4, 4($t5)
					sb $zero, 5($t5)

					#la $t8, ($t5)
					#move $s0, $t8
					j arg2_bin
				$r1a_3:
					jal Rreseta_arg1
					lb $t4, n0
					sb $t4, 0($t5)
					sb $t4, 1($t5)
					lb $t4, n1
					sb $t4, 2($t5)
					sb $t4, 3($t5)
					sb $t4, 4($t5)
					sb $zero, 5($t5)

					#la $t8, ($t5)
					#move $s0, $t8
					j arg2_bin
				
			$r1v_:
				lb $t2, 2($a3)
				lb $t4, n0
				beq $t2, $t4, $r1v_0		#se o num do registrador for 0:
				lb $t4, n1
				beq $t2, $t4, $r1v_1		#se o num do registrador for 1:
				#printa erro se for outro número
				j done
				$r1v_0:
					jal Rreseta_arg1
					lb $t4, n0
					sb $t4, 0($t5)
					sb $t4, 1($t5)
					sb $t4, 2($t5)
					lb $t4, n1
					sb $t4, 3($t5)
					lb $t4, n0
					sb $t4, 4($t5)
					sb $zero, 5($t5)

					#la $t8, ($t5)
					#move $s0, $t8
					j arg2_bin
				$r1v_1:
					jal Rreseta_arg1
					lb $t4, n0
					sb $t4, 0($t5)
					sb $t4, 1($t5)
					sb $t4, 2($t5)
					lb $t4, n1
					sb $t4, 3($t5)
					sb $t4, 4($t5)
					sb $zero, 5($t5)

					#la $t8, ($t5)
					#move $s0, $t8
					j arg2_bin
					
			$r1t_:
				lb $t2, 2($a3)
				lb $t4, n0
				beq $t2, $t4, $r1t_0		#se o num do registrador for 0:
				lb $t4, n1
				beq $t2, $t4, $r1t_1		#se o num do registrador for 1:
				lb $t4, n2
				beq $t2, $t4, $r1t_2		#se o num do registrador for 2:
				lb $t4, n3
				beq $t2, $t4, $r1t_3		#se o num do registrador for 3:
				lb $t4, n4
				beq $t2, $t4, $r1t_4		#se o num do registrador for 4:
				lb $t4, n5
				beq $t2, $t4, $r1t_5		#se o num do registrador for 5:
				lb $t4, n6
				beq $t2, $t4, $r1t_6		#se o num do registrador for 6:
				lb $t4, n7
				beq $t2, $t4, $r1t_7		#se o num do registrador for 7:
				lb $t4, n8
				beq $t2, $t4, $r1t_8		#se o num do registrador for 8:
				lb $t4, n9
				beq $t2, $t4, $r1t_9		#se o num do registrador for 9:
				#printa erro se for outro número
				j done
				$r1t_0:
					jal Rreseta_arg1
					lb $t4, n0
					sb $t4, 0($t5)
					lb $t4, n1
					sb $t4, 1($t5)
					lb $t4, n0
					sb $t4, 2($t5)
					sb $t4, 3($t5)
					sb $t4, 4($t5)
					sb $zero, 5($t5)

					#la $t8, ($t5)
					#move $s0, $t8
					j arg2_bin
				$r1t_1:
					jal Rreseta_arg1
					lb $t4, n0
					sb $t4, 0($t5)
					lb $t4, n1
					sb $t4, 1($t5)
					lb $t4, n0
					sb $t4, 2($t5)
					sb $t4, 3($t5)
					lb $t4, n1
					sb $t4, 4($t5)
					sb $zero, 5($t5)

					#la $t8, ($t5)
					#move $s0, $t8
					j arg2_bin
				$r1t_2:					
					jal Rreseta_arg1
					lb $t4, n0
					sb $t4, 0($t5)
					lb $t4, n1
					sb $t4, 1($t5)
					lb $t4, n0
					sb $t4, 2($t5)
					lb $t4, n1
					sb $t4, 3($t5)
					lb $t4, n0
					sb $t4, 4($t5)
					sb $zero, 5($t5)

					#la $t8, ($t5)
					#move $s0, $t8
					j arg2_bin
				$r1t_3:
					jal Rreseta_arg1
					lb $t4, n0
					sb $t4, 0($t5)
					lb $t4, n1
					sb $t4, 1($t5)
					lb $t4, n0
					sb $t4, 2($t5)
					lb $t4, n1
					sb $t4, 3($t5)
					sb $t4, 4($t5)
					sb $zero, 5($t5)

					#la $t8, ($t5)
					#move $s0, $t8
					j arg2_bin
				$r1t_4:
					jal Rreseta_arg1
					lb $t4, n0
					sb $t4, 0($t5)
					lb $t4, n1
					sb $t4, 1($t5)
					sb $t4, 2($t5)
					lb $t4, n0
					sb $t4, 3($t5)
					sb $t4, 4($t5)
					sb $zero, 5($t5)

					#la $t8, ($t5)
					#move $s0, $t8
					j arg2_bin
				$r1t_5:					
					jal Rreseta_arg1
					lb $t4, n0
					sb $t4, 0($t5)
					lb $t4, n1
					sb $t4, 1($t5)
					sb $t4, 2($t5)
					lb $t4, n0
					sb $t4, 3($t5)
					lb $t4, n1
					sb $t4, 4($t5)
					sb $zero, 5($t5)

					#la $t8, ($t5)
					#move $s0, $t8
					j arg2_bin
				$r1t_6:
					jal Rreseta_arg1
					lb $t4, n0
					sb $t4, 0($t5)
					lb $t4, n1
					sb $t4, 1($t5)
					sb $t4, 2($t5)
					sb $t4, 3($t5)
					lb $t4, n0
					sb $t4, 4($t5)
					sb $zero, 5($t5)

					#la $t8, ($t5)
					#move $s0, $t8
					j arg2_bin
				$r1t_7:
					jal Rreseta_arg1
					lb $t4, n0
					sb $t4, 0($t5)
					lb $t4, n1
					sb $t4, 1($t5)
					sb $t4, 2($t5)
					sb $t4, 3($t5)
					sb $t4, 4($t5)
					sb $zero, 5($t5)

					#la $t8, ($t5)
					#move $s0, $t8
					j arg2_bin
				$r1t_8:					
					jal Rreseta_arg1
					lb $t4, n1
					sb $t4, 0($t5)
					sb $t4, 1($t5)
					lb $t4, n0
					sb $t4, 2($t5)
					sb $t4, 3($t5)
					sb $t4, 4($t5)
					sb $zero, 5($t5)

					#la $t8, ($t5)
					#move $s0, $t8
					j arg2_bin
				$r1t_9:
					jal Rreseta_arg1
					lb $t4, n1
					sb $t4, 0($t5)
					sb $t4, 1($t5)
					lb $t4, n0
					sb $t4, 2($t5)
					sb $t4, 3($t5)
					lb $t4, n1
					sb $t4, 4($t5)
					sb $zero, 5($t5)

					#la $t8, ($t5)
					#move $s0, $t8
					j arg2_bin
			$r1s_:
				lb $t2, 2($a3)
				lb $t4, n0
				beq $t2, $t4, $r1s_0		#se o num do registrador for 0:
				lb $t4, n1
				beq $t2, $t4, $r1s_1		#se o num do registrador for 1:
				lb $t4, n2
				beq $t2, $t4, $r1s_2		#se o num do registrador for 2:
				lb $t4, n3
				beq $t2, $t4, $r1s_3		#se o num do registrador for 3:
				lb $t4, n4
				beq $t2, $t4, $r1s_4		#se o num do registrador for 4:
				lb $t4, n5
				beq $t2, $t4, $r1s_5		#se o num do registrador for 5:
				lb $t4, n6
				beq $t2, $t4, $r1s_6		#se o num do registrador for 6:
				lb $t4, n7
				beq $t2, $t4, $r1s_7		#se o num do registrador for 7:
				#printa erro se for outro número
				j done
				$r1s_0:
					jal Rreseta_arg1
					lb $t4, n1
					sb $t4, 0($t5)
					lb $t4, n0
					sb $t4, 1($t5)
					sb $t4, 2($t5)
					sb $t4, 3($t5)
					sb $t4, 4($t5)
					sb $zero, 5($t5)

					#la $t8, ($t5)
					#move $s0, $t8
					j arg2_bin
				$r1s_1:
					jal Rreseta_arg1
					lb $t4, n1
					sb $t4, 0($t5)
					lb $t4, n0
					sb $t4, 1($t5)
					lb $t4, n0
					sb $t4, 2($t5)
					sb $t4, 3($t5)
					lb $t4, n1
					sb $t4, 4($t5)
					sb $zero, 5($t5)

					#la $t8, ($t5)
					#move $s0, $t8
					j arg2_bin
				$r1s_2:					
					jal Rreseta_arg1
					lb $t4, n1
					sb $t4, 0($t5)
					lb $t4, n0
					sb $t4, 1($t5)
					sb $t4, 2($t5)
					lb $t4, n1
					sb $t4, 3($t5)
					lb $t4, n0
					sb $t4, 4($t5)
					sb $zero, 5($t5)

					#la $t8, ($t5)
					#move $s0, $t8
					j arg2_bin
				$r1s_3:
					jal Rreseta_arg1
					lb $t4, n1
					sb $t4, 0($t5)
					lb $t4, n0
					sb $t4, 1($t5)
					sb $t4, 2($t5)
					lb $t4, n1
					sb $t4, 3($t5)
					sb $t4, 4($t5)
					sb $zero, 5($t5)

					#la $t8, ($t5)
					#move $s0, $t8
					j arg2_bin
				$r1s_4:
					jal Rreseta_arg1
					lb $t4, n1
					sb $t4, 0($t5)
					lb $t4, n0
					sb $t4, 1($t5)
					lb $t4, n1
					sb $t4, 2($t5)
					lb $t4, n0
					sb $t4, 3($t5)
					sb $t4, 4($t5)
					sb $zero, 5($t5)

					#la $t8, ($t5)
					#move $s0, $t8
					j arg2_bin
				$r1s_5:					
					jal Rreseta_arg1
					lb $t4, n1
					sb $t4, 0($t5)
					lb $t4, n0
					sb $t4, 1($t5)
					lb $t4, n1
					sb $t4, 2($t5)
					lb $t4, n0
					sb $t4, 3($t5)
					lb $t4, n1
					sb $t4, 4($t5)
					sb $zero, 5($t5)

					#la $t8, ($t5)
					#move $s0, $t8
					j arg2_bin
				$r1s_6:
					jal Rreseta_arg1
					lb $t4, n1
					sb $t4, 0($t5)
					lb $t4, n0
					sb $t4, 1($t5)
					lb $t4, n1
					sb $t4, 2($t5)
					sb $t4, 3($t5)
					lb $t4, n0
					sb $t4, 4($t5)
					sb $zero, 5($t5)

					#la $t8, ($t5)
					#move $s0, $t8
					j arg2_bin
				$r1s_7:
					jal Rreseta_arg1
					lb $t4, n1
					sb $t4, 0($t5)
					lb $t4, n0
					sb $t4, 1($t5)
					lb $t4, n1
					sb $t4, 2($t5)
					sb $t4, 3($t5)
					sb $t4, 4($t5)
					sb $zero, 5($t5)

					#la $t8, ($t5)
					#move $s0, $t8
					j arg2_bin		
		arg2_bin:
		#la $a0, ($a3)
		#li $v0, 4
		#syscall

		la $a3, arg2_buffer
		lb $t2, 1($a3)
		lb $t4, a
		beq $t2, $t4, $r2a_		#se a segunda letra é "a"
		lb $t4, v
		beq $t2, $t4, $r2v_		#se a segunda letra é "v"
		lb $t4, t
		beq $t2, $t4, $r2t_		#se a segunda letra é "t"
		lb $t4, s
		beq $t2, $t4, $r2s_		#se a segunda letra é "s"
		#lb $t4, x
		#beq $t2, $t4, copia_arg_hex 	#se a segunda letra é "x"(argumento em hexadecimal)
		li  $t4, 0				
		beq $t4, $s7, converteRHex 	#se for lf (sem reg2)
		#printa erro se for outro número
		j done

			$r2a_:
				lb $t2, 2($a3)
				lb $t4, n0
				beq $t2, $t4, $r2a_0		#se o num do registrador for 0:
				lb $t4, n1
				beq $t2, $t4, $r2a_1		#se o num do registrador for 1:
				lb $t4, n2
				beq $t2, $t4, $r2a_2		#se o num do registrador for 2:
				lb $t4, n3
				beq $t2, $t4, $r2a_3		#se o num do registrador for 3:
				lb $t4, t
				beq $t2, $t4, $r2a_t		#se o num do registrador for t:
				#printa erro se for outro número
				j done
				$r2a_t:
					jal Rreseta_arg2
					lb $t4, n0
					sb $t4, 0($t6)
					sb $t4, 1($t6)
					sb $t4, 2($t6)
					sb $t4, 3($t6)
					lb $t4, n1
					sb $t4, 4($t6)
					sb $zero, 5($t6)

					#la $t9, ($t6)
					j arg3_bin
				$r2a_0:
					jal Rreseta_arg2
					lb $t4, n0
					sb $t4, 0($t6)
					sb $t4, 1($t6)
					lb $t4, n1
					sb $t4, 2($t6)
					lb $t4, n0
					sb $t4, 3($t6)
					sb $t4, 4($t6)
					sb $zero, 5($t6)
					#la $t9, ($t6)
					j arg3_bin
				$r2a_1:
					jal Rreseta_arg2
					lb $t4, n0
					sb $t4, 0($t6)
					sb $t4, 1($t6)
					lb $t4, n1
					sb $t4, 2($t6)
					lb $t4, n0
					sb $t4, 3($t6)
					lb $t4, n1
					sb $t4, 4($t6)
					sb $zero, 5($t6)

					#la $t9, ($t6)
					j arg3_bin
				$r2a_2:					
					jal Rreseta_arg2
					lb $t4, n0
					sb $t4, 0($t6)
					sb $t4, 1($t6)
					lb $t4, n1
					sb $t4, 2($t6)
					sb $t4, 3($t6)
					lb $t4, n0
					sb $t4, 4($t6)
					sb $zero, 5($t6)

					#la $t9, ($t6)
					j arg3_bin
				$r2a_3:
					jal Rreseta_arg2
					lb $t4, n0
					sb $t4, 0($t6)
					sb $t4, 1($t6)
					lb $t4, n1
					sb $t4, 2($t6)
					sb $t4, 3($t6)
					sb $t4, 4($t6)
					sb $zero, 5($t6)

					#la $t9, ($t6)
					j arg3_bin
				
			$r2v_:
				lb $t2, 2($a3)
				lb $t4, n0
				beq $t2, $t4, $r2v_0		#se o num do registrador for 0:
				lb $t4, n1
				beq $t2, $t4, $r2v_1		#se o num do registrador for 1:
				#printa erro se for outro número
				j done
				$r2v_0:
					jal Rreseta_arg2
					lb $t4, n0
					sb $t4, 0($t6)
					sb $t4, 1($t6)
					sb $t4, 2($t6)
					lb $t4, n1
					sb $t4, 3($t6)
					lb $t4, n0
					sb $t4, 4($t6)
					sb $zero, 5($t6)

					#la $t9, ($t6)
					j arg3_bin
				$r2v_1:
					jal Rreseta_arg2
					lb $t4, n0
					sb $t4, 0($t6)
					sb $t4, 1($t6)
					sb $t4, 2($t6)
					lb $t4, n1
					sb $t4, 3($t6)
					sb $t4, 4($t6)
					sb $zero, 5($t6)

					#la $t9, ($t6)
					j arg3_bin
					
			$r2t_:
				lb $t2, 2($a3)
				lb $t4, n0
				beq $t2, $t4, $r2t_0		#se o num do registrador for 0:
				lb $t4, n1
				beq $t2, $t4, $r2t_1		#se o num do registrador for 1:
				lb $t4, n2
				beq $t2, $t4, $r2t_2		#se o num do registrador for 2:
				lb $t4, n3
				beq $t2, $t4, $r2t_3		#se o num do registrador for 3:
				lb $t4, n4
				beq $t2, $t4, $r2t_4		#se o num do registrador for 4:
				lb $t4, n5
				beq $t2, $t4, $r2t_5		#se o num do registrador for 5:
				lb $t4, n6
				beq $t2, $t4, $r2t_6		#se o num do registrador for 6:
				lb $t4, n7
				beq $t2, $t4, $r2t_7		#se o num do registrador for 7:
				lb $t4, n8
				beq $t2, $t4, $r2t_8		#se o num do registrador for 8:
				lb $t4, n9
				beq $t2, $t4, $r2t_9		#se o num do registrador for 9:
				#printa erro se for outro número
				j done
				$r2t_0:
					jal Rreseta_arg2
					lb $t4, n0
					sb $t4, 0($t6)
					lb $t4, n1
					sb $t4, 1($t6)
					lb $t4, n0
					sb $t4, 2($t6)
					sb $t4, 3($t6)
					sb $t4, 4($t6)
					sb $zero, 5($t6)

					#la $t9, ($t6)
					j arg3_bin
				$r2t_1:
					jal Rreseta_arg2
					lb $t4, n0
					sb $t4, 0($t6)
					lb $t4, n1
					sb $t4, 1($t6)
					lb $t4, n0
					sb $t4, 2($t6)
					sb $t4, 3($t6)
					lb $t4, n1
					sb $t4, 4($t6)
					sb $zero, 5($t6)

					#la $t9, ($t6)
					j arg3_bin
				$r2t_2:					
					jal Rreseta_arg2
					lb $t4, n0
					sb $t4, 0($t6)
					lb $t4, n1
					sb $t4, 1($t6)
					lb $t4, n0
					sb $t4, 2($t6)
					lb $t4, n1
					sb $t4, 3($t6)
					lb $t4, n0
					sb $t4, 4($t6)
					sb $zero, 5($t6)

					#la $t9, ($t6)
					j arg3_bin
				$r2t_3:
					jal Rreseta_arg2
					lb $t4, n0
					sb $t4, 0($t6)
					lb $t4, n1
					sb $t4, 1($t6)
					lb $t4, n0
					sb $t4, 2($t6)
					lb $t4, n1
					sb $t4, 3($t6)
					sb $t4, 4($t6)
					sb $zero, 5($t6)

					#la $t9, ($t6)
					j arg3_bin
				$r2t_4:
					jal Rreseta_arg2
					lb $t4, n0
					sb $t4, 0($t6)
					lb $t4, n1
					sb $t4, 1($t6)
					sb $t4, 2($t6)
					lb $t4, n0
					sb $t4, 3($t6)
					sb $t4, 4($t6)
					sb $zero, 5($t6)

					#la $t9, ($t6)
					j arg3_bin
				$r2t_5:					
					jal Rreseta_arg2
					lb $t4, n0
					sb $t4, 0($t6)
					lb $t4, n1
					sb $t4, 1($t6)
					sb $t4, 2($t6)
					lb $t4, n0
					sb $t4, 3($t6)
					lb $t4, n1
					sb $t4, 4($t6)
					sb $zero, 5($t6)

					#la $t8, ($t6)
					j arg3_bin
				$r2t_6:
					jal Rreseta_arg2
					lb $t4, n0
					sb $t4, 0($t6)
					lb $t4, n1
					sb $t4, 1($t6)
					sb $t4, 2($t6)
					sb $t4, 3($t6)
					lb $t4, n0
					sb $t4, 4($t6)
					sb $zero, 5($t6)

					#la $t9, ($t6)
					j arg3_bin
				$r2t_7:
					jal Rreseta_arg2
					lb $t4, n0
					sb $t4, 0($t6)
					lb $t4, n1
					sb $t4, 1($t6)
					sb $t4, 2($t6)
					sb $t4, 3($t6)
					sb $t4, 4($t6)
					sb $zero, 5($t6)

					#la $t9, ($t6)
					j arg3_bin
				$r2t_8:					
					jal Rreseta_arg2
					lb $t4, n1
					sb $t4, 0($t6)
					sb $t4, 1($t6)
					lb $t4, n0
					sb $t4, 2($t6)
					sb $t4, 3($t6)
					sb $t4, 4($t6)
					sb $zero, 5($t6)

					#la $t9, ($t6)
					j arg3_bin
				$r2t_9:
					jal Rreseta_arg2
					lb $t4, n1
					sb $t4, 0($t6)
					sb $t4, 1($t6)
					lb $t4, n0
					sb $t4, 2($t6)
					sb $t4, 3($t6)
					lb $t4, n1
					sb $t4, 4($t6)
					sb $zero, 5($t6)

					#la $t9, ($t6)
					j arg3_bin
			$r2s_:
				lb $t2, 2($a3)
				lb $t4, n0
				beq $t2, $t4, $r2s_0		#se o num do registrador for 0:
				lb $t4, n1
				beq $t2, $t4, $r2s_1		#se o num do registrador for 1:
				lb $t4, n2
				beq $t2, $t4, $r2s_2		#se o num do registrador for 2:
				lb $t4, n3
				beq $t2, $t4, $r2s_3		#se o num do registrador for 3:
				lb $t4, n4
				beq $t2, $t4, $r2s_4		#se o num do registrador for 4:
				lb $t4, n5
				beq $t2, $t4, $r2s_5		#se o num do registrador for 5:
				lb $t4, n6
				beq $t2, $t4, $r2s_6		#se o num do registrador for 6:
				lb $t4, n7
				beq $t2, $t4, $r2s_7		#se o num do registrador for 7:
				#printa erro se for outro número
				j done
				$r2s_0:
					jal Rreseta_arg2
					lb $t4, n1
					sb $t4, 0($t6)
					lb $t4, n0
					sb $t4, 1($t6)
					sb $t4, 2($t6)
					sb $t4, 3($t6)
					sb $t4, 4($t6)
					sb $zero, 5($t6)

					#la $t9, ($t6)
					j arg3_bin
				$r2s_1:
					jal Rreseta_arg2
					lb $t4, n1
					sb $t4, 0($t6)
					lb $t4, n0
					sb $t4, 1($t6)
					lb $t4, n0
					sb $t4, 2($t6)
					sb $t4, 3($t6)
					lb $t4, n1
					sb $t4, 4($t6)
					sb $zero, 5($t6)

					#la $t9, ($t6)
					j arg3_bin
				$r2s_2:					
					jal Rreseta_arg2
					lb $t4, n1
					sb $t4, 0($t6)
					lb $t4, n0
					sb $t4, 1($t6)
					sb $t4, 2($t6)
					lb $t4, n1
					sb $t4, 3($t6)
					lb $t4, n0
					sb $t4, 4($t6)
					sb $zero, 5($t6)

					#la $t9, ($t6)
					j arg3_bin
				$r2s_3:
					jal Rreseta_arg2
					lb $t4, n1
					sb $t4, 0($t6)
					lb $t4, n0
					sb $t4, 1($t6)
					sb $t4, 2($t6)
					lb $t4, n1
					sb $t4, 3($t6)
					sb $t4, 4($t6)
					sb $zero, 5($t6)

					#la $t9, ($t6)
					j arg3_bin
				$r2s_4:
					jal Rreseta_arg2
					lb $t4, n1
					sb $t4, 0($t6)
					lb $t4, n0
					sb $t4, 1($t6)
					lb $t4, n1
					sb $t4, 2($t6)
					lb $t4, n0
					sb $t4, 3($t6)
					sb $t4, 4($t6)
					sb $zero, 5($t6)

					#la $t9, ($t6)
					j arg3_bin
				$r2s_5:					
					jal Rreseta_arg2
					lb $t4, n1
					sb $t4, 0($t6)
					lb $t4, n0
					sb $t4, 1($t6)
					lb $t4, n1
					sb $t4, 2($t6)
					lb $t4, n0
					sb $t4, 3($t6)
					lb $t4, n1
					sb $t4, 4($t6)
					sb $zero, 5($t6)

					#la $t9, ($t6)
					j arg3_bin
				$r2s_6:
					jal Rreseta_arg2
					lb $t4, n1
					sb $t4, 0($t6)
					lb $t4, n0
					sb $t4, 1($t6)
					lb $t4, n1
					sb $t4, 2($t6)
					sb $t4, 3($t6)
					lb $t4, n0
					sb $t4, 4($t6)
					sb $zero, 5($t6)

					#la $t9, ($t6)
					j arg3_bin
				$r2s_7:
					jal Rreseta_arg2
					lb $t4, n1
					sb $t4, 0($t6)
					lb $t4, n0
					sb $t4, 1($t6)
					lb $t4, n1
					sb $t4, 2($t6)
					sb $t4, 3($t6)
					sb $t4, 4($t6)
					sb $zero, 5($t6)

					#la $t9, ($t6)
					j arg3_bin
					
		arg3_bin:
		#la $a0, ($a3)
		#i $v0, 4
		#syscall
		
		la $a3, arg3_buffer
		lb $t2, 0($a3)
		lb $t4, _$
		bne $t2, $t4, arg3_num

		lb $t2, 1($a3)
		lb $t4, z
		beq $t2, $t4, $r3z_		#se a segunda letra é "z"
		lb $t4, a
		beq $t2, $t4, $r3a_		#se a segunda letra é "a"
		lb $t4, v
		beq $t2, $t4, $r3v_		#se a segunda letra é "v"
		lb $t4, t
		beq $t2, $t4, $r3t_		#se a segunda letra é "t"
		lb $t4, s
		beq $t2, $t4, $r3s_		#se a segunda letra é "s"
		j done
		arg3_num:			#se o segundo caractere do argumento 3 for um número
			
			li  $t4, 0	#se for lf (sem reg3) ou (reg3 = 0)	
			beq $t4, $s7, converteRHex
			li $t8, 0
			
			# s7: n de digitos
			# $a3: número em string
			# Posso usar: $t4, $t2
			
			li $v0, 0 	# Armazenar inteiro final
			
			loop_determinar_inteiro_text:
				# $t2 Usado para pegar byte atual de armazenar_data_tmp
				# $v0 Será usado para armazenar o valor inteiro final
				# $t4 Usada para armazenar um dígito com seu peso decimal
				# $t8 tem o valor de $s4, mas é usada para não afetar o valor do contador
				beq $s7, 0, transforma_em_bin		# Condição de parada		
				lb $t2, 0($a3)
				addi $t4, $t2, -48			# Pegar número correspondente ao código ascii
				addi $t8, $s7, -1	
	
				add_peso_decimal_text:
					ble $t8, 0, pular_digito_text	# Só adicionar peso da posição decimal se houver mais de um dígito
					mul $t4, $t4, 10
					addi $t8, $t8, -1
					bnez $t8, add_peso_decimal_text	# Se a cópia do contador não for zero, continue multiplicando por 10
			
			pular_digito_text:
				add $v0, $v0, $t4			# Adicionando valores ao inteiro final
				addi $a3, $a3, 1			# Incrementa posicao do armazenar_data_tmp
				addi $s7, $s7, -1			# Decrementa contador da quantidade de dígitos do número	
				j loop_determinar_inteiro_text
							

		transforma_em_bin:
			li $t4, 0
			subi $t7, $t7, 3
			add $t0, $zero, $v0 	# put our input ($a0) into $t0
			add $t8, $zero, $zero 	# Zero out $t1
			addi $t4, $zero, 1 	# load 1 as a mask
			sll $t4, $t4, 4 	# move the mask to appropriate position
			addi $t9, $zero, 5 	# loop counter
			loop:

			and $t8, $t0, $t4 	# and the input with the mask
			beq $t8, $zero, add0 	# Branch to print if its 0

			add $t8, $zero, $zero 	# Zero out $t1
			addi $t8, $zero, 1 	# Put a 1 in $t1
			j add1

			print:
			addi $t7, $t7, 1
			srl $t4, $t4, 1
			addi $t9, $t9, -1
			bne $t9, $zero, loop
			sb $zero, 0($t7)
			la $t7, arg3_buffer
			j converteRHex
			j done
			add0:
				lb $t2, n0
				sb $t2, 0($t7)	
				j print	
			add1:
				lb $t2, n1
				sb $t2, 0($t7)
				j print
		
		
		#printa erro se for outro número
		j done
			
			$r3a_:
				lb $t2, 2($a3)
				lb $t4, n0
				beq $t2, $t4, $r3a_0		#se o num do registrador for 0:
				lb $t4, n1
				beq $t2, $t4, $r3a_1		#se o num do registrador for 1:
				lb $t4, n2
				beq $t2, $t4, $r3a_2		#se o num do registrador for 2:
				lb $t4, n3
				beq $t2, $t4, $r3a_3		#se o num do registrador for 3:
				lb $t4, t
				beq $t2, $t4, $r3a_t		#se o num do registrador for t:
				#printa erro se for outro número
				j done
				$r3z_:
					jal Rreseta_arg3
					lb $t4, n0
					sb $t4, 0($t7)
					sb $t4, 1($t7)
					sb $t4, 2($t7)
					sb $t4, 3($t7)
					sb $t4, 4($t7)
					sb $t4, 5($t7)

					#la $v1, ($t7)
					j converteRHex
				$r3a_t:
					jal Rreseta_arg3
					lb $t4, n0
					sb $t4, 0($t7)
					sb $t4, 1($t7)
					sb $t4, 2($t7)
					sb $t4, 3($t7)
					lb $t4, n1
					sb $t4, 4($t7)
					sb $zero, 5($t7)

					#la $v1, ($t7)
					j converteRHex
					j done
				$r3a_0:
					jal Rreseta_arg3
					lb $t4, n0
					sb $t4, 0($t7)
					sb $t4, 1($t7)
					lb $t4, n1
					sb $t4, 2($t7)
					lb $t4, n0
					sb $t4, 3($t7)
					sb $t4, 4($t7)
					sb $zero, 5($t7)

					#la $v1, ($t7)
					j converteRHex
					j done
				$r3a_1:
					jal Rreseta_arg3
					lb $t4, n0
					sb $t4, 0($t7)
					sb $t4, 1($t7)
					lb $t4, n1
					sb $t4, 2($t7)
					lb $t4, n0
					sb $t4, 3($t7)
					lb $t4, n1
					sb $t4, 4($t7)
					sb $zero, 5($t7)

					#la $v1, ($t7)
					j converteRHex
					j done
				$r3a_2:					
					jal Rreseta_arg3
					lb $t4, n0
					sb $t4, 0($t7)
					sb $t4, 1($t7)
					lb $t4, n1
					sb $t4, 2($t7)
					sb $t4, 3($t7)
					lb $t4, n0
					sb $t4, 4($t7)
					sb $zero, 5($t7)

					#la $v1, ($t7)
					j converteRHex
					j done
				$r3a_3:
					jal Rreseta_arg3
					lb $t4, n0
					sb $t4, 0($t7)
					sb $t4, 1($t7)
					lb $t4, n1
					sb $t4, 2($t7)
					sb $t4, 3($t7)
					sb $t4, 4($t7)
					sb $zero, 5($t7)

					#la $v1, ($t7)
					j converteRHex
					j done
				
			$r3v_:
				lb $t2, 2($a3)
				lb $t4, n0
				beq $t2, $t4, $r3v_0		#se o num do registrador for 0:
				lb $t4, n1
				beq $t2, $t4, $r3v_1		#se o num do registrador for 1:
				#printa erro se for outro número
				j done
				$r3v_0:
					jal Rreseta_arg3
					lb $t4, n0
					sb $t4, 0($t7)
					sb $t4, 1($t7)
					sb $t4, 2($t7)
					lb $t4, n1
					sb $t4, 3($t7)
					lb $t4, n0
					sb $t4, 4($t7)
					sb $zero, 5($t7)

					#la $v1, ($t7)
					j converteRHex
					j done
				$r3v_1:
					jal Rreseta_arg3
					lb $t4, n0
					sb $t4, 0($t7)
					sb $t4, 1($t7)
					sb $t4, 2($t7)
					lb $t4, n1
					sb $t4, 3($t7)
					sb $t4, 4($t7)
					sb $zero, 5($t7)

					#la $v1, ($t7)
					j converteRHex
					j done
					
			$r3t_:
				lb $t2, 2($a3)
				lb $t4, n0
				beq $t2, $t4, $r3t_0		#se o num do registrador for 0:
				lb $t4, n1
				beq $t2, $t4, $r3t_1		#se o num do registrador for 1:
				lb $t4, n2
				beq $t2, $t4, $r3t_2		#se o num do registrador for 2:
				lb $t4, n3
				beq $t2, $t4, $r3t_3		#se o num do registrador for 3:
				lb $t4, n4
				beq $t2, $t4, $r3t_4		#se o num do registrador for 4:
				lb $t4, n5
				beq $t2, $t4, $r3t_5		#se o num do registrador for 5:
				lb $t4, n6
				beq $t2, $t4, $r3t_6		#se o num do registrador for 6:
				lb $t4, n7
				beq $t2, $t4, $r3t_7		#se o num do registrador for 7:
				lb $t4, n8
				beq $t2, $t4, $r3t_8		#se o num do registrador for 8:
				lb $t4, n9
				beq $t2, $t4, $r3t_9		#se o num do registrador for 9:
				#printa erro se for outro número
				j done
				$r3t_0:
					jal Rreseta_arg3
					lb $t4, n0
					sb $t4, 0($t7)
					lb $t4, n1
					sb $t4, 1($t7)
					lb $t4, n0
					sb $t4, 2($t7)
					sb $t4, 3($t7)
					sb $t4, 4($t7)
					sb $zero, 5($t7)

					#la $v1, ($t7)
					j converteRHex
					j done
				$r3t_1:
					jal Rreseta_arg3
					lb $t4, n0
					sb $t4, 0($t7)
					lb $t4, n1
					sb $t4, 1($t7)
					lb $t4, n0
					sb $t4, 2($t7)
					sb $t4, 3($t7)
					lb $t4, n1
					sb $t4, 4($t7)
					sb $zero, 5($t7)

					#la $v1, ($t7)
					j converteRHex
					j done
				$r3t_2:					
					jal Rreseta_arg3
					lb $t4, n0
					sb $t4, 0($t7)
					lb $t4, n1
					sb $t4, 1($t7)
					lb $t4, n0
					sb $t4, 2($t7)
					lb $t4, n1
					sb $t4, 3($t7)
					lb $t4, n0
					sb $t4, 4($t7)
					sb $zero, 5($t7)

					#la $v1, ($t7)
					j converteRHex
					j done
				$r3t_3:
					jal Rreseta_arg3
					lb $t4, n0
					sb $t4, 0($t7)
					lb $t4, n1
					sb $t4, 1($t7)
					lb $t4, n0
					sb $t4, 2($t7)
					lb $t4, n1
					sb $t4, 3($t7)
					sb $t4, 4($t7)
					sb $zero, 5($t7)

					#la $v1, ($t7)
					j converteRHex
					j done
				$r3t_4:
					jal Rreseta_arg3
					lb $t4, n0
					sb $t4, 0($t7)
					lb $t4, n1
					sb $t4, 1($t7)
					sb $t4, 2($t7)
					lb $t4, n0
					sb $t4, 3($t7)
					sb $t4, 4($t7)
					sb $zero, 5($t7)

					#la $v1, ($t7)
					j converteRHex
					j done
				$r3t_5:					
					jal Rreseta_arg3
					lb $t4, n0
					sb $t4, 0($t7)
					lb $t4, n1
					sb $t4, 1($t7)
					sb $t4, 2($t7)
					lb $t4, n0
					sb $t4, 3($t7)
					lb $t4, n1
					sb $t4, 4($t7)
					sb $zero, 5($t7)

					#la $v1, ($t7)
					j converteRHex
					j done
				$r3t_6:
					jal Rreseta_arg3
					lb $t4, n0
					sb $t4, 0($t7)
					lb $t4, n1
					sb $t4, 1($t7)
					sb $t4, 2($t7)
					sb $t4, 3($t7)
					lb $t4, n0
					sb $t4, 4($t7)
					sb $zero, 5($t7)

					#la $v1, ($t7)
					j converteRHex
					j done
				$r3t_7:
					jal Rreseta_arg3
					lb $t4, n0
					sb $t4, 0($t7)
					lb $t4, n1
					sb $t4, 1($t7)
					sb $t4, 2($t7)
					sb $t4, 3($t7)
					sb $t4, 4($t7)
					sb $zero, 5($t7)

					#la $v1, ($t7)
					j converteRHex
					j done
				$r3t_8:					
					jal Rreseta_arg3
					lb $t4, n1
					sb $t4, 0($t7)
					sb $t4, 1($t7)
					lb $t4, n0
					sb $t4, 2($t7)
					sb $t4, 3($t7)
					sb $t4, 4($t7)
					sb $zero, 5($t7)

					#la $v1, ($t7)
					j converteRHex
					j done
				$r3t_9:
					jal Rreseta_arg3
					lb $t4, n1
					sb $t4, 0($t7)
					sb $t4, 1($t7)
					lb $t4, n0
					sb $t4, 2($t7)
					sb $t4, 3($t7)
					lb $t4, n1
					sb $t4, 4($t7)
					sb $zero, 5($t7)

					#la $v1, ($t7)
					j converteRHex
					j done
			$r3s_:
				lb $t2, 2($a3)
				lb $t4, n0
				beq $t2, $t4, $r3s_0		#se o num do registrador for 0:
				lb $t4, n1
				beq $t2, $t4, $r3s_1		#se o num do registrador for 1:
				lb $t4, n2
				beq $t2, $t4, $r3s_2		#se o num do registrador for 2:
				lb $t4, n3
				beq $t2, $t4, $r3s_3		#se o num do registrador for 3:
				lb $t4, n4
				beq $t2, $t4, $r3s_4		#se o num do registrador for 4:
				lb $t4, n5
				beq $t2, $t4, $r3s_5		#se o num do registrador for 5:
				lb $t4, n6
				beq $t2, $t4, $r3s_6		#se o num do registrador for 6:
				lb $t4, n7
				beq $t2, $t4, $r3s_7		#se o num do registrador for 7:
				#printa erro se for outro número
				j done
				$r3s_0:
					jal Rreseta_arg3
					lb $t4, n1
					sb $t4, 0($t7)
					lb $t4, n0
					sb $t4, 1($t7)
					sb $t4, 2($t7)
					sb $t4, 3($t7)
					sb $t4, 4($t7)
					sb $zero, 5($t7)

					#la $v1, ($t7)
					j converteRHex
					j done
				$r3s_1:
					jal Rreseta_arg3
					lb $t4, n1
					sb $t4, 0($t7)
					lb $t4, n0
					sb $t4, 1($t7)
					lb $t4, n0
					sb $t4, 2($t7)
					sb $t4, 3($t7)
					lb $t4, n1
					sb $t4, 4($t7)
					sb $zero, 5($t7)

					#la $v1, ($t7)
					j converteRHex
					j done
				$r3s_2:					
					jal Rreseta_arg3
					lb $t4, n1
					sb $t4, 0($t7)
					lb $t4, n0
					sb $t4, 1($t7)
					sb $t4, 2($t7)
					lb $t4, n1
					sb $t4, 3($t7)
					lb $t4, n0
					sb $t4, 4($t7)
					sb $zero, 5($t7)

					#la $v1, ($t7)
					j converteRHex
					j done
				$r3s_3:
					jal Rreseta_arg3
					lb $t4, n1
					sb $t4, 0($t7)
					lb $t4, n0
					sb $t4, 1($t7)
					sb $t4, 2($t7)
					lb $t4, n1
					sb $t4, 3($t7)
					sb $t4, 4($t7)
					sb $zero, 5($t7)

					#la $v1, ($t7)
					j converteRHex
					j done
				$r3s_4:
					jal Rreseta_arg3
					lb $t4, n1
					sb $t4, 0($t7)
					lb $t4, n0
					sb $t4, 1($t7)
					lb $t4, n1
					sb $t4, 2($t7)
					lb $t4, n0
					sb $t4, 3($t7)
					sb $t4, 4($t7)
					sb $zero, 5($t7)

					#la $v1, ($t7)
					j converteRHex
					j done
				$r3s_5:					
					jal Rreseta_arg3
					lb $t4, n1
					sb $t4, 0($t7)
					lb $t4, n0
					sb $t4, 1($t7)
					lb $t4, n1
					sb $t4, 2($t7)
					lb $t4, n0
					sb $t4, 3($t7)
					lb $t4, n1
					sb $t4, 4($t7)
					sb $zero, 5($t7)

					#la $v1, ($t7)
					j converteRHex
					j done
				$r3s_6:
					jal Rreseta_arg3
					lb $t4, n1
					sb $t4, 0($t7)
					lb $t4, n0
					sb $t4, 1($t7)
					lb $t4, n1
					sb $t4, 2($t7)
					sb $t4, 3($t7)
					lb $t4, n0
					sb $t4, 4($t7)
					sb $zero, 5($t7)

					#la $v1, ($t7)
					j converteRHex
					j done
				$r3s_7:
					jal Rreseta_arg3
					lb $t4, n1
					sb $t4, 0($t7)
					lb $t4, n0
					sb $t4, 1($t7)
					lb $t4, n1
					sb $t4, 2($t7)
					sb $t4, 3($t7)
					sb $t4, 4($t7)
					sb $zero, 5($t7)
					#la $v1, ($t7)
					j converteRHex
					j done
					

		

#-----------------------------#1° passo: juntar a linha inteira em binario (usar $t8 para navegar pela instrução em $a2)-------------------------#
	
	#copia_arg_hex:
	
	#converteIHex:

	converteRHex:

		#la $a0, ($a3)
		#li $v0, 4
		#syscall
		lb $t4, x
		lb $t8, 0($a2)
		beq $t4, $t8, zx_
		lb $t4, a
		lb $t8, 0($a2)
		beq $t4, $t8, za_
		lb $t4, l
		lb $t8, 0($a2)
		beq $t4, $t8, zl_
		lb $t4, s
		lb $t8, 0($a2)				#se a primeira letra da instrução é s
		beq $t4, $t8, zs_
		lb $t4, m				#se a primeira letra da instrução é m
		beq $t4, $t8, zm_
		lb $t4, d				#se a primeira letra da instrução é d (div)
		beq $t4, $t8, RS_em_6_e_RD_e_SHMT0	#armazena (RS, RT) juntos começando no bit 6 e usar os bits 16 - 26 iguais a 0
		j RS_em_6				# se não for nenhum desses, armazena (RS, RT e RD) juntos começando no bit 6
		
		zx_:
			lb $t4, o			#se a segunda letra da instrução é o
			lb $t8, 1($a2)
			beq $t4, $t8, zxo_
		zxo_:
			lb $t4, r			#se a terceira letra da instrução é r
			lb $t8, 2($a2)
			beq $t4, $t8, zxor_
		zxor_:
			lb $t4, i			#se a terceira letra da instrução é r
			lb $t8, 3($a2)
			beq $t4, $t8, padrao_I		# se é (xori)
		
		za_:
			lb $t4, n			#se a segunda letra da instrução é n
			lb $t8, 1($a2)
			beq $t4, $t8, zan_
			lb $t4, d			#se a segunda letra da instrução é d
			lb $t8, 1($a2)
			beq $t4, $t8, zad_
		zad_:
			lb $t4, d			
			lb $t8, 2($a2)
			beq $t4, $t8, zadd_		#se a terceira letra da instrução é d
		zadd_:
			lb $t4, i
			lb $t8, 3($a2)
			beq $t4, $t8, padrao_I		# se é (addi) ou (addiu)
			j RS_em_6			# se é (add) ou (addu)
		zan_:
			lb $t4, d			#se a terceira letra da instrução é d
			lb $t8, 2($a2)
			beq $t4, $t8, zand_
		zand_:
			lb $t4, i
			lb $t8, 3($a2)
			beq $t4, $t8, padrao_I		#se é (andi)
		zl_:
			lb $t4, w
			lb $t8, 1($a2)
			beq $t4, $t8, padrao_I		#se a segunda letra da instrução é w
			lb $t4, b
			lb $t8, l($a2)
			beq $t4, $t8, padrao_I		#se é (lb)
		
		zs_:
			lb $t4, r
			lb $t8, 1($a2)
			beq $t4, $t8, zsr_		#se a segunda letra da instrução é r
			lb $t4, l
			beq $t4, $t8, zsl_		#se a segunda letra da instrução é l
			j RS_em_6
			
		zsr_:
			lb $t4, l
			lb $t8, 2($a2)
			beq $t4, $t8, RT_em_11		#se a terceira letra da instrução é l (srl)
			j RS_em_6
			
		zsl_:	lb $t4, l
			lb $t8, 2($a2)
			beq $t4, $t8, RT_em_11		#se a terceira letra da instrução é l (sll)
			lb $t4, t
			lb $t8, 2($a2)
			beq $t4, $t8, zslt_	
			j RS_em_6
		zslt_:
			lb $t4, i
			lb $t8, 3($a2)
			beq $t4, $t8, padrao_I		#se é (slti) ou (sltiu)
		zm_:
			lb $t4, f
			lb $t8, 1($a2)
			beq $t4, $t8, RD_em_15
			lb $t4, u
			beq $t4, $t8, zmu_
			j RS_em_6
		zmu_:
			lb $t4, l
			lb $t8, 2($a2)
			beq $t4, $t8, zmul_
			j RS_em_6
		zmul_:
			lb $t4, t
			lb $t8, 3($a2)
			beq $t4, $t8, RS_em_6_e_RD_e_SHMT0
			j RS_em_6
		RT_em_11:
			# Usado com SLR E SLL ( arg2, arg 1 e imm - começando no bit 11)
				#---RT					#arg2
				lb $t4, 0($t6)
				sb $t4, 11($s0)
				lb $t4, 1($t6)
     				sb $t4, 12($s0)
     				lb $t4, 2($t6)
     				sb $t4, 13($s0)
     				lb $t4, 3($t6)
     				sb $t4, 14($s0)
     				lb $t4, 4($t6)
     				sb $t4, 15($s0)
     				#---RD					#arg1
     				lb $t4, 0($t5)
     				sb $t4, 16($s0)
     				lb $t4, 1($t5)
     				sb $t4, 17($s0)
     				lb $t4, 2($t5)
     				sb $t4, 18($s0)
     				lb $t4, 3($t5)
     				sb $t4, 19($s0)
     				lb $t4, 4($t5)
     				sb $t4, 20($s0)
     				
     				#---sa					#arg3
     				lb $t4, 0($t7)
     				sb $t4, 21($s0)
     				lb $t4, 1($t7)
     				sb $t4, 22($s0)
     				lb $t4, 2($t7)
     				sb $t4, 23($s0)
     				lb $t4, 3($t7)
     				sb $t4, 24($s0)
     				lb $t4, 4($t7)
     				sb $t4, 25($s0)
     				
     				sb $zero, 33($s0)

				j junta_buffer
				
			padrao_I_im:			#(op-a2-a1-imm)	
				#--- arg2
				lb $t4, 0($t6)
     				sb $t4, 6($s0)
     				lb $t4, 1($t6)
     				sb $t4, 7($s0)
     				lb $t4, 2($t6)
     				sb $t4, 8($s0)
     				lb $t4, 3($t6)
     				sb $t4, 9($s0)
     				lb $t4, 4($t6)
     				sb $t4, 10($s0)
     				#---arg1
     				lb $t4, 0($t5)
     				sb $t4, 11($s0)
     				lb $t4, 1($t5)
     				sb $t4, 12($s0)
     				lb $t4, 2($t5)
     				sb $t4, 13($s0)
     				lb $t4, 3($t5)
     				sb $t4, 14($s0)
     				lb $t4, 4($t5)
     				sb $t4, 15($s0)	
     				#arg3
				lb $t4, 0($t7)
     				sb $t4, 27($s0)
     				lb $t4, 1($t7)
     				sb $t4, 28($s0)
     				lb $t4, 2($t7)
     				sb $t4, 29($s0)
     				lb $t4, 3($t7)
     				sb $t4, 30($s0)
     				lb $t4, 4($t7)
     				sb $t4, 31($s0)	
     				sb $zero, 33($s0)
     				la $a0, ($s0)
				li $v0, 4
				syscall
     				j done
     				
     				j junta_buffer
			padrao_I:			#(op-a2-a1-a3)
				#--- arg2
				lb $t4, 0($t6)
     				sb $t4, 6($s0)
     				lb $t4, 1($t6)
     				sb $t4, 7($s0)
     				lb $t4, 2($t6)
     				sb $t4, 8($s0)
     				lb $t4, 3($t6)
     				sb $t4, 9($s0)
     				lb $t4, 4($t6)
     				sb $t4, 10($s0)
     				#---arg1
     				lb $t4, 0($t5)
     				sb $t4, 11($s0)
     				lb $t4, 1($t5)
     				sb $t4, 12($s0)
     				lb $t4, 2($t5)
     				sb $t4, 13($s0)
     				lb $t4, 3($t5)
     				sb $t4, 14($s0)
     				lb $t4, 4($t5)
     				sb $t4, 15($s0)	
     				#arg3
				lb $t4, 0($t7)
     				sb $t4, 27($s0)
     				lb $t4, 1($t7)
     				sb $t4, 28($s0)
     				lb $t4, 2($t7)
     				sb $t4, 29($s0)
     				lb $t4, 3($t7)
     				sb $t4, 30($s0)
     				lb $t4, 4($t7)
     				sb $t4, 31($s0)	
     				sb $zero, 33($s0)
     				la $a0, ($s0)
				li $v0, 4
				syscall
				j done
     				
     				j junta_buffer
		RS_em_6:
            	#Usado no caso comum (RS, RT e RD)
                                #arg3
                	lb $t4, 0($t6)
                	sb $t4, 6($s0)
                	lb $t4, 1($t6)
                     sb $t4, 7($s0)
                     lb $t4, 2($t6)
                     sb $t4, 8($s0)
                     lb $t4, 3($t6)
                     sb $t4, 9($s0)
                     lb $t4, 4($t6)
                     sb $t4, 10($s0)
                     #---RT                #arg1
                     lb $t4, 0($t7)
                     sb $t4, 11($s0)
                     lb $t4, 1($t7)
                     sb $t4, 12($s0)
                     lb $t4, 2($t7)
                     sb $t4, 13($s0)
                     lb $t4, 3($t7)
                     sb $t4, 14($s0)
                     lb $t4, 4($t7)
                     sb $t4, 15($s0)
                     #---RD                #arg 2
                     lb $t4, 0($t5)
                     sb $t4, 16($s0)
                     lb $t4, 1($t5)
                     sb $t4, 17($s0)
                     lb $t4, 2($t5)
                     sb $t4, 18($s0)
                     lb $t4, 3($t5)
                     sb $t4, 19($s0)
                     lb $t4, 4($t5)
                     sb $t4, 20($s0)

                     sb $zero, 33($s0)

				j junta_buffer
		RS_em_6_e_RD_e_SHMT0:
				#Usado em MULT e DIV
				#--- R1
				lb $t4, 0($t5)
     				sb $t4, 6($s0)
     				lb $t4, 1($t5)
     				sb $t4, 7($s0)
     				lb $t4, 2($t5)
     				sb $t4, 8($s0)
     				lb $t4, 3($t5)
     				sb $t4, 9($s0)
     				lb $t4, 4($t5)
     				sb $t4, 10($s0)
     				#---R2
     				lb $t4, 0($t6)
     				sb $t4, 11($s0)
     				lb $t4, 1($t6)
     				sb $t4, 12($s0)
     				lb $t4, 2($t6)
     				sb $t4, 13($s0)
     				lb $t4, 3($t6)
     				sb $t4, 14($s0)
     				lb $t4, 4($t6)
     				sb $t4, 15($s0)
     				
     				sb $zero, 33($s0)
     				j junta_buffer
			j done
		RD_em_15:
			#Usado em MFHI e MFLO (Só tem o RD e o resto é 0)
				#---RD				#arg 1
     				lb $t4, 0($t5)
     				sb $t4, 16($s0)
     				lb $t4, 1($t5)
     				sb $t4, 17($s0)
     				lb $t4, 2($t5)
     				sb $t4, 18($s0)
     				lb $t4, 3($t5)
     				sb $t4, 19($s0)
     				lb $t4, 4($t5)
     				sb $t4, 20($s0)
     				
     				sb $zero, 33($s0)
				la $a0, ($s0)
				li $v0, 4
				syscall
				j junta_buffer
			
			j done
		
#-----------------------------#2° passo: juntar os caracteres do buffer da linha-------------------------#
   
junta_buffer:
	li $s1, 0		# Para armazenar o inteiro decimal correspondente
	li $t1, 31		# Peso do número para conversão para decimal
	la $s0, buffer_linha_bin
	
loop_to_dec:
	li $t2, 1		# Valor a ser somado com o decimal durante a conversão
	lb $t0, 0($s0)
	
	beq $t0, 49, convert_digit

pula_digito:	
	addi $s0, $s0, 1
	addi $t1, $t1, -1
	
	bne $t1, 0, loop_to_dec
	
	lb $t0, 0($s0)
	beq $t0, 49, convert_digit_1

	j converte_hex_text
			
 convert_digit: 
 	move $t3, $t1		# Cópia de t1 para não modificar valor original
 	
 loop_convert:   
 	mul $t2, $t2, 2
 	addi $t3, $t3, -1
 	bne $t3, 0, loop_convert
	
	add $s1, $s1, $t2
	
	j pula_digito
	
convert_digit_1:
	add $s1, $s1, 1
	j converte_hex_text

converte_hex_text:
	jal zerar_conteudo_linha

	li $t1, 19      		# Posição inicial da string com a parte do dado no formato do .mif
    	
convert_loop_data_text:
	andi $t2, $s1, 0xF  		# Get the lowest 4 bits of the integer
    	lb $t3, hex_digits($t2)  	# Get the corresponding hexadecimal character
    	
    	sb $t3, conteudoLinha($t1)
    
	# Decrementar posição do caractere
    	subi $t1, $t1, 1

   	# Shift de 4 bits no inteiro
    	srl $s1, $s1, 4
    	
    	bnez $s1, convert_loop_data_text
    	la $a1, conteudoLinha			#armazena o hexadecimal convertido em $a1
    	
    	#################### Preparação para escrita da posição do endereço:;;;;;;;;
    	li $t1, 8      			# Posição inicial da string com a parte do endereço no formato do .mif
    	lb $t0, num_instrucoes		# Carregar quantidade de instruções salvas

convert_loop_endereco_text:
	andi $t2, $t0, 0xF  		# Get the lowest 4 bits of the integer
    	lb $t3, hex_digits($t2)  	# Get the corresponding hexadecimal character
    	
    	sb $t3, conteudoLinha($t1)
    
	# Decrementar posição do caractere
    	subi $t1, $t1, 1

   	# Shift de 4 bits no inteiro
    	srl $t0, $t0, 4

    	bnez $t0, convert_loop_endereco_text
    	la $a1, conteudoLinha			#armazena o hexadecimal convertido em $a1
    	
#--------aqui adicionar a linha + \n em outro buffer e converter a proxima instrução, para escrever no arquivo final tudo de uma vez
    	#todas as instruções de uma vez
    	#la $a0, ($a1)
    	#li, $v0, 4			#printa o hexa para conferir
    	#syscall
	
	li $t9, 0		#contador  para chegar na proxima instrução correta
	
salvar_bytes_machine_code:
	# Salvar linha no buffer que vamos usar para escrever no arquivo:
	
	lb $t5, 0($a1)		# Carregar byte do conteudoLinha
	
	la $t2, machine_code 	# Pegar endereço do machine_code

	# Incrementar posições para se escrever no lugar certo, considerando as linhas já escritas:
	lb $t0, num_instrucoes	# Pegar número de instruções já escritas
	
	mul $t3, $t0, 22	# $t3 armazena quantas posições devo pular para começar a armazenar os bytes no machine_code
	
	add $t2, $t2, $t3	# Coloca $t2 na posição certa para o armazenamento sem sobreposição
	
	armazenar_bytes:
		lb $t5, 0($a1)	
	
		sb $t5, 0($t2)			# Armazenar bytes no machine_code
	
		addi $a1, $a1, 1		# Incrementar posição da linha a ser escrita
		addi $t2, $t2, 1		# Incrementar posição do machine_code
	
		bne $t5, $0, armazenar_bytes 
	
	#Incrementar contador do número de instruções escritas:
	addi $t0, $t0, 1
	sb $t0, num_instrucoes

#------------------------------- limpeza dos buffers---------------------------------------------
#buffer_linha_bin
	subi $s0, $s0, 33
#buffer inst

#args 1, 2 e 3
	jal Rreseta_arg1
	jal Rreseta_arg2
	jal Rreseta_arg3
	j identifica_linha

	j done
#-----------------------------#3° passo: converter para hexadecimal, escrever no arquivo e ir para a proxima linha-------------------------#

escrever_text:
	li $v0, 1  			# Chama a syscall para fechar o arquivo
	la $s2, machine_code
	lb $s3, num_instrucoes 
	
	li $v0, 13 		#solicita abertura
	la $a0, diretorio_escrita    #endereço do arquivo
	li $a1, 1 		#0: leitura; 1: escrita
	syscall 		#descritor do arquivo vai para $v0
	move $s1, $v0  			# Salva o descritor do arquivo
	
	escrever_header_text:
		li $v0, 15  			# Chama a syscall para escrever em um arquivo
		move $a0, $s1  			# Passa o descritor do arquivo
		la $a1, conteudoHeader  	# Passa o conteúdo do cabeçalho a ser escrito
		li $a2, 80  			# Passa o tamanho do conteudoHeader
		syscall
	
loop_escrever_conteudo_text:
	li $v0, 15  			# Chama a syscall para escrever em um arquivo
	move $a0, $s1  			# Passa o descritor do arquivo
	move $a1, $s2  			# Passa o conteúdo da linha a ser escrita
	li $a2, 21  			# Passa o tamanho da linha a ser escrita
	syscall	
	
	move $a0, $s2
    	li, $v0, 4			#printa o hexa para conferir
    	syscall
	
	addi $s2, $s2, 22
	addi $s3, $s3, -1
	
	bne $s3, 0, loop_escrever_conteudo_text

	li $v0, 16  			# Chama a syscall para fechar o arquivo
	move $a0, $s1  			# Passa o descritor do arquivo
	syscall

done:
	# Termina o programa
	li $v0, 10
	syscall

zerar_conteudo_linha:
	li $t1, 1
	li $t2, 48
zerar_endereco_text:
	sb $t2, conteudoLinha($t1)
	addi $t1, $t1, 1
	bne $t1, 9, zerar_endereco_text
	li $t1, 12
zerar_dado_text:	
	sb $t2, conteudoLinha($t1)
	addi $t1, $t1, 1
	bne $t1, 20, zerar_dado_text
	jr $ra

remover_newline:
    loop_remover:
        lb $t0, ($a0)    
        beqz $t0, removeu   
        addi $a0, $a0, 1
        j loop_remover

    removeu:
        subi $a0, $a0, 1 
        lb $t1, ($a0)    
        li $t2, 10      

        beq $t1, $t2, remover
        j exit

    remover:
        li $t1, 0        # Null terminator
        sb $t1, ($a0)    # Replace newline with null terminator

    exit:
        jr $ra
#---------------------------------------------------------------------------

open_to_read:
	li $v0, 13 			#solicita abertura
	la $a0, localArquivo  		#endereço do arquivo
	li $a1, 0 			#0: leitura; 1: escrita
	syscall 			#descritor do arquivo vai para $s0
	move $s0, $v0
	jr $ra
	
read_arq:
	move $a0, $s0
	li $v0, 14 			#ler conteúdo do arquivo referenciado por $a0
	la $a1, conteudoArquivo 	#$A1 = ARMAZENA CONTEUDO DO ARQUIVO
	li $a2, 1024 			#tamanho do buffer
	syscall				#leitura realizada(retorna o numero de caracteres)
	move $s2, $a1			#$S2 = CONTEUDO DO ARQUIVO

	li $a2, 0
	jr $ra

debug:
	lb $a0, num_instrucoes
	li $v0, 1
	syscall
	
	li $v0, 10
	syscall
