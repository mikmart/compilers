# Bootstrapping compilers

This is an exploration of bootstrapping compilers from machine code.

* `1c.sh` is a script that outputs a "1lang" compiler in machine code.
* `1c.1.sh` is a script that outputs 1lang code for a 1lang compiler.

## Motivation

OICR Software Engineering Club talk by Kevin Hartman:

* Talk: https://www.youtube.com/watch?v=nQkW6sOvOz4
* Slides: https://oicr.on.ca/wp-content/uploads/2018/06/comilers.pdf

## Resources

* https://shell-storm.org/online/Online-Assembler-and-Disassembler
* https://web.eecs.umich.edu/~prabal/teaching/eecs373-f10/readings/ARM_QRC0006_UAL16.pdf
* https://www.chromium.org/chromium-os/developer-library/reference/linux-constants/syscalls/#arm-32-biteabi
* http://bear.ces.cwru.edu/eecs_382/ARM7-TDMI-manual-pt3.pdf
* https://developer.arm.com/documentation/dui0041/c/Thumb-Procedure-Call-Standard

## Steps

* Working on AArch64 Raspberry Pi OS.
* AArch64 is way too complex to hand assemble so do Thumb instead.
* Set up compiler toolchain: `arm-linux-gnu-gcc`
* Research how gcc does it: `loop.s`
* Hand-craft simplified ELF: who needs sections? `loop.sh`
* Next stop: output an ELF header and exit gracefully: `elfh.sh`
* Then we want to be able to process input: `echo.sh`
* Quit on end of file or "control character" Q, conditionals: `quit.sh`
* Extend interpretation and conditional branching: `quo.sh`
* Add macro definitions and expansions: `def.sh`
* By adding the ELF header output we get a compiler: `1c.sh`
  ``` console
  $ bash 1c.sh | xxd
  00000000: 7f45 4c46 0101 0100 0000 0000 0000 0000  .ELF............
  00000010: 0200 2800 0100 0000 5500 0400 3400 0000  ..(.....U...4...
  00000020: 0000 0000 0000 0005 3400 2000 0100 0000  ........4. .....
  00000030: 0000 0000 0100 0000 5400 0000 5400 0400  ........T...T...
  00000040: 0000 0000 000f 0000 0000 0200 0700 0000  ................
  00000050: 0010 0000 7946 5839 5422 0120 0427 00df  ....yFX9T". .'..
  00000060: 80a6 7946 0339 02b4 01b4 0327 0122 6946  ..yF.9.....'."iF
  00000070: 0020 00df 01bc c0b2 0028 02d1 0020 0127  . .......(... .'
  00000080: 00df 0228 0fd1 01b4 0327 0122 6946 0020  ...(.....'."iF.
  00000090: 00df 01bc c0b2 01b4 0427 0122 6946 0120  .........'."iF.
  000000a0: 00df 01bc 00bd 0128 17d1 01b4 0327 0122  .......(.....'."
  000000b0: 6946 0020 00df 01bc c4b2 01b4 0327 0122  iF. .........'."
  000000c0: 6946 0020 00df 01bc c2b2 2102 8919 0a70  iF. ......!....p
  000000d0: 0327 0131 0020 00df 00bd 0102 8919 0a78  .'.1. .........x
  000000e0: 0427 0131 0120 00df 00bd 0120 0127 00df  .'.1. ..... .'..
  ```
  ``` console
  $ printf '\1h\5Hello\1w\5Worldh\2 w\2!\0' | ./1c | xxd
  00000000: 7f45 4c46 0101 0100 0000 0000 0000 0000  .ELF............
  00000010: 0200 2800 0100 0000 5500 0400 3400 0000  ..(.....U...4...
  00000020: 0000 0000 0000 0005 3400 2000 0100 0000  ........4. .....
  00000030: 0000 0000 0100 0000 5400 0000 5400 0400  ........T...T...
  00000040: 0000 0000 000f 0000 0000 0200 0700 0000  ................
  00000050: 0010 0000 4865 6c6c 6f20 576f 726c 6421  ....Hello World!
  ```
* Next step: re-write the compiler in our new language: `1c.1.sh`
* Next goal: language without non-printable characters: `2c.1.sh`

## Notes

### Branching

The `bne` instruction does a conditional branch after a compare. In assembly,
it takes a label which the assembler transforms into a PC relative jump. But,
we don't have an assembler to do that for us. In the machine code the instruction
looks like `\xNN\xd1` where the leading byte is the count of 16-bit instructions
to skip ahead, with 0 indicating "jump over one", etc.:

```
If comparison not equal:
    NNd1 => Jump ahead 0xNN + 1 instructions.
    ffd1 => Go to next instruction (nop).
```

### Moving

Unshifted move of low registers: `0x 0000 0000 00[sr c][dst]`

### Stack operations

Pop low registers: `NNb4` where has flags for registers: `...[r2][r1][r0]`.
Push is the same but `NNbc`.
