#!/bin/bash

# Prints 1lang source code for a 1lang compiler to stdout.

# -- Byte code definitions

printf "\1{\x06"  # (3) { := Push a loop
printf "\x79\x46" # mov  r1, pc // Organise a loop. PC relative would be better,
printf "\x03\x39" # subs r1, #3 // but I won't track the offsets manually fuck that.
printf "\x02\xb4" # push {r1}   // (-3 to stay in Thumb, dunno why it's not preserved)

printf "\1}\x02"  # (1) } := Jump to the Beginning of a Loop (Continue)
printf "\x00\xbd" # pop  {pc}   // Return to the top of the loop

printf "\1<\x10"  # (8) < := Read a byte from stdin
printf "\x01\xb4" # push {r0}   // Make space on the stack
printf "\x03\x27" # movs r7, #3 // SYS_read
printf "\x01\x22" # movs r2, #1 // One byte
printf "\x69\x46" # mov  r1, sp // Onto the stack
printf "\x00\x20" # movs r0, #0 // From stdin
printf "\x00\xdf" # svc  #0
printf "\x01\xbc" # pop  {r0}   // Pop the read byte
printf "\xc0\xb2" # uxtb r0, r0 // Zero-extend low byte

printf "\1>\x0e"  # (7) > := Write a byte to stdout
printf "\x01\xb4" # push {r0}   // Put the byte on the stack for write
printf "\x04\x27" # movs r7, #4 // SYS_write
printf "\x01\x22" # movs r2, #1 // One byte
printf "\x69\x46" # mov  r1, sp // From the stack
printf "\x01\x20" # movs r0, #1 // Into stdout
printf "\x00\xdf" # svc  #0
printf "\x01\xbc" # pop  {r0}   // Free the stack space

printf "\1H\x0c"  # (6) H := Print ELF header (must be the first operation)
printf "\x79\x46" # mov  r1, pc    // Points 2 instructions ahead.
printf "\x58\x39" # subs r1, #0x58 // Beginning of file.
printf "\x54\x22" # movs r2, #0x54 // ELF header size.
printf "\x01\x20" # movs r0, #0x01 // stdout
printf "\x04\x27" # movs r7, #0x04 // SYS_write
printf "\x00\xdf" # svc  #0

printf "\1Q\x04"  # (2) Q := Exit
printf "\x01\x27" # mov  r7, #1 // SYS_exit
printf "\x00\xdf" # svc  #0

printf "\1=\x01"  # (1) = := Compare r0 to preceding [n=]
printf "\x28"     # cmp  r0, #n

printf "\1?\x03"  # (2) ? := Skip n ops unless equal [n?]
printf "\xd1"     # bne  #2(n + 2)
printf "\x00\xbf" # nop  // Pad

# -- Program output starts

printf "H"

printf "\2\x80\2\xa6" # adr  r6, #0x200 // Keep address of byte code table in r6

printf "{"
printf "<"

printf "\2\x00=\2\x02?" # Skip Quit (2) unless input is \0
printf "Q" # (2)

printf "\2\x02=\2\x10?" # Skip Quote (16) unless input is \2
printf "<" # (8)
printf ">" # (7)
printf "}" # (1)

printf "\2\x01=\2\x1a?" # Skip Define (26) unless input is \1
printf "<" # (8)
printf "\2\x04\2\x46" # mov  r4, r0

printf "<" # (8)
printf "\2\x02\2\x46" # mov  r2, r0

printf "\x011\x0e"
printf "\x21\x02" # lsls r1, r4, #8 // Offset of byte in byte code table
printf "\x89\x19" # adds r1, r1, r6
printf "\x0a\x70" # strb r2, [r1]   // Save len into first field
printf "\x03\x27" # movs r7, #3     // SYS_read
printf "\x01\x31" # adds r1, #1     // Into second field
printf "\x00\x20" # movs r0, #0     // From stdin
printf "\x00\xdf" # svc  #0
printf "1" # (7)
printf "}" # (1)

printf "\x013\x0e"
printf "\x01\x02" # lsls r1, r0, #8 // Offset of byte in byte code table
printf "\x89\x19" # adds r1, r1, r6
printf "\x0a\x78" # ldrb r2, [r1]   // Load len from first field
printf "\x04\x27" # movs r7, #3     // SYS_write
printf "\x01\x31" # adds r1, #1     // From second field
printf "\x01\x20" # movs r0, #1     // Into stdout
printf "\x00\xdf" # svc  #0
printf "3" # (7)
printf "}" # (1)

printf "\2\x01\2\x20" # mov  r0, #1 // Something went wrong if we reached this
printf "Q" # (2)
