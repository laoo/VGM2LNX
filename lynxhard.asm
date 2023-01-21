

.local LYNX

DISPLAY_BUFSIZE   = $1fe0

; First address of the block of hardware addresses.
HARDWARE_START    = $fc00

; SUZY chip functions are mapped into the $FC00 page
SUZY_BASE         = $fc00

; SUZY registers from $FC00-$FC7F (both sprite and MATH) clear the upper byte
; when the lower byte is stored to.

; Sprite engine registers - *'ed values are used internally by SUZY and
; cannot be usefully initialized externally.

;TMPADR           = $fc00 ; *
;TILTACUM         = $fc02 ; *
HOFF              = $fc04 ; Offset to H edge of screen
VOFF              = $fc06 ; Offset to V edge of screen
VIDBAS            = $fc08 ; Base Address of Video Build Buffer
COLLBAS           = $fc0a ; Base Address of Coll Build Buffer
;VIDADR           = $fc0c ; *
;COLLADR          = $fc0e ; *
SCBNEXT           = $fc10 ; Address of Next SCB
;SPRDLINE         = $fc12 ; *
;HPOSSTRT         = $fc14 ; *
;VPOSSTRT         = $fc16 ; *
SPRHSIZ           = $fc18 ; H Size
SPRVSIZ           = $fc1a ; V Size
;STRETCH          = $fc1c ; *
;TILT             = $fc1e ; *
;SPRDOFF          = $fc20 ; *
;SCVPOS           = $fc22 ; *
COLLOFF           = $fc24 ; Offset to Collision Depository
;VSIZACUM         = $fc26 ; *
HSIZOFF           = $fc28 ; H Horizontal Size Offset
VSIZOFF           = $fc2a ; H Vertical Size Offset
;SCBADR           = $fc2c ; *
;PROCADR          = $fc2e ; *


; Math engine registers

MATHD             = $fc52 ;
MATHC             = $fc53 ;
MATHB             = $fc54 ;
MATHA             = $fc55 ;
MATHP             = $fc56 ;
MATHN             = $fc57 ;

MATHH             = $fc60 ;
MATHG             = $fc61 ;
MATHF             = $fc62 ;
MATHE             = $fc63 ;

MATHM             = $fc6c ;
MATHL             = $fc6d ;
MATHK             = $fc6e ;
MATHJ             = $fc6f ;


; More SUZY control registers

SPRCTL0           = $fc80 ;
; Sprite control 0 bit definitions
.enum	@SPRCTL0
BITS_MASK         = %11000000	; Mask for settings bits per pixel
; Sprite bits-per-pixel definitions
ONE_PER_PIXEL     = %00000000
TWO_PER_PIXEL     = %01000000
THREE_PER_PIXEL   = %10000000
FOUR_PER_PIXEL    = %11000000
; More sprite control 0 bit definitions
HFLIP             = %00100000
VFLIP             = %00010000
; Sprite types - redefined to reflect the reality caused by the shadow error
;NORMAL_SPRITE    = %00000111
SHADOW_SPRITE     = %00000111

XOR_SPRITE        = %00000110
XOR_SHADOW_SPRITE = %00000110

NONCOLL_SPRITE    = %00000101

;SHADOW_SPRITE    = %00000100
NORMAL_SPRITE     = %00000100

;BSHADOW_SPRITE   = %00000011
BOUNDARY_SPRITE   = %00000011

;BOUNDARY_SPRITE  = %00000010
BSHADOW_SPRITE    = %00000010

BACKNONCOLL_SPRITE= %00000001

BACKGROUND_SPRITE = %00000000
BACK_SHADOW_SPRITE= %00000000
.ende

SPRCTL1           = $fc81 ;
; Sprite control 1 bit definitions
.enum	@SPRCTL1
LITERAL           = %10000000
ALGO_3            = %01000000	; broken, do not set this bit!
RELOAD_MASK       = %00110000
; Sprite reload mask definitions
RELOAD_NONE       = %00000000	; Reload nothing
RELOAD_HV         = %00010000	; Reload hsize, vsize
RELOAD_HVS        = %00100000	; Reload hsize, vsize, stretch
RELOAD_HVST       = %00110000	; Reload hsize, vsize, stretch, tilt
; More sprite control 1 bit definitions
REUSE_PALETTE     = %00001000
SKIP_SPRITE       = %00000100
DRAW_UP           = %00000010
DRAW_LEFT         = %00000001
.ende

SPRCOLL           = $fc82 ;
; SPRCOLL bit definitions
.enum @SPRCOLL
NO_COLLIDE        = %00100000
.ende

SPRINIT           = $fc83 ; Set to $F3 after at least 100ms after power up and before any sprites are drawn.

SUZYHREV          = $fc88 ;
SUZYSREV          = $fc89 ;

SUZYBUSEN         = $fc90 ; Suzy Bus Enable (W)
.enum @SUZYBUSEN
ENABLE            = %00000001 ; Suzy Bus Enable, 0 = disabled
.ende

SPRGO             = $fc91 ;
; These are the SPRGO flag definitions
.enum @SPRGO
EVER_ON           = %00000100 ;enable everon detector: 1 = enabled.
SPRITE_GO         = %00000001 ;Sprite process enabled: 0 = disabled. Write a 1 to start the process, at completion of process this bit will be reset to 0. Either setting or clearing this bit will clear the Stop At End Of Current Sprite bit.
.ende

SPRSYS            = $fc92 ;System Control Bits (R/W)
.enum @SPRSYS
; These are the SPRSYS flag definitions when writing
SIGNMATH          = %10000000 ; Signmath: 0 = unsigned math, 1 = signed math.
ACCUMULATE        = %01000000 ; OK to accumvlate: 0 = do not accumulate, 1 = yes, accumulate.
NO_COLLIDE        = %00100000	; dont collide: 1 = dont collide with any sprites.
VSTRETCH          = %00010000 ; Vstretch: 1 = stretch the v, 0 = Don't play with it, it will grow by itself.
LEFTHAND          = %00001000 ; Lefthand: 0 = normal handed
UNSAFEACCESSRST   = %00000100 ; Clear the 'unsafeAccess' bit: 1 = clear it, 0 = no change.
SPRITESTOP        = %00000010 ; Stop at end of current sprite: 1 = request to stop. Continue sprite processing by setting the Sprite Process Start Bit. Either setting or clearing the SPSB will clear this stop request.
; These are the SPRSYS flag definitions when reading
MATHWORKING       = %10000000 ; Math in process
MATHWARNING       = %01000000 ; Mathbit: If mult, 1 = accumulator overflow. If div, 1 = div by zero attempted.
MATHCARRY         = %00100000 ; Last carry bit.
VSTRETCHING       = %00010000 ; Vstretch
LEFTHANDED        = %00001000 ; Lefthand
UNSAFEACCESS      = %00000100 ; UnsafeAccess: 1 = Unsafe Access was performed.
SPRITETOSTOP      = %00000010 ; Stop at end of current sprite: 1 = request to stop.
SPRITEWORKING     = %00000001 ; Sprite process was started and has neither completed nor been stopped.
.ende

JOYSTICK          = $fcb0 ;
.enum @JOYSTICK
DOWN              = %10000000   ;up
UP                = %01000000   ;down
RIGHT             = %00100000   ;left
LEFT              = %00010000   ;right
OPTION1           = %00001000
OPTION2           = %00000100
INNER             = %00000010
OUTER             = %00000001
A                 = OUTER
B                 = INNER
RESTART           = OPTION1
FLIP              = OPTION2
.ende

SWITCHES          = $fcb1 ;
.enum @SWITCHES
CART1_IO_INACTIVE = %00000100
CART0_IO_INACTIVE = %00000010
PAUSE_SWITCH      = %00000001
.ende

RCART0            = $fcb2 ;
RCART1            = $fcb3 ;


; LEDS output register only exists on early wire-wrap prototypes
LEDS              = $fcc0 ;

; The parallel IO port only exists on early wire-wrap prototypes
IOStatus          = $fcc2 ;
IOData            = $fcc3 ;

HOWIE             = $fcc4 ;


; MIKEY chip functions are mapped into the $FD00 page

MIKEY_BASE        = $fd00 ;

; The Mikey Timers
HCOUNT_BACKUP     = $fd00 ;
HCOUNT_CONTROLA   = $fd01 ;
HCOUNT_COUNT      = $fd02 ;
HCOUNT_CONTROLB   = $fd03 ;
TIMER0_BACKUP     = $fd00 ;
TIMER0_CONTROLA   = $fd01 ;
TIMER0_COUNT      = $fd02 ;
TIMER0_CONTROLB   = $fd03 ;
TIMER1_BACKUP     = $fd04 ;
TIMER1_CONTROLA   = $fd05 ;
TIMER1_COUNT      = $fd06 ;
TIMER1_CONTROLB   = $fd07 ;
VCOUNT_BACKUP     = $fd08 ;
VCOUNT_CONTROLA   = $fd09 ;
VCOUNT_COUNT      = $fd0a ;
VCOUNT_CONTROLB   = $fd0b ;
TIMER2_BACKUP     = $fd08 ;
TIMER2_CONTROLA   = $fd09 ;
TIMER2_COUNT      = $fd0a ;
TIMER2_CONTROLB   = $fd0b ;
TIMER3_BACKUP     = $fd0c ;
TIMER3_CONTROLA   = $fd0d ;
TIMER3_COUNT      = $fd0e ;
TIMER3_CONTROLB   = $fd0f ;
SERIALRATE_BACKUP = $fd10 ;
SERIALRATE_CONTROLA=$fd11 ;
SERIALRATE_COUNT  = $fd12 ;
SERIALRATE_CONTROLB=$fd13 ;
TIMER4_BACKUP     = $fd10 ;
TIMER4_CONTROLA   = $fd11 ;
TIMER4_COUNT      = $fd12 ;
TIMER4_CONTROLB   = $fd13 ;
TIMER5_BACKUP     = $fd14 ;
TIMER5_CONTROLA   = $fd15 ;
TIMER5_COUNT      = $fd16 ;
TIMER5_CONTROLB   = $fd17 ;
TIMER6_BACKUP     = $fd18 ;
TIMER6_CONTROLA   = $fd19 ;
TIMER6_COUNT      = $fd1a ;
TIMER6_CONTROLB   = $fd1b ;
TIMER7_BACKUP     = $fd1c ;
TIMER7_CONTROLA   = $fd1d ;
TIMER7_COUNT      = $fd1e ;
TIMER7_CONTROLB   = $fd1f ;

; TIM_CONTROLA control bits
.enum @TIM_CONTROLA
ENABLE_INT        = %10000000
RESET_DONE        = %01000000
ENABLE_RELOAD     = %00010000
ENABLE_COUNT      = %00001000
AUD_CLOCK_MASK    = %00000111
; Clock settings
AUD_LINKING       = %00000111
AUD_64            = %00000110
AUD_32            = %00000101
AUD_16            = %00000100
AUD_8             = %00000011
AUD_4             = %00000010
AUD_2             = %00000001
AUD_1             = %00000000
.ende

; TIM_CONTROLB control bits
.enum @TIM_CONTROLB
TIMER_DONE        = %00001000
LAST_CLOCK        = %00000100
BORROW_IN         = %00000010
BORROW_OUT        = %00000001
.ende


AUDIO0_VOLCNTRL   = $fd20 ;
AUDIO0_FEEDBACK   = $fd21 ;
AUDIO0_OUTPUT     = $fd22 ;
AUDIO0_SHIFT      = $fd23 ;
AUDIO0_BACKUP     = $fd24 ;
AUDIO0_CONTROL    = $fd25 ;
AUDIO0_COUNTER    = $fd26 ;
AUDIO0_OTHER      = $fd27 ;
AUDIO1_VOLCNTRL   = $fd28 ;
AUDIO1_FEEDBACK   = $fd29 ;
AUDIO1_OUTPUT     = $fd2a ;
AUDIO1_SHIFT      = $fd2b ;
AUDIO1_BACKUP     = $fd2c ;
AUDIO1_CONTROL    = $fd2d ;
AUDIO1_COUNTER    = $fd2e ;
AUDIO1_OTHER      = $fd2f ;
AUDIO2_VOLCNTRL   = $fd30 ;
AUDIO2_FEEDBACK   = $fd31 ;
AUDIO2_OUTPUT     = $fd32 ;
AUDIO2_SHIFT      = $fd33 ;
AUDIO2_BACKUP     = $fd34 ;
AUDIO2_CONTROL    = $fd35 ;
AUDIO2_COUNTER    = $fd36 ;
AUDIO2_OTHER      = $fd37 ;
AUDIO3_VOLCNTRL   = $fd38 ;
AUDIO3_FEEDBACK   = $fd39 ;
AUDIO3_OUTPUT     = $fd3a ;
AUDIO3_SHIFT      = $fd3b ;
AUDIO3_BACKUP     = $fd3c ;
AUDIO3_CONTROL    = $fd3d ;
AUDIO3_COUNTER    = $fd3e ;
AUDIO3_OTHER      = $fd3f ;

; The AUD_CONTROL bits are almost identical to the TIM_CONTROLA bits.
; Here's the AUD_CONTROL control bits that are different from the TIM_CONTROLA
; control bits.
.enum @AUD_CONTROL
FEEDBACK_7        = %10000000
RESET_DONE        = %01000000
ENABLE_INTEGRATE  = %00100000
ENABLE_RELOAD     = %00010000
ENABLE_COUNT      = %00001000
AUD_CLOCK_MASK    = %00000111
; Clock settings
AUD_LINKING       = %00000111
AUD_64            = %00000110
AUD_32            = %00000101
AUD_16            = %00000100
AUD_8             = %00000011
AUD_4             = %00000010
AUD_2             = %00000001
AUD_1             = %00000000
.ende

; Stereo control registers follow
; Stereo capability does not exist in all Lynxes
; Left and right may be reversed, and if so will be corrected in a later
; release

ATTENREG0         = $fd40 ; Stereo attenuation registers
ATTENREG1         = $fd41 ;
ATTENREG2         = $fd42 ;
ATTENREG3         = $fd43 ;
.enum @ATTENMASK
LEFT              = %11110000
RIGHT             = %00001111
.ende

MPAN              = $fd44 ; Stereo attenuation select register

MSTEREO           = $fd50 ; Stereo channel disable register

; bit definitions for MPAN and MSTEREO registers
.enum @MPAN
LEFT3             = %10000000
LEFT2             = %01000000
LEFT1             = %00100000
LEFT0             = %00010000
RIGHT3            = %00001000
RIGHT2            = %00000100
RIGHT1            = %00000010
RIGHT0            = %00000001
.ende

.enum @MSTEREO
LEFT3             = %10000000
LEFT2             = %01000000
LEFT1             = %00100000
LEFT0             = %00010000
RIGHT3            = %00001000
RIGHT2            = %00000100
RIGHT1            = %00000010
RIGHT0            = %00000001
.ende

INTRST            = $fd80 ; Interrupt Reset
INTSET            = $fd81 ; Interrupt Set 

; Interrupt Reset and Set bit definitions
.enum @INT
TIMER7            = %10000000
TIMER6            = %01000000
TIMER5            = %00100000
TIMER4            = %00010000
TIMER3            = %00001000
TIMER2            = %00000100
TIMER1            = %00000010
TIMER0            = %00000001
SERIAL            = TIMER4
VERTICAL          = TIMER2
HORIZONTAL        = TIMER0
.ende

AUDIN             = $fd86	; Audio in -or- cartridge r/w line
SYSCTL1           = $fd87
; SYSCTL1 bit definitions
.enum @SYSCTL1
POWERON           = %00000010
CART_ADDR_STROBE  = %00000001
.ende

MIKEYHREV         = $fd88 ; Mikey hardware rev
MIKEYSREV         = $fd89 ; Mikey software rev
IODIR             = $fd8a ; Mikey Parallel I/O Data Direction (W). 8 bits I/O direction corresponding to the 8 bits at FD8B: 0=input, 1= output
IODAT             = $fd8b ; Mikey Parallel Data (sort of a R/W)
; Here's the IODIR and IODAT bit definitions
.enum @IO
AUDIN             = %00010000 ; audin input
READ_ENABLE       = %00010000 ; same bit for AUDIN
RESTLESS          = %00001000 ; rest output
NOEXP             = %00000100 ; noexp input If set, redeye is not connected
CART_ADDR_DATA    = %00000010 ; Cart Address Data output
CART_POWER_OFF    = %00000010 ; 0 turns cart power on
EXTERNAL_POWER    = %00000001 ; External Power input (note, ROM sets it to output, you must set it to input)
.ende

SERCTL            = $fd8c ; Serial control
.enum @SERCTL
; Here's the SERCTL bit definitions when writing
TXINTEN           = %10000000
RXINTEN           = %01000000
;unused           = %00100000	; Leave unused bit 0 for future compatability
PAREN             = %00010000
RESETERR          = %00001000
TXOPEN            = %00000100
TXBRK             = %00000010
PAREVEN           = %00000001
; Here's the SERCTL bit definitions when reading
TXRDY             = %10000000
RXRDY             = %01000000
TXEMPTY           = %00100000
PARERR            = %00010000
OVERRUN           = %00001000
FRAMERR           = %00000100
RXBRK             = %00000010
PARBIT            = %00000001
.ende

SERDAT            = $fd8d ; Serial data


SDONEACK          = $fd90 ; Suzy done ack
CPUSLEEP          = $fd91 ; CPU Bus Request Disable(W) A write of '0' to this address will reset the CPU bus request flip flop.
DISPCTL           = $fd92 ; Display control
; Here are the DISPCTL bit definitions
.enum @DISPCTL
DISP_COLOR        = %00001000 ; color: 1 = color, 0 = monochrome. must be set to 1 (set by kernel)
DISP_FOURBIT      = %00000100 ; fourbit: 1 = 4 bit mode, 0 = 2 bit mode. must be set to 1 (set by kernel)
DISP_FLIP         = %00000010 ; 1 = flip, 0 normal
DMA_ENABLE        = %00000001 ; 1 = enable video DMA, 0 = disable. must be set to 1 (set by kernel)
.ende

PBKUP             = $fd93 ; Display's magic 'P' count INT((((line time - .5us) / 15) * 4) -1). Kernel sets $29 = 60 Hz
DISPADR           = $fd94 ; (word) Start of display

MTEST0            = $fd9c ; System test vectors, see spec for bits
MTEST1            = $fd9d ;
MTEST2            = $fd9e ;

; The Color registers
GREEN0            = $fda0
GREEN1            = $fda1
GREEN2            = $fda2
GREEN3            = $fda3
GREEN4            = $fda4
GREEN5            = $fda5
GREEN6            = $fda6
GREEN7            = $fda7
GREEN8            = $fda8
GREEN9            = $fda9
GREENA            = $fdaa
GREENB            = $fdab
GREENC            = $fdac
GREEND            = $fdad
GREENE            = $fdae
GREENF            = $fdaf

BLUERED0          = $fdb0
BLUERED1          = $fdb1
BLUERED2          = $fdb2
BLUERED3          = $fdb3
BLUERED4          = $fdb4
BLUERED5          = $fdb5
BLUERED6          = $fdb6
BLUERED7          = $fdb7
BLUERED8          = $fdb8
BLUERED9          = $fdb9
BLUEREDA          = $fdba
BLUEREDB          = $fdbb
BLUEREDC          = $fdbc
BLUEREDD          = $fdbd
BLUEREDE          = $fdbe
BLUEREDF          = $fdbf

.local KERNEL
SELECT_SECTOR     = $fe00
.endl

MAPCTL            = $fff9 ;
; These are the MAPCTL flag definitions
.enum @MAPCTL
TURBO_DISABLE     = %10000000
VECTOR_SPACE      = %00001000	; 1 maps RAM into specified space
ROM_SPACE         = %00000100
MIKEY_SPACE       = %00000010
SUZY_SPACE        = %00000001
.ende

; 65C02 hardware interrupt and reset vectors
CPU_NMI           = $fffa ; (W)
CPU_RESET         = $fffc ; (W)
CPU_IRQ           = $fffe ; (W)

.struct SCB
SPRCTL0 .byte
SPRCTL1 .byte
SPRCOL  .byte
NEXT    .word
IMAGE   .word
XPOS    .word
YPOS    .word
PAL     :8 .byte
.ends
.endl
