.orig x3000

;shiftl test
	ld r1, num1 	;guarda datos en ro(solucion), r1(numero)
	ld r2, despl	;,r2(cantidad de rotaciones),r3(carry de 16bits)

	and r3,r3,#0
	and r4,r4,#0

	jsr SHIFTLX
	halt	

	num1 .fill x04bb
	despl .fill x5

SHIFTLX		st r2, guarlx2
			st r4, guarlx4
			st r5, guarlx5
			st r6, guarlx6
						
			and r0,r0,#0
			and r4,r4,#0 	;inicializo r4, r5 y r6 por seguridad
			and r5,r5,#0
			ld r5,mascb12		;cargo la mascara del bit 12
			not r6,r5			;creo la antimascara (para restar)
			add r6,r6,#1
			add r1,r1,#0
			brz zeros		; si lo que ingresó es cero, ya termine	
			add r0,r1,#0

op_shiftLx	add r0,r0,r0 		; se multiplica el valor guardado en r1 por 10(bin)
			add r4,r4,r4		; se corre el carry a la izquierda
			
			and r3,r0,r5		;recojo el bit 12
			brz zero 			;si el bit 12 es cero no hay carry(pero si se desplaza hacia la izquierda)
			add r4,r4,#1		;si el bit 12 es uno, se le suma uno al carry
			add r0,r0,r6		;y se resta ese uno del bit 12


zero		add r2,r2,#-1		; se corre tantas veces hacia la izquierda como lo
								; indique R2
			brp op_shiftLx		; mientras que r2 sea zero o positivo, se sigue 	
								; multiplicando por 10(bin)
				
			add r3,r4,#0		;el carry estara en r3		
			ld r2, guarlx2 		;R0 es el resultado del programa , r1 es el operando,
			ld r4, guarlx4 		;R2 son los desplazamientos, r3 es el carry (12b)
			ld r5, guarlx5
			ld r6, guarlx6
zeros
RET
			guarlx2 .BLKW 1
			guarlx4 .BLKW 1
			guarlx5 .BLKW 1
			guarlx6 .BLKW 1
			mascb12 .fill x0800	;0000100000000000 mascara para el bit 12
.end