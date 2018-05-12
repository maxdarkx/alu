.orig x3000

;shiftl test
	and r1,r1,#0 ;guarda datos en ro(solucion), r1(numero),r2(cantidad de rotaciones),r3(carry de 16bits)
	add r1,r1,xFfff

;	and r2,r2,#0
;	add r2,r2,#2

;	and r3,r3,#0
;	and r4,r4,#0

;	jsr ShiftL
;	halt	

ShiftL		st r4, guarsl1
		st r5, guarsl2
		st r6, guarsl3
		st r2, guarsl4
		
		and r4,r4,#0 ;inicializo r4, r5 y r6 por seguridad
		and r5,r5,#0
		and r6,r6,#0

		add r3,r1,#0; variables de control del ciclo=r3 y r5
		brz zeros   ;si lo que ingreso es cero, ya termine	
		add r5,r1,#0

consb		add r3,r3,r3	;r3 dato desplazado
		add r4,r4,r4	;r4 carry de 16 bits
		
		add r0,r3,#0
		not r0,r0
		add r0,r0,#1		
		brz zero
		add r6,r0,r5 ;verificar validez para numeros negativos, de lo contrario convertir
	  	brn consa
zero	  	add r4,r4,#1
consa	 	and r5,r5,#0
		
	  	add r5,r3,#0

neg		add r2,r2,#-1
		brp consb

zeros		and r0,r0,#0
		add r0,r0,r3

		and r3,r3,#0
		add r3,r3,r4
		ld r4, guarsl1
		ld r5, guarsl2
		ld r6, guarsl3
		ld r2, guarsl4
		ret

		guarsl1 .blkw 1
		guarsl2 .blkw 1
		guarsl3 .blkw 1
		guarsl4 .blkw 1
	
.end