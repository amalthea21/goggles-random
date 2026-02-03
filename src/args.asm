%include "constants.inc"

section .text
    global get_args     ; make function available to other files

get_args:
    ; initial stack layout is:
    ; [rsp]     = argc (number of arguments)
    ; [rsp+8]   = argv[0] (pointer to program name)
    ; [rsp+16]  = argv[1] (pointer to first argument)
    ; ...

    ; get original stack pointer from start
    mov rax, [saved_rsp]
    mov rdi, [rax]
    lea rsi, [rax + 8]

    ; return values:
    ; rdi = argc
    ; rsi = pointer to argv
    ret

section .data
    saved_rsq dq 0      ; storage for original stack pointer