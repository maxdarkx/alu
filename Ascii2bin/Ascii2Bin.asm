.ORIG X3000

AND R0, R0, #0

AND R4, R4, #0

AND R2, R2, #0

ADD R1, R1, #0

BRz DoneAtoB

;

LD  R3, GetCode

LEA R2, CodeBUFFER

ADD R2, R2, R1

ADD R2, R2, #-1

;

LDR R4, R2, #0

ADD R4, R4, R3

ADD R0, R0, R4

;

ADD R1, R1, #-1

BRz DoneAtoB

ADD R2, R2, #-1

;

LDR R4, R2, #0

ADD R4, R4, R3

LEA R5, decenas

ADD R5, R5, R4

LDR R4, R5, #0

ADD R0, R0, R4

;

ADD R1, R1, #-1

BRz DoneAtoB

ADD R2, R2, #-1

;

LDR R1, R2, #0

ADD R4, R4, R3

LEA R5, Centenas

ADD R5, R5, R4

LDR R4, R5, #0

ADD R0, R0, R4

;

DoneAtoB     RET

GetCode      .FILL xFFD0

CodeBUFFER   .BLKW 4

decenas      .FILL 0
 
            .FILL 10

             .FILL 20

             .FILL 30

             .FILL 40

             .FILL 50

             .FILL 60

             .FILL 70

             .FILL 80

             .FILL 90

;

Centenas     .FILL 0
   
          .FILL 100

             .FILL 200

             .FILL 300

             .FILL 400

             .FILL 500

             .FILL 600

             .FILL 700

             .FILL 800

             .FILL 900

;

.END


