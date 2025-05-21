#!/bin/bash

# Prints 1lang source code for a 2lang compiler to stdout.

# -- Byte code definitions

printf "\1{\x06"  # (3) { := Push a loop
printf "\x79\x46" # mov  r1, pc
printf "\x03\x39" # subs r1, #3 // 4 would exit Thumb mode, dunno why.
printf "\x02\xb4" # push {r1}

printf "\1}\x02"  # (1) } := Jump to the beginning of a loop (continue)
printf "\x00\xbd" # pop  {pc}

printf "\1^\x02"  # (1) ^ := Discard current loop return address (break)
printf "\x02\xbc" # pop  {r1}

printf "\1=\x01"  # (1) = := [n=] Compare r0 to preceding
printf "\x28"     # cmp  r0, #n

printf "\1?\x03"  # (2) ? := [n?] Skip n ops unless equal
printf "\xd1"     # bne  #2(n + 2)
printf "\x00\xbf" # nop  // Pad

printf "\1L\x03"  # (2) L := [nL] Skip n ops unless less than
printf "\xda"     # bge  #2(n + 2)
printf "\x00\xbf" # nop  // Pad

printf '\1!\x03'  # (2) ! := [n!] Skip n ops
printf "\xe0"     # b    #2(n + 2)
printf "\x00\xbf" # nop  // Pad

printf "\1-\x01"  # (1) = := [n-] Subtract n from r0
printf "\x38"     # subs r0, #n

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

printf "\1Q\x05"  # (3) Q := [nQ] Exit with status code n
printf "\x20"     # mov  r0, #n 
printf "\x01\x27" # mov  r7, #1 // SYS_exit
printf "\x00\xdf" # svc  #0

# -- Program output starts

printf "H"

printf "\2\x80\2\xa6" # adr  r6, #0x200 // Keep address of byte code table in r6

printf "{" # (3)
printf "<" # (8)

printf "\2\x00=\2\x03?" # Skip Quit (3) unless input is \0
printf "\2\x00Q" # (3)

printf "\2\x3b=\2\x10?" # ; => Comment until end of line
printf "{"              # (3)
printf "<"              # (8)
printf "\2\x0a=\2\x01?" # (3)
printf "^"              # (1)
printf "}"              # (1)

printf "\2\x27=\2\x10?" # ' => ['n] Quote next byte
printf "<>" # (8 + 7)
printf "}"  # (1)

printf "\2\x78=\2\x28?" # x => [xdd] Hex literal
printf "<"              # (8)
printf "\2\x61=\2\x02L" # (3)
printf "  \2\x30-"      # (1)
printf "\2\x01!"        # (2)
printf "  \2\x57-"      # (1)
printf "\2\x04\2\x01"   # lsls r4, r0, #4
printf "<"              # (8)
printf "\2\x61=\2\x02L" # (3)
printf "  \2\x30-"      # (1)
printf "\2\x01!"        # (2)
printf "  \2\x57-"      # (1)
printf "\2\x20\2\x44"   # add r0, r4
printf ">"              # (7)
printf "}"              # (1)

printf "\2\x01=\2\x1a?" # Skip Define (26) unless input is \1
printf "<" # (8)
printf "\2\x04\2\x00" # movs  r4, r0

printf "<" # (8)
printf "\2\x02\2\x00" # movs  r2, r0

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

printf "\2\x01Q" # (3)
