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
		add r6,r1,#0
		lea r3,num
		str r4,r3,#0 ;guardo los datos para usar los registros libremente
		str r5,r3,#1
		str r6,r3,#2
		and r3,r3,#0




shiftrx_op 	add r2,r0,#0	; se guarda en r2 el valor actual para verificar si ya terminé
			add r2,r2,#-1
			brnz steprx 		; se le resta -1 y si es negativo o cero ya termine

			ld r5,mascb1
			and  r5,r0,r5	;verifico si el numero a mover (bit 1) produce carry
			brz not_carry

			ld r5,mascb11
			add r3,r3,r5	;agrego un 1 en el bit 11, y lo sigo corriendo a la derecha con el numero original (r0)
			ld r5,mascb1
not_carry	add r3,r3,#0
			brz mov_carry
			add r3,r3,#-2
		
mov_carry 	add r0,r0,#-2	; se divide por 10(bin), por lo tanto esta es la operacion
		
			brp shiftrx_op		; si el numero almacenado es mayor que cero, volver a dividir 
							; entre diez
							; se debe realizar las operaciones anteriores tantas veces
steprx		add r1,r1,#-1	
			brp shiftrx_op

			ld r1,timesrx
			add r2,r0,#0
			ld r0,numrx
			lea r6,numrx
			ldr r4,r6,#1
			ldr r5,r6,#2
			ldr r6,r6,#3
			ret


		numrx .blkw 5 ;
		timesrx .blkw 1;
		mascb1 .fill x0001;
		
		mascb11 .fill x0400	;0000010000000000 mascara para el bit 11
.end