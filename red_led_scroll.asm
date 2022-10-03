/*
  2020-10-12
  Trying out a quick character pixel scroll (not smooth but character by character position).
  Only animating the color for speed (same character in all character positions).
  Trying to imitate a led scroller board with 8x38 led lights.
  Only animating lights on/off (red/dark grey).
*/

.const COLOR_BLACK         = $00
.const COLOR_WHITE         = $01
.const COLOR_RED           = $02
.const COLOR_CYAN          = $03
.const COLOR_PURPLE        = $04
.const COLOR_GREEN         = $05
.const COLOR_BLUE          = $06
.const COLOR_YELLOW        = $07
.const COLOR_ORANGE        = $08
.const COLOR_BROWN         = $09
.const COLOR_PINK          = $0A
.const COLOR_DARK_GREY     = $0B
.const COLOR_GREY          = $0C
.const COLOR_LIGHT_GREEN   = $0D
.const COLOR_LIGHT_BLUE    = $0E
.const COLOR_LIGHT_GREY    = $0F

.const CHARACTER_SPACE     = $20
.const CHARACTER_PERIOD    = $2E
.const CHARACTER_HASH      = $23
.const CHARACTER_PERCENT   = $25

.const CHARACTER_GIANA_FONT_ROUND_1 = $5B
.const CHARACTER_GIANA_FONT_ROUND_2 = $5C
.const CHARACTER_GIANA_FONT_SQUARE_1 = $5D
.const CHARACTER_GIANA_FONT_SQUARE_2 = $5E

.const SYSTEM_IRQ_HANDLER = $ea81


// Assuming Text screen mode
// Assuming using VIC bank 0 (which is default upon C64 start/reset with memory address range $0000-$3FFF thus size $4000=16k bytes).
// To use character font bank 7, (the last possible font bank) within the current VIC bank, set memory location $D018 bit 1 through 3 to value %111 = #7.
// Font bitmap data start at address: <VIC bank start address> + (<font bank size> * <font bank>) = $0000 + ($800 * #7) = $3800

.const   constant_font_bank = $0e
.const   address_font = $3800
.const   address_font_pointer = $D018
.const   address_font_character_lo_byte = $0A
.const   address_font_character_hi_byte = $0B

.const   address_sid_music_init = $1000
.const   address_sid_music_play = address_sid_music_init + 3

.const   constant_pixel_character_active = COLOR_PINK
.const   constant_pixel_character_inactive = COLOR_BROWN

.const   constant_columns_per_line = 40
.const   constant_top_scroll_line_index  = 23 - 8     // 8 lines of "pixels" for characters in text message with it's top on this line (zero index ed from top) [0-23]
.const   constant_static_text_line_index  = 0         // Static text message with it's top on this line (zero index ed from top) [0-23]

.const   constant_horizontal_scroll_delay = 2        // Scroll delay value constant [0-128]  (unit: rendered frames, 1/50th of a second)
//.const   constant_text_color_scroll_delay = 0        // Scroll delay value constant [0-255] (unit: rendered frames, 1/50th of a second)

.const   address_border_color = $D020
.const   address_screen_color = $D021

.const   address_first_screen_char_color = $D800
.const   address_first_screen_char_character = $0400

.const   address_horizontal_scroll_delay_counter = $04           // Scroll delay counter. Stored at zero page

.const   address_scroll_message_character_offset = $05           // Character offset in scroll message. Stored at zero page
.const   address_scroll_message_character_pixel_offset = $08     // Scroll message character pixel column offset. Stored at zero page
.const   address_scroll_message_character_font_data = $09        // Scroll message character pixel data start (first/upper line). Stored at zero page

.const   address_text_color_scroll_delay_counter = $06           // Text color scroll delay counter. Stored at zero page

.const   address_text_color_scroll_line_0 = address_first_screen_char_color + constant_columns_per_line * constant_top_scroll_line_index
.const   address_text_color_scroll_line_1 = address_text_color_scroll_line_0 + constant_columns_per_line
.const   address_text_color_scroll_line_2 = address_text_color_scroll_line_1 + constant_columns_per_line
.const   address_text_color_scroll_line_3 = address_text_color_scroll_line_2 + constant_columns_per_line
.const   address_text_color_scroll_line_4 = address_text_color_scroll_line_3 + constant_columns_per_line
.const   address_text_color_scroll_line_5 = address_text_color_scroll_line_4 + constant_columns_per_line
.const   address_text_color_scroll_line_6 = address_text_color_scroll_line_5 + constant_columns_per_line
.const   address_text_color_scroll_line_7 = address_text_color_scroll_line_6 + constant_columns_per_line

.const   address_text_color_scroll_line_0_last_pos = address_text_color_scroll_line_0 + constant_columns_per_line - 1
.const   address_text_color_scroll_line_1_last_pos = address_text_color_scroll_line_1 + constant_columns_per_line - 1
.const   address_text_color_scroll_line_2_last_pos = address_text_color_scroll_line_2 + constant_columns_per_line - 1
.const   address_text_color_scroll_line_3_last_pos = address_text_color_scroll_line_3 + constant_columns_per_line - 1
.const   address_text_color_scroll_line_4_last_pos = address_text_color_scroll_line_4 + constant_columns_per_line - 1
.const   address_text_color_scroll_line_5_last_pos = address_text_color_scroll_line_5 + constant_columns_per_line - 1
.const   address_text_color_scroll_line_6_last_pos = address_text_color_scroll_line_6 + constant_columns_per_line - 1
.const   address_text_color_scroll_line_7_last_pos = address_text_color_scroll_line_7 + constant_columns_per_line - 1

.const   address_static_message_text_scr_pos = address_first_screen_char_character + constant_columns_per_line * constant_static_text_line_index

.const   adress_scroll_line_0 = address_first_screen_char_character + constant_columns_per_line * (constant_top_scroll_line_index  + 0)
.const   adress_scroll_line_1 = address_first_screen_char_character + constant_columns_per_line * (constant_top_scroll_line_index  + 1)
.const   adress_scroll_line_2 = address_first_screen_char_character + constant_columns_per_line * (constant_top_scroll_line_index  + 2)
.const   adress_scroll_line_3 = address_first_screen_char_character + constant_columns_per_line * (constant_top_scroll_line_index  + 3)
.const   adress_scroll_line_4 = address_first_screen_char_character + constant_columns_per_line * (constant_top_scroll_line_index  + 4)
.const   adress_scroll_line_5 = address_first_screen_char_character + constant_columns_per_line * (constant_top_scroll_line_index  + 5)
.const   adress_scroll_line_6 = address_first_screen_char_character + constant_columns_per_line * (constant_top_scroll_line_index  + 6)
.const   adress_scroll_line_7 = address_first_screen_char_character + constant_columns_per_line * (constant_top_scroll_line_index  + 7)

.const   adress_scroll_line_0_last_pos = adress_scroll_line_0 + (constant_columns_per_line - 1)
.const   adress_scroll_line_1_last_pos = adress_scroll_line_1 + (constant_columns_per_line - 1)
.const   adress_scroll_line_2_last_pos = adress_scroll_line_2 + (constant_columns_per_line - 1)
.const   adress_scroll_line_3_last_pos = adress_scroll_line_3 + (constant_columns_per_line - 1)
.const   adress_scroll_line_4_last_pos = adress_scroll_line_4 + (constant_columns_per_line - 1)
.const   adress_scroll_line_5_last_pos = adress_scroll_line_5 + (constant_columns_per_line - 1)
.const   adress_scroll_line_6_last_pos = adress_scroll_line_6 + (constant_columns_per_line - 1)
.const   adress_scroll_line_7_last_pos = adress_scroll_line_7 + (constant_columns_per_line - 1)

*=$0801 "basic program"
        .byte $0C, $08
        .byte $0A, $00, $9E, $20, $32, $30, $36, $34, $00        // BASIC: 10 SYS 2064      // #2064 = $0810
        .byte $00, $00                                           // end of BASIC program

*=$0810 "main program"

Init:

        ldy #0 - 1
        sty address_scroll_message_character_offset // Reset scroll message to first character position

        ldy #8
        sty address_scroll_message_character_pixel_offset // Reset scroll message pixel offset

        ldy #constant_horizontal_scroll_delay
        sty address_horizontal_scroll_delay_counter // Reset scroll delay counter to delay max value

        // Set character font pointer to point to demo font
        lda address_font_pointer
        ora #constant_font_bank
        sta address_font_pointer

        jsr address_sid_music_init

        // Set 38 column mode
        //lda address_horizontal_scroll_register
        //and #%11110111
        //sta address_horizontal_scroll_register

        jsr clear_screen

        lda #COLOR_BLACK
        sta address_border_color	      // Set screen border color
        sta address_screen_color	      // Set screen color

        jsr print_static_message

        jsr print_leds
        jsr color_off_leds

        sei
        lda #%01111111
        sta $DC0D	      // "Switch off" interrupts signals from CIA-1

        //lda $D01A      // enable VIC-II Raster Beam IRQ
        //ora #$01
        //sta $D01A

        lda #%00000001
        sta $D01A	      // Enable raster interrupt signals from VIC

        lda $D011
        and #%01111111
        sta $D011	      // Clear most significant bit in VIC's raster register (for raster interrupt on upper part of screen, above line #256)

        lda #$60        // Interrupt on this raster line
        sta $D012       // Set the raster line number where interrupt should occur

        lda #<irq1
        sta $0314
        lda #>irq1
        sta $0315	      // Set the interrupt vector to point to interrupt service routine below

        cli

        //rts              // Initialization done// return to BASIC
no_exit:

        jmp no_exit

irq1:
        //jsr rasterline_start
        jsr scroll_text
        jsr address_sid_music_play
        //jsr rasterline_end

        // Set next raster interrupt (back to raster interrupt irq1)
        lda #<irq1
        sta $0314
        lda #>irq1
        sta $0315

        lda #60         // Interrupt on this raster line
        sta $D012       // Set the raster line number where interrupt should occur

        asl $D019	      // "Acknowledge" (asl do both read and write to memory location) the interrupt by clearing the VIC's interrupt flag.
        //jmp $EA31	      // Jump into KERNAL's standard interrupt service routine to handle keyboard scan, cursor display etc.
        jmp SYSTEM_IRQ_HANDLER

print_leds:
        ldx #39
        lda #CHARACTER_GIANA_FONT_ROUND_1
!:
        sta adress_scroll_line_0,x
        sta adress_scroll_line_1,x
        sta adress_scroll_line_2,x
        sta adress_scroll_line_3,x
        sta adress_scroll_line_4,x
        sta adress_scroll_line_5,x
        sta adress_scroll_line_6,x
        sta adress_scroll_line_7,x
        dex
        bpl !-
        rts

color_off_leds:
        ldx #39
        lda #COLOR_BROWN
!:
        sta address_text_color_scroll_line_0,x
        sta address_text_color_scroll_line_1,x
        sta address_text_color_scroll_line_2,x
        sta address_text_color_scroll_line_3,x
        sta address_text_color_scroll_line_4,x
        sta address_text_color_scroll_line_5,x
        sta address_text_color_scroll_line_6,x
        sta address_text_color_scroll_line_7,x
        dex
        bpl !-
        rts

// ---------------------------------------------
// Paint a raster band
// ---------------------------------------------
rasterline_start:
        // rasterline start paint
        lda #COLOR_BROWN
        sta address_border_color	      // Set screen border color to yellow
        //sta address_screen_color	      // Set screen color to yellow

        rts

rasterline_end:
        // rasterline stop paint
        lda #COLOR_BLACK
        sta address_border_color	      // Set screen border color to black
        //sta address_screen_color	      // Set screen color to black

        rts


// ---------------------------------------------
// Clear screen subroutine
// ---------------------------------------------
clear_screen:
        lda #CHARACTER_SPACE // "Space" character code
        //lda #CHARACTER_HASH // Debug character code
        ldx #0
clear_screen_loop:
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $0700,x
        dex
        bne clear_screen_loop

        rts


// ---------------------------------------------
// Print static text message
// ---------------------------------------------
print_static_message:
        ldx #$00

print_static_message_loop:
        lda static_message_text, x
        cmp #$00  // Have we encountered text message null termination
        beq print_static_message_loop_end

        //ora #$80 // Invert character

        sta $0400 + constant_columns_per_line * constant_static_text_line_index , x // print static message text data to screen character location

        lda #COLOR_RED
        sta $D800 + constant_columns_per_line * constant_static_text_line_index , x // print static message text data to screen character location

        inx
        cpx #$00
        beq print_static_message_loop_end
        jmp print_static_message_loop

print_static_message_loop_end:
        rts


// ---------------------------------------------
// Scroll screen text content a "pixel" (character position)
// ---------------------------------------------
scroll_text:

scrolldelaycheck:
        ldx address_horizontal_scroll_delay_counter
        dex
        bpl nopixelscroll

        ldx #constant_horizontal_scroll_delay
        stx address_horizontal_scroll_delay_counter
        jmp pixelscroll

nopixelscroll:
        stx address_horizontal_scroll_delay_counter
        jmp endscroll

pixelscroll:
        jsr text_color_scroll // copy all screen character color content one character position to the left
        jsr add_next_rightmost_scroll_message_char_pixel // Add a new character at the very far right of the line (that will later scroll in to the left)

endscroll:
        rts


// ---------------------------------------------
// Scroll text color of text message line 1 character position
// ---------------------------------------------
text_color_scroll:
        ldy #$FF
!:
        iny
        shift_scroll_color_left_on_row(0)
        shift_scroll_color_left_on_row(1)
        shift_scroll_color_left_on_row(2)
        shift_scroll_color_left_on_row(3)
        shift_scroll_color_left_on_row(4)
        shift_scroll_color_left_on_row(5)
        shift_scroll_color_left_on_row(6)
        shift_scroll_color_left_on_row(7)
        cpy #constant_columns_per_line - 2
        bne !-

        rts

.macro shift_scroll_color_left_on_row(rowNr) {
        lda address_scroll_line_start(rowNr) + 1, Y
        sta address_scroll_line_start(rowNr), Y
}

.function address_scroll_line_start(scrollLineNr) {
    .return address_first_screen_char_color + constant_columns_per_line * constant_top_scroll_line_index + constant_columns_per_line * scrollLineNr
}

address_current_font_character_pixel_data:
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000
        .byte %00000000


// ---------------------------------------------
// Scroll message line 1 character pixel position
// ---------------------------------------------
add_next_rightmost_scroll_message_char_pixel:
        dec address_scroll_message_character_pixel_offset
        lda address_scroll_message_character_pixel_offset
        bne skip_copy_new_char

        lda #8 // Reset character pixel column counter
        sta address_scroll_message_character_pixel_offset

        inc address_scroll_message_character_offset // Advance to next character in scroll message text
        ldy address_scroll_message_character_offset // Load character scroll text offset into Y

        lda scroll_text_message, Y // Load character value into A
        bne skip_scroll_message_offset_reset

        ldy #$00
        sty address_scroll_message_character_offset
        lda scroll_text_message, Y // Load character value into A

skip_scroll_message_offset_reset:

        // ldx #COLOR_WHITE
        // stx $D800
        // sta $0400 // DEBUG: Print character in white at top left corner for debug purpose

setup_font_character_indirect_address:
        // Initialize the indirect address of the font character by setting the character value in the adress low byte
        sta address_font_character_lo_byte
        lda #$00
        sta address_font_character_hi_byte

        // Multiply character index  with 8 (There are 8 bytes per character. Shift left for 3 bits over two bytes.)
        // Font character offset start byte will be at indirect address (hi and lo byte)
        asl address_font_character_lo_byte
        rol address_font_character_hi_byte
        asl address_font_character_lo_byte
        rol address_font_character_hi_byte
        asl address_font_character_lo_byte
        rol address_font_character_hi_byte
        clc

        // Add font address $3800 to calculated (indirect address) font character offset
        // Special case since we use font address $3800 (%00111000 00000000) with bits only set in high byte
        // (and higher than the 3 least significant bits) we can "add" $3800 to font character offset by just OR in the bits into the high byte
        lda address_font_character_hi_byte
        ora #>address_font
        sta address_font_character_hi_byte

        // The indirect address at $address_font_character_lo_byte do now point to the first pixel data byte of sought the character in the font

        ldy #0
copy_font_char_pixel_data:
        lda (address_font_character_lo_byte), Y            // indirect address hold the first byte (upper line) of character's pixel data
        sta address_current_font_character_pixel_data, Y
        iny
        cpy #8
        bne copy_font_char_pixel_data

skip_copy_new_char:

        // Rotate/Shift in leftmost/highest bit of font character pixel data to rightmost/lowest bit
        // For each of the 8 bytes that make out one charcter in the font
        ldx #0
shift_character_pixel_bytes:
        clc
        asl address_current_font_character_pixel_data, X
        bcc !+ // Check if carry bit got value 0
        lda #%00000001 // If carry bit is set (high) then put bit number 0 to high (as if carry was rotated in from right)
        ora address_current_font_character_pixel_data, X
        sta address_current_font_character_pixel_data, X
!:      inx
        cpx #8 // All 8 pixel bytes of the font character rotated/shifted?
        bne shift_character_pixel_bytes

put_font_character_pixel_column_to_screen:

        put_rightmost_pixel(0)
        put_rightmost_pixel(1)
        put_rightmost_pixel(2)
        put_rightmost_pixel(3)
        put_rightmost_pixel(4)
        put_rightmost_pixel(5)
        put_rightmost_pixel(6)
        put_rightmost_pixel(7)

        rts

.macro put_rightmost_pixel(rowNr) {
        lda address_current_font_character_pixel_data + rowNr
        and #%00000001
        bne pixel_character_active
pixel_character_inactive:
        lda #constant_pixel_character_inactive
        jmp put_character
pixel_character_active:
        lda #constant_pixel_character_active
put_character:
        sta address_scroll_line_start(rowNr) + constant_columns_per_line - 1
}


// ---------------------------------------------
// Static message text (null terminated)
// ---------------------------------------------
static_message_text:
    .encoding "screencode_mixed"
//  .text @"1234567890123456789012345678901234567890"
    .text @"              LED scroller              "
    .byte $00 // Static message text is null terminated


// ---------------------------------------------
// Scroll message text (null terminated)
// ---------------------------------------------
scroll_text_message:
    .encoding "screencode_mixed"
//  .text "1234567890123456789012345678901234567890"
//  .text "1234567890123456789012345678901234567890123456789012345678901234"
    .text @"     This is a test of a LED-scroller. It's not really a smooth scroll"
    .text @" but rather a mimics the looks and operation of a 8*40 LED matrix panel that you can see"
    .text @" in the window of your favourite pizza place."
    .byte $00 // Scroll message text is null terminated


// ---------------------------------------------
// SID Music
// ---------------------------------------------
* = address_sid_music_init "music"
        // Player size$0DE0 (3552 bytes)
        // Load address$1000 (4096)
        // Init address$1000 (4096)
        // Play address$1003 (4099)
        // Default subtune1 / 1
    .import binary "sid/Great_Giana_Sisters.sid",$7C + 2


// ---------------------------------------------
// Text font
// ---------------------------------------------
// More fonts at http://kofler.dot.at/c64/
// Load font to last 2k block of bank 3
* = address_font "font"
    .import binary "fonts/Giana sisters demo font 03-charset.bin"
//    !bin "fonts/giana_sisters.font.64c",,2
//    !bin "fonts/devils_collection_25_y.64c",,2
//    !bin "fonts/double_char_font.bin"

