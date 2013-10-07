.globl GetMailboxBase
GetMailboxBase:
	ldr r0,=0x2000B880
	mov pc,lr

.globl MailboxWrite
MailboxWrite:
	// Validate input.
	tst r0,#0b1111
	movne pc,lr
	cmp r1,#15
	movhi pc,lr

	channel .req r1	
	message .req r2
	mov message,r0

	push {lr}
	bl GetMailboxBase
	mailboxAddr .req r0

	// Combine the channel and the message into a single 4-byte value.
	add message,channel

	// Loop until top bit of status code is 0.
	loop0$:
		status .req r3
		ldr status,[mailboxAddr,#0x18]
		tst status,#0x80000000
		.unreq status
		bne loop0$

	str message,[mailboxAddr,#0x20]
	.unreq channel
	.unreq message
	.unreq mailboxAddr

	pop {pc}
	
/*	1. Load address of mailbox.
	2. Loop until 30th status bit is 0.
	3. Write message proper memory address.
	*/
.globl MailboxRead
MailboxRead:
	cmp r0,#15
	movhi pc,lr

	channel .req r1
	mov channel,r0

	push {lr}
	bl GetMailboxBase
	mailboxAddr .req r0

	// Loop until 30th bit of status code is 0.
	loop1$:
		status .req r2
		ldr status,[mailboxAddr,#0x18]
		tst status,#0x40000000
		.unreq status
		bne loop1$

	message .req r2
	ldr message,[mailboxAddr,#0] // Read address is offset 0 bytes.

	// Check to see if the message came on the right channel.
	inchannel .req r3
	and inchannel,message,#0xf
	teq channel,inchannel
	.unreq inchannel
	bne loop1$ // If it's the wrong channel, loop again.

	.unreq channel
	.unreq mailboxAddr
	
	and r0,message,#0xfffffff0
	
	.unreq message	

	pop {pc}
