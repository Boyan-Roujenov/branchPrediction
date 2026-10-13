.global predict_branch
.global actual_branch
.global init

init:
	pushq	%rbp
	movq	%rsp, %rbp

	pushq	%rbp
	movq	%rsp, %rbp

	movq $2047, %rcx

	initTrue:
	movb $1, frequencyArray(%rcx)
	decq %rcx
	jnz initTrue

	movb $1, frequencyArray

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
