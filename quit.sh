#!/bin/bash

# Prints a 32-bit System V ARM Thumb ELF executable to standard output.
# The executable prints its own ELF header into standard output.

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
printf "\x04\x39" # subs r1, #4 // but I won't track the offsets manually fuck that.
printf "\x02\xb4" # push {r1}
printf "\x02\xb4" # push {r1}   // Make space on the stack
printf "\x03\x27" # movs r7, #3 // SYS_read
printf "\x01\x22" # movs r2, #1 // One byte
printf "\x69\x46" # mov  r1, sp // Onto the stack
printf "\x00\x20" # movs r0, #0 // From stdin
printf "\x00\xdf" # svc  #0
printf "\x00\x28" # cmp  r0, #0 // Quit if read 0 = assume end of file
printf "\x02\xd1" # bne  #6
printf "\x00\x20" # mov  r0, #0
printf "\x01\x27" # mov  r7, #1 // SYS_exit
printf "\x00\xdf" # svc  #0
printf "\x69\x46" # mov  r1, sp
printf "\x21\x78" # ldrb r0, [r1] // lrdb from sp is a 32-bit opcode
printf "\x51\x28" # cmp  r0, #'Q' // Quit if read 'Q' = explicit end
printf "\x02\xd1" # bne  #6
printf "\x00\x20" # mov  r0, #0
printf "\x01\x27" # mov  r7, #1 // SYS_exit
printf "\x00\xdf" # svc  #0
printf "\x04\x27" # movs r7, #4 // SYS_write
printf "\x01\x22" # movs r2, #1 // One byte
printf "\x69\x46" # mov  r1, sp // From the stack
printf "\x01\x20" # movs r0, #1 // Into stdout
printf "\x00\xdf" # svc  #0
printf "\x02\xbc" # pop  {r1}   // Free the stack space
printf "\x02\xbc" # pop  {r1}
printf "\x8f\x46" # mov  pc, r1 // Return to loop
printf "\x01\x27" # mov  r7, #1 // SYS_exit
printf "\x00\xdf" # svc  #0
