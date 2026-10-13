.bss
frequencyArray:
.skip 2048

.global predict_branch
.global actual_branch
.global init

init:
	pushq	%rbp
	movq	%rsp, %rbp

	pushq	%rbp
	movq	%rsp, %rbp

	movq $2047, %rcx #we will use rcx as a counter to initialize 2048 byte of 1s. 1 will represent weak not taken. 

	initTrue:
	movb $1, frequencyArray(%rcx) #backwards we initialize from the last byte to the fist byte
	decq %rcx
	jnz initTrue

	movb $1, frequencyArray # we dont forget the 0th byte

	movq	%rbp, %rsp
	popq	%rbp
	ret

	movq	%rbp, %rsp
	popq	%rbp
	ret

predict_branch:
	pushq	%rbp
	movq	%rsp, %rbp

	movq $1, %rax

	andq $2047, %rdi # take the remainder of the address modulo 2048. We do that by anding all bits undero 2048 with the number 2047 which is something like 0000011111111111, only for powers of 2
	cmpq $2, frequencyArray(%rdi) #check whether the frequency is lower than 2
	jl weakOrStrongSkip
	#weak or Strong Jump:
	movq $1, %rax #we predict that the branch will be taken
	jmp end

	weakOrStrongSkip:
		movq $0, %rax #we predict the branch will not be taken


	end:
		movq	%rbp, %rsp
		popq	%rbp
		ret

actual_branch:
	pushq	%rbp
	movq	%rsp, %rbp

	cmp $0, %rsi #if the branch was not taken
	je notTaken 

	movq $0, %rdx #prepare for mod
	movq %rdi, %rax #put the address in rax to be moduloed by the size of our array
	divq $2048

	addb $1, (%rdx) #increase our 2 bit counter for the prediction

	notTaken:
		movq $0, %rdx #prepare for mod
		movq %rdi, %rax #put the address in rax to be moduloed by the size of our array
		divq $2048

		subb $1, (%rdx) #decrease our 2 bit counter for the prediction



	movq	%rbp, %rsp
	popq	%rbp
	ret
