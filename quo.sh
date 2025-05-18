#!/bin/bash

# Prints a 32-bit System V ARM Thumb ELF executable to standard output.
# Reads input and interprets quoting and quit commands.

# ELF header
printf "\x7f\x45\x4c\x46" # 0x7f "ELF" magic number
printf "\x01\x01\x01\x00" # 32-bit little endian, v1, System V ABI (UNIX)
printf "\x00\x00\x00\x00" # ABI v0 + 3 padding
printf "\x00\x00\x00\x00" # Unused padding

printf "\x02\x00\x28\x00" # Executable, ARM (Armv7/AArch32)
printf "\x01\x00\x00\x00" # ELF version 1
printf "\x55\x00\x04\x00" # Entry point address in virtual memory, bit 0 set for Thumb mode
printf "\x34\x00\x00\x00" # Program header table (PHT) offset in file

printf "\x00\x00\x00\x00" # Section header table (SHT) offset in file (0 = not present)
printf "\x00\x00\x00\x05" # Flags: Version5 EABI, needed for Thumb mode
printf "\x34\x00\x20\x00" # ELF header size, size of a program header
printf "\x01\x00\x00\x00" # Program header count, size of a section header

printf "\x00\x00\x00\x00" # Section header count, SHT section names index

# Program header
printf "\x01\x00\x00\x00" # Loadable segment
printf "\x54\x00\x00\x00" # Segment offset in file
printf "\x54\x00\x04\x00" # Virtual address of the segment in memory
printf "\x00\x00\x00\x00" # Physical address of the segment (unused)

printf "\x00\x0f\x00\x00" # Segment size in file
printf "\x00\x00\x01\x00" # Segment size in memory
printf "\x07\x00\x00\x00" # Segment flags: rwx
printf "\x00\x10\x00\x00" # Alignment -- doesn't really matter for us

# Entry point
printf "\x79\x46" # mov  r1, pc // Organise a loop. PC relative would be better,
printf "\x03\x39" # subs r1, #3 // but I won't track the offsets manually fuck that.
printf "\x02\xb4" # push {r1}   // (Also bit 0 weirdness here so -3 instead of -4)

printf "\x01\xb4" # push {r0}   // Make space on the stack for the read
printf "\x03\x27" # movs r7, #3 // SYS_read
printf "\x01\x22" # movs r2, #1 // One byte
printf "\x69\x46" # mov  r1, sp // Onto the stack
printf "\x00\x20" # movs r0, #0 // From stdin
printf "\x00\xdf" # svc  #0
printf "\x01\xbc" # pop  {r0}   // Pop the stack onto return register 0

printf "\x00\x28" # cmp  r0, #0 // Quit
printf "\x02\xd1" # bne  #6

printf "\x00\x20" # mov  r0, #0
printf "\x01\x27" # mov  r7, #1 // SYS_exit
printf "\x00\xdf" # svc  #0

printf "\x02\x28" # cmp  r0, #2 // Quote
printf "\x0f\xd1" # bne  #xx    // Jump over 16 instructions

printf "\x01\xb4" # push {r0}   // Make space on the stack for the read
printf "\x03\x27" # movs r7, #3 // SYS_read
printf "\x01\x22" # movs r2, #1 // One byte
printf "\x69\x46" # mov  r1, sp // Onto the stack
printf "\x00\x20" # movs r0, #0 // From stdin
printf "\x00\xdf" # svc  #0
printf "\x01\xbc" # pop  {r0}   // Pop the stack onto return register 0
printf "\x00\xbf" # nop         // Padding

printf "\x01\xb4" # push {r0}   // Put the byte on the stack for write
printf "\x04\x27" # movs r7, #4 // SYS_write
printf "\x01\x22" # movs r2, #1 // One byte
printf "\x69\x46" # mov  r1, sp // From the stack
printf "\x01\x20" # movs r0, #1 // Into stdout
printf "\x00\xdf" # svc  #0
printf "\x01\xbc" # pop  {r0}   // Free the stack space
printf "\x00\xbf" # nop         // Padding

printf "\x00\xbd" # pop  {pc}   // Retrun to the top of the loop
printf "\x00\xbd" # pop  {pc}   // Retrun to the top of the loop

printf "\x01\x27" # mov  r7, #1 // SYS_exit
printf "\x00\xdf" # svc  #0
