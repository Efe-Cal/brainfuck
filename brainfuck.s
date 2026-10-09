.data
.align 8
jump_table:
	.quad eof

	.rept 42 
		.quad ignore_char 
	.endr
	
	.quad handle_inc_cell		# +
    .quad handle_print         	# ,
    .quad handle_dec_cell      	# -
    .quad handle_read          	# .

    .rept 13                   
    	.quad ignore_char
    .endr
    
	.quad handle_dec_ptr       	# <
    .quad ignore_char          	# =
    .quad handle_inc_ptr       	# >

	.rept 28                 
    	.quad ignore_char
    .endr

	.quad enter_loop			# [
	.quad ignore_char
	.quad exit_loop				# ]

	.rept 162 
		.quad ignore_char 
	.endr

	

.bss
mem_arr: .skip 2048

.text

.global brainfuck


# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.
brainfuck:
	pushq 	%rbp
	movq 	%rsp, %rbp

	movq	$mem_arr, %r13
	movq 	%rdi, %rbx

	mov 	$0, %r12
	read_char_and_dispatch:
		movzbq	(%rbx, %r12, 1), %rax
		inc		%r12

		jmp 	*jump_table(, %rax, 8)

	eof:
	movq 	$0, %rax
	movq 	%rbp, %rsp
	popq 	%rbp
	ret

ignore_char:
	jmp 	read_char_and_dispatch

handle_inc_cell:
	incb 	(%r13)
	jmp 	read_char_and_dispatch

handle_dec_cell:
	decb 	(%r13)
	jmp 	read_char_and_dispatch

handle_print:
	mov 	$1, %rdi
	mov 	%r13, %rsi
	mov 	$1, %rdx
	mov		$1, %rax
	syscall

	jmp 	read_char_and_dispatch

handle_read:
	mov 	$0, %rdi
	mov 	%r13, %rsi
	mov 	$1, %rdx
	mov		$0, %rax
	syscall

	jmp 	read_char_and_dispatch
	
handle_inc_ptr:
	incq 	%r13
	jmp 	read_char_and_dispatch

handle_dec_ptr:
	decq 	%r13
	jmp 	read_char_and_dispatch

enter_loop:
	cmpb 	$0, (%r13)
	je 		begin_search

	push 	%r12
	jmp 	read_char_and_dispatch

	begin_search:
	movq  	$1, %rcx		# rcx: depth counter
	search_forward:
		movzbq	(%rbx, %r12, 1), %rax
		incq 	%r12

		cmp		$'[' , %rax
		je 		found_open_fwd

		cmp		$']' , %rax
		je 		found_close_fwd

		jmp 	search_forward

	found_open_fwd:
		incq 	%rcx
		jmp 	search_forward

	found_close_fwd:
		decq 	%rcx

		testq 	%rcx, %rcx
		je 		read_char_and_dispatch

		jmp 	search_forward

exit_loop:
	cmpb 	$0, (%r13)
	jne 	jump_to_enter

	addq 	$8, %rsp
	jmp 	read_char_and_dispatch

	jump_to_enter:
		movq 	(%rsp), %r12
		jmp 	read_char_and_dispatch

	
		