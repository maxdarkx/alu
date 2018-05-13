.orig x3000


	ld r0,num
	ld r1,times
	and r2,r2,#0
	and r3,r3,#0
	jsr SHIFTR
	st r0,sol
	halt

	num .fill x78
	times .fill x5
	sol   .blkw 1


	
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
.end