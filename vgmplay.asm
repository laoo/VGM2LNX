zero     = 0 ;reserved to be 0
oscadr0  = 2 ;address of oscillator screen row for channel 0
oscadr1  = 4 ;address of oscillator screen row for channel 1
oscadr2  = 6 ;address of oscillator screen row for channel 2
oscadr3  = 8 ;address of oscillator screen row for channel 3
osccol   = 10 ;column of oscillator 0-79
command  = 11 ;command read from cartridge
filladr  = 12 ;address where to start filling
rowsize  = 14 ;size of single block
stride   = 15 ;stride between blocks
rows     = 16 ;number of blocks

tabc0   = $60
tabc1   = $88
tabc2   = $b0
tabc3   = $d8


    opt c+
    org $200

    ldx LYNX.RCART0 ;start lo
    lda LYNX.RCART0 ;start hi
    sta loader_ptr+1
    lda LYNX.RCART0 ;stop lo
    clc
    adc #1
    sta stop_lo
    lda LYNX.RCART0 ;stop hi
    adc #0
    sta stop_hi
loop
    lda LYNX.RCART0
loader_ptr = *+1
    sta $ff00,x
    inx
    bne @+
    inc loader_ptr+1
@   lda loader_ptr+1
stop_hi = *+1
    cmp #$ff
    bne loop
stop_lo = *+1
    cpx #$ff
    bne loop
    jmp start

    org $300

start
    ;init tables
    ldx #0
@   lda srctabL,x
    sta SCRTAB0L,x
    sta SCRTAB2L,x
    clc
    adc #40
    sta SCRTAB1L,x
    sta SCRTAB3L,x
    lda srctabH,x
    sta SCRTAB0H,x
    adc #0
    sta SCRTAB1H,x
    inx
    bne @-

@   lda SCRTAB0H,x
    clc
    adc #$f
    sta SCRTAB2H,x
    lda SCRTAB1H,x
    clc
    adc #$f
    sta SCRTAB3H,x
    inx
    bne @-

    ldx #0
@   stz $00,x
    inx
    bne @-

    lda #LYNX.@DISPCTL(DISP_COLOR|DISP_FOURBIT|DMA_ENABLE)
    sta LYNX.DISPCTL
    lda #LYNX.@SERCTL(TXOPEN)
    sta LYNX.SERCTL
    lda #LYNX.@IO(READ_ENABLE|RESTLESS|CART_POWER_OFF)
    sta LYNX.IODIR
    lda #LYNX.@IO(RESTLESS|CART_ADDR_DATA)
    sta LYNX.IODAT
    lda #$ff
    sta LYNX.MPAN
    stz LYNX.MSTEREO
    stz LYNX.AUDIO3_VOLCNTRL
    stz LYNX.AUDIO2_VOLCNTRL
    stz LYNX.AUDIO1_VOLCNTRL
    stz LYNX.AUDIO0_VOLCNTRL
 
    ;hardcoded refresh rate
    lda #158
    sta LYNX.HCOUNT_BACKUP
    lda #104 ;backup value for vertical scan timer (== 102 vertical lines plus 2)
    sta LYNX.VCOUNT_BACKUP
    lda #41
    sta LYNX.PBKUP

    lda #$ff
    sta LYNX.INTRST
    lda #LYNX.@MAPCTL(VECTOR_SPACE)
    sta LYNX.MAPCTL

    lda #LYNX.@TIM_CONTROLA(ENABLE_RELOAD|ENABLE_COUNT)
    sta LYNX.HCOUNT_CONTROLA	;hbi
    lda #LYNX.@TIM_CONTROLA(ENABLE_RELOAD|ENABLE_COUNT|AUD_LINKING)
    sta LYNX.VCOUNT_CONTROLA	;vbi

    lda #$00
    sta LYNX.GREEN0
    sta LYNX.BLUERED0
    lda #$ff
    sta LYNX.GREENF
    sta LYNX.BLUEREDF

    stz LYNX.DISPADR
    lda #$c0
    sta LYNX.DISPADR+1

    lda #LYNX.@MAPCTL(VECTOR_SPACE)
    sta LYNX.MAPCTL
    lda #<irq
    sta LYNX.CPU_IRQ
    lda #>irq
    sta LYNX.CPU_IRQ+1

    lda #1
    jsr LYNX.KERNEL.SELECT_SECTOR
    lda #24
    sta LYNX.TIMER5_BACKUP
    lda #LYNX.@TIM_CONTROLA(ENABLE_RELOAD|ENABLE_COUNT|AUD_1)
    sta LYNX.TIMER5_CONTROLA

    cli

    lda #$80
    sta LYNX.INTSET
@   dec
    bne @-

main
    lda #0
    ldy osccol
    ldx tabc0,y
    lda scrtab0l,x
    sta oscadr0
    lda scrtab0h,x
    sta oscadr0+1
    lda #$00
    sta (oscadr0),y
    ldx LYNX.AUDIO0_OUTPUT
    stx tabc0,y
    lda scrtab0l,x
    sta oscadr0
    lda scrtab0h,x
    sta oscadr0+1
    lda #$ff
    sta (oscadr0),y

    inc
    ldx tabc1,y
    lda scrtab1l,x
    sta oscadr1
    lda scrtab1h,x
    sta oscadr1+1
    lda #$00
    sta (oscadr1),y
    ldx LYNX.AUDIO1_OUTPUT
    stx tabc1,y
    lda scrtab1l,x
    sta oscadr1
    lda scrtab1h,x
    sta oscadr1+1
    lda #$ff
    sta (oscadr1),y

    inc
    ldx tabc2,y
    lda scrtab2l,x
    sta oscadr2
    lda scrtab2h,x
    sta oscadr2+1
    lda #$00
    sta (oscadr2),y
    ldx LYNX.AUDIO2_OUTPUT
    stx tabc2,y
    lda scrtab2l,x
    sta oscadr2
    lda scrtab2h,x
    sta oscadr2+1
    lda #$ff
    sta (oscadr2),y

    inc
    ldx tabc3,y
    lda scrtab3l,x
    sta oscadr3
    lda scrtab3h,x
    sta oscadr3+1
    lda #$00
    sta (oscadr3),y
    ldx LYNX.AUDIO3_OUTPUT
    stx tabc3,y
    lda scrtab3l,x
    sta oscadr3
    lda scrtab3h,x
    sta oscadr3+1
    lda #$ff
    sta (oscadr3),y

    inc osccol
    lda osccol
    cmp #40
    bcc jmain
    stz osccol
jmain
   jmp main

SCRTAB0L equ $1000
SCRTAB0H equ $1100
SCRTAB1L equ $1200
SCRTAB1H equ $1300
SCRTAB2L equ $1400
SCRTAB2H equ $1500
SCRTAB3L equ $1600
SCRTAB3H equ $1700

irq pha
    phx
    phy
    lda #$ff
    sta LYNX.INTRST

irq_loop
    lda LYNX.RCART0 ;command
    asl
    sta command
    bcc skip_fill_mikey

    ;filling mikey registers
    ldy LYNX.RCART0 ;number of registers
@   ldx LYNX.RCART0 ;register
    lda LYNX.RCART0 ;value
    sta LYNX.MIKEY_BASE,x
    dey
    bne @-

skip_fill_mikey
    asl command
    bcc skip_fill_memory

    ;filling memory
    ldx #4
@   lda LYNX.RCART0
    sta filladr,x
    dex
    bpl @-

fill_loop
    ldy rowsize
@   lda LYNX.RCART0
    sta (filladr),y
    dey
    bne @-

    lda filladr
    clc
    adc stride
    bcc @+
    inc filladr+1
@   dec rows
    bne fill_loop

skip_fill_memory
    asl command
    bcc skip_change_block
    lda LYNX.RCART0 ;block number
    jsr LYNX.KERNEL.SELECT_SECTOR

skip_change_block
    asl command
    bcc skip_jsr

    lda LYNX.RCART0
    sta autojsr
    lda LYNX.RCART0
    sta autojsr+1
autojsr = *+1
    jsr $ffff

skip_jsr
    asl command
    bcs irq_loop

    ply
    plx
    pla
    rti

sc_h = 96/2
sc_hh = sc_h/2

srctabL
    .rept 128
    dta l($c000+[sc_hh-1-.r*sc_hh/128]*80)
    .endr
    .rept 128
    dta l($c000+[sc_h-1-.r*sc_hh/128]*80)
    .endr

srctabH
    .rept 128
    dta h($c000+[sc_hh-1-.r*sc_hh/128]*80)
    .endr
    .rept 128
    dta h($c000+[sc_h-1-.r*sc_hh/128]*80)
    .endr

    icl 'lynxhard.asm'
