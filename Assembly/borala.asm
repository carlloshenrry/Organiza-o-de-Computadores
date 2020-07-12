title Calculation

.model small
.stack 100h

.data
N1 dw ?
R dw ?

choice db "Enter Operation:$"
prom db "ENTRE COM PRIMEIRO NUMERO.:$"
promp db "ENTRE COM SEGUNDO NUMERO:$"
printresult DB 0AH, 0DH,'RESULTADO:', 0AH, 0DH, '$'
avisodeerro DB 0AH, 0DH,'Nao eh numero, digite novamente', 0AH, 0DH, '$'
OPCAO DB 0Ah,0Dh, 'SELECIONE UMA OPCAO', 0Ah,0Dh,'$' ;'0Ah,0Dh,' pula linha
MSGS DB '1) SOMA', 0Ah,0Dh,'$'
MSGSU DB '2) SUBTRACAO', 0Ah,0Dh,'$'
MSGM DB '3) MULTIPLICACAO', 0Ah,0Dh,'$'
MSGD DB '4) DIVISAO', 0Ah,0Dh,'$'
MSGDD DB '5) MULTIPLICACAO POR 2', 0Ah,0Dh,'$'
MSGMM  DB '6) DIVISAO POR 2', 0Ah,0Dh,'$'

.code
.startup

menu:

			
			MOV AX,@DATA ;coloca o numero do segmento de dados em AX
			MOV DS,AX    ;pois DS nao pode receber @DATA diretamente
		;SELECIONE UMA OPCAO			
			LEA DX, OPCAO
			MOV AH,9h	;funcao para exibir caracter
			INT 21H		;exibir
		;SOMA
			LEA DX,MSGS
			MOV AH,9h 	;funcao para exibir caracter
			INT 21H 	;exibir
		;SUBTRACAO
			LEA DX,MSGSU
			MOV AH,9h 	;funcao para exibir caracter
			INT 21H 	;exibir
		;MULTIPLICACAO
			LEA DX,MSGM
			MOV AH,9h 	;funcao para exibir caracter
			INT 21H 	;exibir
		;DIVISAO
			LEA DX,MSGD
			MOV AH,9h 	;funcao para exibir caracter
			INT 21H 	;exibir
            CALL ENTRADA10
;-------------------------------------------------------------------------jump para as operações-----------------------------------------------------------------
            
        ;JMP PARA SOMA
             CMP AX, 1D 	;compara se o caracter eh igual a 1
             JE JMPSOMA10
		;JMP PARA SUBTRACAO
            CMP AX,	2D	;compara se o caracter eh igual a 2
             JE JMPSUB10
		;JMP PARA MULTIPLICACAO
		    CMP AX,3D
			JE JMPMULT10
		;JMP PARA DIVISAO
		    CMP AX,4D
			JE JMPDIV10
			 


;------------------------------------------------------------------------jmp para nao dar erro de entrada das operacoes-------------------------------------------		

			
			
         ;PULAR PARA A INSTRUCAO SOMATORIA
          JMPSOMA10:
             JMP ADICAO10
		;PULAR PARA A INSTRUCAO SUBTRACAO	 
		  JMPSUB10:
		     JMP SUBTRACAO10
		;PULAR PARA A INSTRUCAO MULTIPLICA
		JMPMULT10:
		     JMP MULTIPLICACAO10
		;PULAR PARA A INSTRUCAO DIVISAO
         JMPDIV10:
		     JMP DIVISAO10

FIMPOROGRAMA:
MOV AH, 4CH
INT 21H
;---------------------------------------------------------------------------ENTRADA DE VALOR--------------------------------------------------------------------
PROC receptorDEC
PUSH AX
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
int 21h;RECEBER VALOR, AH JA TEM O VALOR 1 ENTAO A FUNÇÃO JA FUNCIONA

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
POP AX
ret

receptorDEC endp

;-------------------------------------------------------------------------Saida Decimal------------------------------------------------------------------------
proc saidaDEC

PUSH AX
PUSH BX
PUSH CX
PUSH DX 

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
MOV BX,10 ;BX recebe 10 para dividir

PT2: XOR DX,DX ;inicializa o byte alto do dividendo em 0; restante eh ax
DIV BX ; apos execucao, AX = quociente; DX = resto
PUSH DX ;salva o primeiro digito decimal na pilha (1o. resto)
INC CX ;contador = contador + 1
OR AX,AX ;quociente = 0 ? (teste de parada)
JNE PT2 ;nao, continuamos a repetir 
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
RET ;retorna ?rotina que chamou
saidaDEC ENDP


;-------------------------------------------------------------------------SOMATORIA-----------------------------------------------------------------------------

ADICAO10:


call receptorDEC;recebe numero
PUSH AX

MOV AH,2
MOV DL,'+'
INT 21H;printa +

call receptorDEC
MOV N1,AX
POP AX

LEA DX, printresult
MOV AH, 9H
INT 21H;printa a palavra resultado com =

ADD AX, N1 

call saidaDEC

jmp menu
	
	
;--------------------------------------------------------------------------SUBTRACAO---------------------------------------------------------------------------	

SUBTRACAO10:



CALL RECEPTORDEC;recebe numero
PUSH AX

MOV AH,2
MOV DL,'+'
INT 21H;printa -

CALL RECEPTORDEC;recebe segundo numero
MOV N1,AX
POP AX

LEA DX, printresult
MOV AH, 9H
INT 21H;printa a palavra resultado com =

SUB AX, N1

call saidaDEC 

jmp menu
;-------------------------------------------------------------------------Multiplicacao--------------------------------------------------------------------------

multiplicacao10:


CALL RECEPTORDEC
PUSH AX

MOV AH,2
MOV DL,'x'
INT 21H;printa x

CALL RECEPTORDEC
MOV N1,AX
POP AX

LEA DX, printresult
MOV AH, 9H
INT 21H;printa a palavra resultado com =

MUL N1
 
call saidaDEC

jmp menu
;---------------------------------------------------------------------------Divisao---------------------------------------------------------------------------------

Divisao10:




CALL RECEPTORDEC;recebe numero
PUSH AX

MOV AH,2
MOV DL,'/'
INT 21H;printa /

CALL RECEPTORDEC;recebe numero
MOV N1,AX
POP AX

LEA DX, printresult
MOV AH, 9H
INT 21H;printa a palavra resultado com =


DIV N1

call saidaDEC

jmp menu
;----------------------------------------------------------------------------AND-----------------------------------------------------------------------------------