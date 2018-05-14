;-------------------------------suma de 16 bits-----------------------------
;los operandos se encontraran en r1 y r2
;el resultado se pondra en r0
;
;
;
.orig x3000
;
		and r0,r0,#0
		and r1,r1,#0
		and r2,r2,#0
		and r5,r5,#0
		and r6,r6,#0

		ld r3, na		; multiplicador de 16 bits
		ld r4, nb		; multiplicando de 16 bits
		and r1,r1,x0 	; signo1	
		and r2,r2,x0 	; signo2
		ld r5,mascs  	; mascara para el signo
		and r1,r5,r3 	; almaceno el signo en r1 y r2 para xor
		and r2,r5,r4
;	
		jsr XOR			; ejecutamos la operacion
		st r0, stt		; guardo la xor en la posicion stt

		ld r5,masce		; cargo la mascara para sacar el exponente
		and r1,r3,r5	; saco el exponente de n1, guardo en r1
		and r2,r4,r5	; saco el exponente de n2, guardo en r2
		not r2,r2 		; niego el exponente del segundo para la diferencia
		add r2,r2,#1
		add r2,r1,r2 	; calculo la diferencia

		st r2,diffe		; guardo la diferencia para futuras instancias
		ld r5,masc15	; mascara para sacar el bit 15
		and r5,r2,r5	; sacamos el bit 15
		
		brz maxb		; branch para calculo del max
		not r2,r2		; si el bit 15 es 1, niego diffe
		add r2,r2,#1
maxb	st r2, max
		add r6,r5,#0	; guardo el bit 15 de diffe, importante mas adelante
		brz shifting	; segun el bit 15 de diffe, corro la mantisa max veces hacia la izquierda
		

		ld r5, mascm	; cargo la mascara para la mantisa
		and r1,r3,r5	; saco la mantisa de n1, guardo en r1
		ld r5, mascb11	; cargo la mascara para el bit 11
		add r1,r5,#0	; agrego el bit adicional a la mantisa de NA
 		jsr SHIFTLX		; corro

















halt
;espacios reservados en memoria y constantes utilizadas
;________________________________________________________________________
	na .fill x58F8 ; 159=0101100011111000 = x58F8
	nb .fill x4400 ; 4 = 0100010000000000 = x4400
	stt .blkw 1			;signo del resultado
	es  .blkw 1			;exponente del resultado	
	mant  .blkw 1		;mantisa del resultado

	diffe  .blkw 1 		;espacio para la diferencia entre exponentes
	max  .blkw 1 		;espacio la variable max
	mascs  .fill x8000	;1000000000000000 mascara para el signo
	masce  .fill x7C00	;0111110000000000 mascara para el exponente
	mascm  .fill x03ff	;0000001111111111 mascara para la mantisa
	mascb11 .fill x0400	;0000010000000000 mascara para el bit 11
	masc15 .fill x4000 	;0100000000000000 mascara para el bit 15
	bias   .fill x3c00 	;0011110000000000 bias
;_________________________________________________________________________
;
;_______________________________funciones______________________________
;
;_________________________________XOR___________________________________
;los operandos se encuentran en r1 y r2
; el resultado estara en r0
;
;
XOR st r3, guarXOR3		;Se almacenan en memoria los registros a utilizar
	st r4, guarXOR4
	st r5, guarXOR5
	st r6, guarXOR6
;
	not r3,r1			;se realiza la xor= ((~A) and B) or(+) (A and(~B))
	not r4,r2
	and r5,r1,r4
	and r6,r2,r3 
	add r0,r5,r6
;
	ld r3, guarXOR3 ;se cargan los datos anteriormente ubicados en la memoria
	ld r4, guarXOR4
	ld r5, guarXOR5
	ld r6, guarXOR6
;
	ret
;
	guarXOR3 .blkw 1
	guarXOR4 .blkw 1
	guarXOR5 .blkw 1
	guarXOR6 .blkw 1
;_____________________________________________________________________
;______________________________SHIFTR_________________________________
;funcion para mover cadenas de bits hacia la derecha
;
;
SHIFTR	st r0, guarsr1 	; se utilizan los registros r0, r1, r2 y r3
		st r2, guarsr2	; en r0 se recibe el numero a mover a la derecha
		st r3, guarsr3	; en r1 se encuentra el numero de corrimientos
						; r2 y r3 son para uso interno
		add r3,r1,#0	
		and r1,r1,#0
		and r2,r2,#0	; se inicializan los registros r3(# de corrimientos),
						; r1(para verificar si ya llegue a uno o a cero) 
						; y r2(en donde se almacenara el resultado parcial)
;
shiftr1	add r1,r0,#0	; se guarda en r1 el valor actual para verificar si ya terminé
		add r1,r1,#-1
		brnz step 		; se le resta -1 y si es negativo o cero ya termine

		add r2,r2,#1	; se guarda el divisor
		add r0,r0,#-2	; se divide por 10(bin), por lo tanto esta es la operacion
		
		brp shiftr1		; si el numero almacenado es mayor que cero, volver a dividir 
						; entre diez
						;
step	add r0,r2,#0	; se debe realizar las operaciones anteriores tantas veces
		and r2,r2,#0	; como corrimientos se necesiten
		and r1,r1,#0
		add r3,r3,#-1	
		brp shiftr1
		ld r1,guarsr1	; se cargan los valores originales. Solo se conserva R0 como 
		ld r2,guarsr2	; resultado del algoritmo
		ld r3,guarsr3	
RET

		guarsr1 .blkw 1
		guarsr2 .blkw 1
		guarsr3 .blkw 1
;______________________________________________________________________________________

;______________________________SHIFTL__________________________________________________
;operacion para mover cadenas de bits  a la izquierda
SHIFTL		st r2, guarshiftl	; se guarda el dato en r2
op_shiftL	add r0,r0,r1 		; se multiplica el valor guardado en r1 por 10(bin)
			add r2,r2,#-1		; se corre tantas veces hacia la izquierda como lo
								; indique R2
			brzp op_shiftL		; mientras que r2 sea zero o positivo, se sigue 	
								; multiplicando por 10(bin)
			ld r2, guarshiftl	;R0 es el resultado del programa y r1 es el operando,
						;		R2 es para uso interno
RET
			guarshiftl .blkw 1
;______________________________________________________________________________________

;______________________________________________________________________________________

;______________________________SHIFTL__________________________________________________
;operacion para mover cadenas de 11 bits  a la izquierda con carry de 11bits

SHIFTLX	st r4, guarslX1
		st r5, guarslX2
		st r6, guarslX3
		st r2, guarslX4
		
		and r4,r4,#0 ;inicializo r4, r5 y r6 por seguridad
		and r5,r5,#0
		and r6,r6,#0

		add r3,r1,#0; variables de control del ciclo=r3 y r5
		brz zeros   ;si lo que ingreso es cero, ya termine	
		add r5,r1,#0

consb	add r3,r3,r3	;r3 dato desplazado
		add r4,r4,r4	;r4 carry de 16 bits
		
		add r0,r3,#0
		not r0,r0
		add r0,r0,#1		
		brz zero
		add r6,r0,r5 ;verificar validez para numeros negativos, de lo contrario convertir
	  	brn consa
zero	add r4,r4,#1
consa	and r5,r5,#0
		
	  	add r5,r3,#0

neg		add r2,r2,#-1
		brp consb

zeros	and r0,r0,#0
		add r0,r0,r3

		and r3,r3,#0
		add r3,r3,r4
		ld r4, guarslX1
		ld r5, guarslX2
		ld r6, guarslX3
		ld r2, guarslX4
		ret

		guarslX1 .blkw 1
		guarslX2 .blkw 1
		guarslX3 .blkw 1
		guarslX4 .blkw 1




.end
;_____________________________________________________________________