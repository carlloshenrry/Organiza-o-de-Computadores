TITLE Projeto 2
.MODEL SMALL
.STACK 100H

.DATA
VET DW 10000 DUP (?)
T DW ?
DIGTNUM DB "Digite um numero:$"
Opcion DB "Escolha uma Opcao:$"
CRESCENTE DB "1) Crescente $"
DECRESCENTE DB "2) DECRESCENTE $"
RANDOMICO DB "3) RANDOMICO $"
SAIR DB "4) SAIR $"
avisodeerro DB "Erro $"
MSGSAIDA DB "GOSTARIA DE REALIZAR OUTRA OPERACAO? 1) SIM / 2)NAO$" ; NAO SAI DE VEZ, SIM VOLTA (APERTA 0 PARA SAIR)

.CODE
.STARTUP

ORGAN PROC
;----------------------------------------------------------------MENU-----------------------------------------------------------------------
MENU:
MOV AX,@DATA 			;coloca o numero do segmento de dados em AX
MOV DS,AX    			;pois DS nao pode receber @DATA diretamente
LEA DX, Opcion
MOV AH, 09H
INT 21H
LEA DX, CRESCENTE    
MOV AH, 09H
INT 21H
LEA DX, DECRESCENTE			
MOV AH, 09H
INT 21H
LEA DX, RANDOMICO
MOV AH, 09H
INT 21H
;--------------------------------------------------------CHAMA FUNCAO----------------------------------------------------------------
CALL receptorDEC
CMP AX, 1D			 	;compara se o caracter eh igual a 1
JZ JMPVETORCRESCENT  
CMP AX, 2D			 	;compara se o caracter eh igual a 2
JZ JMPVETORDECRESCENT  
CMP AX, 3D			 	;compara se o caracter eh igual a 3
JZ JMPVETORRAND
CMP AX, 4D			 	;compara se o caracter eh igual a 4
JZ JMPSAIDA  
JMP MENU
;Se nao for nenhum dos casos
;JXXX TEM EXCECAO DE ACORDO COM O NUMERO DE LINHAS
JMPVETORCRESCENT:
CALL VETORCRESCENT
CALL PRINTVETOR
JMP MENU
JMPVETORDECRESCENT:
CALL VETORDECRESCENT
CALL PRINTVETOR
JMP MENU
JMPVETORRAND:
CALL VETORRAND
CALL PRINTVETOR
JMP MENU
JMPSAIDA:
JMP SAIDA

;---------------------------------------------------------ENTRADA DE VALOR----------------------------------------------------------
PROC receptorDEC
PUSH BX
PUSH CX
PUSH DX
ENTRADA10:
MOV BX,0
MOV CX,0;0 CX PARA VERIFICAR SINAL (FLAG)
mov ah,1 ;recebe caracter
int 21h
cmp al,'-';verifica se eh sinal
je menos;jump para receber numero _
cmp al,'+';verifica sinal
je mais;jump para receber numero +
jmp num;se nao for as opcoes anteriores recebe numero
menos: MOV CX,1;SE O NUMERO FOR NEGATIVO CX RECEBE 1
mais:
int 21h;RECEBER VALOR, AH JA TEM O VALOR 1 ENTAO A FUNǃO JA FUNCIONA
num:
sub al,48;TRANFORMA EM NUMERO VERDADEIRO
MOV AH, 0;ZERA AH PARA DEIXAR AX APENAS COM NUMERO VERDADEIRO
PUSH AX;ACUMULA VALOR VDD NA PILHA
MOV AX,10;AX RECEBE 10 AGORA
MUL BX;O VALOR DE BX MULTIPLICA POR AX QUE EH 10
POP BX;BX RECEBE O VALOR DA PILHA
ADD BX,AX;VALOR DA PILHA VEZES 10
secnumber:
MOV AH,1
INT 21H ;RECEBER OUTRO NUMERO
CMP AL,13;VERIFICA SE AL EH ENTER
JE FORA;SE IGUAL ELE SAI
CMP AL,48;verifica se numero
JL numerror
CMP AL,57;verifica se numero
JG numerror;jmp para avisar erro e pedir outra entrada10
JMP num
numerror:
LEA DX, avisodeerro
MOV AH, 9H
INT 21H;avisa que nao eh numero
jmp secnumber
FORA:
MOV AX,BX;O VALOR VERDADEIRO VAI PARA AX
CMP CX,0;VERIFICA FALOR DE CX PARA SABER SE O NUMERO EH POSITIVO OU NAO
JE SAIENTRADA10
NEG AX;TRANFORMA O VALOR VERDADEIRO EM NEGATIVO
SAIENTRADA10:
POP DX
POP CX
POP BX
ret
receptorDEC endp

;---------------------------------------------------------------------SAIDA DE DECIMAL-----------------------------------------------------
SAIDEC PROC ;exibe o conteudo de AX como decimal inteiro com sinal
		;variaveis de entrada: AX -> valor binario equivalente do n?ero decimal
		;variaveis de saida: nehuma (exibição de d?itos direto no monitor de video)
			PUSH AX
			PUSH BX
			PUSH CX
			PUSH DX ;salva na pilha os registradores usados
			OR AX,AX ;prepara comparação de sinal
			JGE PT1 ;se AX maior ou igual a 0, vai para PT1
			PUSH AX ;como AX menor que 0, salva o n?ero na pilha
			MOV DX, 45D ;prepara o caracter ' - ' para sair
			MOV AH,2h ;prepara exibição
			INT 21h ;exibe ' - '
			POP AX ;recupera o n?ero
			NEG AX ;troca o sinal de AX (AX = - AX)
		;obtendo d?itos decimais e salvando-os temporariamente na pilha
			PT1: XOR CX,CX ;inicializa CX como contador de d?itos
			MOV BX,10 ;BX possui o divisor
			PT2: XOR DX,DX ;inicializa o byte alto do dividendo em 0; restante ?AX
			DIV BX ;ap? a execução, AX = quociente; DX = resto
			PUSH DX ;salva o primeiro d?ito decimal na pilha (1o. resto)
			INC CX ;contador = contador + 1
			OR AX,AX ;quociente = 0 ? (teste de parada)
			JNE PT2 ;n?, continuamos a repetir o la?
		;exibindo os d?itos decimais (restos) no monitor, na ordem inversa
			MOV AH,2h ;sim, termina o processo, prepara exibição dos restos
			PT3: POP DX ;recupera d?ito da pilha colocando-o em DL (DH = 0)
			ADD DL,30h ;converte valor bin?io do d?ito para caracter ASCII
			INT 21h ;exibe caracter
			LOOP PT3 ;realiza o loop ate que CX = 0
			POP DX ;restaura o conte?o dos registros
			POP CX
			POP BX
			POP AX ;restaura os conte?os dos registradores
			
			MOV AH, 2
			MOV DL, ' '
			INT 21H
			
			RET ;retorna ?rotina que chamou
		SAIDEC ENDP
;----------------------------------------------------------------------VETOR CRESCENTE--------------------------------------
PROC VETORCRESCENT
CALL receptorDEC
MOV T,AX
MOV CX,T
XOR BX,BX
XOR AX,AX
L1:
INC AX
ADD BX,2
MOV [VET+BX], AX
LOOP L1
RET
VETORCRESCENT ENDP
;---------------------------------------------------------------------VETOR DECRESCENTE--------------------------------------
PROC VETORDECRESCENT

CALL receptorDEC
MOV T,AX
MOV CX,T
XOR BX,BX
L2:
MOV [VET+BX],CX
ADD BX,2
LOOP L2
RET
VETORDECRESCENT ENDP
;--------------------------------------------------------------------VETOR RANDONICO--------------------------------------
PROC VETORRAND

CALL receptorDEC
MOV T,AX
MOV CX,T
LEA DX, DIGTNUM
MOV AH, 09H
INT 21H
MOV AH,1
INT 21H
MOV BX,AX
L3:
CALL ALEATORIO
MOV BX,CX
MOV [VET+BX],DX
SUB CX, 2
CMP CX, 0
JNZ L3
RET
VETORRAND ENDP
;-----------------------------------------------------------------FUNCAO PARA RANDOMICO-------------------------------
ALEATORIO PROC
ADD BX,100
MOV AX,BX
MOV BX,5
MUL BX
XOR DX,DX
MOV BX,100
IDIV BX
RET
ALEATORIO ENDP
;------------------------------------------------------------------PRINTAR O VETOR-----------------------------------
PRINTVETOR PROC 


XOR BX,BX

MOV CX,T
PRINT:

MOV AX,[VET+BX]
CALL SAIDEC
INC BX
INC BX
LOOP PRINT



PRINTVETOR ENDP
;-----------------------------------------------------------SAIR-------------------------------------------------
SAIDA:
	LEA DX, MSGSAIDA
	MOV AH, 9H
	INT 21H
	CMP AX, 1D
	JZ MENUJMP
	CMP AX, 2D
	JZ FIM
MENUJMP:
	JMP MENU
;RETORNO AO DOS
FIM:
	MOV AH,4CH 				;funcao para saida
	INT 21H 	
;--------------------------------------------------FECHANDO O PROGRAMA-----------------------------------------------------
ORGAN ENDP
MOV AH,4CH
INT 21H	
END
