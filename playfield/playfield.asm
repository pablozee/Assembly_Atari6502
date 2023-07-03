    processor 6502

    include "vcs.h"
    include "macro.h"

;;;;;;;;;;;;;;;;;
;;; Start our ROM code
;;;;;;;;;;;;;;;;;
    seg
    org $F000

Reset:
    CLEAN_START

    ldx #$80                ; Blue background colour
    stx COLUBK

    lda #$1C                ; Yellow playfield colour
    sta COLUPF

;;;;;;;;;;;;;;;;;
;;; Start a new frame by configuring VBLANK and VSYNC
;;;;;;;;;;;;;;;;;
StartFrame:
    lda #02
    sta VBLANK              ; Turn on VBLANK
    sta VSYNC               ; Turn on VSYNC

 ;;;;;;;;;;;;;;;;;
;;; Generate the 3 lines of VSYNC
;;;;;;;;;;;;;;;;;   
    REPEAT 3
        sta WSYNC
    REPEND
    lda #0
    sta VSYNC               ; Turn off VSYNC

;;;;;;;;;;;;;;;;;
;;; Let the TIA output the recommended 37 lines of VBLANK
;;;;;;;;;;;;;;;;;
    REPEAT 37
        sta WSYNC
    REPEND
    lda #0
    sta VBLANK              ; Turn off VBLANK

;;;;;;;;;;;;;;;;;
;;; Set the CTRLPF to enable playfield reflection
;;;;;;;;;;;;;;;;;
    ldx #%00000001          ; D0 means reflect playfield
    stx CTRLPF

;;;;;;;;;;;;;;;;;
;;; Draw the 192 visible scanlines
;;;;;;;;;;;;;;;;;
    
    ; Skip 7 scanlines with no PF set
    ldx #0
    stx PF0
    stx PF1
    stx PF2
    REPEAT 7
        sta WSYNC
    REPEND

    ; Set the PF0 to 1110 (Least significant byte first) and PF1 and PF2 to 1111 1111
    ldx #%11100000
    stx PF0
    ldx #%11111111
    stx PF1
    stx PF2
    REPEAT 7
        sta WSYNC
    REPEND

    ; Set the next 164 scanlines only with the third bit of PF0 enabled
    ldx #%00100000
    stx PF0
    ldx #0
    stx PF1
    ldx #%10000000
    stx PF2
    REPEAT 164
        sta WSYNC
    REPEND

    ; Set the PF0 to 1110 (Least significant byte first) and PF1 and PF2 to 1111 1111
    ldx #%11100000
    stx PF0
    ldx #%11111111
    stx PF1
    stx PF2
    REPEAT 7
        sta WSYNC
    REPEND

    ; Skip 7 scanlines with no PF set
    ldx #0
    stx PF0
    stx PF1
    stx PF2
    REPEAT 7
        sta WSYNC
    REPEND

;;;;;;;;;;;;;;;;;
;;; Output 30 more VBLANK scanlines to complete the frame
;;;;;;;;;;;;;;;;;
    lda #2
    sta VBLANK
    REPEAT 30
        sta WSYNC
    REPEND
    lda #0
    sta VBLANK

;;;;;;;;;;;;;;;;;
;;; Loop to next frame
;;;;;;;;;;;;;;;;;
    jmp StartFrame

;;;;;;;;;;;;;;;;;
;;; Complete the ROM size to 4KB
;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Reset
    .word Reset