.global _start
.type	_start, %function  // Makes ld set bit 0 of the entrypoint to enter in Thumb mode

.thumb
_start:
loop:	b	loop
