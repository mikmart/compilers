#!/bin/bash

# Prints a 32-bit System V ARM Thumb ELF executable to standard output.
# The executable just loops forever.

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
printf "\xfe\xe7"  # loop: b loop
