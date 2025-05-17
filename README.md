# Bootstrapping a compiler

* Inspiration: https://www.youtube.com/watch?v=nQkW6sOvOz4
* Working on AArch64 Raspberry Pi OS.
* AArch64 is way too complex to hand assemble so do Thumb instead.
* Set up compiler toolchain: arm-linux-gnu-gcc
* Research how gcc does it: `loop.s`
* Hand-craft simplified ELF: who needs sections? `loop.sh`
* Next stop: output an ELF header and exit gracefully: `elfh.sh`
* Then we want to be able to process input: `echo.sh`
* With echo we also had to investigate loops.
* We will also need to do conditionals and comparisons: `comp.sh`
