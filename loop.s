.global _start
.type	_start, %function  // Makes ld set bit 0 of the entrypoint to enter in Thumb mode

.thumb
.syntax unified  // Somehow disables Error: instruction not supported in Thumb16 mode -- `subs r1,#3'
_start:

        mov  r1, pc
        subs r1, #3
        push {r1}
        pop  {pc}

loop:   b   loop
