.section .init
.globl _start
_start:

b main

	
.section .text
main:
mov sp,#0x8000
		
.section .data
	.align 2
pattern:
.int 0b00000000000000000000011100010101
