.orig x3000
lea r1, num
ldr r0,r1,#0
ldr r1,r1,#1

jsr SHIFTRX

halt

num .fill x4488 ;numero random
times .fill x0005 ;rotar el dato 5 veces a la derecha

		; Funcion para mover cadenas de 11 bits hacia la derecha
		; con carry de 11 bits
		; se recibe en r0 el dato a mover y en r1 
		; el numero de posiciones a desplazar
		; se da la respuesta en r2 (solucion) y r3 (carry), 

SHIFTRX	st r0, numrx
		st r1, timesrx
		and r2,r2,#0 ;solucion al problema(cociente entre 2)
		and r3,r3,#0
		lea r3,numrx
		str r4,r3,#1 ;guardo los datos para usar los registros libremente
		str r5,r3,#2
		str r6,r3,#3

		and r4,r4,#0
		and r3,r3,#0
		ld r5,mascb1
		


shiftrx_op  and r6,r0,r5
			brz bitmov
			ld r5,mascb12
			add r4,r4,r5
			ld r5,mascb1
bitmov		add r3,r0,#0	; se guarda en r2 el valor actual para verificar si ya terminé
			add r3,r3,#-1
			brnz steprx 		; se le resta -1 y si es negativo o cero ya termine

			add r2,r2,#1
			add r0,r0,#-2
			brp bitmov		; si el numero almacenado es mayor que cero, volver a dividir 
							; entre diez
							; se debe realizar las operaciones anteriores tantas veces
steprx		

			add r4,r4,#0
			brz carry
			and r6,r6,#0
carry_mov	add r6,r6,#1
			add r4,r4,#-2
			brp carry_mov

carry		add r4,r6,#0	; r4 contiene el carry movido a la derecha
			add r0,r2,#0	;r0 continene el elemento corrido a la derecha
			and r2,r2,#0
			add r1,r1,#-1	
			brp shiftrx_op


			ld r1,timesrx
			add r2,r0,#0
			add r3,r4,#0


			ld r0,numrx
			lea r6,numrx
			ldr r4,r6,#1
			ldr r5,r6,#2
			ldr r6,r6,#3
			ret


		numrx .blkw 4 ;
		timesrx .blkw 1;
		mascb1 .fill x0001;
		
		mascb11 .fill x0400	;0000010000000000 mascara para el bit 11
		mascb12 .fill x0800	;0000100000000000 mascara para el bit 12
.end