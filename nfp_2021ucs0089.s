.section .data
num1: .word 0x7ff60000
num2: .word 0x00330000
result: .word 0
signval: .word 0x80000000
expval: .word 0x7FF80000
manval: .word 0x0007FFFF
signif: .word 0x00080000
comp: .word 0x0000007F
count: .word 0x00100000
signalt: .word 0x7FFFFFFF

.section .text
.global _start



nfpAdd:
    stmfd sp!, {r0,r2-r9,lr}
    ldr r0,=num1
    ldr r2,=num2
    ldr r1,=result
    ldr r3,[r0]
    ldr r4,[r2]
    ldr r5,=expval
    ldr r6,[r5]
    and r7,r6,r3 @expA
    @signextention
    lsl r7,r7,#1
    asr r7,r7,#1
    and r8,r6,r4 @expB
    @signextention
    lsl r8,r8,#1
    asr r8,r8,#1
    cmp r7,r8
    bgt d1
    beq d1
    mov r0,r3
    mov r3,r4
    mov r4,r0
    mov r0,r7
    mov r7,r8
    mov r8,r0
    d1:
        ldr r5,=signval
        ldr r6,[r5]
        and r2,r6,r3 @signA
        add r9,r9,r2
        sub r2,r7,r8 @diffex
        lsr r2,#19
        ldr r5,=manval
        ldr r6,[r5]
        and r7,r6,r3 @manA
        and r8,r6,r4 @manB
        ldr r5,=signif
        ldr r6,[r5]
        add r7,r6,r7 @signiA
        add r8,r6,r8 @signiB
        lsr r8,r8,r2 @rightshifting smaller singni
        ldr r5,=signval
        ldr r6,[r5]
        and r2,r6,r3 @signA
        and r0,r6,r4 @signB
        subs r6,r2,r0
        beq d3
        mov r6,#-1
        mul r8,r8,r6
    d3:
        add r8,r7,r8
        ldr r5,=signval
        ldr r6,[r5]
        and r2,r6,r8
        cmp r6,r2
        bne d4
        mov r6,#-1
        mul r8,r8,r6
        mvn r9,r9
        ldr r5,=signval
        ldr r6,[r5]
        and r9,r9,r6
    d4:
        ldr r5,=count
        ldr r6,[r5]
        @Finding the first 1 in the significand
        mov r2,#1
        loop:
            and r0,r6,r8
            cmp r6,r0
            sub r2,r2,#1
            lsr r6,r6,#1
            bne loop
        add r2,r2,#1
        mov r0,r2
        lsl r2,#19
        ldr r5,=expval
        ldr r6,[r5]
        and r7,r6,r3 @expA
        add r7,r7,r2
        ldr r5,=signval
        ldr r6,[r5]
        cmp r6,r9
        add r9,r9,r7
        beq d7
        ldr r5,=signalt
        ldr r6,[r5]
        and r9,r9,r6
        bne d8
    d7:
        ldr r5,=signval
        ldr r6,[r5]
        orr r9,r9,r6
    d8:
        cmp r0,#0
        bgt d5
        mov r2,#-1
        mul r2,r0,r2
        lsl r8,r8,r2
        bmi d6
    d5:
        cmp r0,#1
        bne d6
        lsr r8,r8,#1
    d6:
        ldr r5,=manval
        ldr r6,[r5]
        and r8,r8,r6
        add r9,r9,r8
        @ str r9,[r1]
        @storing byte by byte
        add r1,r1,#3
        strb r9,[r1]
        lsr r9,r9,#8
        sub r1,r1,#1
        strb r9,[r1]
        lsr r9,r9,#8
        sub r1,r1,#1
        strb r9,[r1]
        lsr r9,r9,#8
        sub r1,r1,#1
        strb r9,[r1]
        ldmfd sp!, {r0,r2-r9,pc}



nfpMultiply:
    stmfd sp!, {r0,r2-r9,lr}
    ldr r0,=num1
    ldr r2,=num2
    ldr r1,=result
    ldr r3,[r0]
    ldr r4,[r2]
    ldr r5,=signval
    ldr r6,[r5]
    and r7,r6,r3 @signA
    and r8,r6,r4 @signB
    eor r9,r7,r8
    ldr r5,=expval
    ldr r6,[r5]
    and r7,r6,r3 @expA
    and r8,r6,r4 @expB
    lsl r7,r7,#1
    lsl r8,r8,#1
    asr r7,r7,#20
    asr r8,r8,#20
    add r7,r7,r8 @expA+expB
    lsl r7,r7,#20
    lsr r7,r7,#1
    and r8,r7,r6
    add r9,r9,r8
    ldr r5,=manval
    ldr r6,[r5]
    and r7,r6,r3 @manA
    and r8,r6,r4 @manB
    ldr r5,=signif
    ldr r6,[r5]
    add r7,r6,r7 @signiA
    add r8,r6,r8 @signiB
    umull r7,r8,r7,r8

    @checking whether increament in exponent is required
    cond: 
        ldr r5,=comp
        ldr r6,[r5]
        cmp r8,r6
        bmi cond1
        mov r4,#1
        b cond2
        

    cond1:
    mov r4,#0
    cond2:
    lsl r4,r4,#19
    add r9,r9,r4 @increasing the exponent
    mov r4,#0
    adc r4,r4,#6
    mov r2,r4
    mov r3,#32
    sub r4,r3,r4
    lsl r8,r8,r4
    lsr r8,r8,#13
    mov r3,#19
    sub r2,r3,r2
    mov r3,#32
    sub r2,r3,r2
    lsr r7,r2
    add r8,r8,r7
    add r9,r9,r8
    @ str r9,[r1]
    @storing byte by byte
    add r1,r1,#3
    strb r9,[r1]
    lsr r9,r9,#8
    sub r1,r1,#1
    strb r9,[r1]
    lsr r9,r9,#8
    sub r1,r1,#1
    strb r9,[r1]
    lsr r9,r9,#8
    sub r1,r1,#1
    strb r9,[r1]
    ldmfd sp!, {r0,r2-r9,pc} 

_start:
bl nfpAdd
ldr r0,[r1]
nop