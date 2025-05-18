.global _start
.type	_start, %function  // Makes ld set bit 0 of the entrypoint to enter in Thumb mode

.thumb
.syntax unified  // Somehow disables Error: instruction not supported in Thumb16 mode -- `subs r1,#3'
_start:

        movs r0, #0
repeat:
        adds r0, #1
        cmp  r0, #0
        beq  break
        b    repeat
break:
        movs r7, #1
        svc  #0
