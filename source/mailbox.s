.globl GetMailboxBase
GetMailboxBase:
	ldr r0,=0x2000B880
	mov pc,lr
	
 /*	1. Load address of mailbox.
	2. Prepare message.
	3. Loop until highest status bit is 0.
	4. Write message proper memory address.
	*/
.globl MailboxSend
MailboxSend:
	// Validate input.
	tst r0,#7
	movne pc,lr
	cmp r1,#15
	movhi pc,lr

	channel .req r1	
	message .req r2
	mov message,r0

	push {lr}
	bl GetMailboxBase
	mailboxAddr .req r0

	// Combine the channel and the message into a single 4-byte integer.
	add message,channel

	// Loop until top bit of status code is 0.
	loop0:
		status .req r3
		ldr status,[mailboxAddr,#12] // Status addr is offset 12 bytes.
		cmp #0,r3,LSR #31
		.unreq status
		bne loop0$

	str message,[mailboxAddr,#20] // Write address is offset 20 bytes.

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

	channel .req r4
	mov channel,r0

	push {lr}
	bl GetMailboxBase
	mailboxAddr .req r1
	mov r1,r0

	message .req r0
	
	// Loop until 30th bit of status code is 0.
	loop1:
		status .req r3
		// Status address is offset 12 bytes.
		ldr status,[mailboxAddr,#12]
		lsr status,status,#29
		and status,status,#1
		cmp #0,status
		.unreq status
		bne loop1$

	ldr message,[mailboxAddr] // Read address is offset 0 bytes.

	// Check to see if the message came on the right channel.
	inchannel .req r2
	mov inchannel,message
	and inchannel,#7
	cmp channel,inchannel
	.unreq inchannel
	bne loop1 // If it's the wrong channel, loop again.

	.unreq channel
	.unreq mailboxAddr
	
	and r0,message,#0xfffffff0
	.unreq message

	pop {pc}
	