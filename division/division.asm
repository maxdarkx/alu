.ORIG x3000
;---------------------------------------------DIVISION 
; recibe r1 y r2 y hace la division R4/R5
;
ld r1,N1X
ld r2,N2X
JSR DIVISION


halt
N1X .fill X4B40
N2X .fill X4280




DIVISION

lea r0, save
str r3, r0,#1
str r4, r0,#2
str r5, r0,#3
str r6, r0,#4
str r7, r0,#5



and r0,r0, #0	;se inicializan todos los registros en cero
and r3,r3, #0
and r4,r4, #0
and r5,r5, #0
and r6,r6, #0
and r7,r7, #0
;
st r1, N1		;el dividendo y el divisor se encuentran almacenados en n1 y n2
st r2,N2
;
ld r0,signo
and r4,r1,r0
and r5,r2,r0
add r0,r4,r5
st  r0, signoF	;extraigo el signo de ambos operadores, lo opero y lo almaceno
;
ld r0, signo
not r0,r0
and r4,r1,r0  
st  r4,N1
and r5,r2,r0
st  r5,N2
;
ld r0, unoinv
ld r3, mantisa
and r4,r1,r3
add r4,r4,r0
st r4,MAN1 		;Extraigo las mantisas de los numeros para operarlas
and r5,r2,r3 	; y hago comparaciones de magnitud con ellas
add r5,r5,r0
st r5,MAN2

;
;------------ mantisa1 < mantisa2
not r5,r5
add r5,r5, #1
add r5,r5 ,#4
brzp cambio
and r5,r5,#0
add r5,r5, #1
st r5, permit
cambio
;
JSR DIV 	;calculo la division de mantisas
;
ld r3, expo 	;saco los exponentes de los numeros
ld r1, N1
ld r2, N2
and r4,r1,r3; EXPONENTE 1
st r4, E1
and r5,r2,r3; EXPONENTE 2
st r5, E2
;
JSR DESPLAZAMIENTO
;
ld r3, bias 	;calculo y realizo los desplazamientos necesarios en los exponentes
not r3,r3
add r3,r3,#1
;
ld r1, exponentecorr
ld r2, exponentecorr2
;
add r4, r1, r3
st r4, expobias1
add r5,r2,r3
ld r0, permit
brz label
add r5,r5, #1
label
st r5, expobias2
;
not r5,r5
add r5,r5,#1
;
add r6,r4,r5; resta exponentes
ld r3,bias
add r6,r6,r3
ld r3,DIEZ
LACH
add r6,r6,r6
add r3,r3,#-1
brnp LACH
;
st r6,expoF
ld r1,DEC
ld r0,expoF
add r0,r1,r0
;
ld r1,signoF
add r0,r1,r0
;
st r0, Resultado
;
ld r1,N1
Ld r2,N2

lea r6, save
ldr r3, r6,#1
ldr r4, r6,#2
ldr r5, r6,#3
ldr r7, r6,#5
ldr r6, r6,#4

RET
;

;division para un registro de 32 bits de longitud
DIV
st r5,saveR5
st r4,saveR4
st r3,saveR3
st r6,saveR6
st r0,saveR0 ; REGISTRO PARTE ENTERA
st r1,saveR1 ; REGISTRO PARTE FRACCION
st r7,saveR7
;
ld r4,MAN1
ld r5,MAN2
and r0,r0,#0
and r1,r1,#0
add r6,r5,#0
;
ld r0,permit
brz jh
add r4,r4,r4
jh
add r0,r0,#0
;
not r5,r5
add r5,r5,#1
add r4,r4,r5
brzp GO
ld r5,debajo
add r4,r4,r4
GO
;
ld r3,DIEZ
add r3,r3,#1
POLS
brz salir
;
add r1,r1,r1
add r0,r4,r5
brzp correr
add r0,r0,#0
brnzp juts
;
correr
add r1,r1,#1
add r4,r4,r5
juts 
add r4,r4,r4
add r3,r3,#-1
brnzp POLS
;
salir
st r1,DEC
ld r5,saveR5
ld r4,saveR4
ld r3,saveR3
ld r6,saveR6
ld R7,saveR7
RET
;
MENOSUNO .FILL X0400
CINCO .FILL X0005
debajo .FILL XFC00
DIEZ .FILL X000A
QUINCE .FILL X000F
expo .FILL X7C00 
mantisa .FILL X03FF
signo .FILL X8000
exponentecorr .BLKW 1
exponentecorr2 .BLKW 1
expobias1 .BLKW 1
expobias2 .BLKW 1
bias .FILL X000F
;
MAN1 .BLKW 1
MAN2 .BLKW 1
S1 .BLKW 1
S2  .BLKW 1
signoF  .BLKW 1
permit .BLKW 1
;
expoF .BLKW 1
MF .BLKW 1
save .blkw 7
saveR5 .BLKW 1
saveR2 .BLKW 1
saveR4 .BLKW 1
saveR3 .BLKW 1
saveR6 .BLKW 1
saveR1 .BLKW 1
saveR0 .BLKW 1
saveR7 .BLKW 1
ENT .BLKW 1
DEC .BLKW 1
unoinv .FILL X0400 
;
JAH .FILL X07FF
JAL .FILL X03FF
;
Resultado .BLKW 1
;
N1 .blkw 1;X4B40
N2 .blkw 1;X4280
OVERFLOW .FILL XFFFF
ERR .FILL XFFFF
E1 .BLKW 1
E2 .BLKW 1
ERROR;
ld r0, ERR;
HALT
;
DESPLAZAMIENTO
st r5, saveR5
st r6, saveR6
st r4, saveR4
st r1, saveR1
st r2, saveR2  
st r3, saveR3
st r7, saveR3
;
and r5,r5,#0
and r6,r6,#0
ld r1, E1
ld r4, CINCO
LOPO
add r1,r1,r1 ;-----------MOVEMOS EL EXPONENTE UNO A LA IZQUIERDA PAR ELIMINAR EL CERO DEL SIGNO
brn sumauno
add  r1,r1,#0
brzp sumacero
;
sumauno
;
add r5,r5,r5
add r5,r5,#1
add r4,r4,#-1
brnp LOPO
add r4,r4,#0
brz CORR
;
sumacero
;
add r5,r5,r5
add r5,r5,#0
add r4,r4,#-1
brnp LOPO
add r4,r4,#0
brz CORR
;
CORR 
and r1,r1,#0 ;-----------NUEVO REGISTRO DESTINADO PARA EL EXPONENTE 1
and r1,r1,r5;
st r1, exponentecorr
;
and r0,r0,#0
and r1,r1,#0
and r2,r2,#0
and r3,r3,#0
and r4,r4,#0
and r5,r5,#0
and r6,r6,#0
;
ld r2,E2
ld r4,CINCO
LOPO2
add r2,r2,r2 ;------------MOVEMOS EL EXPONENTE UNO A LA IZQUIERDA PAR ELIMINAR EL CERO DEL SIGNO
brn sumauno2
add r2,r2,#0
brzp sumacero2
;
sumauno2
;
add r6,r6,r6
add r6,r6,#1
add r4,r4,#-1
brnp LOPO2
add r4,r4,#0
brz corr2
;
sumacero2
;
add r6,r6,r6
add r6,r6,#0
add r4,r4,#-1
brnp LOPO2
add r4,r4,#0
brz corr2
;
corr2
;
and r2,r2,#0 ;-----------NUEVO REGISTRO DESTINADO PARA EL EXPONENTE 2
and r2,r2,r6;
st r2, exponentecorr2
;
ld r5, saveR5
ld r6, saveR6
ld r4, saveR4
ld r3, saveR3
ld r2, saveR2
ld r1, saveR1
RET
.END