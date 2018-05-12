.orig x3000
	and r0,r0,#0
	and r3,r3,#0
	and r4,r4,#0
	and r5,r5,#0
	and r6,r6,#0

	ld r1,guarx1
	ld r2,guarx2
	jsr mult2x
	halt




mult2x	st r7,guarmt21 ;multiplicador
	st r2,guarmt22	;multiplicando
	st r3,guarmt23	;carry
	st r4,guarmt24	;auxiliar para carry
	st r5,guarmt25  ;auxiliar para determinar el carry, bitmask
	

	and r3,r3,#0 	 ;r3 es el carry de 16 bits
	and r0,r0,#0
	and r4,r4,#0
	ld r5, bitmask
	not r6,r5
	add r6,r6,#1
	

	add r2,r2,#0	;no puedo tener un multiplicando negativo
	brp mult2x1
	not r2,r2
	add r2,r2,#1

mult2x1	add r0,r1,r0
	and r4,r0,r5
	add r4,r4,r6
	brn not_over
	add r3,r3,#1
	add r0,r0,r6
not_over 

	add r2,r2,#-1
	brp mult2x1
		
	ld r7,guarmt21
	ld r2,guarmt22
	ld r4,guarmt24
	ld r5,guarmt25
	ret
	
	guarmt21 .blkw 1
	guarmt22 .blkw 1
	guarmt23 .blkw 1
	guarmt24 .blkw 1
	guarmt25 .blkw 1
	guarmt26 .blkw 1
	guarx1 .fill x07FF
	guarx2 .fill x0002
	bitmask .fill x0800


 ;r0 dato corrido 
	;r1 dato entrante
	;r2 cantidad de corrimientos necesarios

shiftR		st r2, guarshiftx1
op_shiftrx 	add r0,r0,#-10
		add r2,r2,#-1
		brp op_shiftrx
		ld r2, guarshiftx1
		ret

	guarshiftx1 .blkw 1 
	
.end
