.ORIG x3000

LDI R0, KBSR

ADD R0, R0, #15

ADD R0, R0, #15

LD R3, POS

STI R3, DSR

STI R0, DDR

ADD R3,R3,#1

BRnzp #-5

KBSR .FILL xFDEE

DDR .FILL xFDFE

DSR .FILL xFDFF

POS .FILL x0720

.END
