    processor 6502
    include "vcs.h"
    include "macro.h"

    seg code
    org $F000

Start:
    CLEAN_START             ; Macro to safely clear memory and TIA

;;;;;;;;;;;;;;;;;
;; Start a new frame by turning on VBLANK and VSYNC
;;;;;;;;;;;;;;;;;
NextFrame:
    lda #2                  ; Load A with binary value %00000010
    sta VBLANK              ; Turn on VBLANK
    sta VSYNC               ; Turn on VSYNC

;;;;;;;;;;;;;;;;;
;; Generate the three lines of VSYNC
;;;;;;;;;;;;;;;;;
    sta WSYNC               ; First scanline
    sta WSYNC               ; Second scanline
    sta WSYNC               ; Third scanline

    lda #0
    sta VSYNC

;;;;;;;;;;;;;;;;;
;; Let the TIA output the recommended 37 lines of VBLANK
;;;;;;;;;;;;;;;;;
    ldx #37                 ; X = 37 to count 37 scanlines

LoopVBlank:
    sta WSYNC               ; Hit WSYNC and wait for next scanline
    dex                     ; X--
    bne LoopVBlank          ; Loop while X != 0

    lda #0
    sta VBLANK              ; Turn off VBLANK

;;;;;;;;;;;;;;;;;
;; Draw 192 visible scanlines (kernel)
;;;;;;;;;;;;;;;;;
    ldx #192                ; Counter for 192 scanlines
LoopVisible:
    stx COLUBK              ; Set the background colour
    sta WSYNC               ; Wait for the next scanline
    dex                     ; X--
    bne LoopVisible         ; Loop while X != 0

;;;;;;;;;;;;;;;;;
;; Output 30 more VBLANK lines (overscan) to complete our frame
;;;;;;;;;;;;;;;;;
    lda #2
    sta VBLANK              ; Hit and turn on VBLANK

    ldx #30
LoopOverscan:
    sta WSYNC               ; Wait for the next scanline
    dex                     ; X--
    bne LoopOverscan        ; Loop while X != 0

    jmp NextFrame

;;;;;;;;;;;;;;;;;
;; Complete ROM size to 4KB
;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Start
    .word Start