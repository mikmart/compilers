# Bootstrapping a compiler

* `1c.sh` is a script that outputs a 1lang compiler in machine code.
* `1c.1.sh` is a script that outputs 1lang code for a 1lang compiler.

## Motivation

* Inspiration: https://www.youtube.com/watch?v=nQkW6sOvOz4

## Resources

* https://oicr.on.ca/wp-content/uploads/2018/06/comilers.pdf
* https://shell-storm.org/online/Online-Assembler-and-Disassembler
* https://web.eecs.umich.edu/~prabal/teaching/eecs373-f10/readings/ARM_QRC0006_UAL16.pdf
* https://www.chromium.org/chromium-os/developer-library/reference/linux-constants/syscalls/#arm-32-biteabi
* http://bear.ces.cwru.edu/eecs_382/ARM7-TDMI-manual-pt3.pdf
* https://developer.arm.com/documentation/dui0041/c/Thumb-Procedure-Call-Standard/TPCS-definition/TPCS-register-names?lang=en

## Steps

* Working on AArch64 Raspberry Pi OS.
* AArch64 is way too complex to hand assemble so do Thumb instead.
* Set up compiler toolchain: arm-linux-gnu-gcc
* Research how gcc does it: `loop.s`
* Hand-craft simplified ELF: who needs sections? `loop.sh`
* Next stop: output an ELF header and exit gracefully: `elfh.sh`
* Then we want to be able to process input: `echo.sh`
* With echo we also had to investigate loops.
* Quit on end of file or "control character" Q, conditionals: `quit.sh`
* Extend interpretation and conditional branching: `quo.sh`
* Add macro definitions and expansions: `def.sh`
* By adding the ELF header output we get a compiler: `1c.sh`
  ```
  $ printf '\1h\5Hello\1w\5Worldh\2 w\2!\2\n\0' | ./1c | xxd
    00000000: 7f45 4c46 0101 0100 0000 0000 0000 0000  .ELF............
    00000010: 0200 2800 0100 0000 5500 0400 3400 0000  ..(.....U...4...
    00000020: 0000 0000 0000 0005 3400 2000 0100 0000  ........4. .....
    00000030: 0000 0000 0100 0000 5400 0000 5400 0400  ........T...T...
    00000040: 0000 0000 000f 0000 0000 0200 0700 0000  ................
    00000050: 0010 0000 4865 6c6c 6f20 576f 726c 6421  ....Hello World!
    00000060: 0a 
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
