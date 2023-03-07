// fills the screen with PETSCII characters

//  SUBROUTINES
//-------------
.var    _print_char     = $EA13
.var    _set_cursor_pos = $E50A

//  MEMORY
//-------------
.var    currentRasterLine   = $D012

//  ZEROPAGE
//------------------
.var    character   = $00FE


BasicUpstart2(__start)

    .cpu    _6502
    *       = $1000


__start:

    lda     #00  
    pha         // push the x coordinate to stack
    pha         // push the y coordinate to stack

    lda     #'@' // the first character is gonna be 'a'

!:
    sta     character // saving the character to the unused zeropage address
    inc     character // incrementing the character code
    
!:  // the following routine synchronizes the code with raster interrupts
    lda     currentRasterLine
    cmp     #$80
    bne     !-

    pla           // pop the y coordinate
    tax 
    pla           // pop the x coordinate 
    tay 
    cpy     #40   // check if we reached the end of the line
    bne     !+    // if not, print a character...

    inx           // ...otherwise, proceed to the next line
    cpx     #25   // check if it's the last line
    beq     !++   // if so, finish the execution
    ldy     #00   // if not, set the x coordinate to 0

!:
    jsr     _set_cursor_pos
    iny   // increment the x coordinate
    tya 
    pha   // push the x coordinate to stack
    txa 
    pha   // push the y coordinate to stack

    lda     character   // load the current character
    ldx     #14         // set the character color (light blue)
    jsr     _print_char // nuff said

    lda     character // restore the character

    jmp     !---    // repeat until the coordinate is (40,25)

!:
    rts 
