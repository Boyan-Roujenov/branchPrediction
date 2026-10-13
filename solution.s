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

	movq	%rbp, %rsp
	popq	%rbp
	ret

actual_branch:
	pushq	%rbp
	movq	%rsp, %rbp

	cmp $0, %rsi
	je notTaken

	
	notTaken:



	movq	%rbp, %rsp
	popq	%rbp
	ret
