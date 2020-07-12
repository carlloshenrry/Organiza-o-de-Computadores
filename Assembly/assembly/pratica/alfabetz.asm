title alfabeto

.model small
.stack 100h

.data
n dw '?'
n1 dw '?'

LF EQU 0AH
CR EQU 0DH 

.code
.startup

mov ah,1;recebe caracter
int 21h
mov ah,0
mov n,ax
sub n,48


mov ah,1;recebe caracter
int 21h
mov ah,0
mov n1,ax



L1: MOV AX, n1;comparação

CMP AX, 13

JE FIM;sai do loop 

sub n1,48
mov AX,10
mul n     

mov cx,n1
add n,cx

mov ah,1
int 21h
mov ah,0
mov n1,ax


JMP L1;retorna para L1

FIM:

mov ah,2;mostrar
mov dx,n
int 21h 

mov ah,4ch
int 21h

end
