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

ptrn .req r8
ldr ptrn,=pattern // Set ptrn equal to pattern, which is a memory address.
ldr ptrn,[ptrn] // Load ptrn w/ the value at the address currently in ptrn.
seq .req r7
mov seq,#0

pinNum .req r0
pinVal .req r1
delay .req r2

loop$:
	// Set the PIN value according to the sequence.
	mov pinVal,#0
	mov r2,#1
	lsl r2,seq
	and r2,ptrn
	cmp r2,#0
	moveq pinVal,#1
	
	mov pinNum,#16
	bl SetGpio

	ldr delay,=500000
	bl Timer

	add seq,#1
	cmp seq,#32
	blt loop$

// Turn LED off at the end.
mov pinVal,#1
mov pinNum,#16
bl SetGpio

.unreq pinNum
.unreq pinVal
.unreq delay

.section .data
	.align 2
pattern:
//	.int 0b11111111101010100010001000101010
.int 0b00000000000000000000011100010101
