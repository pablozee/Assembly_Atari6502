    processor 6502

    seg code
    org $F000       ; Define the code origin at F000]

Start:
    sei             ; Disable interrupts
    cld             ; Disable the BCD decimal math mode
    ldx #$FF        ; Loads the X register with #$FF
    txs             ; Transfers the X register to the Stack Pointer

;;;;;;;;;;;;
;; Clear the Page Zero section ($00 to $FF)
;; In other words the entire RAM and entire TIA registers
;;;;;;;;;;;;

    lda #0          ; A = 0
    ldx #$FF        ; X = #$FF
    sta $FF         ; Make sure $FF is zeroed before the loop starts

MemLoop:
    dex             ; X--
    sta $0,X        ; Store the value of A inside the memory address $0 + X
    bne MemLoop     ; Loop until X is equal to zero (z-flag is set)

;;;;;;;;;;;;
;; Fill the ROM size to exactly 4KB
;;;;;;;;;;;;

    org $FFFC
    .word Start     ; Reset vector at $FFFC (where the program starts)
    .word Start     ; Interrupt vector at $FFFE (unused by VCS)