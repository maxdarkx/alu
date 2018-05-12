
;
;-----------------Multtiplicacion de 16 bits-------------------------
;los operandos se encontraran en r1 y r2
;en r0 se pondra el resultado final de la operacion
;
;	
;
.orig x3000
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
;	
		ld r5,masce		; cargo la mascara para sacar el exponente
		and r1,r3,r5	; saco el exponente de n1, guardo en r1
		and r2,r4,r5	; saco el exponente de n2, guardo en r2
		add r6,r1,r2	; sumo los exponentes
		ld r5, bias		; cargo el bias en r5
		not r5,r5		; hallo el -bias 
		add r5,r5,#1	; -bias
		add r6, r6,r5	; sumo los exponentes y les resto el bias
		st r6, es		; los guardo en es

;__________________________________________________________________________________
;_____________________________revisar desde aca____________________________________
		ld r5, mascm	; cargo la mascara para la mantisa	
		and r1,r3,r5	; cargo la mantisa del numero 1
		and r2,r4,r5	; cargo la mantisa del numero 2
		ld r5, addon
		add r1,r1,r5	; agrego el 1 virtual
		add r2,r2,r5	; agrego el 1 virtual
		jsr MULT2x 		; envio las mantisas en r1 y r2 y 
						; retorno los resultados en r0 y r3
;
		and r5,r5,#0    ; necesito hallar el bit 22 en r3
		ld r5,mascb22	; cargo una mascara adecuada para sacar el bit 11
;
		not r6,r5		; 
		add r6,r6,#1
;		
		and r4,r5,r3	; guardo el bit22 en r5
;
		brz masc10		; si el bit 22 el un 1, debo quitarlo y esa es mi mantisa
;		
		add r3,r6,r6	;r3, mantisa lista
		st r3, mant
		ld r4, es		;debo sumarle #1 al exponente
		add r4,r4,#1
		st r4, es 		;guardo el nuevo exponente
		brnzp result1
;
masc10	add r4,r0,#0	;si el bit 22 es un cero, necesito correr el dato que hay en r3
		add r0,r3,#0	;un bit a la izquierda, y tomar el ultimo bit de r0
		add r3,r4,#0
		and r2,r2,#0
		add r2,r2,#1	;en r2 estara la cantidad de corrimientos (=1)
		add r0,r0,r6	;en r0 estara la mantisa a correr
		jsr SHIFTL	 	;en r3 estara la mantisa que va a enviar su ultimo bit
		and r4,r3,r5	;pongo en r4 el ultimo bit de r3
		add r0,r0,r4
		add r3,r0,#0
result1	st r3, mant 	;guardo el resultado de la mantisa en mant

		and r0,r0,#0	;hallo el numero resultado y lo pongo en r0
		ld r1,stt
		ld r2,es
		add r0,r0,r1
		add r0,r0,r2
		add r0,r0,r3

	halt
;
;espacios reservados en memoria y constantes utilizadas
;________________________________________________________________________
	na .fill x57b0 ;signo 0
	nb .fill x4a00 ;signo 0
	stt .blkw 1
	es  .blkw 1
	mascs .fill x8000					;mascara para el signo
	masce .fill x7C00 ;0111110000000000	mascara para el exponente
	mascm .fill x03ff ;0000001111111111	mascara para la mantisa
	mascb22 .fill x0400; 0000010000000000 mascara para el bit 11
	addon .fill x0800 ;0000010000000000 uno invisible (o 'virtual')
	bias  .fill x3c00 ;001111 bias
	mant  .blkw 1
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
;_______________________________________________________________________________________
;
;_____________________________MULT2X____________________________________________________
;multiplicacion en 11 bits(incluyendo el '1 virtual') con carry de 11 bits para overflow
;se usan r1 y r2 como operandos y el resultado se almacena en r0 y r3
MULT2x	st r2,guarmt22	;multiplicando
		;st r3,guarmt23	;carry
		st r4,guarmt24	;auxiliar para carry
		st r5,guarmt25  ;auxiliar para determinar el carry, bitmask
		st r6,guarmt26  ;auxiliar para determinar el carry, not(bitmask)
;

		and r3,r3,#0 	;r3 es el carry de 16 bits
		and r0,r0,#0
		and r4,r4,#0
		ld r5, bitmask
		not r6,r5
		add r6,r6,#1
;
;
		add r2,r2,#0		;no puedo tener un multiplicando negativo
		brp mult2x1
		not r2,r2
		add r2,r2,#1

mult2x1	add r0,r1,r0		;funcion principal de la multiplicacion
		and r4,r0,r5		
		add r4,r4,r6
		brn not_over		;determino si debo agregar carry mirando si hay bits
		add r3,r3,#1		;de salida en el bit 12. de ser asi comienzo a acumular
		add r0,r0,r6		;esos bits en r3 y los quito del registro de salida r0
not_over add r2,r2,#-1
		brp mult2x1
		
		ld r2,guarmt22
		ld r4,guarmt24
		ld r5,guarmt25
		ld r6,guarmt26
	ret
	
		guarmt22	.blkw 1
		;guarmt23	.blkw 1
		guarmt24 	.blkw 1
		guarmt25 	.blkw 1
		guarmt26 	.blkw 1
		guarx1 		.fill x07FF
		guarx2 		.fill x0002
		bitmask 	.fill x0800
;_____________________________________________________________________
;______________________________SHIFTR_________________________________
SHIFTR		st r2, guarshiftr
op_shiftr 	add r0,r0,#-10
			add r2,r2,#-1
			brp op_shiftr
			ld r2, guarshiftr
		ret

			guarshiftr .blkw 1 


;_____________________________________________________________________

;______________________________SHIFTL_________________________________

SHIFTL		st r2, guarshiftl
op_shiftL	add r0,r0,r1
			add r2,r2,#-1
			brp op_shiftL
			ld r2, guarshiftl
		ret
			guarshiftl .blkw 1
.end
;_____________________________________________________________________