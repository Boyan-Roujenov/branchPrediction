.bss
historyArray:
.skip 2048

counterArray:
.skip 524288 #we will have 256 counters for each address for the 8 past outcomes 

.global predict_branch
.global actual_branch
.global init

.text

init:

	pushq	%rbp
	movq	%rsp, %rbp

	movq $524287, %rcx #we will use rcx as a counter to initialize 524288=2048 x 256 byte of 1s. 1 will represent weak not taken. 

	initTrue:
	movb $1, counterArray(%rcx) #backwards we initialize from the last byte to the fist byte
	decq %rcx
	jnz initTrue

	movb $1, counterArray # we dont forget the 0th byte

	movq	%rbp, %rsp
	popq	%rbp
	ret


predict_branch:
	pushq	%rbp
	movq	%rsp, %rbp

	movq $1, %rax

	#this is masking the address
	andq $2047, %rdi # take the remainder of the address modulo 2048. We do that by anding all bits undero 2048 with the number 2047 which is something like 0000011111111111, only for powers of 2
	movq %rdi, %rax #move the masked address in RAX to be able to multiply it with 256 to get the correct indez for the counter array

	movzbq historyArray(%rdi), %rdi #move the history bite of the current address in the last byte of %rdi and 0 extend it into 64 bits

	#we calculate the index of the counter for the prediction status for the situation we are in 
	movq $0, %rdx #prepare for multiplication
	movq $256, %rcx
	mulq %rcx #we get the index for the address we are looking at for the counter array 
	addq %rdi, %rax #get the complete index for the exact counter we need to check ai x 256 + hb 

	cmpb $2, counterArray(%rax) #check whether the frequency is lower than 2
	jl weakOrStrongSkip
	#weak or Strong Jump:
	movq $1, %rax #we predict that the branch will be taken
	jmp end

	weakOrStrongSkip: #branch will not be taken (skipped)
		movq $0, %rax #we predict the branch will not be taken

	end:
		movq	%rbp, %rsp
		popq	%rbp
		ret

actual_branch:
	pushq	%rbp
	movq	%rsp, %rbp
	
	andq $2047, %rdi #mask the address
	movq %rdi, %rax #move the masked address in RAX to be able to multiply it with 256 to get the correct indez for the counter array

	movzbq historyArray(%rdi), %r9 #move the history bite of the current address in the last byte of %rdi and 0 extend it into 64 bitd

	#we calculate the index of the counter for the prediction status for the situation we are in 
	movq $0, %rdx #prepare for multiplication
	movq $256, %rcx
	mulq %rcx #we get the index for the address we are looking at for the counter array 
	addq %r9, %rax #get the complete index for the exact counter we need to check ai x 256 + hb 


	cmp $0, %rsi #if the branch was not taken
	je notTaken 

	addb $1, counterArray(%rax) #increase our 2 bit counter for the prediction
	cmpb $4, counterArray(%rax) #if we are already at stong taken we stop counting
	jl ending

	subb $1, counterArray(%rax) #we go back to 3 and make sure not to wrap around
	jmp ending

	notTaken:
		subb $1, counterArray(%rax) #decrease our 2 bit counter for the prediction
		cmpb $-1, counterArray(%rax) #if we are already at stong taken we stop counting
		jg ending

		addb $1, counterArray(%rax) #we go back to 0 and make sure not to wrap around
		jmp ending


	ending:
		#we update the history of the address
		shlq $1, %r9 #discard the oldes history outcome of the 8 we look at by shifting one bit
		orq %rsi, %r9 #or the blank history with the result of the last branch
		movb %r9b, historyArray(%rdi) #store the updated hystory byte at the corresponding address in the history array

		movq	%rbp, %rsp
		popq	%rbp
		ret
