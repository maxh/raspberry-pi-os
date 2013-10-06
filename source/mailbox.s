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
	mov r3,r0
	message .req r3
	mov r4,r1
	channel .req r4

	bl GetMailboxBase
	mailboxAddr .req r0

	// Set the lowest 4 bits of the message to 0.
	lsr message,message,#4
	lsl message,message,#4 // (bitwise AND would be faster here.)

	// Set all but the lowest 4 bits of the channel to 0.
	and channel,channel,#15

	// Combine the channel and the message into a single 4-byte integer.
	and message,channel,message

	// Loop until top bit of status code is 0.
	loop0:
		ldr r1,[mailboxAddr,#12] // Status address is offset 12 bytes.
		cmp #0,r1,LSR #31
		bne loop0$

	str message,[mailboxAddr,#20] // Write address is offset 20 bytes.

	.unreq channel
	.unreq message
	.unreq mailboxAddr

	mov pc,lr
	
/*	1. Load address of mailbox.
	2. Loop until 30th status bit is 0.
	3. Write message proper memory address.
	*/
.globl MailboxRead
MailboxRead:
	mov r4,r0
	channel .req r4

	bl GetMailboxBase
	mov r0,r1
	mailboxAddr .req r1

	status .req r3
	message .req r0
	
	// Loop until 30th bit of status code is 0.
	loop1:
		// Status address is offset 12 bytes.
		ldr status,[mailboxAddr,#12]
		lsr status,status,#29
		and status,status,#1
		cmp #0,status
		bne loop1$

	ldr message,[mailboxAddr] // Read address is offset 0 bytes.

	// Check to see if the message came on the right channel.
	mov r2,message
	and r2,#7
	cmp channel,r2
	bne loop1 // If it's the wrong channel, loop again.

	lsr message,#4 // Clear the channel information.

	.unreq channel
	.unreq message
	.unreq mailboxAddr

	mov pc,lr
	

	