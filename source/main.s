.section .init
.globl _start
_start:

b main

.section .text
main:
mov sp,#0x8000
		
// Enable output to the 'act' light.
pinNum .req r0
pinFunc .req r1
mov pinNum,#16
mov pinFunc,#1
bl SetGpioFunction
.unreq pinNum
.unreq pinFunc

pinNum .req r0
pinVal .req r1
delay .req r2
	
loop$:
	// Turn the LED on.
	mov pinNum,#16
	mov pinVal,#0
	bl SetGpio
	mov delay,#0x3F0000
	bl Timer

	// Turn the LED off.
	mov pinNum,#16
	mov pinVal,#1
	bl SetGpio
	mov delay,#0x3F0000
	bl Timer

b loop$

